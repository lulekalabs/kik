# handles all questions and is a direct decendant of front application 
class QuestionsController < FrontApplicationController
  include QuestionsControllerBase
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :kik_realm_required
  before_filter :special_message, :only => [:open]
  before_filter :login_required, :only => [:open, :toggle_follow, :close, :reopen, :mandate_received, :mandate_given, :show]
  before_filter :build_kase, :only => [:new, :create]
  before_filter :build_search_filter
  before_filter :load_topic
  before_filter :load_kase, :only => [:toggle_follow]
  before_filter :load_kase_if_mine_or_redirect_back, :only => [:close, :reopen, :mandate_given]
  before_filter :load_kase_if_advocate_or_redirect_back, :only => [:mandate_received]
  before_filter :load_current_registering_kase_or_redirect, :only => [:confirm, :resend_activate]
  skip_before_filter :verify_authenticity_token, :only => [:new]
  before_filter :load_kase_if_mine_or_user_is_advocate, :only => :show
  
  #--- actions
  
  def new
  end
  
  def create
    if self.save
      self.current_registering_kase = @kase
      redirect_to confirm_question_path(@kase)
      return
    end
    render :template => "questions/new"
  end

  def confirm
    render :template => "questions/confirm"
  end

  def activate
    if @kase = Kase.find_by_activation_code(params[:id])
      if @kase.activate! == true
        render :template => "questions/activated"
        return
      end
    end
    raise ActiveRecord::RecordNotFound
  end

  def resend_activate
    if @kase = Kase.find_by_activation_code(params[:id])
      @kase.send_activation_code
    end
    respond_to do |format|
      format.js {
        render :update do |page|
          page << "alert('Der Aktivierungs-Link wurde erfolgreich versandt.')"
        end
      }
      format.html { render :template => "questions/confirm" }
    end
  end

  def index
    do_index_and_render :open
  end
  
  def open
    do_index_and_render :open
  end

  def accessible
    do_index_and_render :accessible
  end

  def follows
    do_index_and_render :follows
  end

  def search_filter
    do_index_and_render :search_filter
  end
  
  def toggle_follow
    respond_to do |format|
      format.js {
        if current_user.person.following?(@kase)
          @follow = current_user.person.stop_following(@kase)
          @kase.reload
        else
          @follow = current_user.person.follow(@kase)
          @kase.reload
        end
        render :update do |page|
          page.replace dom_id(@kase), :partial => "questions/show", :object => @kase
        end
      }
      format.html { render :nothing => true }
    end
  end
  
  def close
    respond_to do |format|
      format.js {
        @kase.cancel!
        render :update do |page|
          page.replace dom_id(@kase), :partial => "questions/show", :object => @kase
          page << "alert('Frage wurde geschlossen!')" if @kase.closed?
        end
      }
      format.html { render :nothing => true }
    end
  end

  def reopen
    respond_to do |format|
      format.js {
        @kase.reopen!
        render :update do |page|
          page.replace dom_id(@kase), :partial => "questions/show", :object => @kase, 
            :locals => {:open => !!(params[:open].to_s =~ /^(true|1)/i)}
          page << "alert('Frage wurde wieder geöffnet!')" if @kase.open?
        end
      }
      format.html { render :nothing => true }
    end
  end

  def mandate_given
    respond_to do |format|
      format.js {
        @kase.mandated = true
        # @kase.cancel!
        render :update do |page|
          page.replace dom_id(@kase), :partial => "questions/show", :object => @kase
          page << "alert('Mandat wurde erteilt!')" 
        end
      }
      format.html { render :nothing => true }
    end
  end

  def mandate_received
    respond_to do |format|
      format.js {
        @person = Person.find_by_id(params[:person_id])
        @kase.mandated_person = @person
        @kase.mandated = true
        # @kase.cancel!
        render :update do |page|
          page.replace dom_id(@kase), :partial => "questions/show", :object => @kase
          page << "alert('Mandat wurde erteilt an #{@person.title_and_name}')" 
        end
      }
      format.html { render :nothing => true }
    end
  end
  
  def show
  end
  
  protected
  
  # TODO wow, nice spaghetti! this is not from Juergen Fesslmeier ;-)
  def special_message
    flash[:message_for_not_logged_user] = true if params[:action] == 'open' and  params[:controller] == 'questions' # ticket 430
  end
  
  def main_menu_class_name
    case action_name 
    when /new/, /create/ then "new_question"
    else
      "open_question"
    end
  end

  def sub_menu_partial_name
    "shared/sub_menu_empty"
  end

  def build_kase(options={})
    if logged_in?
      @user = current_user
      @person = @user.person
    else
      @user = User.new({:persist => false})
      @person = @user.person = Client.new

      @address = @person.build_personal_address({:country_code => "DE"})
      @person.attributes = {}.merge((params[:person] || {}).symbolize_keys).merge(options[:person] || {})

      @user.attributes = {}.merge((params[:user] || {}).symbolize_keys).merge(options[:user] || {})
      @person.user = @user
    end
    
    @kase = Question.new({
      :person => @person
    }.merge((params[:kase] || {}).symbolize_keys))
    
    @kase
  end
  
  def set_default_fields
    self.set_kase_default_fields

    User.default_fields = {
      :login          =>  "Benutzername*",
      :email          =>  "E-Mail-Adresse*",
      :email_confirmation =>  "E-Mail-Adresse wiederholen*"
    }
    
    Person.default_fields = {
      :first_name          =>  "Vorname*" ,
      :last_name           =>  "Nachname*" , 
      :phone_number        =>  "Mobilfunk- oder Festnetznummer",
      :fax_number          =>  "Faxnummer"
    }
    
    PersonalAddress.default_fields = {
      :street              =>  "Straße" ,
      :street_number       =>  "Hausnnummer" ,
      :postal_code         =>  "PLZ" ,
      :city                =>  "Wohnort"
    }
    
    SearchFilter.default_fields = {
      :tags => "Suchbegriffe",
      :postal_code => "PLZ",
      :city => "Wohnort"
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    # @kase.default_fields_with_name(:kase) if @kase
    defaults = {}
    defaults = defaults.merge(@kase.default_fields_with_name(:kase)) if @kase
    defaults = defaults.merge(@person.default_fields_with_name(:person)) if @person && !logged_in?
    defaults = defaults.merge(@user.default_fields_with_name(:user)) if @user && !logged_in?
    defaults = defaults.merge(@address.default_fields_with_name(:person_personal_address_attributes)) if @address && !logged_in?
    defaults = defaults.merge(@search_filter.default_fields_with_name(:search_filter)) if @search_filter
    defaults
  end
  helper_method :default_fields

  # validates @kase and if not logged in the @user, etc. as well
  def valid?
    result = @kase.valid?
    unless logged_in?
      result = @user.new_record? && @user.valid? && @kase.person.valid? && result
    end
    result
  end

  # save all necessary instances, including @user if necessary
  def save
    if result = self.valid?
      @user.register! if !logged_in? && @user.valid?
      @user.person.personal_address.save if @user.person.personal_address.valid?
      @kase.save!
    end
    result
  end

  def load_topic
    @topic = Topic.find(params[:topic_id]) if params[:topic_id]
  end
  
  def load_kase_if_mine_or_redirect_back
    @kase = Kase.find(params[:id]) if params[:id]
    if current_user.person != @kase.person
      redirect_to request.referrer || questions_path
      return
    end
  end

  def load_kase_if_mine_or_user_is_advocate
    @kase = Kase.find(params[:id]) if params[:id]
    unless current_user.person == @kase.person || current_user.person.is_a?(Advocate)
      redirect_to questions_path
      return
    end
  end
  
  def build_search_filter(options={})
    @search_filter = KaseSearchFilter.new((params[:search_filter] || {}).symbolize_keys.merge({
      :finder_class => Question, :person => logged_in? ? current_user.person : nil}).merge(options))
    @search_filter.topics << @topic if @topic
    @search_filter
  end
  
  def do_index(select, options={})
    if select == :open
      @search_filter.with_query_scope do |query|
        @kases = query.open.by_topic(@topic).all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
        @kases_count = @kases.size
      end
    elsif select == :accessible
      if logged_in? && current_user.person.is_a?(Advocate)
        @search_filter.with_query_scope do |query|
          @kases = query.open.accessible_by(current_user.person).all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
          @kases_count = @kases.size
        end
      end
    elsif select == :follows
      if logged_in?
        @search_filter.with_query_scope do |query|
          @kases = query.open.followed_by(current_user.person).all.paginate(:page => params[:page] || 1, :per_page => @search_filter.per_page || 5)
          @kases_count = @kases.size
        end
      end
    elsif select == :search_filter
      if logged_in?
        if sf = current_user.person.search_filters.last
          @search_filter = sf
          do_index(:open)
        end
      end
    end
  end
  
  def do_index_and_render(select, options={})
    do_index(select, options)
    render :template => "questions/index"
  end
  
  def current_questions_path
    if action_name == "open"
      open_questions_path
    elsif action_name == "accessible"
      accessible_questions_path
    elsif action_name == "follows"
      follows_questions_path
    elsif action_name == "search_filter"
      search_filter_questions_path
    else
      questions_path
    end
  end
  helper_method :current_questions_path
  
  # Accesses the current registering question from the session. 
  # Future calls avoid the database because nil is not equal to false.
  def current_registering_kase
    @current_registering_kase ||= load_registering_kase_from_session unless @current_registering_kase == false
  end

  def current_registering_kase=(new_kase)
    session[registering_kase_session_param] = new_kase ? new_kase.id : nil
    @current_registerin_kase = new_kase || false
  end

  def registering_kase_session_param
    :registering_kase_id
  end

  def clear_current_registering_kase
    self.current_registering_kase = nil
  end

  def load_current_registering_kase_or_redirect
    unless @kase = self.current_registering_kase
      redirect_to new_question_path
      return false
    end
  end
  
  def load_registering_kase_from_session
    self.current_registering_kase = Kase.find_by_id(session[registering_kase_session_param]) if session[registering_kase_session_param]
  end
  
end
