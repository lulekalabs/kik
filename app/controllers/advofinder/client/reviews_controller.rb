# advofinder client useris reviewing an advocate
class Advofinder::Client::ReviewsController < Advofinder::Client::ClientApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields
  prepend_before_filter :login_advofinder_client_required, :only => [:new, :create]
  before_filter :load_advocate
  before_filter :unreviewed_required, :only => [:new, :create]
  before_filter :build_review, :only => [:new, :create]
  before_filter :load_review, :only => [:show, :rate]
  before_filter :build_comment, :only => [:show, :rate]
  
  #--- actions
  
  def new
  end

  def create
    if @review.save
      @review.activate!
      flash[:notice] = "Vielen Danke für Ihre Bewertung."
      redirect_to advofinder_client_advocate_review_path(@advocate, @review)
      return
    else
      render :template => "advofinder/client/reviews/new"
    end
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
  
  def build_review(options={})
    @review = Review.new({:reviewer => logged_in? ? current_user.person : nil, :reviewee => @advocate}.merge((params[:review] || {}).symbolize_keys).merge(options))
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

  def load_advocate
    @advocate = advocate_class.find(params[:advocate_id]) if params[:advocate_id]
  end
  
  def load_review
    @review = Review.find(params[:id]) if params[:id]
    @advocate = @review.reviewee unless @advocate
  end
  
  def build_comment(options={})
    @comment = ReviewComment.new((params[:comment] || {}).symbolize_keys.merge({:commentable => @review, :person => current_user.person}.merge(options)))
  end
  
  def unreviewed_required
    if current_user.person.has_reviewed?(@advocate)
      redirect_to reviewed_client_account_advocates_path
      return
    end
  end
  
end
