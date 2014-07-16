# Mails to register, activate and confirm an advocate
class ClientMailer < Notifier

  def signup_activated(person)
    setup_email(person)
    @subject    = "#{person.title_and_name}, vielen Dank für die Bestätigung Ihrer kostenlosen Frage auf kann-ich-klagen.de"
  end

  protected
  
  def setup_email(person)
    load_settings
    @recipients    = person.name_and_email
    @from          = self.signup_email
    @subject       = "#{self.site_url} "
    @sent_on       = Time.now
    @body[:user]   = person.user
    @body[:person] = person
  end
    
end
