# Base class handling wheater the mandate was given or received
#
# Client indicates that he has given the mandate to an advocate "Wurde das Mandat erteilt?"
#
# E.g.
#
# ClientMandate.create(:kase => @kase, :client => @client, :advocate => @advocate)
#
#
# Advocate indicates that has received the mandate on question by "Haben Sie das Mandat erhalten?"
# 
# E.g.
#
# AdvocateMandate.create(:kase => @kase, :advocate => @advocate, :client => @client)
#
class Mandate < ActiveRecord::Base
  
  #--- assocations
  belongs_to :client, :foreign_key => :client_id, :class_name => "Client"
  belongs_to :advocate, :foreign_key => :advocate_id, :class_name => "Advocate"
  belongs_to :kase
  belongs_to :response

  #--- validations
  validates_presence_of :client_id, :kase_id

  #--- state machine
  acts_as_state_machine :initial => :created, :column => :status
  state :created
  state :accepted, :enter => :enter_accepted, :after => :after_accepted
  state :declined, :enter => :enter_declined, :after => :after_declined

  event :accept do
    transitions :from => :created, :to => :accepted
  end

  event :decline do
    transitions :from => :created, :to => :declined
  end

  #--- scopes
  named_scope :created, :conditions => ["mandates.status = ?", 'created']
  named_scope :accepted, :conditions => ["mandates.status = ?", 'accepted']
  named_scope :declined, :conditions => ["mandates.status = ?", 'declined']

  #--- instance methods
  
  def after_accepted; end
  def after_declined; end
  
  def enter_accepted
    self.accepted_at = Time.now.utc
  end
  
  def enter_declined
    self.declined_at = Time.now.utc
  end
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end
  
end
