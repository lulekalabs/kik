# Handles the corporate contact form
class Corporate::ContactsController < Corporate::CorporateApplicationController
  include ContactsControllerBase

  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :build_contact
  before_filter :load_current_contact_or_redirect, :only => :complete
  after_filter :clear_current_contact, :only => :complete
  
  #--- actions
  
  def new
    render :template => 'corporate/contacts/new'
  end
  
  def create
    if @contact.valid?
      @contact.deliver!
      self.current_contact = @contact
      redirect_to complete_corporate_contacts_path
      return
    end
    render :template => 'corporate/contacts/new'
  end
  
  def complete
  end
  
  protected
  
  def build_contact
    if logged_in?
      @contact = Contact.new({
        :sender => @person,
        :sender_first_name => @person.first_name,
        :sender_last_name => @person.last_name,
        :sender_email => @person.email,
        :copy_sender => true
      }.merge((params[:contact] || {}).symbolize_keys))
    else
      @contact = Contact.new((params[:contact] || {}).symbolize_keys)
    end
  end
  
  def set_default_fields
    Contact.default_fields = {
      :sender_first_name => "Vorname*",
      :sender_last_name => "Nachname*",
      :sender_email => "E-Mail-Adresse*",
      :subject => "Betreff*",
      :message => "Schreiben Sie hier Ihr Anliegen*"
    }
  end
  
  # returns a flat hash of all default fields
  def default_fields
    @contact.default_fields_with_name(:contact) if @contact
  end
  helper_method :default_fields

  # loads current contact if any or redirects to new
  def load_current_contact_or_redirect
    unless self.current_contact
      redirect_to new_corporate_contact_path
      return false
    end
    true
  end

  private

  # returns true for remote modal call
  def modal?
    request.xhr?
  end
  
  def choose_layout
    modal? ? 'modal' : (af_realm? ? "advofinder" : "front")
  end
  
end
