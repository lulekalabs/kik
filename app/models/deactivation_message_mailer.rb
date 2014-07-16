# Handles sending of email message
class DeactivationMessageMailer < Notifier
  
  def notify(message)
    load_settings
    @subject       = "#{message.sender.user_id} hat gerade sein Konto deaktiviert"
    @recipients    = self.admin_email
    @from          = self.admin_email
    @sent_on       = Time.now
    @body[:message] = message
  end

end
