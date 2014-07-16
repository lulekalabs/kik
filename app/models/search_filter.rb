# Search filter to use to compose the query and for pre-composed search queries
class SearchFilter < ActiveRecord::Base
  include DefaultFields
  
  #--- attributes
  attr_accessor :per_page
  attr_accessor :sort_order
  attr_accessor :finder_class
  attr_accessor :persist
  
  #--- associations
  belongs_to :person

  #--- instance methods
  
  # find with search filter
  #
  # e.g.
  #
  #   @question_search_filter.find_with_query :first, :conditions => "..."
  #
  def find_with_query(*args)
    with_finder_class_scope do
      self.finder_class.find(*args)
    end
  end
  
  # with scope handler to user for other finders
  #
  # e.g. 
  #
  #  @question_search_filter = SearchFilter.new(:finder_class => Question, :tags => "foo")
  #  @question_search_filter.with_finder_class_scope do
  #    Question.all
  #  end
  #
  def with_finder_class_scope(options={})
    #select = "#{finder_table_name}.*"
    #order = "created_at ASC"
    #group = "#{finder_table_name}.#{primary_key}"
    #conditions = self.sanitize_sql(["#{finder_table_name}.id = ?", 666])
    self.finder_class.send(:with_scope, :find => self.finder_options(options)) do
      yield
    end
  end

  # e.g. 
  #
  #  @search_filter = SearchFilter.new(:finder_class => Question, :tags => "foo")
  #  @search_filter.with_query_scope do |query|
  #    query.all
  #  end
  #
  def with_query_scope(options={})
    # scoped = self.finder_class.scoped(self.finder_options(options))
    scoped = self.scoped(options)
    yield(scoped)
  end
  
  def scoped(options={})
    self.finder_class.scoped(self.finder_options(options))
  end
  
  # collects finder options as hash
  def finder_options(options={})
    clear_default_fields

    select = "#{finder_table_name}.*"
    order = self.sort_order || "#{finder_table_name}.created_at ASC"
    group = "#{finder_table_name}.#{primary_key}"

    result = {:select => select, :order => order, :group => group}.merge_finder_options(options)
    
    reset_default_fields
    result
  end
  
  def per_page
    @per_page ? @per_page.to_i : 5
  end
  
  def blank?
    true
  end

  # does this search filter need to be persisted
  def persist?
    !!self.persist
  end

  protected
  
  # make sure we have at least a default finder class
  def after_initialize
    self.per_page = 5 unless @per_page
  end
  
  # sanitize helper
  def sanitize_sql(*args)
    self.finder_class.send(:sanitize_sql, *args)
  end
  
  # finder class table name
  def finder_table_name
    self.finder_class.table_name
  end

  # finder class primary key
  def primary_key
    self.finder_class.primary_key
  end

end
