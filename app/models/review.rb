# Collects the recommendations from clients
class Review < ActiveRecord::Base
  include DefaultFields

  #attr_accessor :disqualification
  
  #--- associations
  belongs_to :reviewer, :class_name => "Person"
  belongs_to :reviewee, :class_name => "Person"
  has_many :comments, :as => :commentable, :dependent => :destroy, 
    :class_name => "ReviewComment", :order => "comments.created_at ASC"
  
  #--- validations
  validates_presence_of :search_reason
  validates_presence_of :reviewer, :reviewee
  validates_presence_of :v, :z, :m, :e, :a
  validates_acceptance_of :disqualification

  acts_as_rateable
  
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
    transitions :from => [:closed], :to => :open
  end
  
  #--- scopes
  named_scope :visible, :conditions => ["reviews.status IN (?)", ["open"]]
  named_scope :recommended, :conditions => ["reviews.friend_recommend = ?", true]
  named_scope :created_chronological_descending, :order => "reviews.created_at DESC"
  named_scope :created_chronological_ascending, :order => "reviews.created_at ASC"
  named_scope :opened_chronological_descending, :order => "reviews.opened_at DESC"
  named_scope :opened_chronological_ascending, :order => "reviews.opened_at ASC"
  named_scope :reviewed_by, lambda {|person| person ? {:conditions => ["reviews.reviewer_id = ?", person.id]} : {}}
  
  #--- callbacks
  before_create :do_create, :calculate_grade_point_average
  
  #--- instance variables

  # returns a 8-digit review number, e.g. "0000012"
  def number
    "#{self.id}".rjust(8, "0")
  end

  # returns true if there is no votes on section below the given one
  #
  # E.g. 
  #
  #  @review.sub_section_empty? :v
  #
  def sub_section_empty?(section)
    result = false
    5.times do |index|
      result ||= self.send("#{section}#{index + 1}".to_sym)
    end
    !result
  end

  def sub_section_count(section)
    result = 0
    5.times do |index|
      result += 1 if self.send("#{section}#{index + 1}".to_sym)
    end
    result
  end
    
  # remove rounding errors
  def grade_point_average
    if self[:grade_point_average]
      (self[:grade_point_average] * 100).to_i / 100.to_f
    end
  end
  alias_method :gpa, :grade_point_average
  
  def to_s
    "Bewertung von #{self.reviewee.title_and_name} durch #{self.reviewer.title_and_name}"
  end
  
  # can given person submit a comment?
  def can_comment?(person)
    self.reviewer != person && !commented_by?(person)
  end
  
  # has this been commented by given person before?
  def commented_by?(person)
    !!self.comments.find(:first, :conditions => ["comments.person_id = ?", person.id])
  end
  
  # is the the given person allowed to cast to vote (and rate) the review
  def can_rate?(person)
    person != self.reviewer && person != self.reviewee && !self.rated_by?(person)
  end
  
  # can this user flag this review abusive, etc.
  def can_flag?(person)
    person != self.reviewer && person != self.reviewee
  end
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end
  
  protected
  
  def do_create
  end
  
  def do_preapprove
    self.preapproved_at = Time.now.utc
    ReviewMailer.deliver_activated(self)
    ReviewMailer.deliver_notify(self)
  end
  
  def do_open
    self.opened_at = Time.now.utc
    ReviewMailer.dispatch(:opened_to_reviewer, self)
    ReviewMailer.dispatch(:opened_to_reviewee, self)
  end
  
  def after_open
    if self.reviewee.is_a?(Advocate)
      self.reviewee.update_grade_point_average
    end
  end

  def after_close
    if self.reviewee.is_a?(Advocate)
      self.reviewee.update_grade_point_average
    end
  end

  def do_close
    self.closed_at = Time.now.utc
    ReviewMailer.dispatch(:closed, self)
  end
  
  def calculate_grade_point_average
    weighted_grades = 0.to_f
    # v
    if self.sub_section_empty?(:v)
      weighted_grades +=  ((self.v * 25) / 5.to_f) 
    else
      weighted_grades +=  ((self.v * (50 * 0.25.to_f)) / 5.to_f) 
      5.times do |index|
        weighted_grades +=  ((self.send("v#{index + 1}".to_sym) * (50 / sub_section_count(:v).to_f * 0.25.to_f)) / 5.to_f) if self.send("v#{index + 1}".to_sym)
      end
    end
    # z
    if self.sub_section_empty?(:z)
      weighted_grades += ((self.z * 25) / 5.to_f) 
    else
      weighted_grades +=  ((self.z * (50 * 0.25.to_f)) / 5.to_f)
      5.times do |index|
        weighted_grades +=  ((self.send("z#{index + 1}".to_sym) * (50 / sub_section_count(:z).to_f * 0.25.to_f)) / 5.to_f) if self.send("z#{index + 1}".to_sym)
      end
    end
    # m
    if self.sub_section_empty?(:m)
      weighted_grades += ((self.m * 25) / 5.to_f) 
    else
      weighted_grades +=  ((self.m * (50 * 0.25.to_f)) / 5.to_f)
      5.times do |index|
        weighted_grades +=  ((self.send("m#{index + 1}".to_sym) * (50 / sub_section_count(:m).to_f * 0.25.to_f)) / 5.to_f) if self.send("m#{index + 1}".to_sym)
      end
    end
    # e
    if self.sub_section_empty?(:e)
      weighted_grades += ((self.e * 15) / 5.to_f) 
    else
      weighted_grades += ((self.e * (50 * 0.15.to_f)) / 5.to_f)
      5.times do |index|
        weighted_grades += ((self.send("e#{index + 1}".to_sym) * (50 / sub_section_count(:e).to_f * 0.15.to_f)) / 5.to_f) if self.send("e#{index + 1}".to_sym)
      end
    end
    # a
    if self.sub_section_empty?(:a)
      weighted_grades += ((self.a * 10) / 5.to_f)
    else
      weighted_grades += ((self.a * (50 * 0.10.to_f)) / 5.to_f)
      5.times do |index|
        weighted_grades += ((self.send("a#{index + 1}".to_sym) * (50 / sub_section_count(:a).to_f * 0.10.to_f)) / 5.to_f) if self.send("a#{index + 1}".to_sym)
      end
    end

    gpa = weighted_grades * 5 / 100.to_f
    
    result = self.grade_point_average = (gpa * 100).to_i / 100.to_f
    result
  end

end
