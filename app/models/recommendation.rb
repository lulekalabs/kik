# Recommendation to hold invitations to the service, derives from message
class Recommendation < Message
  include DefaultFields
  
  #--- accessors
  attr_accessor :copy_sender
  
  #--- validations
  validates_uniqueness_of :receiver_email, :message => "wurde bereits eingeladen"
  validates_presence_of :sender_gender, :sender_first_name, :sender_last_name, :sender_email,
    :receiver_gender, :receiver_first_name, :receiver_last_name, :receiver_email
  validates_email_format_of :sender_email, :receiver_email
  validates_acceptance_of :friend_confirm
  
  #--- instance methods
  
  def copy_sender?
    !!@copy_sender
  end
  
  protected

  def validate
    self.errors.add(:sender_email, "kann sich nicht selbst empfehlen") if self.sender_email == self.receiver_email
  end
  
  def do_deliver
    RecommendationMailer.deliver_message(self)
#    RecommendationMailer.deliver_message_copy(self) if copy_sender?
  end
  
end