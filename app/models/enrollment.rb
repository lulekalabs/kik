# Represents a newsletter or press release subscription. There are:
#
#  * AdvocateEnrollment
#  * ClientEnrollment
#  * JournalistEnrollment
#
require 'digest/sha1'

class Enrollment < ActiveRecord::Base
  include DefaultFields
  
  #--- association
  belongs_to :person
  belongs_to :academic_title

  #--- validations
  validates_presence_of :email, :email_confirmation
  validates_confirmation_of :email, :on => :create
  validates_email_format_of :email
#  validates_uniqueness_of :email
  
  #--- state machine
  acts_as_state_machine :initial => :passive
  state :passive
  state :pending, :enter => :do_register
  state :active,  :enter => :do_activate
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending
    transitions :from => :pending, :to => :pending, :guard => :resend_activation
  end
  
  event :activate do
    transitions :from => [:passive, :pending, :deleted], :to => :active
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active], :to => :deleted
  end

  #--- scopes
  named_scope :visible, :conditions => ["enrollments.state IN (?)", ['active']]
  named_scope :without_journalist_enrollments, :conditions => ['enrollments.type != ?', "JournalistEnrollment"]
  
  #--- callbacks  
  after_destroy :update_person

  #--- class methods
  
  class << self
    
    # type casts to the class specified in :type parameter
    #
    # E.g.
    #
    #   ce = Enrollment.new(:type => :client_enrollment)  ->  ClientEnrollment
    #   ce = Enrollment.new(:type => ClientEnrollment)
    #   ce = Enrollment.new(:type => 'ClientEnrollment')
    #
    def new_with_cast(*a, &b)  
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and (!type.blank?) and
          (k = type.class == Class ? type : (type.class == Symbol ? klass(type): type.constantize)) != self
        raise "type not descendent of Enrollment" unless k < self  # klass should be a descendant of us  
        return k.new(*a, &b)  
      end  
      new_without_cast(*a, &b)  
    end  
    alias_method_chain :new, :cast

    def klass(a_kind=nil)
      [ClientEnrollment, AdvocateEnrollment, JournalistEnrollment].each do |k|
        return k if k.name.underscore.to_sym == a_kind
      end
      Enrollment
    end

    # finds existing enrollment or creates new
    def find_or_build(attributes={})
      attributes = attributes.symbolize_keys

      unless enrollment = find_by_email(attributes[:email])
        enrollment = new(attributes)
      end
      enrollment
    end
    
  end
  
  #--- instance methods

  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end

  # returns true if an invitee as person is associated
  def has_registered_person?
    self.person && self.person.activated?
  end

  # Returns a person instance, either, through the associated
  # or builds a new one from attributes
  def to_person
    if self.has_registered_person?
      self.person
    else
      ec = self.dup
      ec.clear_default_fields
      Person.new({
        :gender => ec.gender,
        :academic_title_id => ec.academic_title_id,
        :first_name => ec.first_name,
        :last_name => ec.last_name,
        :email => ec.email
      })
    end
  end
  
  def to_s
    "Newsletter"
  end
  
  # prepare for deactivation, generate activation code if none was present, in order
  # to deactivate and send out deactivation email
  def deactivation!
    unless self.activation_code
      self.make_activation_code 
      self.save(false)
    end
    EnrollmentMailer.deliver_deactivation(self)
  end

  # removes the subscription entirely
  def deactivate!
    self.delete!
    self.destroy
  end

  # returns title and full name if present, otherwise, "Guten Tag"
  def mailer_title_and_name
    self.to_person.name.blank? ? "Guten Tag" : self.to_person.title_and_name
  end

  # returns "Guten Tag Herr Dr. Meier" or simply "Guten Tag" if there is no name
  def mailer_salutation_and_title_and_last_name
    self.to_person.name.blank? ? "Guten Tag" : "Guten Tag #{self.to_person.salutation_and_title_and_last_name}"
  end
  
  # send the registered email to activate
  def resend_activation
    EnrollmentMailer.deliver_activation(self) if self.activation_code
  end
  
  def suppress_notifications!
    @suppress_notifications = true
  end
  
  protected

  def suppress_notifications?
    !!@suppress_notifications
  end
  
  def email_required?
    self.new_record?
  end
  
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
  end
  
  def validate
    self.errors.add(:type, "muss angegeben werden") unless ['ClientEnrollment', 'AdvocateEnrollment', 'JournalistEnrollment'].include?(self.type)
  end

  def do_register
    self.make_activation_code
    EnrollmentMailer.deliver_activation(self) unless suppress_notifications?
  end
  
  # only used as guard in :pending -> :pending
  def resend_activation
    EnrollmentMailer.deliver_activation(self) unless suppress_notifications?
    true
  end

  def do_activate
    self.activated_at = Time.now.utc
    self.deleted_at = nil
    self.make_activation_code unless self.activation_code
    EnrollmentMailer.deliver_activated(self) unless suppress_notifications?
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
    EnrollmentMailer.deliver_deactivated(self)
  end

  # remove newsletter
  def update_person
    if self.person
      options = {:newsletter => false}
      options.merge!({:email_confirmation => self.person.email}) if self.person.respond_to?(:email_confirmation)
      self.person.update_attributes(options)
    end
  end

end
