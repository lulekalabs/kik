module ActiveSupport #:nodoc:
  module CoreExtensions #:nodoc:
    module Hash #:nodoc:
      module FinderOptions
        
        # merges finder options
        def merge_finder_options(options={})
          result = self.dup
          options.reject! {|k,v| v.blank?}
          result[:select] = [self[:select], options.delete(:select)].compact.join(", ")
          result[:conditions] = ActiveRecord::Base.sanitize_and_merge_conditions(self[:conditions], options.delete(:conditions))
          result[:order] = ActiveRecord::Base.sanitize_and_merge_order(self[:order], options.delete(:order))
          result.reject {|k,v| v.blank?}.merge(options)
        end
        
        # merges finder options and changes
        def merge_finder_options!(options={})
          options.reject! {|k,v| v.blank?}
          result[:select] = [self[:select], options.delete(:select)].compact.join(", ")
          self[:conditions] = ActiveRecord::Base.sanitize_and_merge_conditions(self[:conditions], options.delete(:conditions))
          self[:order] = ActiveRecord::Base.sanitize_and_merge_order(self[:order], options.delete(:order))
          self.reject! {|k,v| v.blank?}
          self.merge!(options)
        end
        
      end
    end
  end
end

class Hash
  include ActiveSupport::CoreExtensions::Hash::FinderOptions
  
  # E.g.
  #
  # {:foo => 'bar', :baz => 'snoopy'}.to_url_params -> "foo=bar&baz=snoopy"
  #
  def to_url_params
    elements = []
    keys.size.times do |i|
      elements << "#{keys[i]}=#{values[i]}"
    end
    elements.join('&')
  end
  
  # E.g.
  #
  # Hash.from_url_params("foo=bar&baz=snoopy") -> {:foo => 'bar', :baz => 'snoopy'}
  #
  def self.from_url_params(url_params)
    result = {}.with_indifferent_access
    url_params.split('&').each do |element|
      element = element.split('=')
      result[element[0]] = element[1]
    end
    result
  end
  
end
