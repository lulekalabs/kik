# Manages the produts in the admin
class Admin::ProductsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :product do |config|
    #--- columns
    standard_columns = [
      :id,
      :sku,
      :name,
      :description,
      :cents,
      :currency,
      :contacts,
      :subscription,
      :active,
      :term_in_days,
      :tax_rate
    ]
    crud_columns = [
      :name,
      :description,
      :cents,
      :tax_rate,
      :contacts,
      :term_in_days,
      :subscription,
      :active
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:sku, :name, :cents, :tax_rate, :contacts, :term_in_days, :subscription, :active]

    config.label = "Produkte"
    
  end 
  
  protected
  
end
