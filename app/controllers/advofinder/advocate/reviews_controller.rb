class Advofinder::Advocate::ReviewsController < Advofinder::Advocate::AdvocateApplicationController
  #--- filters
  prepend_before_filter :login_required
  prepend_before_filter :set_default_fields
  before_filter :load_advocate
  before_filter :load_review, :only => [:show, :rate]
  before_filter :build_comment, :only => [:show, :rate]
  
  #--- actions
  
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
  
  def set_default_fields
    Comment.default_fields = {
      :message => "Hier können Sie einen Kommentar zu dieser Bewertung schreiben."
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    # @kase.default_fields_with_name(:kase) if @kase
    defaults = {}
    defaults = defaults.merge(@comment.default_fields_with_name(:comment)) if @comment
    defaults
  end
  helper_method :default_fields

  def load_advocate
    @advocate = advocate_class.find(params[:profile_id]) if params[:profile_id]
  end
  
  def load_review
    @review = Review.find(params[:id]) if params[:id]
    @advocate = @review.reviewee unless @advocate
  end
  
  def build_comment(options={})
    if logged_in?
      @comment = ReviewComment.new((params[:comment] || {}).symbolize_keys.merge({:commentable => @review, :person => current_user.person}.merge(options)))
    end
  end
end
