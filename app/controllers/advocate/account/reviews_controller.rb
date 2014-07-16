# Handles reviews "Bewertungen" of advocates
class Advocate::Account::ReviewsController < Advocate::Account::AdvocateAccountApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :load_review, :only => [:show, :rate]
  before_filter :build_search_filter, :only => :index
  before_filter :build_comment, :only => [:show, :rate]
  
  #--- actions

  def index
    do_index_and_render
  end
  
  def show
  end
  
  def rate
    respond_to do |format|
      format.html { render :nothing => true }
      format.js {
        grade = params[:rating][:rating]
        @review.rate(grade, current_user.person)
        render :update do |page|
          page.replace dom_id(@review), :partial => "shared/reviews/show", :object => @review
          page << "alert('Vielen Dank für Ihr Feedback!')"
        end
      }
    end
  end
  
  protected
  
  def load_review
    @review = Review.find(params[:id]) if params[:id]
  end
  
  def do_index(select=nil, options={})
    @search_filter.with_finder_class_scope do
      @reviews = current_user.person.reviews.visible.created_chronological_descending.all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
      @reviews_count = @reviews.size
    end
  end
  
  def do_index_and_render(select=nil, options={})
    do_index(select, options)
    render :template => "advocate/account/reviews/index" 
  end
  
  def build_search_filter(options={})
    @search_filter = ReviewSearchFilter.new((params[:search_filter] || {}).symbolize_keys.merge({
      :person => logged_in? ? current_user.person : nil}).merge(options))
    @search_filter.topics << @topic if @topic
    @search_filter
  end
  
  def build_comment(options={})
    @comment = ReviewComment.new((params[:comment] || {}).symbolize_keys.merge({:commentable => @review, :person => current_user.person}.merge(options)))
  end

  def set_default_fields
    Review.default_fields = {
      :like_description => "Schreiben Sie hier Ihre Erfahrungen rein.",
      :dislike_description => "Schreiben Sie hier Ihre Erfahrungen rein."
    }
    
    Comment.default_fields = {
      :message => "Hier können Sie einen Kommentar zu dieser Bewertung schreiben."
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    # @kase.default_fields_with_name(:kase) if @kase
    defaults = {}
    defaults = defaults.merge(@review.default_fields_with_name(:review)) if @review
    defaults = defaults.merge(@comment.default_fields_with_name(:comment)) if @comment
    defaults
  end
  helper_method :default_fields

end
