# Handles messages for advocates
class Advocate::Account::AdvomessagesController < Advocate::Account::AdvocateAccountApplicationController

  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :build_advomessage
  before_filter :load_advomessage, :only => [:show, :edit, :update, :destroy]
  
  #--- actions

  def new
  end

  def index
    do_index
  end
  
  def create
    respond_to do |format|
      format.html {
        if @advomessage.save
          @advomessage.deliver!
          redirect_to advocate_account_advomessages_path
          return
        end
        render :template => "advocate/account/advomessages/index"
      }
      format.js {
        @new_dom_id = dom_id(@advomessage, :new)
        if @advomessage.save
          @advomessage.deliver!
          render :update do |page|
            page.replace @new_dom_id, :partial => "show", :object => @advomessage
            page.replace "new-more", :partial => "new_control", 
              :object => Advomessage.new(:sender => current_user.person)
          end
        else
          render :update do |page|
            page.replace_html @new_dom_id, :partial => "new", :object => @advomessage
          end
        end
      }
    end
  end

  def edit
    render :template => "advocate/account/advomessages/edit", :layout => false
  end

  def update
    @advomessage.attributes = params[:advomessage]
    respond_to do |format|
      format.js {
        if @advomessage.save
          render :update do |page|
            page.replace dom_id(@advomessage), :partial => "show", :object => @advomessage
          end
        else
          render :update do |page|
            page.replace_html dom_id(@advomessage), :partial => "edit", :object => @advomessage
          end
        end
      }
      format.html {
        if @advomessage.save
          redirect_to advocate_account_advomessages_path
          return
        end
        render :template => "advocate/account/advomessages/index"
      }
    end
  end
  
  def show
    #render :template => "advocate/account/advomessages/show", :layout => !request.xhr?
    #return
    
    respond_to do |format|
      format.js {
        render :update do |page|
          page.replace dom_id(@advomessage), :partial => "show", :object => @advomessage
        end
      }
      format.html {
        render :template => "advocate/account/advomessages/show"
      }
    end
  end
    
  def destroy
    @advomessage.destroy
    render :nothing => true
  end
  
  protected
  
  def set_default_fields
    Advomessage.default_fields = {
      :subject => "Betreff*",
      :message => "Nachricht für Mandanten*"
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    # @kase.default_fields_with_name(:kase) if @kase
    defaults = {}
    defaults = defaults.merge(@advomessage.default_fields_with_name(:advomessage)) if @advomessage
    defaults
  end
  helper_method :default_fields

  def build_advomessage(options={})
    @advomessage = Advomessage.new((params[:advomessage] || {}).symbolize_keys.merge({:sender => current_user.person}).merge(options))
  end

  def load_advomessage
    @advomessage = Advomessage.find(params[:id]) if params[:id]
  end

  def do_index
    @advomessages = current_user.person.advomessages.visible.created_chronological_descending
  end
  
end
