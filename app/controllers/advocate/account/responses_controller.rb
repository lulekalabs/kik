# Takes care of answering (bewerben) a question
class Advocate::Account::ResponsesController < Advocate::Account::AdvocateAccountApplicationController

  #--- filters
  before_filter :load_kase
  before_filter :build_response, :only => [:new, :create]
  before_filter :load_response_if_mine_or_redirect_back, :only => [:show, :show_close, :close]
  
  #--- actions

  def new
  end
  
  def create
    if @response.save
      @response.approve!
      redirect_to advocate_account_question_response_path(@kase, @response)
      return
    end
    render :template => "advocate/account/responses/new"
  end
  
  def show_close
    if params[:close_reason]
      @response.close_action = "close"  # advocate wants to cancel
      if params[:close_reason] =~ /^advocate_cancel/i
        @response.close_reason = "advocate_cancel"
      elsif params[:close_reason] =~ /^advocate_mandated/i
        @response.close_reason = "advocate_mandated"
      end
    else
      @response.close_action = "no"  # set default to "no"
    end

    respond_to do |format|
      format.html { render :template => "advocate/account/responses/show" }
      format.js { 
        render :template => "advocate/account/responses/show_close", :layout => false 
        return
      }
    end
  end
  
  def close
    @response.attributes = params[:response]
    if @response.valid?
      respond_to do |format|
        format.js {
          @response.cancel! if @response.mandated? || @response.advocate_cancel?
          render :update do |page|
            page << "jQuery(document).trigger('close.facebox')"
            if @response.closed?
              page.replace dom_id(@response), :partial => "advocate/account/responses/show", :object => @response
              page << "alert('Bewerbung wurde geschlossen!')" if @response.closed?
            end
          end
        }
        format.html { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          @response.cancel!
          render :update do |page|
            page.replace dom_id(@response, :show_close), :partial => "show_close", :object => @response
          end
        }
      end
    end
  end

  protected
  
  def load_kase
    @kase = Kase.find(params[:question_id]) if params[:question_id]
  end

  def load_response
    @response = Response.find(params[:id]) if params[:id]
  end
  
  def build_response(options={})
    @response = @kase.responses.build((params[:response] || {}).symbolize_keys.merge({:person => current_user.person}).merge(options))
  end

  def load_response_if_mine_or_redirect_back
    @response = Response.find(params[:id]) if params[:id]
    if @response && current_user.person != @response.person
      respond_to do |format|
        format.js {
          render :update do |page|
            page.redirect_to request.referrer || advocate_account_questions_path
          end
          return
        }
        format.html {
          redirect_to request.referrer || advocate_account_questions_path
          return
        }
      end
    end
    @kase = @response.kase unless @kase
  end
  
end
