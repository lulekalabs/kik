module Admin::CommentsHelper
  
  def commentable_column(record)
    link_to(record.commentable.to_s, polymorphic_path([:edit, :admin, record.commentable]))
  end
  
end
