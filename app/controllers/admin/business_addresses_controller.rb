class Admin::BusinessAddressesController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :business_address do |config|
    #--- columns
    standard_columns = [
      :id,
      :first_name,
      :middle_name,
      :last_name,
      :street,
      :street_number,
      :postal_code,
      :city,
      :company_name,
      :created_at,
      :updated_at
    ]
    crud_columns = [
      :street,
      :street_number,
      :postal_code,
      :city,
      :company_name,
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:first_name, :last_name, :street, :postal_code, :city, :created_at]
    
  end  
  
end
