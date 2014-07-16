# #735
class Client::Account::MandatesController < Client::Account::ClientAccountApplicationController

  #--- filters
  before_filter :load_kase
  before_filter :load_advocate
  
  #--- actions
  
  def accept
    if @advocate_mandate = @kase.received_mandates.find(:first, :conditions => ["mandates.advocate_id = ?", @advocate.id])
      #--- accept mandate
      @advocate_mandate.accept!
      
      #--- close question and set mandated
      @kase.close_action = "close"
      @kase.close_reason = "advocate_found"
      @kase.mandated_advocate = @advocate
      
      @kase.mandate_given = "yes"
      @kase.cancel!
    end
  end
  
  def decline
    if @advocate_mandate = @kase.received_mandates.find(:first, :conditions => ["mandates.advocate_id = ?", @advocate.id])
      #--- accept mandate
      @advocate_mandate.decline!
    end
  end
  
  protected
  
  def load_advocate
    @advocate = Advocate.find(params[:id]) if params[:id]
  end
  
  def load_kase
    @kase = Kase.find(params[:question_id]) if params[:question_id]
    if current_user.person != @kase.person
      if request.xhr?
        render :update do |page|
          page.redirect_to client_account_questions_path
        end
      else
        redirect_to client_account_questions_path
      end
      return
    end
  end
  
end
