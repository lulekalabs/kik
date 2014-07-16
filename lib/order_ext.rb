# Enhances the order from merchant_sidekick with callback from the state 
# machine. This will enable us to add notifiers and other stuff to intefere
# with orders.
class Order < ActiveRecord::Base

  attr_accessor :review
  attr_accessor :edit
  attr_accessor :preferred_payment_method

  attr_accessor :bank_account_owner_name
  attr_accessor :bank_account_number
  attr_accessor :bank_routing_number
  attr_accessor :bank_name
  attr_accessor :bank_location
  attr_accessor :paypal_account

  #--- validations
  validates_acceptance_of :auto_debit, :if => Proc.new {|o| o.debit?}
  validates_presence_of :preferred_billing_method, :preferred_payment_method, 
    :on => :create
  validates_presence_of :bank_account_owner_name, :bank_account_number, :bank_routing_number, :bank_name, :bank_location,
    :on => :create, :if => :debit?
  validates_format_of :bank_account_number, :with => /^[0-9]*$/i, :message => I18n.t("activerecord.errors.messages.bank_account_number_format"),
    :if => :debit?
  validates_format_of :bank_routing_number, :with => /^[0-9]{8}$/i, :message => I18n.t("activerecord.errors.messages.bank_routing_number_format"),
    :if => :debit?
  validates_presence_of :paypal_account,
    :on => :create, :if => Proc.new {|o| o.preferred_payment_method == "paypal"}
  validates_email_format_of :paypal_account, 
    :on => :create, :if => Proc.new {|o| o.preferred_payment_method == "paypal"}

  #--- scope
  named_scope :recurring, :conditions => ["orders.status IN (?) AND payments.action = ?", ['pending'], "recurring"], :include => :payments
  named_scope :with_invoice_payment, :conditions => ["payments.type = ?", 'InvoicePayment'], :include => :payments
  named_scope :sufficient_occurrances, :conditions => ["payments.duration_occurrences > ?", 0], :include => :payments
  named_scope :with_debit_bank_payment, :conditions => ["payments.type = ?", 'DebitBankPayment'], :include => :payments
  named_scope :with_paypal_payment, :conditions => ["payments.type = ?", 'PaypalPayment'], :include => :payments
  named_scope :unbilled, :conditions => ["invoices.status IN (?)", ["authorized", "paid"]], :include => :purchase_invoices
  named_scope :due, lambda {|date| date ? {:conditions => ["orders.billing_due_on <= ?", date]} : {:conditions => ["orders.billing_due_on <= ?", Date.today]}}

  #--- callbacks

  #--- state transition callbacks

  def enter_pending
    # next payment due date for recurring orders
    if !self.payments.recurring.empty?
      self.billing_due_on = self.service_period_end_on + 1.day
    end
  end

  def after_pending
    OrderMailer.deliver_confirmation(self)
    OrderMailer.deliver_notify(self)

    # add contacts to buyer's account
    self.line_item_products.each do |product|
      if product.is_subscription?
        transaction = self.buyer.premium_contact_transactions.create(
          :amount => product.contacts || 0, :order_id => self.id, :flat => product.has_unlimited_contacts?,
            :flex => product.is_flex?, :expires_at => self.service_period_end_on.to_time.utc, 
              :start_at => self.service_period_start_on.to_time.utc)
      end
    end
  end
  
  def enter_canceled
    self.canceled_at = Time.now.utc
    self.billing_due_on = nil
  end

  def after_canceled
    OrderMailer.deliver_canceled(self)

    #--- remove all contacts of buyer's account related to this order or invoice
    self.buyer.premium_contact_transactions.find(:all, :conditions => ["contact_transactions.order_id = ? OR contact_transactions.invoice_id IN (?)", self.id, self.purchase_invoices.map(&:id)]).each do |ct|
      ct.update_attributes({:expires_at => Time.now.utc - 1.minute})
    end
  end
  
  #--- class methods
  class << self

    def find_by_id(id_or_number, options={})
      find(:first, {:conditions => ["orders.id = ? OR (orders.id <> ? AND orders.number LIKE ?)", 
        id_or_number, id_or_number, "#{id_or_number}"]}.merge_finder_options(options))
    end
    alias_method :find_by_id_or_number, :find_by_id

  end
  
  #--- instance methods
  
  def to_param
    self.number
  end
  
  # formats the order number in 6 groups, e.g.
  # a4-1793f7-6125f9-032a10-415705-b20a66 
  def number_with_formatting
    if /^(.*)(.{6})(.{6})(.{6})(.{6})(.{6})/i.match(number_without_formatting)
      "#{$1}-#{$2}-#{$3}-#{$4}-#{$5}-#{$6}"
    else
      number_without_formatting
    end
  end
  alias_method_chain :number, :formatting
  
  # e.g. "000001082011" for 1st in Oct 2011
  def short_number
    self.new_record? ? self.number : "#{self.id.to_s.rjust(6, "0")}#{I18n.l(self.created_at, :format => "%m%Y")}"
  end
  
  # Array of products purchased part of this order
  def line_item_products
    self.line_items.map(&:sellable).map {|s| s.respond_to?(:product) ? s.product : s}.compact.reject {|p| !p.is_a?(Product)}
  end

  # Array of products purchased part of this order
  def line_item_product_subscriptions
    self.line_item_products.select(&:subscription?)
  end

  # returns line items that only are product subscription
  def line_items_only_product_subscriptions
    self.line_items.select {|li| li.product.is_subscription?}
  end

  # returns line items that only are product subscription
  def line_items_only_paper_bills
    self.line_items.select {|li| li.product.is_paper_bill?}
  end

  # returns line items that are not shipping line items
  def line_items_without_shipping
    self.line_items.reject {|r| r.sellable.is_a?(ShippingCarrierRateItem) || r.sellable.product.is_a?(ShippingCarrierRateItem)}
  end

  # returns line items that are not shipping line items
  def line_items_only_shipping
    self.line_items.select {|r| r.sellable.is_a?(ShippingCarrierRateItem) || r.sellable.product.is_a?(ShippingCarrierRateItem)}
  end

  # is this a preferred debit payment method
  def debit?
    self.preferred_payment_method.to_s =~ /^debit/
  end

  # is this a invoice payment method
  def invoice?
    self.preferred_payment_method.to_s =~ /^invoice/
  end

  # order not in edit mode?
  def review?
    !!@review
  end
  
  # creates clear text of preferred_payment_method
  def preferred_payment_method_name
    case self.preferred_payment_method.to_s
    when /debit/ then "Zahlung per Lastschrift"
    when /invoice/ then "Zahlung per Rechnung"
    when /paypal/ then "Zahlung per Paypal"
    end
  end

  def preferred_billing_method_name
    case self.preferred_billing_method.to_s
    when /pdf_and_paper/ then "Versand per E-Mail als PDF + per Post in Papierform"
    when /pdf/ then "Versand per E-Mail als PDF"
    end
  end
  
  def to_s
    "#{self.class.human_name} #{self.short_number} (#{self.number})"
  end
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end
  
  # leistungszeitraum start
  def service_period_start_on(without_invoice=nil)
    pis = self.purchase_invoices.find(:all, 
      :conditions => without_invoice && !without_invoice.new_record? ? ["invoices.id <> ?", without_invoice.id] : nil,
        :order => "invoices.id ASC")
    if pis.empty?
      if (payments = self.payments.recurring.find(:all, :order => "payments.id ASC")).empty?
        self.created_at.to_date
      else
        payments.last.duration_start_date
      end
    else
      pis.last.service_period_start_on
    end
  end

  # leistungszeitraum ende
  def service_period_end_on(without_invoice=nil)
    pis = self.purchase_invoices.find(:all, 
      :conditions => without_invoice && !without_invoice.new_record? ? ["invoices.id <> ?", without_invoice.id] : nil,
        :order => "invoices.id ASC")
    if pis.empty?
      if (payments = self.payments.recurring.find(:all, :order => "payments.id ASC")).empty?
        (self.created_at + Project.default_recurring_options[:interval][:length].to_i.send(Project.default_recurring_options[:interval][:unit] || :month) - 1.day).to_date
      else
        payment = payments.last
        payment.duration_start_date + payment.interval_length.to_i.send(payment.interval_unit || :month) - 1.day
      end
    else
      pis.last.service_period_end_on
    end
  end
  
  # true if this order is recurring
  def recurring?
    self.pending? && !self.payments.recurring.empty?
  end
  
  #--- for active scaffold
  class Buyer < ActiveRecord::Base
  end
  
  class Seller < ActiveRecord::Base
  end
  
end

