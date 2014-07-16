# Bookkeeping of all contacts that were used during a subscription period on top of available contacts
class OverdrawnContactTransaction < ContactTransaction

  #--- class methods
  class << self
    
    def contacts_count_column_name
      :overdrawn_contacts_count
    end
    
    def contact_transactions_association_name
      :overdrawn_contact_transactions
    end
    
  end
  
end