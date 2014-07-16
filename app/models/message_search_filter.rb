# Search filter to use to compose the query and for pre-composed search queries
class MessageSearchFilter < SearchFilter

  #--- attributes
  attr_accessor :state
  
  #--- instance methods
  
  # collects finder options as hash
  def finder_options(options={})
    clear_default_fields

    select = "#{finder_table_name}.*"
    order = self.sort_order || "#{finder_table_name}.created_at ASC"
    group = "#{finder_table_name}.#{primary_key}"

    conditions = []
    conditions << if self.state =~ /^read$/
      sanitize_sql(['? = messages.receiver_id AND messages.id IN (SELECT messages.id FROM messages ' +
        'LEFT OUTER JOIN readings ON messages.id = readings.readable_id AND readings.readable_type = \'Message\' ' + 
          'WHERE readings.readable_id = messages.id AND readings.readable_type = \'Message\' AND readings.person_id = ?)',
            self.person.id, self.person.id])
    elsif self.state =~ /^unread$/
      sanitize_sql(['? = messages.receiver_id AND messages.id NOT IN (SELECT messages.id FROM messages ' +
        'LEFT OUTER JOIN readings ON messages.id = readings.readable_id AND readings.readable_type = \'Message\' ' + 
          'WHERE readings.readable_id = messages.id AND readings.readable_type = \'Message\' AND readings.person_id = ?)',
            self.person.id, self.person.id])
    end
    
    conditions << sanitize_sql(["messages.status IN (?)", ['delivered', 'done', 'read']])
    conditions = conditions.compact.reject(&:blank?).join(" AND ")
    
    result = {:select => select, :order => order, :group => group, :conditions => conditions,
      :include => :readings}.merge_finder_options(options)
    
    reset_default_fields
    result
  end
  
  # makes sure that all state is returned as nil
  def state
    @state.blank? ? nil : @state
  end
  
  protected
  
  # make sure we have at least a default finder class
  def after_initialize
    super
    self.finder_class = Message unless @finder_class
    self.sort_order = "#{self.finder_table_name}.created_at DESC" unless @sort_order
  end
  
end
