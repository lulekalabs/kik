# Enhances the order from merchant_sidekick with callback from the state 
# machine. This will enable us to add notifiers and other stuff to intefere
# with orders.
class Payment < ActiveRecord::Base
  
  #--- scopes
  named_scope :recurring, :conditions => ["payments.action IN (?)", ["recurring"]]
  
  #--- class methods 
  
  # overrides the class_for to include Piggy Bank payments
  def self.class_for(payment_object)
    raise "payment_object is not of class Payment" unless payment_object.is_a?(Payment)
    payment_object.class
  end
  
  
  #--- instance methods
  
  def to_s
    self.class.human_name
  end
  
end