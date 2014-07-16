# This is the advofinder portion of  reviews
class Advofinder::ReviewsController < Advofinder::AdvofinderApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :load_topic
  before_filter :build_advocate_search_filter

  #--- actions
  
  def index
    do_index_and_render
  end
  
  protected
  
  def main_menu_class_name
    "evaluate"
  end

  def sub_menu_partial_name
    "advofinder/reviews/sub_menu"
  end
  
  def set_default_fields
    AdvocateSearchFilter.default_fields = {
      :tags => "Suchbegriffe",
      :postal_code => "PLZ",
      :city => "Wohnort",
      :person_name => "Vorname, Nachname"
    }
  end
  
  def load_topic
    @topic = Topic.find(params[:topic_id]) if params[:topic_id]
  end
  
  # returns a flat hash of all default fields
  def default_fields
    # @kase.default_fields_with_name(:kase) if @kase
    defaults = {}
    defaults = defaults.merge(@search_filter.default_fields_with_name(:search_filter)) if @search_filter
    defaults
  end
  helper_method :default_fields

  def do_index_and_render(select=nil, options={})
    do_index(select, options)
    render :template => "advofinder/reviews/index"
  end
  
  def do_index(select=nil, options={})
    @search_filter.with_query_scope do |query|
      @advocates = query.all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 50)
      @advocates_count = @advocates.size
      @addresses = Address.find(:all, :conditions => ["people.type = ? AND users.state IN (?)", "Advocate", ["active"]], 
        :joins => "LEFT OUTER JOIN people ON people.id = addresses.addressable_id AND addresses.addressable_type = #{Person.quote_value("Person")} " +
          "LEFT OUTER JOIN users ON users.person_id = people.id", :group => "addresses.city")
      @sidebar_cities = @addresses.map(&:city).uniq
    end
  end

end
