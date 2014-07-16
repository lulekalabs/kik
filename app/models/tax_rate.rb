# Determines the tax rate for each order line item
class TaxRate

  #--- class methods
  class << self
    
    # find tax rate depending on orgin and destination
    def find_tax_rate(options={})
      result = 19.0
      if sellable = options[:sellable]
        if sellable.is_a?(Product)
          result = sellable.tax_rate
        elsif sellable.respond_to?(:product)
          result = sellable.product.tax_rate
        end
      end
      result
    end
    
  end
  
end
