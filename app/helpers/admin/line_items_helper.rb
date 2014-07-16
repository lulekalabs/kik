module Admin::LineItemsHelper

  def sellable_id_column(record)
    case record.sellable.class.name
    when /Product/ then link_to(record.sellable.name, admin_product_path(record.sellable))
    when /CartLineItem/ then link_to(record.sellable.name, admin_product_path(record.sellable.product))
    when /ShippingCarrierRateItem/ then link_to(record.sellable.name, '')
    end
  end

  def tax_rate_column(record)
    "#{record.tax_rate}%" 
  end
  
  def net_amount_column(record)
    record.net_amount.format
  end

  def tax_amount_column(record)
    record.tax_amount.format
  end

  def gross_amount_column(record)
    record.gross_amount.format
  end
  
  def success_column(record)
    record.type
  end

end
