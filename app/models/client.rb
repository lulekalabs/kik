# i.e. Mandant
class Client < Person

  #--- associations
  has_many :accesses, :foreign_key => :requestee_id, :dependent => :destroy
  has_many :reviews, :foreign_key => :reviewer_id, :dependent => :destroy, :conditions => 'reviews.reviewer_id = #{id}'
  has_many :reviewed_advocates, :through => :reviews, 
    :source => :reviewee, :conditions => ["reviews.status IN (?)", ['open']]
  has_many :unreviewed_advocates, :through => :accesses, :source => :requestor,
    :conditions => '(SELECT (id) FROM reviews WHERE reviews.reviewee_id = accesses.requestor_id AND reviews.reviewer_id = #{id}) IS NULL'
  has_many :mandates, :foreign_key => :client_id, :dependent => :destroy, :conditions => ["mandates.type = ?", "ClientMandate"]
  has_many :given_mandates, :foreign_key => :client_id, :dependent => :destroy, :class_name => "ClientMandate"

  #--- validations
  validates_presence_of :first_name, :last_name

  #--- class methods
  class << self
    
    def enrollment_class
      ClientEnrollment
    end
    
  end
  
  #--- instance methods
  
  # prints either user.login, user.person.name or user.id
  def user_id
    self.name.blank? ? self.user.login : self.title_and_name
  end
  
end