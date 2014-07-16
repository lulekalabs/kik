# Message from an advocate to all users that view advocat's profile
class Advomessage < Message
  include DefaultFields
  
  attr_accessor :assigned
  
  #--- valditions
  validates_presence_of :sender, :subject, :message
  
  #--- instance methods
  
  def blank?
    clear_default_fields
    result = self.subject.blank? && self.message.blank?
    reset_default_fields
    result
  end
  
  def assigned?
    !!@assigned
  end
  
end