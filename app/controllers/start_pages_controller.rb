# holds all start pages like the home page, etc.
class StartPagesController < PagesController
  
  #--- filters
  before_filter :check_for_pre_launch, :only => [:index]
  prepend_before_filter :set_default_fields, :only => [:index]
  
  #--- actions
  
  def index
    if af_realm?
      set_default_fields
      @search_filter = build_search_filter
      render :template => "advofinder/pages/index"
    else
      @kase = Kase.new
      render :template => "start_pages/index"
    end
  end
  
  protected
  
  def main_menu_class_name
    "start"
  end
  
  def set_default_fields
    self.set_kase_default_fields
  end
  
  # returns a flat hash of all default fields
  def default_fields
    defaults = {}
    defaults = defaults.merge(@kase.default_fields_with_name) if @kase
    defaults = defaults.merge(@search_filter.default_fields_with_name(:search_filter)) if @search_filter
    defaults
  end
  helper_method :default_fields
  
  # override pre launch path
  def pre_launch_redirect_path
    advocate_path
  end
  
  def set_default_fields
    AdvocateSearchFilter.default_fields = {
      :tags => "Suchbegriffe",
      :postal_code => "PLZ",
      :city => "Wohnort",
      :person_name => "Vorname, Nachname"
    }
  end
  
  def build_search_filter(options={})
    @search_filter = AdvocateSearchFilter.new((params[:search_filter] || {}).symbolize_keys.merge({
      :finder_class => Advocate, :person => logged_in? ? current_user.person : nil}).merge(options))
    @search_filter.topics << @topic if @topic
    @search_filter.city_name = params[:city_name] if params[:city_name]
    @search_filter.province_code = params[:province_code] if params[:province_code]
    @search_filter
  end
  
end
