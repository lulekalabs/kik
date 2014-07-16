# manages and sends generic feedback
class Feedback < Message
  include DefaultFields
  
  #--- accessors
  attr_accessor :copy_sender
  
  #--- validations
  validates_presence_of :sender_email, :subject, :message
  validates_email_format_of :sender_email
  
  #--- instance methods
  
  def receiver_first_name
    "Admin"
  end
  
  def receiver_last_name
    "kann-ich-klagen.de"
  end

  def receiver_email
    Notifier.admin_email
  end
  
  def copy_sender?
    !!@copy_sender
  end
  
  # override from Message class
  def to_sender
    if self.sender && self.sender.first_name == self.sender_first_name && self.sender.last_name == self.sender_last_name && self.sender.email == self.sender_email
      self.sender
    else
      Person.new({
        :gender => self.sender_gender,
        :academic_title_id => self.sender_academic_title_id,
        :first_name => self.sender_first_name,
        :last_name => self.sender_last_name,
        :email => self.sender_email
      })
    end
  end
  
  protected
  
  def do_deliver
    FeedbackMailer.deliver_message_copy(self)
  end
  
end