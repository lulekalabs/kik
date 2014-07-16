# e.g. Journalist
class Journalist < Person

  #--- validations
  validates_associated :business_address
  validates_presence_of :company_name, :media, :email, :email_confirmation
  validates_presence_of :fax_number, :if => :press_release_per_fax?
  validates_email_format_of :email
  validates_confirmation_of :email, :on => :create
  validates_uniqueness_of :email

  #--- class methods
  class << self
    
    def enrollment_class
      JournalistEnrollment
    end
    
  end
  
  #--- instance methods
  
  def first_name=(value)
    self.enrollment ? self.enrollment.first_name = value : nil
    self[:first_name] = value
  end

  def last_name=(value)
    self.enrollment ? self.enrollment.last_name = value : nil
    self[:last_name] = value
  end

  def email=(value)
    self.enrollment ? self.enrollment.email = value : nil
    self[:email] = value
  end

  def gender=(value)
    self.enrollment ? self.enrollment.gender = value : nil
    self[:gender] = value
  end

  def academic_title_id=(value)
    self.enrollment ? self.enrollment.academic_title_id = value : nil
    self[:academic_title_id] = value
  end
  
  def press_release_per_email=(value)
    self.enrollment ? self.enrollment.press_release_per_email = value : @press_release_per_email = value
  end
  
  def press_release_per_email
    self.enrollment ? self.enrollment.press_release_per_email : !!(@press_release_per_email && (@press_release_per_email.to_s =~ /1|true/))
  end
  alias_method :press_release_per_email?, :press_release_per_email

  def press_release_per_fax=(value)
    self.enrollment ? self.enrollment.press_release_per_fax = value : @press_release_per_fax = value
  end
  
  def press_release_per_fax
    self.enrollment ? self.enrollment.press_release_per_fax : !!(@press_release_per_fax && (@press_release_per_fax.to_s =~ /1|true/))
  end
  alias_method :press_release_per_fax?, :press_release_per_fax

  def press_release_per_mail=(value)
    self.enrollment ? self.enrollment.press_release_per_mail = value : @press_release_per_mail = value
  end
  
  def press_release_per_mail
    self.enrollment ? self.enrollment.press_release_per_mail : !!(@press_release_per_mail && (@press_release_per_mail.to_s =~ /1|true/))
  end
  alias_method :press_release_per_mail?, :press_release_per_mail
  
  protected
  
  def enrollment_attributes(options={})
    super({
      :press_release_per_email => true, # self.press_release_per_email,
      :press_release_per_fax => self.press_release_per_fax,
      :press_release_per_mail => self.press_release_per_mail
    }.merge(options))
  end
  
  def validate
    super
    if self.newsletter
      self.errors.add(:press_release_per_email, 
        "wenigstens ein Medium muss ausgewählt werden") unless self.press_release_per_fax || self.press_release_per_email || self.press_release_per_mail

      self.errors.add(:press_release_per_fax, 
        "wenigstens ein Medium muss ausgewählt werden") unless self.press_release_per_fax || self.press_release_per_email || self.press_release_per_mail

      self.errors.add(:press_release_per_mail, 
        "wenigstens ein Medium muss ausgewählt werden") unless self.press_release_per_fax || self.press_release_per_email || self.press_release_per_mail
    end
  end
  
end