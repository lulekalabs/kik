# Advocate comments
class Advocate::Account::CommentsController < Advocate::Account::AdvocateAccountApplicationController
  include CommentsControllerBase
  
  protected
  
  def show_comment_partial_path
    if @commentable.is_a?(Review)
      "shared/reviews/comments/show"
    else
      "advocate/account/comments/show"
    end
  end

  def new_comment_partial_path
    if @commentable.is_a?(Review)
      "shared/reviews/comments/new"
    else
      "advocate/account/comments/new"
    end
  end
  
end
