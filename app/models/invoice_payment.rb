# This class handles all payments using inoicing
class InvoicePayment < Payment
  #--- accessors
  attr_accessor :account
  serialize :params

  #--- class methods
  class << self

    def authorize(amount, bank_account, options = {})
      payment = new(:account => bank_account)
      payment.process('authorization', amount, options)
    end
    
    def capture(amount, authorization, options = {})
      payment = new(:account => nil) 
      payment.process('capture', amount, options)
    end

    def purchase(amount, bank_account, options = {})
      payment = new(:account => bank_account)
      payment.process('purchase', amount, options)
    end
    
    def recurring(amount, bank_account, options = {})
      payment = new(:account => bank_account)
      payment.process('recurring', amount, options)
    end

  end
  
  #--- instance methods

  def process(action, amount = nil, options={})
    options.symbolize_keys!
    self.amount = amount
    self.action = action
    if action == "recurring"
      self.interval_length = account.interval_length || options[:interval] ? options[:interval][:length] : 1
      self.interval_unit = account.interval_unit || options[:interval] ? options[:interval][:unit].to_s : "month"
      self.duration_start_date = account.duration_start_date || options[:duration] ? options[:duration][:start_date] : Date.today
      self.duration_occurrences = account.duration_occurrences || options[:duration] ? options[:duration][:occurrences] : 1
    end
    self.success = true
    self.reference = self.uuid
    self
  end
  
  # override in subclass
  def payment_type
    :invoice
  end
  
  protected
  
  def after_initialize
    self[:uuid] = Project.generate_random_uuid
  end
  
end