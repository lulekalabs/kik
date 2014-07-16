require 'digest/sha1'

class User < ActiveRecord::Base
  include DefaultFields
  
  #--- accessors
  attr_accessor :password
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :email
  attr_accessor :current_password
  attr_reader :default_field
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :current_password, :persist,
    :email_confirmation, :concession, :terms_of_service

  #--- associations
  belongs_to :person, :foreign_key => :person_id

  #--- validators
  validates_associated      :person
  validates_presence_of     :login,                      :if => :is_client?
  validates_presence_of     :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_presence_of     :email_confirmation,         :if => :email_required?
  validates_length_of       :password, :within => 4..6,  :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_confirmation_of :email,                      :if => :email_required?
  validates_length_of       :email,                      :within => 3..100
  validates_uniqueness_of   :login,                      :case_sensitive => false#, :if => :persist?, :scope => :persist
  validates_email_format_of :email
  validates_email_format_of :login, :message => nil
  
  validates_acceptance_of   :concession
  validates_acceptance_of   :terms_of_service
  

  #--- state machine
  acts_as_state_machine :initial => :passive
  state :passive
  state :pending, :enter => :make_activation_code
  state :preapproved, :enter => :do_preapprove
  state :inactive, :enter => :do_confirm
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?)}
    transitions :from => :passive, :to => :pending, :guard => :guest?
  end

  event :confirm do
    transitions :from => :pending, :to => :preapproved, :guard => Proc.new {|u| Project.user_optin?}
    transitions :from => :pending, :to => :inactive, :guard => Proc.new {|u| !Project.user_optin?}
  end

  event :approve do
    transitions :from => :preapproved, :to => :inactive
  end
  
  event :activate do
    transitions :from => [:pending, :inactive], :to => :active, :guard => :is_client?
    transitions :from => [:pending, :inactive], :to => :active
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active, :inactive], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :inactive, :suspended], :to => :deleted
  end

  event :unsuspend do
#    transitions :from => :suspended, :to => :inactive, :guard => Proc.new {|u| u.activation_code.blank? && u.activated_at.blank?}
    transitions :from => :suspended, :to => :active,   :guard => Proc.new {|u| !u.activated_at.blank?}
    transitions :from => :suspended, :to => :pending,  :guard => Proc.new {|u| !u.activation_code.blank?}
    transitions :from => :suspended, :to => :passive
  end

  #--- scopes
  named_scope :pre_active, :select => "DISTINCT users.*", 
    :conditions => ["users.state IN(?)", ['passive', 'pending', 'preapproved', 'inactive']]

  #--- callbacks
  before_save :encrypt_password
  after_save :save_person, :update_login
  after_destroy :destroy_person
  
  #--- class methods

  class << self

    def find_by_credential(login_or_email_or_id, options={})
      find(:first,
        :conditions => ["(users.login = ? OR people.email = ? OR users.id = ?) AND users.persist = ?", 
          login_or_email_or_id, login_or_email_or_id, login_or_email_or_id, true], :include => :person)
    end

    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login_or_email_or_id, password, options={})
      u = find_in_state(:first, :active, 
        :conditions => ["(users.login = ? OR people.email = ? OR users.id = ?) AND users.persist = ?", 
          login_or_email_or_id, login_or_email_or_id, login_or_email_or_id, true], :include => :person)
      u && u.authenticated?(password) ? u : nil
    end

    def is_suspended?(login_or_email_or_id, password, options={})
      !!find_in_state(:first, :suspended, 
        :conditions => ["(users.login = ? OR people.email = ? OR users.id = ?) AND users.persist = ?", 
          login_or_email_or_id, login_or_email_or_id, login_or_email_or_id, true], :include => :person)
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

    # Reset password, generate new one, state machine triggers a new email
    def reset_password(login, email)
      if user = User.find(:first, :conditions => ['login = ? AND people.email = ? AND state = ?', login, email, 'active'], :include => :person)
        self.generate_password(true)
        UserMailer.deliver_reset_password(user)
      end
      user
    end

  end

  #--- instance methods

  # is this user from advofinder?
  def advofinder_realm?
    Project.af_realm?
  end
  alias_method :af_realm?, :advofinder_realm?

  # is this user from kik?
  def kik_realm?
    Project.kik_realm?
  end

  # name of project this user belongs to, e.g. "kann-ich-klagen.de" or "advofinder.de"
  def project_name
    Project.name
  end

  # domain of project this user belongs to, e.g. "kann-ich-klagen.de" or "advofinder.de"
  def project_domain
    Project.domain
  end

  # host of project this user belongs to, e.g. "www.kann-ich-klagen.de" or "www.advofinder.de"
  def project_host
    Project.host
  end

  def after_initialize
    self.build_person(:user => self) unless self.person
    self.first_name = @first_name if @first_name
    self.last_name = @last_name if @last_name
    self.email = @email if @email
  end

  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end

  # virtual attribute for first_name, fetch it from contact
  def first_name
    return self.person.first_name if self.person
    nil
  end
  
  # first_name setter
  def first_name=(a_first_name)
    @first_name = a_first_name
    self.person.first_name = a_first_name if self.person
  end
  
  # last_name getter
  def last_name
    return self.person.last_name if self.person
    nil
  end
  
  # last_name setter
  def last_name=(a_last_name)
    @last_name = a_last_name
    self.person.last_name = a_last_name if self.person
  end 
  
  # email getter. since email is not stored with the user, fetch it from the associated contact
  def email
    return self.person.email if self.person
    nil
  end

  # email setter
  def email=(an_email)
    @email = an_email
    self.person.email = an_email if self.person
    self.login = an_email if self.person && self.person.is_a?(Advocate)
  end

  # returns the full name; first and last and with login name 
  # Options:
  #   :include_login => true
  def name(options={})
    defaults = { :with_login => true }
    options = defaults.merge(options).symbolize_keys
    
    if options[:with_login]
      "#{first_name} #{last_name} (#{login})"
    else
      "#{first_name} #{last_name}".strip
    end
  end
  
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  # returns true if this user has been actvated before
  def activated?
    !!self.activated_at
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  # returns true if the user has just been activated.
  def recently_activated?
    !!@activated
  end

  # returns true if the user has just registered
  def recently_registered?
    !!@registered
  end

  # alias for persistent column
  def persist?
    !!self.persist
  end

  # returns true for guest users, or those are not persisted
  def guest?
    !self.persist?
  end

  # make default text in the fileds.
  def init_fields block , f_param = nil
    @default_field = {
      :email_confirmation  =>  "E-Mail-Adresse wiederholen*"
    }
    block.call( self , f_param )
  end
  
  # randomly generates password 
  def generate_password(update=false)
    result = [Array.new(4){(rand(25) + 92).chr}.join].pack("m").chomp.chomp("=").chomp("=")
    self.password = result
    self.password_confirmation = result
    self.password_is_generated = true
    self.persist = true

    # we need to set the password attribute through person in user as well...
    if self.person && self.person.user
      self.person.user.password = result
      self.person.user.password_confirmation = result
      self.person.user.password_is_generated = true
      self.person.user.persist = true
    end
    
    self.save(false) if update
    result
  end
  
  def password_is_generated?
    !!self.password_is_generated
  end

  # destroys the associated person
  def destroy_person
    self.person.destroy if self.person && !self.person.new_record?
  end
  
  # send the registered email to activate
  def resend_registered
    self.send_registered if self.activation_code
  end

  # returns true if the user has not been activated
  def pre_active?
    ['passive', 'pending', 'preapproved', 'inactive'].include?(self.current_state.to_s)
  end
  
  # creates a reset password
  def create_reset_password
    @reset_password = true
    self.generate_password(true)
    UserMailer.deliver_reset_password(self)
  end 

  # returns true if recently reset
  def recently_reset_password?
    @reset_password
  end 
  
  # force password validations
  def password_required!
    @password_required = true
  end
  
  protected
  
  def save_person
    self.person.save(false) if self.person
  end
  
  # generate login in case we are advocate
  def update_login
    if self.person && self.person.is_a?(Advocate) && self.login == self.email
      iteration = 0
      begin
        name = generate_login(iteration)
        if (count = self.class.count(:conditions => ["users.login = ?", name])) == 0
          self.update_attributes({:login => name})
        else
          iteration += 1
        end
      end until count == 0
    end
  end
  
  # returns a login generate from person's title, first- and last name
  # 
  # E.g.
  #
  #   dr-juergen-fesslmeier
  #   dr-juergen-fesslmeier-02
  #   dr-juergen-fesslmeier-03
  #
  def generate_login(iteration=0)
    result = [] 
    result << self.person.title
    result << self.person.first_name
    result << self.person.last_name
    result = result.reject(&:blank?).map(&:downcase).map(&:strip)
    result.each do |stuff|
      stuff.gsub!(/[äöüÄÖÜß]/) do |match|
        case match
        when "ä", "Ä" then 'ae'
        when "ö", "Ö" then 'oe'
        when "ü", "Ü" then 'ue'
        when "ß" then 'ss'
        end
      end
    end
    result = result.map {|s| s.gsub(/\s/, "-")}
    result = result.map {|s| s.gsub(/[\.,;]/, "")}
    name = result.join("-") # titel-vorname-nachname
    if iteration > 0
      iteration += 1
      "#{name}-#{iteration.to_s.rjust(2, "0")}"
    else
      name
    end
  end

  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{self.login}--") if new_record? || !self.salt
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    (@password_required || crypted_password.blank? || !password.blank?) && self.persist?
  end

  def email_required?
    self.new_record?
  end
  
  # returns if associated person is a Client
  def is_client?
    !!(self.person && self.person.is_a?(Client))
  end

  # returns if associated person is a Advocate
  def is_advocate?
    !!(self.person && self.person.is_a?(Advocate))
  end
  
  def make_activation_code
    @registered = true
    self.deleted_at = nil
    self.activation_code = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)
    self.save
    self.send_registered
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
  end

  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
    
    if self.activation_code
      # generate password in case there's none 
      self.generate_password(true) unless self.crypted_password
      # in any case, send out the activation mail
      self.send_activated
      
      # add 50 starting promotion contacts
      if self.person && self.person.is_a?(Advocate)
        if self.person.promotion_contact_transactions.empty?
          self.person.promotion_contact_transactions.create(
            :amount => 100, :expires_at => Time.now.utc + 365.days)
        end
      end
    end

    self.deleted_at = self.activation_code = nil
  end
  
  def do_preapprove
    AdvocateMailer.deliver_notify(self.person)
  end
  
  def do_confirm
    self.send_confirmed
  end
  
  def send_registered
    if self.person && self.person.is_a?(Advocate)
      AdvocateMailer.deliver_signup_registered(self.person)
    elsif self.person && self.person.is_a?(Client)
      # will not receive separate email, because signing up the client works
      # through the asking of a question, user activation happens when the 
      # question is activated.
    end
  end

  def send_confirmed
    if self.person && self.person.is_a?(Advocate)
      AdvocateMailer.deliver_signup_confirmed(self.person)
    end
  end

  def send_activated
    if self.person && self.person.is_a?(Advocate)
      AdvocateMailer.deliver_signup_activated(self.person)
    elsif self.person && self.person.is_a?(Client)
      ClientMailer.deliver_signup_activated(self.person)
    end
  end

  def validate
    self.errors.add(:current_password, "ist ungültig") if self.current_password && !User.authenticate(self.login, self.current_password)
    self.errors.add(:new_password, "muss sich vom bestehenden Passwort unterscheiden") if self.current_password && self.current_password == self.password
  end
end
