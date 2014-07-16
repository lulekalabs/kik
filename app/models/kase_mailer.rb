# Mails to activate a question
class KaseMailer < Notifier

  def activate(kase)
    setup_email(kase)
    @subject    = "#{kase.person.title_and_name}, bitte bestätigen Sie Ihre kostenlose Frage auf kann-ich-klagen.de"
  end

  def activated(kase)
    setup_email(kase)
    @subject    = "#{kase.person.title_and_name}, vielen Dank für die Bestätigung und Aktivierung Ihrer Frage auf kann-ich-klagen.de"
  end

  def notify(kase)
    setup_email(kase)
    @recipients    = self.admin_email
    @from          = self.admin_email
    @subject       = "Frage von #{kase.person.title_and_name} prüfen und freigeben"
  end

  def opened(kase)
    setup_email(kase)
    @from            = self.admin_email
    @body[:receiver] = kase.person
    @subject         = "#{kase.person.title_and_name}, Ihre kostenlose Frage auf kann-ich-klagen.de ist nun freigeschaltet und für Anwälte sichtbar"
  end

  def closed(kase)
    setup_email(kase)
    @body[:receiver] = kase.person
    @subject         = "#{kase.person.title_and_name}, Ihre Frage vom #{I18n.l(kase.created_at)} wurde geschlossen"
  end

  def closed_update_response(kase, response)
    setup_email(kase)
    @recipients      = response.person.name_and_email
    @body[:receiver] = response.person
    @body[:response] = response
    @subject         = "#{response.person.title_and_name}, die Frage #{kase.number} von #{kase.person.user_id} wurde geschlossen"
  end

  def client_reminder(kase)
    setup_email(kase)
    @body[:receiver] = kase.person
    @subject         = "#{kase.person.title_and_name}, ist Ihre Frage noch aktuell?"
  end

  protected
  
  def setup_email(kase)
    load_settings
    person = kase.person
    @recipients    = person.name_and_email
    @from          = self.admin_email
    @subject       = "#{self.site_url} "
    @sent_on       = Time.now
    @body[:user]   = person.user
    @body[:person] = person
    @body[:kase]   = kase
  end
    
end
