class ActiveRecord::Base

  #--- class methods
  class << self

=begin
    # define_attr_column :province_code, :state
    def define_attr_column(name, value=nil, &block)
      sing = class << self; self; end
      sing.send :alias_method, "original_#{name}", name
      sing.class_eval <<-KLASS
      cattr_accessor :#{name}_column
      @@#{name}_column = value
      def #{name}?
        return true if #{name}_column
        false
      end
      KLASS
      
      class_eval <<-INST
      def #{name}
        self[#{name}_column] if #{name}?
      end

      def #{name}?
        return true if #{name}_column
        false
      end

      def #{name}=(a_#{name})
        self[#{name}_column] = a_#{name} if #{name}?
      end
        
      INST
    end
=end

    # Adds a method to safely merge conditions
    # Example:
    #   User.sanitize_and_merge_conditions "id = 1", [':state = ?', state]
    #     returns a string like "id = 1 AND state = 'new'"
    def sanitize_and_merge_conditions(*conditions)
      options = { :operator => 'AND' }
      sql = ''
      conditions.compact!
      conditions.each_with_index do |condition, index|
        next if condition.empty?
        sql << sanitize_sql_for_assignment(condition)
        sql << " #{options[:operator]} " if condition != conditions.last
      end
      return nil if sql.empty?
      sql
    end
    
  end
  
  
  # Dito, but the instance method
  def sanitize_and_merge_conditions(*conditions)
    self.class.sanitize_and_merge_conditions(*conditions)
  end
  
end