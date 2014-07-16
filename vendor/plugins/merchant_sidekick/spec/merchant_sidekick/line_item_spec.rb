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

def valid_line_item_attrs(attrs = {})
  {:order_id => 1, :sellable_id => 1, :sellable_type => 'ProductDummy'}.merge(attrs)
end

describe "A LineItem" do
  it "should belong to an order" do
    lambda { LineItem.new.order true }.should_not raise_error
  end

  it "should belong to a sellable model" do
    lambda { LineItem.new.sellable true }.should_not raise_error
  end
end

describe "A new LineItem" do

  it "should set #price when setting #sellable" do
    @sellable = ProductDummy.new(:price => 10.to_money)
    @line_item = LineItem.new(:sellable => @sellable)
    @line_item.amount.should == @sellable.price
  end
  
  it "should set #price to 0 when #sellable doesn't have a price" do
    @sellable = ProductDummy.new()
    @line_item = LineItem.new(:sellable => @sellable)
    @line_item.amount.should == 0.to_money
  end
  
  it "should return sellable when calling #sellable=" do
    @sellable = ProductDummy.new(:title => "Rad New Widget", :price => 10)
    @line_item = LineItem.new
    sellable = @line_item.sellable=(@sellable)
    sellable.should === @sellable
  end
end
