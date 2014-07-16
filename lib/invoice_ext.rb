# Enhances the invoice from merchant_sidekick
class Invoice < ActiveRecord::Base

  attr_accessor :paper_bill

  #--- associations
  acts_as_list :column => "month_number",
    :scope => 'YEAR(invoices.created_at) = YEAR(NOW()) AND MONTH(invoices.created_at) = MONTH(NOW())'

  #--- scopes
  named_scope :created_chronological_descending, :order => "invoices.created_at DESC"
  named_scope :created_chronological_ascending, :order => "invoices.created_at ASC"
  named_scope :paid_chronological_descending, :order => "invoices.paid_at DESC"
  named_scope :paid_chronological_ascending, :order => "invoices.paid_at ASC"
  named_scope :paid, :conditions => ["invoices.status IN (?)", ["paid"]]

  #--- callbacks
  after_create :update_service_periods

  #--- class methods

  class << self

    def find_by_id(id_or_number, options={})
      find(:first, {:conditions => ["invoices.id = ? OR (invoices.id <> ? AND invoices.number LIKE ?)", 
        id_or_number, id_or_number, "#{id_or_number}"]}.merge_finder_options(options))
    end
    alias_method :find_by_id_or_number, :find_by_id

  end

  #--- instance methods

  def enter_authorized
    self.authorized_at = Time.now.utc
  end

  def after_authorized
    # first update billing cycle
    self.update_billing_cycle

    # generate pdf and sign using signaturportal.de
    Delayed::Job.enqueue GenerateAndSignInvoiceJob.new(self.id)
    
    # update billing date
    self.update_attributes({:billing_date_on => self.service_period_start_on + 1.day}) if self.service_period_start_on
  end

  def enter_paid
    self.paid_at = Time.now.utc
  end

  def after_paid
    # first update billing cycle if necessary
    self.update_billing_cycle unless self.authorized_at

    # generate pdf and sign using signaturportal.de
    Delayed::Job.enqueue GenerateAndSignInvoiceJob.new(self.id)

    unless self.purchase_order.canceled?
      # add contacts to buyer's account
      self.line_item_products.each do |product|
        if product.is_subscription? && product.has_contacts?
          nbp = self.next_service_billing_period
          transaction = self.buyer.premium_contact_transactions.create(
            :amount => product.contacts || 0, :invoice_id => self.id, :flat => product.has_unlimited_contacts?,
              :flex => product.is_flex?, :expires_at => nbp.last.to_time.utc,
                :start_at => nbp.first.to_time.utc)
        end
      end
    
      # update billing date
      if !self.billing_date_on && self.service_period_start_on
        self.update_attributes({:billing_date_on => self.service_period_start_on + 1.day})
      end
    end
  end

  def enter_capture
    self.paid_at = Time.now.utc
  end
  
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

  # e.g. 2011
  def short_number_year
    "#{I18n.l(self.created_at, :format => "%Y")}"
  end

  # e.g. January
  def short_number_month
    "#{I18n.l(self.created_at, :format => "%B")}"
  end
  
  # in case we need one, e.g. "Rechnung-000001082011.pdf"
  # Note: this is 
  def human_pdf_filename
    "Rechnung-#{self.short_number}.pdf"
  end

  # E.g. "2011.01.3"
  def human_number
    if new_record?
      # this is unsave, we would have to lock the record
      nm = self.class.count(:conditions => "MONTH(invoices.created_at) = MONTH(NOW()) AND YEAR(invoices.created_at) = YEAR(NOW())")
      "#{I18n.l(self.created_at, :format => "%Y")}.#{I18n.l(self.created_at, :format => "%m")}.#{nm + 1}"
    else
      "#{I18n.l(self.created_at, :format => "%Y")}.#{I18n.l(self.created_at, :format => "%m")}.#{self.month_number}"
    end
  end

  # leistungszeitraum start
  def service_period_start_on
    if self[:service_period_start_on]
      self[:service_period_start_on]
    else
      pis = self.purchase_order.purchase_invoices.find(:all, :conditions => ["invoices.id <> ?", self.id], 
        :order => "invoices.id ASC")
      payments = self.purchase_order.payments.recurring.find(:all, :order => "payments.id ASC")
      if pis.empty?
        if payments.empty?
          (self.paid_at || self.created_at).to_date
        else
          self.purchase_order.service_period_start_on(self)
        end
      else
        if payments.empty?
          Date.today
        else
          pis.last.service_period_end_on + 1.day
        end
      end
    end
  end

  # leistungszeitraum end
  def service_period_end_on
    if self[:service_period_end_on]
      self[:service_period_end_on]
    else
      pis = self.purchase_order.purchase_invoices.find(:all, :conditions => ["invoices.id <> ?", self.id], 
        :order => "invoices.id ASC")
      payments = self.purchase_order.payments.recurring.find(:all, :order => "payments.id ASC")
      if pis.empty?
        if payments.empty?
          ((self.paid_at || self.created_at) + 1.month - 1.day).to_date
        else
          payment = payments.last
          self.purchase_order.service_period_end_on(self) # + 1.day + payment.interval_length.to_i.send(payment.interval_unit || :month) - 1.day
        end
      else
        if payments.empty?
          ((self.paid_at || self.created_at) + 1.month - 1.day).to_date
        else
          payment = payments.last
          pis.last.service_period_end_on + 1.day + payment.interval_length.to_i.send(payment.interval_unit || :month) - 1.day
        end
      end
    end
  end
  
  def to_s
    "#{self.class.human_name} #{self.short_number} (#{self.number})"
  end
  
  # returns "geschlossen" etc. for current_state
  def human_current_state_name
    self.class.human_attribute_name("status_#{self.current_state}")
  end
  
  # only if we are an invoice with subscibable products
  def update_service_periods
    if self.purchase_order
      payments = self.purchase_order.payments.recurring.find(:all, :order => "payments.id ASC")
      unless payments.empty?
        self.update_attributes(:service_period_start_on => self.service_period_start_on,
          :service_period_end_on => self.service_period_end_on)
      end
    end
  end
  
  # Array of products purchased part of this order
  def line_item_products
    self.line_items.map(&:sellable).map {|s| s.respond_to?(:product) ? s.product : s}.compact.reject {|p| !p.is_a?(Product)}
  end

  # Array of products purchased part of this order
  def line_item_product_subscriptions
    self.line_item_products.select(&:subscription?)
  end

  # billing due is end of next billing period + 1 day
  def update_billing_cycle
    if recurring_payment = self.purchase_order.payments.recurring.first
      recurring_payment = recurring_payment.decrement(:duration_occurrences)
      # udpate the billing period of the order only 
      if recurring_payment.duration_occurrences > 0
        nbp = self.next_service_billing_period
        if nbp && (!self.purchase_order.billing_due_on || nbp.include?(self.purchase_order.billing_due_on))
          self.purchase_order.billing_due_on = nbp.last + 1.day
          self.purchase_order.save(false)
        end
      else
        self.purchase_order.cancel!
      end
    end
  end

  # e.g. Feb 26..Mar 25
  def service_billing_period
    (self.service_period_start_on..self.service_period_end_on)
  end
  
  # e.g. Mar 26..Apr 25
  def next_service_billing_period
    if self.purchase_order && self.purchase_order.recurring? && self.purchase_order.pending?
      payment = self.purchase_order.payments.recurring.find(:all, :order => "payments.id ASC").last
      (self.service_period_end_on + 1.day)..(self.service_period_end_on + (payment.interval_length.to_i.send(payment.interval_unit || :month)))
    end
  end
  
  #--- for active scaffold
  class Buyer < ActiveRecord::Base
  end
  
  class Seller < ActiveRecord::Base
  end
  
end
