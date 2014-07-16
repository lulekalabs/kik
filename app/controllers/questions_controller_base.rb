# Common code for all questions controller in client, advocate and general questions
module QuestionsControllerBase

  def self.included(base)
    #base.send :helper_method, :form_flash_messages
    base.extend(ClassMethods)
  end
  
  module ClassMethods
  end
  
  protected
  
  def load_kase 
    @kase = Kase.find(params[:id]) if params[:id]
  end

  def load_kase_if_mine_or_redirect_back
    @kase = Kase.find(params[:id]) if params[:id]
    if !logged_in? || current_user.person != @kase.person
      respond_to do |format|
        format.html {
          redirect_to request.referrer || questions_path
          return
        }
        format.js {
          render :update do |page|
            page.redirect_to request.referrer || questions_path
          end
          return
        }
      end
    end
  end
  
  def load_kase_if_advocate_or_redirect_back
    @kase = Kase.find(params[:id]) if params[:id]
    if !logged_in? || !current_user.person.is_a?(Advocate)
      respond_to do |format|
        format.html {
          redirect_to request.referrer || questions_path
          return
        }
        format.js {
          render :update do |page|
            page.redirect_to request.referrer || questions_path
          end
          return
        }
      end
    end
  end
  
end