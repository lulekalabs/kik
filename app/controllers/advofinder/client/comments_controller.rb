# All comments from a client's comment on a review
class Advofinder::Client::CommentsController < Advofinder::Client::ClientApplicationController
  include CommentsControllerBase
  
  protected
  
  def show_comment_partial_path
    "shared/reviews/comments/show"
  end

  def new_comment_partial_path
    "shared/reviews/comments/new"
  end
  
end
