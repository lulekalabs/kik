# This class handles all payments using paypal
class PaypalPayment < Payment
  #--- accessors
  attr_accessor :account
  serialize :params

  #--- class methods
  class << self

    def authorize(amount, bank_account, options = {})
      payment = new(:account => bank_account)
      payment.process('authorization', amount, options) do |db|
        db.authorize(amount, :context => options[:payable])
      end
    end
    
    def capture(amount, authorization, options = {})
      payment = new(:account => nil) # get the bank account from somewhere, e.g. options.delete(:buyer).piggy_bank
      payment.process('capture', amount, options) do |db|
        db.capture(amount, authorization, :context => options[:payable])
      end
    end
    
    def purchase(amount, bank_account, options = {})
      payment = new(:account => bank_account)
      payment.process('purchase', amount, options) do |db|
        db.purchase(amount, :context => options[:payable])
      end
    end

    def void(amount, authorization, options = {})
      payment = new(:account => nil) # get the bank account from somewhere, e.g. options.delete(:buyer).piggy_bank
      payment.process('void', amount, options) do |db|
        db.void(authorization, :context => options[:payable])
      end
    end

  end
  
  #--- instance methods

  def process(action, amount = nil, options={})
    options.symbolize_keys!
    self.amount = amount
    self.action = action
    self.paypal_account = options[:paypal_account]
    self.success = true
    self.reference = self.uuid
    self
  end
  
  # override in subclass
  def payment_type
    :paypal
  end
  
  protected
  
  def after_initialize
    self[:uuid] = Project.generate_random_uuid
  end
  
end