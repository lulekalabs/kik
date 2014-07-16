class UserMailer < Notifier
  
  def signup_notification(user)
    setup_email(user)
    @subject    = "#{user.person.title_and_name}, bitte bestätigen Sie Ihre kostenlose Anmeldung auf kann-ich-klagen.de"
  end

  def pre_launch_activation(user)
    setup_email(user)
    @subject    += 'Ihr Konto ist auf inaktiv gestellt, Admin muss Sie noch freischalten!'
    @body[:url]  = "http://#{self.site_url}/"
  end
  
  def activation(user)
    setup_email(user)
    @subject    = "#{user.person.title_and_name}, vielen Dank für die Bestätigung Ihrer Anmeldung auf kann-ich-klagen.de"
  end
  
  def reset_password(user)
    setup_email(user)
    @subject    = "#{user.person.title_and_name}, Ihr Passwort für den Login auf kann-ich-klagen.de!"
  end

  def signup_registered(user)
    setup_email(user)
    @subject    = "#{user.person.title_and_name}, bitte bestätigen Sie Ihre kostenlose Anmeldung auf kann-ich-klagen.de"
  end

  def signup_confirmed(user)
    setup_email(user)
    @subject    = "#{user.person.title_and_name}, vielen Dank für die Bestätigung Ihrer Anmeldung auf kann-ich-klagen.de"
  end

  def signup_activated(user)
    setup_email(user)
    @subject    = "#{user.person.title_and_name}, vielen Dank für die Bestätigung Ihrer Anmeldung auf kann-ich-klagen.de"
  end

  protected
  
  def setup_email(user)
    load_settings
    @recipients    = "#{user.first_name} #{user.last_name} <#{user.email}>"
    @from          = self.admin_email
    @subject       = "#{self.site_url} "
    @sent_on       = Time.now
    @body[:user]   = user
    @body[:person] = user.person
  end
    
end
