#
# Copyright (c) 2007-2011 Juergen Fesslmeier
# 
# Permission is hereby granted, to kann-ich-klagen.de, for this software and associated 
# documentation files (the "Software"). The Software is restricted, including the rights 
# to copy, modify, merge, publish, distribute, sublicense, and/or sell or resell copies
# of the Software, and is not permitted to persons to whom the Software is not furnished 
# to do so.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS 
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Invoices are invoices are invoices that are invoices :-)
class Invoice < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  #--- accessors
  attr_accessor :authorization

  #--- associations
  belongs_to :seller, :polymorphic => true  # originator
  belongs_to :buyer, :polymorphic => true  # buyer or seller
  has_many   :line_items
  belongs_to :order
  has_many   :payments, :as => :payable, :dependent => :destroy
  
  #--- mixins
  money :net_amount,   :cents => :net_cents,   :currency => :currency         # net amount
  money :tax_amount,   :cents => :tax_cents,   :currency => :currency         # tax amount
  money :gross_amount, :cents => :gross_cents, :currency => :currency         # gross amount

  acts_as_addressable :origin, :billing, :shipping, :has_one => true
  acts_as_state_machine :initial => :pending, :column => 'status'

  #--- states
  state :pending, :enter => :enter_pending, :after => :after_pending
  state :authorized, :enter => :enter_authorized, :after => :after_authorized
  state :paid, :enter => :enter_paid, :after => :after_paid
  state :voided, :enter => :enter_voided, :after => :after_voided
  state :refunded, :enter => :enter_refunded, :after => :after_refunded
  state :payment_declined, :enter => :enter_payment_declined, :after => :after_payment_declined

  #--- events
  event :payment_paid do
    transitions :from => :pending, :to => :paid, :guard => :guard_payment_paid_from_pending
  end
  
  event :payment_authorized do
    transitions :from => :pending, :to => :authorized, :guard => :guard_payment_authorized_from_pending
    transitions :from => :payment_declined, :to => :authorized, :guard => :guard_payment_authorized_from_payment_declined
  end

  event :payment_captured do
    transitions :from => :authorized, :to => :paid, :guard => :guard_payment_captured_from_authorized
  end

  event :payment_voided do
    transitions :from => :authorized, :to => :voided, :guard => :guard_payment_voided_from_authorized
  end

  event :payment_refunded do
    transitions :from => :paid, :to => :refunded, :guard => :guard_payment_refunded_from_paid
  end

  event :transaction_declined do
    transitions :from => :pending, :to => :payment_declined, :guard => :guard_transaction_declined_from_pending
    transitions :from => :payment_declined, :to => :payment_declined, :guard => :guard_transaction_declined_from_payment_declined
    transitions :from => :authorized, :to => :authorized, :guard => :guard_transaction_declined_from_authorized
  end
  
  #--- scopes
  named_scope :paid, :conditions => ["invoices.status IN (?)", ['paid']]
  
  #--- callbacks
  before_save :number
  
  # state transition callbacks
  def enter_pending; end
  def enter_authorized; end
  def enter_paid; end
  def enter_voided; end
  def enter_refunded; end
  def enter_payment_declined; end

  def after_pending; end
  def after_authorized; end
  def after_paid; end
  def after_voided; end
  def after_refunded; end
  def after_payment_declined; end
  
  # event guard callbacks
  def guard_transaction_declined_from_authorized; true; end
  def guard_transaction_declined_from_payment_declined; true; end
  def guard_transaction_declined_from_pending; true; end
  def guard_payment_refunded_from_paid; true; end
  def guard_payment_voided_from_authorized; true; end
  def guard_payment_captured_from_authorized; true; end
  def guard_payment_authorized_from_payment_declined; true; end
  def guard_payment_authorized_from_pending; true; end
  def guard_payment_paid_from_pending; true; end
  
  #--- instance methods

  def number
    self[:number] ||= Order.generate_unique_id
  end

  # returns a hash of additional merchant data passed to authorize
  # you want to pass in the following additional options
  #
  #   :ip => ip address of the buyer
  #   
  def payment_options(options={})
    {}.merge(options)
  end
  
  # From payments, returns :credit_card, etc.
  def payment_type
    payments.first.payment_type if payments
  end
  alias_method :payment_method, :payment_type

  # Human readable payment type
  def payment_type_display
    self.payment_type.to_s.titleize
  end
  alias_method :payment_method_display, :payment_type_display

  # Net total amount
  def net_total 
    self.net_amount ||= line_items.inject(Money.new(0, self.currency || Money.default_currency)) {|sum,l| sum + l.net_amount }
  end
  
  # Calculates tax and sets the tax_amount attribute
  # It adds tax_amount across all line_items
  def tax_total
    self.tax_amount = line_items.inject(Money.new(0, self.currency || Money.default_currency)) {|sum,l| sum + l.tax_amount }
    self.tax_rate # calculates average rate, leave for compatibility reasons
    self.tax_amount
  end

  # Since each line_item has it's own tax_rate now, we will calculate
  # the average tax_rate across all line items and store it in the database
  # The attribute tax_rate will not have any relevance in Order/Invoice to 
  # calculate the tax_amount anymore
  def tax_rate
    self[:tax_rate] ||= Float(line_items.inject(0) {|sum, l| sum + l.tax_rate}) / line_items.size
  end
  
  # Gross amount including tax
  def gross_total
    self.gross_amount ||= self.net_total + self.tax_total
  end
  
  # Same as gross_total
  def total
    self.gross_total
  end

  # updates the order and all contained line_items after an address has changed
  # or an order item was added or removed. The order can only be evaluated if the
  # created state is active. The order is saved if it is an existing order. 
  # Returns true if evaluation happend, false if not.
  def evaluate
    result = false
    self.line_items.each(&:evaluate)
    self.calculate
    result = save(false) unless self.new_record?
    result
  end
  
  protected

  # override in subclass
  def purchase_invoice?
    false
  end

  # marks sales invoice, override in subclass
  def sales_invoice?
    false
  end

  def push_payment(a_payment)
    a_payment.payable = self
    self.payments.push(a_payment)
  end

  # Recalculates the order, adding order lines, tax and gross totals
  def calculate
    self.net_amount = nil
    self.tax_amount = nil
    self.gross_amount = nil
    self.tax_rate = nil
    self.total
  end

end
