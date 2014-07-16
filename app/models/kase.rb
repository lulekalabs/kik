# Superclass for question, generically described as case or "Fall"
class Kase < ActiveRecord::Base
  include DefaultFields

  MANDATED_STATES = %w(listed unlisted listed_response)
  
  #--- accessors
  attr_accessor :terms_of_service
  attr_accessor :close_action
  attr_accessor :mandate_given
  attr_accessor :mandate_given_action
  attr_accessor :mandate_received
  attr_accessor :mandate_received_advocate
  
  #--- associations
  belongs_to :person
  belongs_to :mandated_person, :class_name => "Person"
  has_and_belongs_to_many :topics, :join_table => "kases_topics"
  has_many :attached_assets, :as => :assetable, :dependent => :destroy
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => "comments.created_at ASC"
  has_many :responses, :dependent => :destroy
  has_many :accesses, :foreign_key => :accessible_id
  has_many :accessors, :through => :accesses, :source => :requestor
  has_many :mandates, :foreign_key => :kase_id, :dependent => :destroy
  has_many :given_mandates, :foreign_key => :kase_id, :dependent => :destroy, :class_name => "ClientMandate"
  has_many :received_mandates, :foreign_key => :kase_id, :dependent => :destroy, :class_name => "AdvocateMandate"
  has_many :mandidate_given_advocates, :through => :given_mandates, :source => :advocate
  has_many :mandidate_received_advocates, :through => :received_mandates, :source => :advocate

  acts_as_readable
  acts_as_followable
  acts_as_mappable :default_units => :kms, 
    :default_formula => :flat, :distance_field_name => :distance
  
  #--- validations
  validates_associated :person, :if => :person?
  validates_associated :attached_assets
  validates_presence_of :description, :postal_code
  validates_format_of :postal_code, :with => /^[0-9]{5}$/i, :message => I18n.t("activerecord.errors.messages.postal_code_format")
  validates_length_of :description, :within => 15..2000
  validates_presence_of :summary
  validates_presence_of :contract_period
  validates_inclusion_of :contract_period, :in => 1..30
  validates_presence_of :sender_email, :sender_email_confirmation, :unless => :person?
  validates_confirmation_of :sender_email, :unless => :person?
  validates_acceptance_of :terms_of_service, :unless => :person?

  #--- state machine
  acts_as_state_machine :initial => :created, :column => :status
  state :created
  state :preapproved, :enter => :do_preapprove
  state :open, :enter => :do_open, :after => :after_open
  state :closed, :enter => :do_close, :after => :after_close

  event :activate do
    transitions :from => :created, :to => :preapproved
  end

  event :approve do
    transitions :from => :preapproved, :to => :open
  end
  
  event :cancel do
    transitions :from => [:open], :to => :closed
  end

  event :reopen do
    transitions :from => [:closed], :to => :open, :guard => :guard_reopen?
  end
  
  #--- callbacks
  before_validation :reject_blank_assets, :reset_close_action
  before_create :create_and_send_activation_code
  before_save :geocode_postal_code
  after_save :update_mandate_given, :update_mandate_received
  
  #--- scopes
  named_scope :client_visible, :conditions => ["kases.status IN (?)", ['created', 'preapproved', 'open', 'closed']]
  named_scope :client_visible_and_not_closed, :conditions => ["kases.status IN (?)", ['created', 'preapproved', 'open']]
  named_scope :closed, :conditions => ["kases.status IN (?)", ['closed']]
  named_scope :open, :conditions => ["kases.status IN (?)", ['open']]
  named_scope :followed_by, lambda {|person| {:conditions => ["follows.follower_id = ?", person.id], :include => :follows}}
  named_scope :accessible_by, lambda {|person| {:conditions => ["accesses.requestor_id = ?", person.id], :include => :accesses}}
  named_scope :by_topic, lambda {|topic| topic ? {:conditions => ["topics.id IN (?)", topic.id], :include => :topics} : {}}
  named_scope :open_responded_or_accessible_by, lambda {|person| {:conditions => ["kases.status IN (?) AND (responses.person_id = ? OR accesses.requestor_id = ?)", "open", person.id, person.id], :include => [:responses, :accesses]}}
  named_scope :closed_responded_or_accessible_by, lambda {|person| {:conditions => ["kases.status IN (?) AND (responses.person_id = ? OR accesses.requestor_id = ?)", "closed", person.id, person.id], :include => [:responses, :accesses]}}
  named_scope :since, lambda {|since| since ? {:conditions => ["kases.created_at >= ? AND kases.created_at <= ?", since, Time.now.utc]} : {}} 
  named_scope :client_reminder, :conditions => ["kases.expires_at >= ? AND ((kases.client_reminded_at IS NULL AND TIMESTAMPDIFF(DAY, kases.created_at , NOW()) >= 1) OR (kases.client_reminded_at IS NOT NULL AND TIMESTAMPDIFF(DAY, kases.client_reminded_at , NOW()) >= 1))", Time.now.utc]
  named_scope :created_chronological_descending, :order => "kases.created_at DESC"
  named_scope :created_chronological_ascending, :order => "kases.created_at ASC"
  named_scope :expired, :conditions => ["kases.expires_at < ?", Time.now.utc]
  named_scope :not_expired, :conditions => ["kases.expires_at >= ?", Time.now.utc]
  named_scope :with_unanswered_received_mandates_more_than_24_hours_ago, 
    :conditions => ["mandates.status = ? AND mandates.created_at <= ? AND mandates.type = ?", 'created', Time.now.utc - 24.hours, 'AdvocateMandate'], 
      :include => :received_mandates
  
  #--- class methods
  
  class << self
    
    # type casts to the class specified in :type parameter
    #
    # E.g.
    #
    #   d = Kase.new(:type => :idea)
    #   d.kind == :idea  # -> true
    #   Kase.new(:type => "Problem") ->  Problem
    #
    def new_with_cast(*a, &b)  
      if (h = a.first).is_a? Hash and (type = h[:type] || h['type']) and 
        (k = type.class == Class ? type : (type.class == Symbol ? klass(type): type.constantize)) != self
        raise "type not descendent of Kase" unless k < self  # klass should be a descendant of us  
        return k.new(*a, &b)  
      end  
      new_without_cast(*a, &b)  
    end  
    alias_method_chain :new, :cast

    # finds a kase class by kind/type, e.g. Kase.klass(:idea) -> Idea
    def klass(a_kind=nil)
      ordered_subclasses.each do |sc|
        return sc if !a_kind.blank? && sc.kind == a_kind.to_sym
      end
      Kase
    end

    # make subclasses method public
    public :subclasses

    # subclasses in logical order
    def ordered_subclasses
      [Question]
    end

    # e.g. Question.kind => :question
    def kind
      self.name.underscore.to_sym
    end
    
  end

  #--- instance methods
  
  # returns a 8-digit question number, e.g. "0000012"
  def number
    "#{self.id}".rjust(8, "0")
  end
  
  def person?
    !!self.person
  end

  # returns true if the objec has been geo coded with lat/lng attributes
  def geo_coded?
    !!(self.lat && self.lng)
  end
  
  # returns true if we have mandated an advocate
  def accepted?
    false
  end

  # temporary counter for responses until we use cashing
  def responses_count
    @responses_count ||= self.responses.visible.count || 0
  end

  # temporary counter for responses until we use cashing
  def comments_count
    @comments_count ||= self.comments.count || 0
  end
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end
  
  # true if the kase expired
  def expired?
    self.expires_at && Time.now.utc > self.expires_at
  end

  # true if the kase has not expired
  def not_expired?
    self.expires_at && Time.now <= self.expires_at
  end
  
  # returns true if the person has purchased the contact
  def contact_purchased?(person)
    puts "-->> deprecated: use can_be_accessed_by?"
    can_be_accessed_by?(person)
  end
  
  # true if the person is able to read the contact information of the owner
  def can_be_accessed_by?(advocate)
    !!accessors.find(:first, :conditions => ["accesses.requestor_id = ?", advocate.id])
  end
  
  # has mandated been given to 
  def has_been_mandated?
    !!accessors.find(:first, :conditions => ["accesses.requestor_id = ? AND mandated IN (?)", person.id, ['1'] + MANDATED_STATES])
  end

  def has_not_been_mandated?
    !has_been_mandated?
  end

  # how many advocates have contacted this question
  def accessors_count
    self.accessors.count
  end

  # can a new comment be added to the question by this person?
  def can_comment?(person)
    (self.preapproved? || self.open?) && person == self.person
=begin    
    if self.preapproved? || self.open?
      if self.comments.last
        (self.comments.last.person.is_a?(Client) && person.is_a?(Advocate)) ||
          (self.comments.last.person.is_a?(Advocate) && person.is_a?(Client))
      else
        # no comments, yet, client can comment
        person == self.person
      end
    else
      false
    end
=end    
  end
  
  def can_edit?(person)
    self.person == person
  end
  
  # assigns nested attached asset attributes
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
  
  # deliver activation code
  def send_activation_code
    KaseMailer.deliver_activate(self)
  end

  # has this been given/mandated to a advocate?
  def mandated?
    !self.mandated.blank? && !(self.mandated =~ /^(0|false)/i)
  end

  # inverse of dito
  def not_mandated?
    !self.mandated?
  end
  
  # guard for reopening a question
  def guard_reopen?
    !self.expired?
  end
  
  # close reason indicates that the client has canceled the question and wants to close
  def client_cancel?
    !!(self.close_reason && self.close_reason =~ /^client_cancel/i)
  end

  # returns a human readable reason why question was closed
  def human_close_reason
    if self.closed?
      if self.client_cancel?
        "Frage hat sich erledigt"
      elsif self.mandated? && self.mandated =~ /listed/i
        "Anwalt wurde gefunden"
      elsif self.mandated? && self.mandated =~ /unlisted/i
        "Anwalt wurde gefunden"
      else
        "Laufzeit der Frage beendet"
      end
    end
  end
  
  # returns all advocates that have posted a response
  def participating_advocates
    result = []
    result << self.mandated_advocate if self.mandated_advocate
    result += self.responses.visible.map(&:person)
    result += self.accessors
    result.uniq!
    result
  end

  # assignes a person's id of the advocate that is mandated, or if assigned "none"
  # will clear the assigned mandated person
  def mandated_advocate_id=(value)
    if value
      if value.to_s =~ /^(none|unlisted)/i
        self.mandated_person_id = nil
        self.mandated = "unlisted"
        self.mandate_given_action = "external"
        @mandate_given = "yes"
      else 
        self.mandated_person_id = value
        self.mandate_given_action = "internal"
        self.mandated = "listed"
        @mandate_given = "yes"
      end
    else
      self.mandated_person_id = nil
      self.mandated = nil
      self.mandate_given_action = nil
    end
  end

  # alias 
  def mandated_advocate_id
    self.mandated_person_id
  end

  # alias 
  def mandated_advocate
    self.mandated_person
  end

  # alias for mandated person
  def mandated_advocate=(value)
    if value
      @mandate_given = "yes"
      self.mandated = "listed"
      self.mandate_given_action = "internal"
    end
    self.mandated_person = value
  end

  # did question come from an external site
  def referred?
    !self.referrer.blank?
  end

  # check which extern site it is
  def referred_by?(agent)
    self.referred? && agent.to_s == self.referrer.to_s
  end
  
  def referrer_name
    if self.referred?
      case self.referrer
      when /schoener_garten/ then "Mein Schöner Garten"
      when /super_illu/ then "Busenwunder"
      end
    end
  end

  # only if the client explicitly gives a mandate to an advocate
  def mandate_recently_given?
    @mandate_given && (@mandate_given.is_a?(TrueClass) || @mandate_given.to_s =~ /^(yes|1|true)$/i) ? true : false
  end

  # when @mandate_given is set to "no"
  def mandate_recently_given_removed?
    @mandate_given && (@mandate_given.is_a?(FalseClass) || @mandate_given.to_s =~ /^(no|0|fase)$/i) ? true : false
  end

  # recently given mandate to an external candidate? used only for after_create :update_mandate_given
  def mandate_given_action_external?
    @mandate_given_action && (@mandate_given_action.to_s =~ /^external$/i) ? true : false
  end
  
  # has a mandate given to this kase before, so it is in the associated mandates list
  def mandate_given?
    !self.given_mandates.empty?
  end

  def mandate_given_external?
    self.mandate_given? && !self.given_mandates.select {|m| m.action.to_s =~ /external/i}.empty?
  end

  # has the mandate been given to a particular advocate?
  def mandate_given_to?(advocate)
    return false if advocate.blank?
    !self.given_mandates.find(:first, :conditions => ["mandates.advocate_id = ?", advocate.id]).blank?
  end

  # received the mandate from a particular advocate
  def mandate_received_from?(advocate)
    return false if advocate.blank?
    !self.received_mandates.find(:first, :conditions => ["mandates.advocate_id = ?", advocate.id]).blank?
  end

  def mandate_recently_received?
    @mandate_received && (@mandate_received.is_a?(TrueClass) || @mandate_received.to_s =~ /^(yes|1|true)$/i) ? true : false
  end

  # when @mandate_given is set to "no"
  def mandate_recently_received_removed?
    @mandate_received && (@mandate_received.is_a?(FalseClass) || @mandate_received.to_s =~ /^(no|0|fase)$/i) ? true : false
  end

  protected
  
  def validate
    # if the advocate was indicated 
    if self.close_reason && self.close_reason =~ /^advocate_found/i && self.mandated? && self.mandated.to_s =~ /^listed/i && self.mandated_advocate.nil?
      self.errors.add(:mandated_advocate, "wurde nicht aus der Anwaltsliste ausgewählt")
    end
    
    # the user indicates that he has found an advocate, but didn't specify wheter she is from the list nor another avocate
    if self.close_reason && self.close_reason =~ /^advocate_found/i && !self.mandated?
      self.errors.add(:close_reason, "fehlt einen Anwalt auszuwählen")
    end
  end
  
  def do_preapprove
    self.preapproved_at = Time.now.utc
    self.expires_at = self.preapproved_at.midnight + self.contract_period.days
    if self.person && self.person.is_a?(Client) && self.person.user && self.person.user.pre_active?
      self.person.user.activate!
    else
      KaseMailer.deliver_activated(self)
    end
    KaseMailer.deliver_notify(self)
  end
  
  def do_open
    self.opened_at = Time.now.utc
    self.mandated = false
    self.mandated_person = nil
    KaseMailer.dispatch(:opened, self)
  end

  def after_open
    # destroy all mandate stuff as we may have reopen the question
    self.update_attributes({:close_reason => nil, :mandated => nil, :mandated_person_id => nil})
    self.mandate_given_action = nil
    self.mandates.destroy_all

    # send the digest for all advocates who want to receive updats immediately
    Delayed::Job.enqueue KaseSearchFilterJob.new(self.id)
  end

  def do_close
    self.closed_at = Time.now.utc
  end

  def after_close
    KaseMailer.dispatch(:closed, self)
    self.responses.visible.each do |response|
      KaseMailer.dispatch(:closed_update_response, self, response)
    end
  end

  def create_and_send_activation_code
    self.activation_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
    self.send_activation_code
  end

  # geocode question based on postal code
  def geocode_postal_code
    return unless self.postal_code
    if self.postal_code && (!!self.geo_coded? || !!self.changes.symbolize_keys[:postal_code])
      res = GeoKit::Geocoders::MultiGeocoder.geocode("#{self.postal_code}, DE")
      if res.success
        self.lat = res.lat
        self.lng = res.lng
        self.province_code = Project.province_name_to_code(res.state)
      end
    end
  rescue GeoKit::Geocoders::GeocodeError => ex
    logger.error "Exception #{ex.message} caught when geocoding #{self.postal_code}, DE"
    return
  end
  
  # remove all empty assets
  def reject_blank_assets
    self.attached_assets.each {|a| self.attached_assets.delete(a) if a.file.url.to_s =~ /missing.png/ || a.file.blank?}
  end

  # make sure we prepare attributes correctly before validation
  def reset_close_action
    if self.close_action && self.close_action =~ /^no/i
      self.mandated = nil
      self.close_reason = nil
      self.mandated_advocate = nil
    elsif self.close_action && self.close_action =~ /^close/i
      # we might be fine, attributes were already set
    end
  end
  
  def update_mandate_given
    # mandate given recently changed
    if @mandate_given
      self.given_mandates.destroy_all
      if self.mandate_recently_given?
        client_mandate = ClientMandate.create(:kase => self, 
          :advocate => self.mandate_given_action_external? ? nil : self.mandated_advocate, 
            :client => self.person, :action => self.mandate_given_action)
        client_mandate.accept! if client_mandate.valid?
        @mandate_given = nil
      elsif self.mandate_recently_given_removed?
        @mandate_given = nil
        self.update_attributes({:mandated_person_id => nil})
      end
    end
  end

  def update_mandate_received
    if @mandate_received
      if self.mandate_received_advocate && self.mandate_recently_received?
        unless self.mandate_received_from?(self.mandate_received_advocate)
          AdvocateMandate.create(:kase => self, :advocate => self.mandate_received_advocate, 
            :client => self.person, :action => "internal")
        end
      elsif self.mandate_received_advocate && self.mandate_recently_received_removed?
        if mandate = self.received_mandates.find(:first, :conditions => ["mandates.advocate_id = ?", self.mandate_received_advocate.id])
          mandate.destroy
        end
      end
      @mandate_received = nil
    end
  end

end
