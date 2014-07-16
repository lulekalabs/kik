class DeactivationMessage < Message
  include DefaultFields

  #--- validations
  validates_presence_of :sender #, :message

  #--- instance methods
  
  def deliver!
    self.do_deliver
  end
  
  # make sure we have the message without default field
  def message_text
    clear_default_fields
    result = self.message
    reset_default_fields
    result
  end

  protected 
  
  def do_deliver
    DeactivationMessageMailer.deliver_notify(self)
  end

end