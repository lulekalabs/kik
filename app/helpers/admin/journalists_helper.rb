module Admin::JournalistsHelper
  
  def address_show_column(record)
    record.business_address.to_s
  end
  
end
