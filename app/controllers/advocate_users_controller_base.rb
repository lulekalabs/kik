# Common code for all advocate users used in advocate/users and advofinder/advocate/users
module AdvocateUsersControllerBase

  def self.included(base)
    base.send :helper_method, :default_fields
    base.extend(ClassMethods)
  end
  
  module ClassMethods
  end
  
  protected

  def activate_and_redirect_to(path)
    if @user.valid?
      @user.confirm!
      flash[:notice] = "Danke für die Bestätigung Ihres Anwaltkontos!"
      self.current_registering_user = nil
      redirect_to path
      return
    end
    render :template => "advocate/users/activate"
  end
  
  # builds user with advocate + address instance and assigns attributes from params, if any applicable
  def build_user(options={})
    @user = User.new({:persist => false})
    @person = @user.person = Advocate.new
    
    @address = @person.build_business_address({:country_code => "DE"})
    @person.attributes = {:profession_advocate => true}.merge(params[:person] || {}).merge(options[:person] || {})

    @user.attributes = params[:user] || {}
    @person.user = @user
    @user
  end

  # loads the current registering user if found in session, otherwise redirect to user registration
  def load_current_registering_user_or_redirect
    unless @user = self.current_registering_user
      redirect_to new_advocate_user_path
      return false
    end
  end
  
  # loads user by activation code in activate action
  def load_pending_user_or_redirect
    if (@user = User.find_by_activation_code(params[:id])) && @user.pending?
    else
      redirect_to new_advocate_user_path
      return false
    end
  end

  # on before filter for update
  def load_user_or_redirect
    unless (@user = User.find_by_id(params[:id])) && @user.pending? && @user.activation_code == params[:user][:activation_code]
      redirect_to new_advocate_user_path
      return false
    end
  end
  
  # hash key for registering user in the session
  def registering_user_session_param
    :registering_user_id
  end
  
  # Accesses the current registering user from the session. 
  # Future calls avoid the database because nil is not equal to false.
  def current_registering_user
    @current_registering_user ||= load_registering_user_from_session unless @current_registering_user == false
  end

  # Store the given registering user id in the session.
  def current_registering_user=(new_user)
    session[registering_user_session_param] = new_user ? new_user.id : nil
    @current_registerin_user = new_user || false
  end
  
  # used in before filter to remove session registering user
  def clear_current_registering_user
    self.current_registering_user = nil
  end
  
  # override from advocate_application_controller
  def build_recommendation
    if current_registering_user
      @recommendation = Recommendation.new({
        :sender => current_registering_user.person,
        :sender_first_name => current_registering_user.person.first_name,
        :sender_last_name => current_registering_user.person.last_name,
        :sender_email => current_registering_user.person.email
      })
    else
      @recommendation = Recommendation.new(params[:recommendation] || {})
    end
  end
  
  def set_default_fields
    User.default_fields = {
      :email  => "E-Mail-Adresse*",
      :email_confirmation  =>  "E-Mail-Adresse wiederholen*"
    }

    Person.default_fields = {
      :first_name          =>  "Vorname*" ,
      :last_name           =>  "Nachname*" , 
      :company_name        =>  "Kanzleiname" ,
      :phone_number        =>  "Telefonnummer für Rückfragen*",
      :company_url         =>  "Internet-Adresse (URL) der Kanzlei-Website",
      :email               =>  "E-Mail-Adresse*",
      :referral_source     =>  "Wie haben Sie von #{af_realm? ? "advofinder.de" : "kann-ich-klagen.de"} erfahren?"
    }
    
    BusinessAddress.default_fields = {
      :street              =>  "Straße der Kanzlei*" ,
      :street_number       =>  "Hausnr. der Kanzlei*" ,
      :postal_code         =>  "PLZ der Kanzlei*" ,
      :city                =>  "Ort der Kanzlei*"
    }
    
    Recommendation.default_fields = {
      :sender_first_name => 'Vorname*',
      :sender_last_name =>  'Nachname*',
      :sender_email => 'E-Mail-Adresse*',
      :receiver_first_name => 'Vorname des Empfängers*',
      :receiver_last_name =>  'Nachname des Empfängers*',
      :receiver_email => 'E-Mail-Adresse des Empfängers*',
      :message => 'Hier können Sie, wenn Sie es wünschen, zusätzlich eine persönliche Mitteilung an den Empfänger hinzufügen.'
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    defaults = @user.default_fields_with_name(:user, 
      @person.default_fields_with_name(:person, 
        @address.default_fields_with_name(:person_business_address_attributes))) if @user && @person && @address

    if @recommendation
      defaults ? defaults.merge(@recommendation.default_fields_with_name) : defaults = @recommendation.default_fields_with_name
    end

    defaults
  end
  
  private

  def load_registering_user_from_session
    self.current_registering_user = user_class.find_by_id(session[registering_user_session_param]) if session[registering_user_session_param]
  end
  
end