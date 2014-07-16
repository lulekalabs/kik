# handles questions for advocates
class Advocate::Account::QuestionsController < Advocate::Account::AdvocateAccountApplicationController
  include QuestionsControllerBase

  #--- filters
  before_filter :load_kase, :only => [:contact, :show_contact, :show_mandate_received, :mandate_received]
  before_filter :require_contacts, :only => [:contact, :show_contact]
  before_filter :load_search_filter, :only => [:index, :open, :closed]
  
  #--- actions

  def index
  end

  def open
    do_index_and_render(:open)
  end
  
  def closed
    do_index_and_render(:closed)
  end

  def show_contact
    respond_to do |format|
      format.html { render :template => "advocate/account/questions/show" }
      format.js { 
        render :template => "advocate/account/questions/show_contact", :layout => false 
        return
      }
    end
  end

  # get access to the client's 
  def contact
    respond_to do |format|
      format.html { do_index_and_render(:open) }
      format.js {
        result = @person.access_to!(@kase)
        render :update do |page|
          page << "jQuery(document).trigger('close.facebox')"
          page.replace dom_id(@kase), :partial => "questions/show", :object => @kase,
            :locals => {:show_contact_if_available => result.is_a?(TrueClass)}
          if result.is_a?(Access)
            page << "alert('Der Kontakt zum Rechtsuchenden konnte nicht freigestellt werden: #{result.errors.full_messages}')"
          elsif result.is_a?(TrueClass)
            @person.reload
            page.replace "header-welcome", :partial => "shared/header_welcome"
            # page << "alert('Der Kontakt zum Rechtsuchenden ist jetzt freigestellt!')"
          else
            page << "alert('Der Kontakt zum Rechtsuchenden konnte nicht freigestellt werden!')"
          end
        end
      }
    end
  end
  
  def show_mandate_received
    if @kase.mandate_received_from?(current_user.person)
      @kase.mandate_received = "yes"
    else
      @kase.mandate_received = "no"
    end
    respond_to do |format|
      format.html { render :template => "advocate/account/questions/show" }
      format.js { 
        render :template => "advocate/account/questions/show_mandate_received", :layout => false 
        return
      }
    end
  end
  
  def mandate_received
    @kase.attributes = params[:kase]
    if @kase.valid?
      respond_to do |format|
        format.js {
          @kase.mandate_received_advocate = current_user.person
          @kase.save
          @kase.reload
          render :update do |page|
            page << "jQuery(document).trigger('close.facebox')"
            page.replace dom_id(@kase), :partial => "questions/show", :object => @kase
          end
        }
        format.html { render :nothing => true }
      end
    else
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          render :update do |page|
            page.replace dom_id(@kase, :show_mandate_received), :partial => "show_mandate_received", :object => @kase
          end
        }
      end
    end
  end
  
  protected
  
  def require_contacts
    unless current_user.person.can_access?(@kase)
      session[:contact_question_location] = return_to_current_url || request.referrer
      respond_to do |format|
        format.js {
          if uses_modal?
            with_format :html do
              render :inline => <<-ERB 
  <%= javascript_tag("window.location.href = '#{advocate_account_products_path}'") %>
  <%#= javascript_tag("jQuery(document).trigger('close.facebox')") %>
  <p>Weiterleiten zur Produktübersicht...</p>
ERB
            end
          else
            render :update do |page|
              page.redirect_to advocate_account_products_path
            end
          end
          return
        }
        format.html {
          redirect_to advocate_account_products_path
          return
        }
      end
      # redirect_to advocate_account_products_path
      return
    else
      session[:contact_question_location] = nil
    end
  end

  # returns true if modal call (lightbox2) is expected, must be set from client
  def uses_modal?
    params[:uses_modal].to_s.match(/^(true|1)/i) ? true : false
  end

  def do_index(select, options={})
    if select == :open
      @kases = Kase.open_responded_or_accessible_by(current_user.person).created_chronological_descending.all.paginate(:page => params[:page] || 1, :per_page => 1000)
      @kases_count = @kases.size
    elsif select == :closed
      @kases = Kase.closed_responded_or_accessible_by(current_user.person).closed.created_chronological_descending.all.paginate(:page => params[:page] || 1, :per_page => 1000)
      @kases_count = @kases.size
    end  
  end
  
  def do_index_and_render(select, options={})
    do_index(select, options)
    render :template => "advocate/account/questions/index"
  end
  
  def load_search_filter
    @search_filter = current_user.person.search_filters.last
  end
  
end
