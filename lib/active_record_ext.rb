# patch ActiveRecord
module ActiveRecord
  module SanitizeAndMerge

    #--- class methods
    module ClassMethods

      # sanitizes SQL and safely merges multiple conditions
      #
      # e.g.
      #
      #   User.sanitize_and_merge_conditions "id = 1", [':state = ?', state]
      #   ->  "id = 1 AND state = 'new'"
      #
      def sanitize_and_merge_conditions(*conditions)
        conditions = conditions.reject(&:blank?).map {|condition| sanitize_sql_for_assignment(condition)}.reject(&:blank?)
        conditions.empty? ? nil : conditions.join(" AND ")
      end

      # merges order (ORDER BY) statements
      def sanitize_and_merge_order(*orders)
        orders = orders.reject(&:blank?).map do |order|
          order.strip!
          order = order.last == ',' ? order.chop : order
        end
        orders = orders.reject(&:blank?)
        orders.empty? ? nil : orders.join(", ")
      end

    end

    module InstanceMethods

      # same as class method 
      def sanitize_and_merge_conditions(*conditions)
        self.class.sanitize_and_merge_conditions(*conditions)
      end

      # same as class method method
      def sanitize_and_merge_order(*orders)
        self.class.sanitize_and_merge_order(*orders)
      end
      
    end
  end
  
  module Validations
    module ClassMethods
      
      # fixing the nil message problem
      def validates_associated(*attr_names)
        configuration = {:on => :save}
        configuration.update(attr_names.extract_options!)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          unless (value.is_a?(Array) ? value : [value]).collect { |r| r.nil? || r.valid? }.all?
            record.errors.add(attr_name, :invalid, :default => configuration[:message], :value => value) if configuration[:message]
          end
        end
      end
      
      # fixing the nil message problem
      def validates_presence_of(*attr_names)
        configuration = { :on => :save }
        configuration.update(attr_names.extract_options!)

        # can't use validates_each here, because it cannot cope with nonexistent attributes,
        # while errors.add_on_empty can
        send(validation_method(configuration[:on]), configuration) do |record|
          record.errors.add_on_blank(attr_names, configuration[:message]) unless configuration[:message].is_a?(String) && configuration[:message].empty?
        end
      end
      
    end
  end
end

class ActiveRecord::Base
  extend ActiveRecord::SanitizeAndMerge::ClassMethods
  include ActiveRecord::SanitizeAndMerge::InstanceMethods
end

# following patch is not going into CoreExtension models, because the patch would 
# not be applied
ActiveRecord::Base.class_eval do 
  class << self
    protected
    
    # overrides active_record/base in 2.3.4, 
    # order merge now supported
    def with_scope(method_scoping = {}, action = :merge, &block)
      method_scoping = method_scoping.method_scoping if method_scoping.respond_to?(:method_scoping)

      # Dup first and second level of hash (method and params).
      method_scoping = method_scoping.inject({}) do |hash, (method, params)|
        hash[method] = (params == true) ? params : params.dup
        hash
      end

      method_scoping.assert_valid_keys([ :find, :create ])

      if f = method_scoping[:find]
        f.assert_valid_keys(VALID_FIND_OPTIONS)
        set_readonly_option! f
      end

      # Merge scopings
      if [:merge, :reverse_merge].include?(action) && current_scoped_methods
        method_scoping = current_scoped_methods.inject(method_scoping) do |hash, (method, params)|
          case hash[method]
            when Hash
              if method == :find
                (hash[method].keys + params.keys).uniq.each do |key|
                  merge = hash[method][key] && params[key] # merge if both scopes have the same key
                  if key == :conditions && merge
                    if params[key].is_a?(Hash) && hash[method][key].is_a?(Hash)
                      hash[method][key] = merge_conditions(hash[method][key].deep_merge(params[key]))
                    else
                      hash[method][key] = merge_conditions(params[key], hash[method][key])
                    end
                  elsif key == :include && merge
                    hash[method][key] = merge_includes(hash[method][key], params[key]).uniq
                  elsif key == :joins && merge
                    hash[method][key] = merge_joins(params[key], hash[method][key])
                  # begin patch  
                  elsif key == :order && merge
                    hash[method][key] = [params[key], hash[method][key]].reverse.join(' , ')                        
                  # end patch  
                  else
                    hash[method][key] = hash[method][key] || params[key]
                  end
                end
              else
                if action == :reverse_merge
                  hash[method] = hash[method].merge(params)
                else
                  hash[method] = params.merge(hash[method])
                end
              end
            else
              hash[method] = params
          end
          hash
        end
      end

      self.scoped_methods << method_scoping
      begin
        yield
      ensure
        self.scoped_methods.pop
      end
    end
    
  end
end
