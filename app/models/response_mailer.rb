# Mails to communicate on response (bewerbung)
class ResponseMailer < Notifier

  # trac #539
  def received(response)
    setup_email(response, response.kase.person)
    @subject = "Neue Bewerbung von Rechtsanwalt #{response.person.title_and_name}"
  end
  
  # trac #540
  def read(response)
    setup_email(response, response.person)
    @subject = "Ihre Bewerbung auf die Frage von #{response.kase.person.title_and_name} wurde gelesen"
  end
  
  # see #588
  def advocate_reminder(response)
    setup_email(response, response.person)
    @subject = "#{response.person.title_and_name}, ist Ihre Bewerbung noch aktuell?"
  end

  # see #740 and #574
  def client_closed(response)
    setup_email(response, response.kase.person)
    @subject = "#{response.kase.person.user_id}, die Bewerbung von #{response.person.title_and_name} wurde geschlossen"
  end

  # see #740 and #529
  def advocate_closed(response)
    setup_email(response, response.person)
    @subject = "#{response.person.title_and_name}, Ihre Bewerbung vom #{I18n.l(response.created_at)}, bei #{response.kase.person.title_and_name} wurde geschlossen"
  end
  
  protected
  
  def setup_email(response, receiver=nil)
    load_settings
    receiver         = receiver || response.kase.person
    @recipients      = receiver
    @from            = self.admin_email
    @subject         = "#{self.site_url} "
    @sent_on         = Time.now
    @body[:receiver] = receiver
    @body[:response] = response
    @body[:kase]     = response.kase
  end
    
end
