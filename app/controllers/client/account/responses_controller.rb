# Client browses through the responses on his questions
class Client::Account::ResponsesController < Client::Account::ClientAccountApplicationController

  #--- filters
  before_filter :load_kase
  before_filter :load_response
  
  #--- actions
  
  def show
    @response.read_by!(current_user.person)
  end
  
  def decline
    respond_to do |format|
      format.html { render :nothing => true }
      format.js {
        @response.decline!
        render :update do |page|
          page.replace dom_id(@response), :partial => "client/account/responses/show", :object => @response
          page << "alert('Bewerbung wurde abgelehnt!')" if @response.declined?
        end
      }
    end
  end

  def accept
    respond_to do |format|
      format.html { render :nothing => true }
      format.js {
        @response.accept!
        render :update do |page|
          page.replace dom_id(@response), :partial => "client/account/responses/show", :object => @response
          page << "alert('Bewerbung wurde angenommen!')" if @response.accepted?
        end
      }
    end
  end
  
  protected
  
  def load_kase
    @kase = Kase.find(params[:question_id] || params[:kase_id]) if params[:question_id] || params[:kase_id]
    if @kase && current_user.person != @kase.person
      if request.xhr?
        render :update do |page|
          page.redirect_to request.referrer || client_account_path
        end
      else
        redirect_to request.referrer || client_account_path
      end
      return
    end
  end
  
  def load_response
    @response = Response.find(params[:id]) if params[:id]
    if @response && current_user.person != @response.kase.person
      if request.xhr?
        render :update do |page|
          page.redirect_to request.referrer || client_account_path
        end
      else
        redirect_to request.referrer || client_account_path
      end
      return
    end
  end
  
end
