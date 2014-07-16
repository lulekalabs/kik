# Search filter to use to compose the query and for pre-composed search queries
class ReviewSearchFilter < SearchFilter

  #--- attributes
  
  #--- instance methods
  
  # collects finder options as hash
  def finder_options(options={})
    clear_default_fields

    select = "#{finder_table_name}.*"
    order = self.sort_order || "#{finder_table_name}.created_at ASC"
    group = "#{finder_table_name}.#{primary_key}"

    conditions = []
    # todo
    conditions = conditions.compact.reject(&:blank?).join(" AND ")
    
    result = {:select => select, :order => order, :group => group, :conditions => conditions}.merge_finder_options(options)
    
    reset_default_fields
    result
  end
  
  protected
  
  # make sure we have at least a default finder class
  def after_initialize
    super
    self.finder_class = Review unless @finder_class
    self.sort_order = "#{self.finder_table_name}.created_at DESC" unless @sort_order
  end
  
end
