# Instances created through Notifier.deliver_message(...)
class Email < Message

  #--- validations
  validates_presence_of :sender, :receiver
  
  # looks up the mail and finds a nicer name for email
  def sender_email_to_title_and_name
    known_emails = [Notifier.help_email, Notifier.search_filter_email, Notifier.message_email, Notifier.signup_email,
      Notifier.newsletter_email, Notifier.admin_email, Notifier.contact_email, Notifier.info_email,
        Notifier.feedback_email, Notifier.press_email].map {|m| Notifier.unprettify(m)}
    if known_emails.include?(self.sender_email)
      "kann-ich-klagen.de"
    elsif ps = Person.find_by_email(self.sender_email)
      ps.title_and_name
    else
      self.sender_email
    end
  end
  
  protected 
  
  #--- instance methods
  
  def do_deliver
    EmailMailer.deliver_message(self)
  end
  
end