# Handles the press contact form
class Press::ContactsController < Press::PressApplicationController
  include ContactsControllerBase
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :build_contact
  before_filter :load_current_contact_or_redirect, :only => :complete
  after_filter :clear_current_contact, :only => :complete
  
  #--- actions
  
  def new
  end
  
  def create
    if @contact.valid?
      @contact.deliver!
      self.current_contact = @contact
      redirect_to complete_press_contacts_path
      return
    end
    render :template => 'press/contacts/new'
  end
  
  protected
  
  def build_contact
    if logged_in?
      @contact = PressContact.new({
        :sender => @person,
        :sender_first_name => @person.first_name,
        :sender_last_name => @person.last_name,
        :sender_email => @person.email
      }.merge((params[:contact] || {}).symbolize_keys))
    else
      @contact = PressContact.new((params[:contact] || {}).symbolize_keys)
    end
  end
  
  def set_default_fields
    PressContact.default_fields = {
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
      redirect_to new_press_contact_path
      return false
    end
    true
  end
  
end
