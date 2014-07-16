# Common code for all comments
module CommentsControllerBase

  def self.included(base)
    base.send :helper_method, :show_comment_partial_path, :new_comment_partial_path
    base.extend(ClassMethods)
    base.send :include, InstanceMethods
    
    base.send :before_filter, :load_commentable
    base.send :before_filter, :build_comment, :only => [:new, :create]
  end
  
  module ClassMethods
  end

  module InstanceMethods
    
    def create
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          @new_dom_id = dom_id(@comment, dom_id(@commentable))
          if @comment.save
            # activate all response comments and comments unless it is a comment made by a client (nachtrag)
            @comment.activate! if !@commentable.is_a?(Kase) || (@commentable.is_a?(Kase) && @commentable.person && !@commentable.person.is_a?(Client))
            render :update do |page|
              page.replace @new_dom_id, :partial => show_comment_partial_path, :object => @comment,
                :locals => {:commentable => @commentable, :show_new => true}
            end
          else
            render :update do |page|
              page.replace_html @new_dom_id, :partial => new_comment_partial_path, :object => @comment,
                :locals => {:commentable => @commentable}
            end
          end
        }
      end
    end
  
    protected
  
    def load_commentable
      if response_id = params[:response_id]
        @commentable = @response = Response.find(response_id)
        @kase = @response.kase
      elsif kase_id = params[:question_id] || params[:kase_id]
        @commentable = Kase.find(kase_id)
      elsif review_id = params[:review_id]
        @commentable = Review.find(review_id)
      end
    end
  
    def build_comment(options={})
      @comment = @commentable.comments.build((params[:comment] || {}).symbolize_keys.merge(:person => current_user.person).merge(options))
    end
  
    def show_comment_partial_path
      raise "Implement in include controller e.g. 'client/account/comments/show'"
    end

    def new_comment_partial_path
      raise "Implement in include controller e.g. 'client/account/comments/show'"
    end
  
  end
end