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

describe Order do
  fixtures :orders, :user_dummies, :addresses
  
  it "should have line_items" do
    lambda { Order.new.line_items.first }.should_not raise_error
  end
  
  it "should have an amount" do
    orders(:sams_widget).net_amount.should == Money.new(2995)
    orders(:sams_widget).tax_amount.should == Money.new(0)
    orders(:sams_widget).gross_amount.should == Money.new(2995)
    o = orders(:sams_widget)
  end
  
  it "should have billing, shipping and origin address" do
    lambda { orders(:paid).billing_address.should_not be_nil }.should_not raise_error
    lambda { orders(:paid).shipping_address.should_not be_nil }.should_not raise_error
    lambda { orders(:paid).origin_address.should_not be_nil }.should_not raise_error
  end
end

describe "A new order" do
  fixtures :product_dummies
  
  def create_order
    Order.create :line_items => [LineItem.new(:sellable => product_dummies(:widget)), LineItem.new(:sellable => product_dummies(:knob))]
  end
  
  it "amount should equal sum of sellables price" do
    create_order.net_amount.should == [product_dummies(:widget), product_dummies(:knob)].inject(0.to_money) {|sum,p| sum + p.price }
  end
end

describe "A new order with purchases" do
  fixtures :user_dummies, :product_dummies, :addresses
  
  before(:each) do
    @user = user_dummies(:sam)
    @user.create_billing_address(addresses(:sam_billing).content_attributes)
    @user.create_shipping_address(addresses(:sam_shipping).content_attributes)

    @order = @user.purchase product_dummies(:widget)
  end
  
  it "should initialize but not save the order" do
    @order.should be_new_record
  end

  it "should evaluate after pushing a new item" do
    @order.gross_total.to_s.should == '29.95'
    lambda { @order.push(product_dummies(:knob)) }.should change(@order, :items_count).by(1)
    @order.gross_total.to_s.should == '33.94'
    @order.should be_new_record
  end
  
end
