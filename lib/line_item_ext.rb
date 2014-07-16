# extends Merchant Sidekik line item
class LineItem < ActiveRecord::Base
  
  #--- instance methods
  
  # returns the line items associated product no matter if a cart line item is the sellable or the product directly
  def product
    if self.sellable && self.sellable.is_a?(Product)
      self.sellable
    elsif self.sellable && self.sellable.respond_to?(:product)
      self.sellable.product
    end
  end

end
