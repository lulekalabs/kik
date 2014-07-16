# Handles sending of email message
class EmailMailer < Notifier
  
  def message(email)
    load_settings
    @subject    = email.subject
    @body       = email.message
    @recipients = email.receiver_email || email.receiver.email
    @from       = email.sender_email || self.signup_email
    @sent_on    = Time.now
  end

end
