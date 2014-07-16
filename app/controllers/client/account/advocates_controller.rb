# Controller used to review advocates
class Client::Account::AdvocatesController < Client::Account::ClientAccountApplicationController

  #--- filters
  before_filter :load_advocate, :except => [:index, :reviewed, :unreviewed]
  before_filter :build_search_filter, :only => [:index, :reviewed, :unreviewed]

  #--- actions
  
  def index
    do_index_and_render(:unreviewed_advocates)
  end
  
  def reviewed
    do_index_and_render(:reviewed_advocates)
  end
  
  def unreviewed
    do_index_and_render(:unreviewed_advocates)
  end

  # Tab "Profil"
  def profile
  end
  
  # Tab "Bewertungen"
  def reviews
    @reviews = @advocate.reviews.visible
  end
  
  # Tab "Mitteilungen"
  def messages
    @messages = @advocate.advomessages.visible.created_chronological_descending
  end
  
  # Tab "Artikel"
  def articles
    @articles = @advocate.articles.law_article.published.published_chronological_descending
  end
  
  protected
  
  def do_index(select=nil, options={})
    @select = select
    if select == :unreviewed_advocates
      @search_filter.with_finder_class_scope do
        # @advocates = current_user.person.unreviewed_advocates.all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
        @advocates = Advocate.unreviewed_by(current_user.person).all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
        @unreviewed_advocates_count = current_user.person.unreviewed_advocates.count
        @reviewed_advocates_count = current_user.person.reviewed_advocates.count
      end
    elsif select == :reviewed_advocates
      @search_filter.with_finder_class_scope do
        # @advocates = current_user.person.reviewed_advocates.all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
        @advocates = Advocate.reviewed_by(current_user.person).all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
        @reviewed_advocates_count = current_user.person.reviewed_advocates.count
        @unreviewed_advocates_count = current_user.person.unreviewed_advocates.count
      end
    end
  end
  
  def do_index_and_render(select=nil, options={})
    do_index(select, options)
    render :template => "client/account/advocates/index"
  end
  
  def load_advocate
    @advocate = Advocate.find(params[:id]) if params[:id]
  end
  
  def build_search_filter(options={})
    @search_filter = AdvocateSearchFilter.new((params[:search_filter] || {}).symbolize_keys.merge({
      :finder_class => Advocate, :person => logged_in? ? current_user.person : nil}).merge(options))
    # @search_filter.topics << @topic if @topic
    # @search_filter.city_name = params[:city_name] if params[:city_name]
    # @search_filter.province_code = params[:province_code] if params[:province_code]
    @search_filter
  end
  
end
