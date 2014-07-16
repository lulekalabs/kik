# Handles the audit trail of a question or a response
class Comment < ActiveRecord::Base
  include DefaultFields
  
  #--- associations
  belongs_to :commentable, :polymorphic => true
  belongs_to :person
  
  #--- validations
  validates_presence_of :person_id, :commentable_id, :commentable_type
  validates_presence_of :message
  validates_length_of :message, :within => 5..1200

  #--- state machine
  acts_as_state_machine :initial => :created, :column => :status
  state :created
  state :open, :enter => :do_open

  event :activate do
    transitions :from => :created, :to => :open
  end

  event :approve do
    transitions :from => :created, :to => :open
  end

  #--- scopes
  named_scope :visible, :conditions => ["comments.status IN (?)", ['open']]
  named_scope :created_chronological_descending, :order => "comments.created_at DESC"
  named_scope :created_chronological_ascending, :order => "comments.created_at ASC"

  #--- instance methods

  # for active scaffold
  def to_s
    "#{self.class.human_name} zu #{self.commentable.to_s}"
  end
  
  def human_name
    if self.commentable.is_a?(Kase) || self.commentable.is_a?(Response)
      "Nachtrag zur #{Kase.human_name}"
    elsif self.commentable.is_a?(Review)
      "Kommentar zur #{Review.human_name}"
    else
      self.class.human_name
    end
  end

  protected
  
  def do_open
    if self.commentable.is_a?(Kase)
      CommentMailer.dispatch(:approved, self)
      
      # deliver update to all responded advocates
      self.commentable.responses.visible.each do |response|
        CommentMailer.dispatch(:updated_response, self, response)
      end
    elsif self.commentable.is_a?(Response)
      # so we are a response ("Bewerbung")
      receiver = if self.person.is_a?(Advocate)
        # mail goes to question owner, as commented by advocate
        self.commentable.kase.person
      elsif self.person.is_a?(Client)
        # mail goes to the response owner, which is the advocate
        self.commentable.person
      end
      CommentMailer.dispatch(:posted, self, receiver) if receiver
    elsif self.commentable.is_a?(Review)
      review = self.commentable
      CommentMailer.dispatch(:posted_reviewer, self, review.reviewer) if review.reviewee == self.person
    end
  end
  
  def after_create
    if self.commentable.is_a?(Kase)
      CommentMailer.deliver_notify(self)
      CommentMailer.dispatch(:approving, self)
    elsif self.commentable.is_a?(Review)
      # CommentMailer.deliver_notify(self)
    end
  end

  # only for ActiveScaffold
  class Commentable < ActiveRecord::Base
  end
  
end
