# Search filter management, create new ones, etc.
class Advocate::Account::SearchFiltersController < Advocate::Account::AdvocateAccountApplicationController
  
  #--- filters
  before_filter :build_search_filter, :only => [:new, :create]
  before_filter :load_search_filter, :only => :index
  
  #--- actions
  
  def index
    build_search_filter unless @search_filter
    render :template => "advocate/account/search_filters/new"
  end
  
  def new
  end
  
  def create
    if @search_filter.valid?
      current_user.person.search_filters.each {|s| s.destroy }
      current_user.person.search_filters.reload
      @search_filter.save!
      flash[:notice] = "Suchfilter wurde gespeichert."
      redirect_to advocate_account_search_filters_path
      return
    end
    render :template => "advocate/account/search_filters/new"
  end
  
  protected
  
  def load_search_filter
    @search_filter = current_user.person.search_filters.last
  end
  
  def build_search_filter(options={})
    @search_filter = KaseSearchFilter.new((params[:search_filter] || {}).symbolize_keys.merge({
      :finder_class => Question, :person => logged_in? ? current_user.person : nil,
        :persist => true}).merge(options))
    @search_filter.topics << Topic.new if @search_filter.topics.empty?
    @search_filter
  end
  
end
