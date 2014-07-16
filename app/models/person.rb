# Person is the base class for all clients (Mandanten) and advocates (Rechtsanwälte)
class Person < ActiveRecord::Base
  include DefaultFields

  #--- accessors
  attr_reader :default_field
  
  #--- assocations
  belongs_to :academic_title
  has_one :user, :dependent => :delete
  has_many :enrollments, :dependent => :destroy
  has_many :readings
  has_many :questions, :class_name => "Kase", :foreign_key => :person_id, :dependent => :destroy
  has_many :received_messages, :class_name => "Message", :foreign_key => :receiver_id, :dependent => :destroy
  has_many :unread_received_messages, :class_name => "Message", 
    :finder_sql => 'SELECT DISTINCT messages.id FROM messages ' +
      'WHERE #{id} = messages.receiver_id AND messages.status IN (\'read\', \'delivered\', \'done\') ' +
        'AND messages.id NOT IN (SELECT messages.id FROM messages ' +
          'LEFT OUTER JOIN readings ON messages.id = readings.readable_id AND readings.readable_type = \'Message\' ' + 
            'WHERE readings.readable_id = messages.id AND readings.readable_type = \'Message\' AND readings.person_id = #{id})',
    :counter_sql => 'SELECT DISTINCT count(messages.id) FROM messages ' +
      'WHERE #{id} = messages.receiver_id AND messages.status IN (\'read\', \'delivered\', \'done\') ' +
        'AND messages.id NOT IN (SELECT messages.id FROM messages ' +
          'LEFT OUTER JOIN readings ON messages.id = readings.readable_id AND readings.readable_type = \'Message\' ' + 
            'WHERE readings.readable_id = messages.id AND readings.readable_type = \'Message\' AND readings.person_id = #{id})'
  has_many :read_received_messages, :class_name => "Message", :foreign_key => :receiver_id,
    :conditions => 'readings.person_id = #{id}', 
      :include => :readings
  has_many :sent_messages, :class_name => "Message", :foreign_key => :sender_id, :dependent => :destroy
  has_many :search_filters, :order => "search_filters.created_at ASC", :dependent => :destroy
  has_and_belongs_to_many :spoken_languages
  has_many :memorizes, :dependent => :destroy
  acts_as_addressable :personal, :business, :billing, :has_one => true
 	acts_as_follower
  acts_as_rater

  has_attached_file :image, 
    :storage => :filesystem,
    :styles => {:normal => "75x94>", :small => "48x60>"},
    :url => "/images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension",
    :path => "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension"

  has_attached_file :logo, 
    :storage => :filesystem,
    :styles => {:normal => "150x19>"},
    :url => "/images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension",
    :path => "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/:class/:attachment/:id/:style_:basename.:extension"

  #--- validations
  validates_uniqueness_of :email
  validates_email_format_of :email
  validates_attachment_size :image, :in => 1..900.kilobytes, :message => "muss zwischen 1 und 900 KB sein"
  validates_attachment_content_type :image, :content_type => Project.image_content_types
  
  #--- scopes
  named_scope :created_chronological_descending, :order => "people.created_at DESC"
  named_scope :created_chronological_descending, :order => "people.created_at DESC"
  named_scope :visible, :conditions => ["users.state IN (?)", ["active"]], :include => :user
  
  #--- callbacks
  before_validation :build_enrollment 
  after_update :create_enrollment
  after_create :create_enrollment
  before_save :geocode_addresses
  
  #--- class methods
  class << self
    
    def enrollment_class
      Enrollment
    end
    
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
      [Advocate, Client]
    end

    # e.g. Question.kind => :question
    def kind
      self.name.underscore.to_sym
    end
    
  end
  
  #--- instance methods

  # returns a 8-digit customer number, e.g. "0000012"
  def number
    "#{self.id}".rjust(8, "0")
  end

  # returns the latest enrollment
  def enrollment
    self.enrollments.last
  end
  
  # has the person's associated user been registered? meaning activated the account
  def activated?
    self.user && self.user.activated?
  end
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.user.human_current_state_name if self.user
  end
  
  # creates a name string 
  #
  # e.g.
  #
  #   Adam Smith
  #
  #  Note: if a name is not available, the username will be returned instead
  #
  def name
    result = []
    result << self.first_name
    result << self.last_name
    if result.compact.empty?
      self.user.login if self.user
    else
      result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
    end
  end

  # e.g. "Herr" or "Frau" or dative "Herrn" or "Frau"
  def salutation(dative=false)
    result = []
    if dative
      result << "Frau" if self.female?
      result << "Herrn" if self.male?
    else
      result << "Frau" if self.female?
      result << "Herr" if self.male?
    end
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Herr Prof. Dr. Schmiedl   
  #   Herr Meier
  #
  def salutation_and_title_and_last_name(dative=false)
    result = []
    result << self.salutation(dative)
    result << self.academic_title.name if self.academic_title && self.academic_title != AcademicTitle.no_title
    result << self.last_name || (self.user ? self.user.login : "anonym")
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # E.g. Rechtsanwältin Prof. Dr. Maulwurf
  def profession_and_title_and_last_name
    result = []
    if self.is_a?(Advocate)
      result << "Rechtsanwalt" if self.male?
      result << "Rechtsanwältin" if self.female?
    end
    result << self.academic_title.name if self.academic_title && self.academic_title != AcademicTitle.no_title
    result << self.last_name || (self.user ? self.user.login : "anonym")
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # E.g. Rechtsanwältin Frau Prof. Dr. Maulwurf
  def profession_and_salutation_and_title_and_last_name(dative=false)
    result = []
    if self.is_a?(Advocate)
      result << "Rechtsanwalt" if self.male?
      result << "Rechtsanwältin" if self.female?
    end
    result << self.salutation(dative)
    result << self.academic_title.name if self.academic_title && self.academic_title != AcademicTitle.no_title
    result << self.last_name || (self.user ? self.user.login : "anonym")
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Herr Prof. Dr. Arndt Schmiedl   
  #   Herr Peter Meier
  #
  def salutation_and_title_and_name(dative=false)
    result = []
    result << self.salutation(dative)
    result << self.academic_title.name if self.academic_title && self.academic_title != AcademicTitle.no_title
    result << self.first_name
    result << self.last_name
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Prof.
  #
  def title
    result = []
    result << self.academic_title.name if self.academic_title && self.academic_title != AcademicTitle.no_title
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Herr Prof.
  #
  def salutation_and_title(dative=false)
    result = []
    result << self.salutation(dative)
    result << self.title
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # e.g.
  #
  #   Prof. Dr. Hans Schmiedl   
  #   Peter Meier
  #
  def title_and_name
    result = []
    result << self.academic_title.name if self.academic_title && self.academic_title != AcademicTitle.no_title
    result << self.name
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end

  # returns true for female
  def female?
    self.gender == 'f'
  end

  # returns true for male
  def male?
    self.gender == 'm'
  end

  # e.g.
  #
  #   Sehr geehrter Herr Prof. Dr. Dr. Dr. Dr. Schmiedl   
  #   Sehr geehrte Frau Dr. Merkel
  #
  def notifier_salutation_and_title_and_last_name
    result = []
    result << (self.female? ? "Sehr geehrte" : "Sehr geehrter")
    result << self.salutation_and_title_and_last_name
    result.compact.map {|m| m.to_s.strip}.reject {|i| i.blank?}.join(' ')
  end
  
  # returns a pretty print email formatted like
  #
  # e.g.
  #
  #   "Dan Nye" <dan_n.yahoo.com>
  #   dan_n.yahoo.com
  #
  def name_and_email
    email_address = Notifier.unprettify(self.email)
    self.name.blank? ? email_address : "\"#{self.name}\" <#{email_address}>"
  end

  # returns the name if available, otherwise, the email address
  # this is used in invitations, where the invitee does only have email.
  def name_or_email
    self.name.blank? ? self.email : self.name
  end

  # references the state from the attached user
  def state
    self.user.state if self.user
  end

  # returns the newsletter enrollment for this person's enrollment type
  def enrollment
    @enrollment_cache ||= self.enrollments.select {|r| r.class == self.class.enrollment_class}.first
  end

  # prints either user.login, user.person.name or user.id
  def user_id
    raise "Implement in Client or Advocate"
  end
  
  def search_filters?
    !self.search_filters.map(&:new_record?).empty?
  end

  # has the client reviewed this advocate before?
  def has_reviewed?(advocate)
    if self.is_a?(Client)
      !!self.reviews.find(:first, :conditions => ["reviews.reviewee_id = ?", advocate.id])
    else
      false
    end
  end

  # return the address
  def location
    self.is_a?(Client) ? self.personal_address : self.business_address
  end
  
  # used for static map
  def location_s
    self.location.to_s
  end

  # can this person create a review about the given person?
  def can_review?(person)
    self.is_a?(Client) && person.is_a?(Advocate) && !self.has_reviewed?(person)
  end
  
  # has this person already reviewed given person
  def has_reviewed?(advocate)
    !!Review.find(:first, :conditions => ["reviews.reviewer_id = ? AND reviews.reviewee_id = ?", self.id, advocate.id])
  end

  # is an image assigned?
  def image?
    self.image.file?
  end

  # creates the newsletter enrollment and activated
  def create_enrollment(activate=true)
    if self.newsletter?
      if er = self.enrollment_class.find_by_email(self.enrollment_attributes[:email])
        # check if an enrollment with this person's email exists and assign
        if !er.person || er.person != self
          er.attributes = self.enrollment_attributes
        end
      else 
        er = self.enrollment ? self.enrollment : self.enrollments.build(self.enrollment_attributes) 
      end
      if activate
        er.suppress_notifications!
        er.activate!
      else
        er.register!
      end
    else
      self.destroy_enrollment
    end
  end
  
  # remove all enrollments
  def destroy_enrollment
    if self.enrollment
      self.enrollment.deactivate!
      #self.enrollment.delete!
      #self.enrollment.delete
    end
  end
  
  # was there something?
  def enrollment?
    !!self.enrollment
  end

  # returns true if the objec has been geo coded with lat/lng attributes
  def geo_coded?
    !!(self.lat && self.lng)
  end

  protected
  
  def validate
    # to be extended in subclass
  end
  
  def enrollment_class
    self.class.enrollment_class
  end
  
  def enrollment_attributes(options={})
    {
      :type => self.enrollment_class.name,
      :person => self,
      :gender => self.gender,
      :first_name => self.first_name,
      :last_name => self.last_name,
      :email => self.email,
      :email_confirmation => self.email,
      :academic_title_id => self.academic_title_id
    }.merge(options)
  end

  # before validate
  def build_enrollment
    if self.newsletter?
      self.enrollments.build(self.enrollment_attributes) unless self.enrollment
    end
  end

  # geocode address in case it is a personal or business address
  # assigns person's location to either personal or business address
  def geocode_addresses
    address = if self.is_a?(Advocate)
      self.business_address
    elsif self.is_a?(Client)
      # self.personal_address  <- not for now
    end
    return unless address

    if !self.geo_coded? || address.changed?
      res = GeoKit::Geocoders::MultiGeocoder.geocode(address.to_s)
      if res.success
        self.lat = res.lat
        self.lng = res.lng
        self.province_code = Project.province_name_to_code(res.state)
      end
    end
  rescue GeoKit::Geocoders::GeocodeError => ex
    logger.error "Exception #{ex.message} caught when geocoding #{address.to_s}"
    return
  end

end
