# Bookkeeping of all paid contacts
class PremiumContactTransaction < ContactTransaction

  #--- assosciations
  belongs_to :order
  belongs_to :invoice
  
  #--- class methods
  class << self
    
    def contacts_count_column_name
      :premium_contacts_count
    end
    
    def contact_transactions_association_name
      :premium_contact_transactions
    end
    
  end
  
  #--- instance methods

  def expired?
    self.expires_at ? Time.now.utc > self.expires_at : false
  end

  # associated product that led to this transaction
  def active_product
    if !expired? 
      if self.invoice && self.invoice.paid?
        product = self.invoice.line_item_products.select(&:is_subscription?).first
        return product if product
      elsif self.order && self.order.recurring?
        product = self.order.line_item_products.select(&:is_subscription?).first
        return product if product
      end
    end
  end
  
end