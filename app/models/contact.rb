# manages and sends generic contacts
class Contact < Message
  include DefaultFields
  
  #--- accessors
  attr_accessor :copy_sender
  attr_accessor :validate_message
  
  #--- validations
  validates_presence_of :sender_first_name, :sender_last_name, :sender_email, :subject
  validates_presence_of :message, :if => :validate_message?
  validates_email_format_of :sender_email
  
  #--- instance methods
  
  def after_initialize
    @validate_message = true if @validate_message.nil?
  end
  
  def receiver_first_name
    "Kontakt"
  end
  
  def receiver_last_name
    "kann-ich-klagen.de"
  end

  def receiver_email
    Notifier.contact_email
  end

  # figure out if a copy needs to be sent, note: view assigns as string
  def copy_sender?
    if @copy_sender.is_a?(TrueClass)
      true
    elsif @copy_sender.is_a?(FalseClass)
      false
    else
      "#{@copy_sender}".to_i > 0
    end
  end
  
  # if set to true (default) the message will be validated, ignore message 
  # use @contact.validate_message = false
  def validate_message?
    !!@validate_message
  end

  protected
  
  def do_deliver
    ContactMailer.deliver_message(self, self.copy_sender?)
  end
  
end