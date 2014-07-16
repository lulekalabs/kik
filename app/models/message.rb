# Message is the superclass of recommendation
require 'uuidtools'
class Message < ActiveRecord::Base
  
  #--- associations
  belongs_to :sender, :class_name => 'Person', :foreign_key => :sender_id
  belongs_to :receiver, :class_name => 'Person', :foreign_key => :receiver_id
  belongs_to :sender_academic_title, :foreign_key => :sender_academic_title_id, :class_name => "AcademicTitle"
  belongs_to :receiver_academic_title, :foreign_key => :receiver_academic_title_id, :class_name => "AcademicTitle"
  
  acts_as_readable 
  
  #--- state machine
  acts_as_state_machine :initial => :queued, :column => :status
  state :queued
  state :delivered, :enter => :do_deliver
  state :done
  
  #--- events
  event :deliver do
    transitions :from => :queued, :to => :delivered
  end

  event :complete do
    transitions :from => :delivered, :to => :done
  end

  event :confirm do
    transitions :from => [:delivered, :done], :to => :read
  end
  
  #--- scopes
  named_scope :visible, :conditions => ["messages.status IN (?)", ['delivered', 'done', 'read']]
  named_scope :created_chronological_descending, :order => "messages.created_at DESC"
  named_scope :created_chronological_ascending, :order => "messages.created_at ASC"

  
  #--- callbacks
  before_validation_on_create :generate_uuid
  
  #--- instance methods
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end
  
  # Provides the invitee's name to display in the email
  # "Sam Smith <sam@smith.com>"
  def receiver_name
    if self.has_registered_receiver?
      "#{self.receiver.name}"
    else
      self.to_receiver.name_and_email
    end
  end
  
  # returns true if an invitee as person is associated
  def has_registered_receiver?
    self.receiver && self.receiver.activated?
  end
  
  # returns true if the receiver has not registered and activated his account
  def has_no_registered_receiver?
    !self.has_registered_receiver?
  end

  # makes sure we return a person instance
  def to_sender
    if self.sender
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
  
  # Returns an receiver instance, if a new user has signed up,
  # build a new person from message information. This is 
  # used in notifiers.
  def to_receiver
    if self.has_registered_receiver?
      self.receiver
    else
      Person.new({
        :gender => self.receiver_gender,
        :academic_title_id => self.receiver_academic_title_id,
        :first_name => self.receiver_first_name,
        :last_name => self.receiver_last_name,
        :email => self.receiver_email
      })
    end
  end
  
  # returns those attributes that relevant for the person
  def receiver_attributes(with_email=false, options={})
    if self.receiver
      {
        :gender => self.receiver.gender,
        :academic_title_id => self.receiver.academic_title_id,
        :first_name => self.receiver.first_name,
        :last_name => self.receiver.last_name
      }.merge(with_email ? {:email => self.receiver.email} : {}).merge(options)
    else
      {
        :gender => self.receiver_gender,
        :academic_title_id => self.receiver_academic_title_id,
        :first_name => self.receiver_first_name,
        :last_name => self.receiver_last_name
      }.merge(with_email ? {:email => self.email} : {}).merge(options)
    end
  end

  protected
  
  # generates a uuid based on the current time
  def generate_uuid
#    self[:uuid] = UUID.sha1_create(UUID_OID_NAMESPACE, Time.now.utc.to_f.to_s).to_s
  end

  def do_deliver
    # override in subclass
  end
  
end
