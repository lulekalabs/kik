# Handling all comments related to the question
class CommentsController < FrontApplicationController
  include CommentsControllerBase
  
  #--- filter
  before_filter :login_required
  
  protected
  
  def show_comment_partial_path
    "comments/show"
  end

  def new_comment_partial_path
    "comments/new"
  end
  
end
