# All comments (answer) on a client's question response (bewerbung) or review (bewertung)
class Client::Account::CommentsController < Client::Account::ClientAccountApplicationController
  include CommentsControllerBase
  
  protected
  
  def show_comment_partial_path
    if @commentable.is_a?(Review)
      "shared/reviews/comments/show"
    else
      "client/account/comments/show"
    end
  end

  def new_comment_partial_path
    if @commentable.is_a?(Review)
      "shared/reviews/comments/new"
    else
      "client/account/comments/new"
    end
  end
  
end
