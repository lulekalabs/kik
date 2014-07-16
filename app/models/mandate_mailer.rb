# #585
class MandateMailer < Notifier

  def client_mandate_confirmation(mandate)
    setup_email(mandate)
    @subject = "#{mandate.client.title_and_name}, haben Sie einen Anwalt gefunden?"
  end
  
  def notify_mandate_accepted(mandate)
    setup_email(mandate)
    @recipients    = self.admin_email
    @from          = self.admin_email
    @subject       = "Mitteilung über zustande gekommenes Mandat zur Frage #{mandate.kase.number} von Rechtsuchenden #{mandate.client.title_and_name} (#{mandate.client.number})"
  end

  def notify_mandate_declined(mandate)
    setup_email(mandate)
    @recipients    = self.admin_email
    @from          = self.admin_email
    @subject       = "Rechtsuchender bestreitet zustande gekommenes Mandat zur Frage #{mandate.kase.number}"
  end
  
  protected
  
  def setup_email(mandate)
    load_settings
    @recipients         = mandate.client.name_and_email
    @from               = self.admin_email
    @subject            = "#{self.site_url} "
    @sent_on            = Time.now
    @body[:receiver]    = mandate.client
    @body[:sender]      = mandate.advocate
    @body[:client]      = mandate.client
    @body[:kase]        = mandate.kase
    @body[:advocate]    = mandate.advocate
    @body[:mandate]     = mandate
  end

end
