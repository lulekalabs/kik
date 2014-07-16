class FeedbackMailer < Notifier
  
  def message_copy(message)
    setup_email(message, true)
    @subject    = "Vielen Dank für Ihr Feedback!"
  end

  protected
  
  def setup_email(message, copy=false)
    load_settings
    @recipients        = message.to_sender.name_and_email
    @from              = self.feedback_email # self.admin_email
    @bcc               = self.admin_email
    @subject           = "#{self.site_url} "
    @sent_on           = Time.now
    @body[:sender]     = message.to_sender
    @body[:message]    = message.message
  end
  
end
