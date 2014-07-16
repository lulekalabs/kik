class EnrollmentMailer < Notifier
  
  def activation(enrollment)
    setup_email(enrollment)
    @subject    = "#{enrollment.mailer_title_and_name}, bitte bestätigen Sie Ihre kostenlose Anmeldung zum kann-ich-klagen.de #{enrollment.to_s}"
  end

  def activated(enrollment)
    setup_email(enrollment)
    @subject    = "Bestellung des kann-ich-klagen.de Newsletters erfolgreich!"
  end

  def deactivation(enrollment)
    setup_email(enrollment)
    @subject    = "#{enrollment.mailer_title_and_name}, bitte bestätigen Sie die Stornierung Ihres #{enrollment.to_s}"
  end

  def deactivated(enrollment)
    setup_email(enrollment)
    @subject    = "#{enrollment.mailer_title_and_name}, Ihr kann-ich-klagen.de #{enrollment.to_s} wurde abbestellt"
  end
  
  protected
  
  def setup_email(enrollment)
    load_settings
    @recipients    = "#{enrollment.to_person.name_and_email}"
    @from          = self.newsletter_email
    @subject       = "#{self.site_url} "
    @sent_on       = Time.now
    @body[:enrollment]   = enrollment
    @body[:person]       = enrollment.to_person
    @body[:user]         = @user = enrollment.to_person.user
  end
    
end
