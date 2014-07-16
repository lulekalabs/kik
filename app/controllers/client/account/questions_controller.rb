class Client::Account::QuestionsController < Client::Account::ClientAccountApplicationController
  include QuestionsControllerBase

  #--- filters
  before_filter :load_kase, :only => [:update]
  before_filter :load_kase_if_mine_or_redirect_back, :only => [:show, :show_close, :close, :show_mandate_given, :mandate_given]
  
  #--- actions

  def index
    do_index_and_render(:open)
  end
  
  def open
    do_index_and_render(:open)
  end
  
  def closed
    do_index_and_render(:closed)
  end

  def update
    @kase.attributes = params[:kase]
    respond_to do |format|
      format.html {
        if @kase.save
          redirect_to client_account_questions_path
          return
        end
        render :template => "client/account/questions/index"
      }
      format.js {
        render :nothing => true  # replace if AJAX update
      }
    end
  end
  
  def show_close
    if params[:close_reason]
      @kase.close_action = "cancel"  # client wants to cancel
      if params[:close_reason] =~ /^advocate_found/i
        @kase.close_reason = "advocate_found"
      elsif params[:close_reason] =~ /^client_cancel/i
        @kase.close_reason = "client_cancel"
      end
    else
      @kase.close_action = "no"  # set default to "no"
      @kase.close_reason = nil
    end

    respond_to do |format|
      format.html { render :template => "client/account/questions/show" }
      format.js { 
        render :template => "client/account/questions/show_close", :layout => false 
        return
      }
    end
  end
  
  def close
    @kase.attributes = params[:kase]
    if @kase.valid?
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          @kase.cancel! if @kase.mandated? || @kase.client_cancel?
          render :update do |page|
            # page << "$('a.show_close_question_modal').fancybox.close()"
            page << "jQuery(document).trigger('close.facebox')"
            if @kase.closed?
              page.replace dom_id(@kase), :partial => "questions/show", :object => @kase
              page << "alert('Frage wurde geschlossen!')" if @kase.closed?
            end
          end
        }
      end
    else
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          render :update do |page|            
            page.replace dom_id(@kase, :show_close), :partial => "show_close", :object => @kase
          end
        }
      end
    end
  end

  def show_mandate_given
    if @kase.mandate_given_external?
      @kase.mandate_given = "yes"
      @kase.mandate_given_action = "external"
    else
      @kase.mandate_given = "no"  # set default to "no"
    end

    respond_to do |format|
      format.html { render :template => "client/account/questions/show" }
      format.js { 
        render :template => "client/account/questions/show_mandate_given", :layout => false 
        return
      }
    end
  end
  
  def mandate_given
    @kase.attributes = params[:kase]
    if @kase.valid?
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          @kase.save # if @kase.mandate_recently_given? || @kase.mandate_recently_given_removed?
          @kase.reload
          render :update do |page|
            # page << "$('a.show_close_question_modal').fancybox.close()"
            page << "jQuery(document).trigger('close.facebox')"
            page.replace dom_id(@kase), :partial => "questions/show", :object => @kase
          end
        }
      end
    else
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          render :update do |page|            
            page.replace dom_id(@kase, :show_close), :partial => "show_mandate_given", :object => @kase
          end
        }
      end
    end
  end

  protected

  def do_index(select, options={})
    @select = select
    if select == :open
      @kases = @person.questions.client_visible_and_not_closed.created_chronological_descending
    elsif select == :closed
      @kases = @person.questions.closed.created_chronological_descending
    end
  end
  
  def do_index_and_render(select, options={})
    do_index(select, options)
    render :template => "client/account/questions/index"
  end
  
  def load_kase_if_mine_or_redirect_back
    @kase = Kase.find(params[:id]) if params[:id]
    if current_user.person != @kase.person
      if request.xhr?
        render :update do |page|
          page.redirect_to request.referrer || questions_path
        end
      else
        redirect_to request.referrer || questions_path
      end
      return
    end
  end
  
end
