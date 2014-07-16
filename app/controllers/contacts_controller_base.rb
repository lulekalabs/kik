# provides controller helpers for contacts common methods across controllers,
# mostly methods to store and retrieve contacts from session and cookie
module ContactsControllerBase
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
  end
  
  protected

  def contact_class
    Contact
  end

  # hash key for contact session id
  def contact_session_param
    :contact_id
  end
  
  def contact_cookie_auth_token
    "#{contact_session_param}_auth_token".to_sym
  end
  
  # Accesses the current contact from the session. 
  # Future calls avoid the database because nil is not equal to false.
  def current_contact
    @current_contact ||= load_contact_from_session unless @current_contact == false
  end

  # Store the given contact in the session.
  def current_contact=(new_contact)
    session[contact_session_param] = new_contact ? new_contact.id : nil
    @current_contact = new_contact || false
  end
  
  def load_contact_from_session
    self.current_contact = contact_class.find_by_id(session[contact_session_param]) if session[contact_session_param]
  end

  # used in before filter
  def clear_current_contact
    self.current_contact = nil
  end
  
end