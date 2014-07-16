# Implements the behavior of an Advocate being able to buy a contact and have access to a Client's
# contact information
class Access < ActiveRecord::Base

  #--- assocations
  belongs_to :requestor, :class_name => "Person"
  belongs_to :requestee, :class_name => "Person"
  belongs_to :accessible, :class_name => "Kase"

  #--- validations
  validates_presence_of :requestor_id, :requestee_id, :accessible_id

  #--- callbacks
  before_create :update_requestor_contacts

  #--- instance methods
  
  protected
  
  def validate
    if self.requestor && !self.requestor.can_access?(self.accessible)
      self.errors.add(:requestor, "hat nicht genügend Kontakte auf seinem Konto")
    end
  end
  
  # does the math to deduct from 
  def update_requestor_contacts
    result = false
    if self.requestor && self.requestor.is_a?(Advocate)
      result = self.requestor.decrement_contact
    end
    result
  end
  
end
