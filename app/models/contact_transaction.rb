# Takes care of the bookkeeping of all handling the amount of contacts a advocate has bought
# There will be PremiumContactTransaction and PromotionContactTransaction
class ContactTransaction < ActiveRecord::Base
  
  #--- assocations
  belongs_to :person
  
  #--- validations
  validates_presence_of :person

  #--- scopes
  named_scope :active, :conditions => ["(contact_transactions.expires_at >= ? AND contact_transactions.start_at IS NULL) OR (contact_transactions.start_at <= ? AND contact_transactions.expires_at >= ?)", Time.now.utc, Time.now.utc, Time.now.utc]
  named_scope :positive, :conditions => ["contact_transactions.amount > ?", 0]
  named_scope :flat, :conditions => ["contact_transactions.flat = ?", true]
  named_scope :uncleared, :conditions => ["contact_transactions.cleared_at IS NULL"]
  named_scope :cleared, :conditions => ["contact_transactions.cleared_at IS NOT NULL"]
  named_scope :within, lambda {|from, to| {:conditions => ["contact_transactions.created_at >= ? AND contact_transactions.created_at <= ?", from.to_time, to.to_time]}} 
  
  #--- callbacks
  after_create :update_contacts_count
  after_update :update_contacts_count
  after_destroy :update_contacts_count

  #--- class methods
  class << self
    
    def contacts_count_column_name
      raise "Must be implemented in subclass, e.g. PromotionContactTransaction"
    end
    
    def contact_transactions_association_name
      raise "Must be implemented in subclass, e.g. PromotionContactTransaction"
    end
    
  end
  
  #--- instance methods
  
  protected

  def contacts_count_column_name
    self.class.contacts_count_column_name
  end

  def contact_transactions_association_name
    self.class.contact_transactions_association_name
  end
  
  # update members count cache for person
  def update_contacts_count
    if self.person && self.person.class.columns.to_a.map {|a| a.name.to_sym}.include?(self.contacts_count_column_name)
      self.person.class.transaction do 
        self.person.lock!
        contact_amount = self.person.send(self.contact_transactions_association_name).sum(:amount,
          :conditions => ["(contact_transactions.expires_at >= ? AND contact_transactions.start_at IS NULL) OR (contact_transactions.start_at <= ? AND contact_transactions.expires_at >= ?)", Time.now.utc, Time.now.utc, Time.now.utc])
        self.person.update_attribute(self.contacts_count_column_name, contact_amount)
      end
    end
  end
  
end
