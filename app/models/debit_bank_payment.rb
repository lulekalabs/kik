# This class handles all payments using debit from a bank account
class DebitBankPayment < Payment
  #--- accessors
  cattr_accessor :test
  @@test = false
  
  attr_accessor :account
  serialize :params

  #--- class methods
  class << self

    def purchase(amount, payment_object, options = {})
      payment = new(:account => payment_object)
      payment.process('purchase', amount, options) do |paygate|
        bank_account = Paygate::BankAccount.new(payment.bank_account_number, payment.bank_routing_number, 
          payment.bank_name, payment.bank_account_owner_name)
        
        payable = options[:payable]  
        payable_id = payable.number
        payable_description = payable.line_items.map(&:sellable).map(&:name).compact.first

        paygate.debit(amount, bank_account, 
          {:description_line_1 => payable_description ? "#{Project.name} #{payable_description}" : Project.name, 
            :description_line_2 => "Referenz-Nr.: #{payable_id}"})
      end
    end

    # here only used to setup recurring order
    def recurring(amount, payment_object, options = {})
      payment = new(:account => payment_object)
      payment.process('recurring', amount, options)
    end

  end
  
  #--- instance methods

  def process(action, amount = nil, options={})
    options.symbolize_keys!
    self.amount = amount
    self.action = action
    self.bank_account_owner_name = account.bank_account_owner_name || options[:bank_account_owner_name]
    self.bank_account_number = account.bank_account_number || options[:bank_account_number]
    self.bank_routing_number = account.bank_routing_number || options[:bank_routing_number]
    self.bank_name = account.bank_name || options[:bank_name]
    self.bank_location = account.bank_location || options[:bank_location]
    self.reference = self.uuid
    self.success = false
    if action == "recurring"
      self.interval_length = account.interval_length || options[:interval] ? options[:interval][:length] : 1
      self.interval_unit = account.interval_unit || options[:interval] ? options[:interval][:unit].to_s : "month"
      self.duration_start_date = account.duration_start_date || options[:duration] ? options[:duration][:start_date] : Date.today
      self.duration_occurrences = account.duration_occurrences || options[:duration] ? options[:duration][:occurrences] : 1
      self.success = true
    elsif action == "purchase"
      begin
        response = yield Paygate
        self.success   = response.success?
        self.reference = response.authorization
        self.message   = response.message
        self.params    = response.params
        self.test      = response.test?
      rescue Paygate::PaygateError => e
        self.success   = false
        self.reference = nil
        self.message   = e.message
        self.params    = {}
        self.test      = Paygate.test?
      end
    end
    self
  end
  
  # override in subclass
  def payment_type
    :debit_bank
  end
  
  def obfuscated_bank_account_number
    len = bank_account_number.to_s.length
    if len > 4
      self.bank_account_number[0, len - 4].ljust(len, "X")
    else
      self.bank_account_number
    end
  end
  
  protected
  
  def after_initialize
    self[:uuid] = Project.generate_random_uuid
  end
  
end