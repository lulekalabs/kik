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
# Superclass for all payment transaction. Each purchase, authorization, etc. attempt
# will result in a new sublcass payment instance
class Payment < ActiveRecord::Base

  #--- associations
  belongs_to :payable, :polymorphic => true
  acts_as_list :scope => 'payable_id=#{quote_value(payable_id)} AND payable_type=#{quote_value(payable_type)}'

  #--- mixins
  money :amount, :cents => :cents, :currency => :currency

  #--- class methods
  
  # determines which payment class to use based on the payment object passed.
  # overriden this if other payment types must be supported, like bank
  # transfer, etc.
  # 
  # e.g. Payment.class_for(ActiveMerchant::Billing::CreditCard.new(...))
  #   returns CreditCardPayment class
  def self.class_for(payment_object)
    CreditCardPayment
  end
  
  def self.content_column_names
    content_columns.map(&:name) - %w(payable_type payable_id kind reference message action params test cents currency lock_version position type uuid created_at updated_at success)
  end

  #--- instance methods
  
  # override in sublcass
  # infers payment
  def payment_type
    :payment
  end
  
  # Used to display payment type in views
  # e.g. 'Credit Card'
  def payment_type_display
    payment_type.to_s.titleize
  end
  alias_method :payment_method_display, :payment_type_display

  # returns true if the payment transaction was successful
  def success?
    self[:success] || false
  end

  # return only attributes with relevant content
  def content_attributes
    self.attributes.reject {|k,v| !self.content_column_names.include?(k.to_s)}.symbolize_keys
  end
  
  # returns content column name strings 
  def content_column_names
    self.class.content_column_names
  end

  #--- exceptions
  class AuthorizationError < StandardError; end
  
end