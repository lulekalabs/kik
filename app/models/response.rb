# A response is an answer to a question or "bewerbung"
class Response < ActiveRecord::Base
  
  attr_accessor :close_action
  
  #--- associations
  belongs_to :kase, :class_name => "Question"
  belongs_to :person
  has_many :attached_assets, :as => :assetable, :dependent => :destroy
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => "comments.created_at ASC"

  acts_as_readable

  #--- validations
  validates_presence_of :person_id
  validates_presence_of :description
  validates_length_of :description, :within => 15..2000

  #--- state machine
  acts_as_state_machine :initial => :created, :column => :status
  state :created
  state :open, :enter => :do_open
  state :accepted, :enter => :do_accepted
  state :declined, :enter => :do_declined
  state :closed, :enter => :do_closed, :after => :after_closed

  event :activate do
    transitions :from => :created, :to => :open
  end

  event :approve do
    transitions :from => :created, :to => :open
  end

  event :accept do
    transitions :from => :open, :to => :accepted
  end

  event :decline do
    transitions :from => :open, :to => :declined
  end

  event :cancel do
    transitions :from => [:created, :open], :to => :closed
  end

  #--- callbacks
  before_validation :reset_close_action
  after_save :save_close_action

  #--- scopes
  named_scope :visible, :conditions => ["responses.status IN (?)", ['open', 'accepted', 'declined']]
  named_scope :closed, :conditions => ["responses.status IN (?)", ['closed']]
  named_scope :kase_open, :conditions => ["kases.status IN (?)", ['open']], :include => :kase
  named_scope :advocate_reminder, :conditions => ["kases.expires_at >= ? AND ((responses.advocate_reminded_at IS NULL AND TIMESTAMPDIFF(DAY, responses.created_at, NOW()) >= 1) OR (responses.advocate_reminded_at IS NOT NULL AND TIMESTAMPDIFF(DAY, responses.advocate_reminded_at , NOW()) >= 1))", Time.now.utc], :include => :kase
  named_scope :responded_by, lambda {|person| {:conditions => ["responses.person_id = ?", person.id]}}

  #--- instance methods
  
  # returns a 8-digit response number, e.g. "0000012"
  def number
    "#{self.id}".rjust(8, "0")
  end
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name(person=nil)
    if person.is_a?(Advocate) && [:closed, :declined].include?(self.current_state)
      self.class.human_attribute_name("status_#{self.current_state}")
    elsif person.is_a?(Advocate) && self.read_by?(self.kase.person)
      self.class.human_attribute_name("status_read")
    elsif person.is_a?(Advocate) && !self.read_by?(self.kase.person)
      self.class.human_attribute_name("status_unread")
    else
      self.class.human_attribute_name("status_#{self.current_state}")
    end
  end
  
  # temporary counter for responses until we use cashing
  def comments_count
    @comments_count ||= self.comments.count || 0
  end

  # can a new comment be added by this person?
  def can_comment?(person)
    self.kase.open? && (self.open? || self.accepted?) ? true : false
  end
  
  # assigns nested attributes
  def attached_assets_attributes=(options)
    options.each do |k,v|
      v.symbolize_keys!
      if v[:id].nil?
        # new
        self.attached_assets.build({:assetable => self, :person => self.person}.merge(v))
      elsif v[:id] != 0 && v[:_delete] =~ /^(1|true)/i
        # delete
        if asset = self.attached_assets.to_a.find {|r| r.id == v[:id].to_i}
          self.attached_assets.delete(asset)
        end
      end
    end
  end

  # to handel no for an answer when asked "Mandat erhalten? No"
  def close_reason=(reason)
    self[:close_reason] = reason.to_s == "no" ? nil : reason
  end

  # returns true if the advocate has indicated that he wants to close the application/response
  def advocate_cancel?
    !!(self.close_reason && self.close_reason =~ /^advocate_cancel/i)
  end
  
  # true if advocate has indicated that he was mandated
  def mandated?
    !!(self.close_reason && self.close_reason =~ /^advocate_mandated/i)
  end
  
  # E.g.
  #
  #  "Ich ziehe meine Bewerbung zurück" or
  #  "Ich habe das Mandat erhalten"
  #
  def human_close_reason(past_tense=false)
    if self.close_reason && self.close_reason =~ /^advocate_cancel/i
      past_tense ? "Bewerbung zurückgezogen" : "Ich ziehe meine Bewerbung zurück"
    elsif self.close_reason && self.close_reason =~ /^advocate_mandated/i
      past_tense ? "Mandat erhalten" : "Ich habe das Mandat erhalten"
    end
  end
  
  # for active_scaffold
  def to_s
    "Bewerbung auf Frage #{self.kase.number}"
  end
  
  protected
  
  def do_open
    ResponseMailer.dispatch(:received, self)
  end
  
  def do_accepted
    # obsolete
  end
  
  def do_declined
    # obsolete
  end

  # Ticket #740
  def do_closed
    ResponseMailer.dispatch(:client_closed, self)
    ResponseMailer.dispatch(:advocate_closed, self)
  end

  def after_closed
    # now, make sure we "claim" mandate to the kase, see #735
    if mandated?
      self.kase.mandate_received = true
      self.kase.mandate_received_advocate = self.person
      self.kase.save(false)
    end
  end

  # make sure we prepare attributes correctly before validation
  def reset_close_action
    if self.close_action && self.close_action =~ /^no/i
      self.close_reason = nil
      self.close_description = nil
    elsif self.close_action && self.close_action =~ /^close/i
      # we might be fine, attributes were already set
    end
  end

  # set the mandate in the kase
  def save_close_action
    if self.mandated?
      if self.kase && self.kase.can_be_accessed_by?(self.person)
        self.kase.update_attributes(:mandated => "listed_response", :mandated_person => self.person)
      end
    end
  end
  
end
