# Admin users are those that have access to the admin management console only.
# They also have seperate session context.
require 'digest/sha1'
class AdminUser < ActiveRecord::Base
  #--- accessors
  attr_accessor :password
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_protected :state
  attr_accessor :password_is_generated
  
  #--- associations
  before_save :encrypt_password
  
  #--- validations
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  validates_email_format_of :email

  #--- state machine
  acts_as_state_machine :initial => :pending
  state :passive
  state :pending, :enter => :make_activation_code
  state :active,  :enter => :do_activate
  state :suspended
  state :deleted, :enter => :do_delete

  event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending, :to => :active 
  end
  
  event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| u.activated_at.blank?}
    transitions :from => :suspended, :to => :passive
  end

  #--- class methods
  
  class << self
    
    def find_by_credential(login_or_email_or_id, options={})
      find(:first, :conditions => ["admin_users.login = ? OR admin_users.email = ?", login_or_email_or_id, login_or_email_or_id])
    end
    
    # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
    def authenticate(login, password)
      u = find_in_state :first, :active, 
        :conditions => ["admin_users.login = ? OR admin_users.email = ?", login, login]
      u && u.authenticated?(password) ? u : nil
    end

    def is_suspended?(login_or_email_or_id, password, options={})
      !!find_in_state(:first, :suspended, 
        :conditions => ["admin_users.login = ? OR admin_users.email = ?", login, login])
    end

    # Encrypts some data with the salt.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

  end
  #--- instance methods
  
  # returns the login name and email 
  def name(options={})
    "#{login} (#{email})"
  end
  
  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
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

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  # creates a reset password
  def create_reset_password
    @reset_password = true
    self.generate_password(true)
    AdminUserMailer.deliver_reset_password(self)
  end 

  # returns true if recently reset
  def recently_reset_password?
    @reset_password
  end 
  
  protected
  
  # randomly generates password 
  def generate_password(update=false)
    result = [Array.new(8){(rand(25) + 92).chr}.join].pack("m").chomp.chomp("=").chomp("=")
    self.password = result
    self.password_confirmation = result
    self.password_is_generated = true
    #self.persist = true

    self.save(false) if update
    result
  end
  
  def password_is_generated?
    !!self.password_is_generated
  end

  # before filter 
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end
    
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
  
  def do_delete
    self.deleted_at = Time.now.utc
  end

  def do_activate
    @activated = true
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
  end
end
