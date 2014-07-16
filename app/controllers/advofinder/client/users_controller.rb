# client sign up inside advofinder realm
class Advofinder::Client::UsersController < Advofinder::Client::ClientApplicationController

  #--- filters
  prepend_before_filter :set_default_fields
  
  #--- actions
  
  def new
    @user = User.new
    @person = Client.new
    @address = PersonalAddress.new
  end
  
  protected
  
  def set_default_fields
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
  end

  # returns a flat hash of all default fields
  def default_fields
    # @kase.default_fields_with_name(:kase) if @kase
    defaults = {}
    defaults = defaults.merge(@person.default_fields_with_name(:person)) if @person && !logged_in?
    defaults = defaults.merge(@user.default_fields_with_name(:user)) if @user && !logged_in?
    defaults = defaults.merge(@address.default_fields_with_name(:person_personal_address_attributes)) if @address && !logged_in?
    defaults
  end
  helper_method :default_fields

end
