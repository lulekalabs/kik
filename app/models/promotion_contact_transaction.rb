class PromotionContactTransaction < ContactTransaction

  #--- scopes
  named_scope :active, :conditions => ["contact_transactions.expires_at IS NULL OR contact_transactions.expires_at >= ?", 
    Time.now]

  #--- class methods
  class << self
    
    def contacts_count_column_name
      :promotion_contacts_count
    end
    
    def contact_transactions_association_name
      :promotion_contact_transactions
    end
    
  end
end