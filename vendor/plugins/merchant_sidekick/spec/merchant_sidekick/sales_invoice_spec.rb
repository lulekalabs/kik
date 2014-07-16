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
require File.dirname(__FILE__) + '/../spec_helper'

describe SalesInvoice do
  fixtures :addresses, :product_dummies, :user_dummies

  before(:each) do
    # invoice
    @invoice = SalesInvoice.new(
      :net_amount => Money.new(2995, 'USD'),
      :tax_rate => 0, # obsolete
      :tax_amount => Money.new(0, 'USD'),
      :gross_amount => Money.new(2995, 'USD'),
      :buyer => user_dummies(:sam),
      :seller => user_dummies(:sally)
    )
    @invoice.should_not be_nil

    # addresses
    @invoice.build_origin_address(addresses(:sally_billing).content_attributes)
    @invoice.build_billing_address(addresses(:sam_billing).content_attributes)
    @invoice.build_shipping_address(addresses(:sam_shipping).content_attributes)

    # line items and add
    @line_item = LineItem.new(
      :order => nil,
      :invoice => @invoice,
      :sellable => product_dummies(:widget),
      :tax_rate => 0
    )
    @line_item.should_not be_nil
    @invoice.line_items.push(@line_item)
    
    # credit card
    @credit_card = valid_credit_card
  end
  
  it "should cash" do
    payment = nil
    lambda { payment = @invoice.cash("success@test.tst") }.should change(Payment, :count).by(1)
    payment.should be_success
    payment.position.should == 1
    @invoice.current_state.should == :paid
  end
  
  it "should not cash" do
    payment = nil
    lambda { payment = @invoice.cash("error@error.tst") }.should change(Payment, :count).by(1)
    payment.should_not be_success
    payment.position.should == 1
    @invoice.current_state.should == :payment_declined
  end
  
end
