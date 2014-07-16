module DefaultFields

  def self.included(base)
    unless base.respond_to?(:default_fields)
      base.class_inheritable_reader :default_fields
      base.class_inheritable_writer :default_fields
      base.extend(ClassMethods)
      base.send :include, InstanceMethods
    
      base.class_eval do
        alias_method_chain :attributes=, :default_fields

        before_validation_on_create :clear_default_fields
        after_validation_on_create :reset_default_fields
        before_create :clear_default_fields
        
        class << self
          alias_method_chain :default_fields, :superclass
          alias_method_chain :new, :default_fields
        end
        
      end
    end
  end

  
  module ClassMethods

    # returns default fields or propagates to the superclass's default_fields
    def default_fields_with_superclass
      if default_fields_without_superclass && default_fields_without_superclass.is_a?(Hash)
        default_fields_without_superclass.symbolize_keys
      elsif superclass.respond_to?(:default_fields)
        superclass.send(:default_fields)
      else
        {}
      end
    end

    # intercept new to include default fields
    def new_with_default_fields(*a, &b)  
      object = new_without_default_fields(*a, &b)
      # object.attributes = a.first || {} <- removed, as we initialize the fields w/ new in previous line already 
      object
    end  

  end
  
  module InstanceMethods
  
    # intercept attributes setter
    # set default field values unless they are filled
    def attributes_with_default_fields=(new_attributes, guard_protected_attributes = true)
      self.default_fields.each do |k, v|
        if respond_to?("#{k}=")
          self.send("#{k}=", v) if self.send("#{k}").blank? && (new_attributes.is_a?(Hash) && new_attributes.symbolize_keys[k].blank?)
        else
          raise(ActiveRecord::UnknownAttributeError, "unknown default field attribute: #{self.class} #{k}")
        end
      end

      send(:attributes_without_default_fields=, new_attributes, guard_protected_attributes)
    end
    
    # returns default fields with hash
    # e.g. default_fields_with_name(:user)
    def default_fields_with_name(name=self.class.name.underscore, options={})
      self.default_fields.each do |k, v|
        options["#{name}_#{k}"] = v
      end
      options
    end
    
    # removes all field values that are still in default "state"
    def clear_default_fields
      reset_cleared_default_fields
      self.default_fields.each do |k, v|
        if respond_to?("#{k}=") && unescape(self.send("#{k}")) == unescape(v)
          add_to_cleared_default_fields(k, self.send("#{k}")) and self.send("#{k}=", "")
        end
      end
    end

    protected
    
    # sets the default field values unless it has already been set
    def reset_default_fields
      self.cleared_default_fields.each do |k, v|
        self.send("#{k}=", v)
      end
    end
    
    # returns a hash of all fields that were cleared before
    def cleared_default_fields
      @cleared_default_fields || {}
    end
    
    # adds a cleared field to the clear default fields hash
    def add_to_cleared_default_fields(k, v)
      @cleared_default_fields ? @cleared_default_fields[k] = v : @cleared_default_fields = {k => v}
    end

    # reset all cleared default fields
    def reset_cleared_default_fields
      @cleared_default_fields = {}
    end
    
    # remove all new lines (\n) and carriage returns (\r)
    def unescape(string)
      string.is_a?(String) ? string.gsub(/\n|\r/, "") : string
    end
    
  end
  
end