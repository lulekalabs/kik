class Admin::LineItemsController < Admin::AdminApplicationController
  
  #--- active scaffold
  active_scaffold :line_items do |config|
    #--- columns
    standard_columns = [
      :id,
      :order_id,
      :invoice_id,
      :sellable_id,
      :sellable_type,
      :net_amount,
      :tax_amount,
      :gross_amount,
      :tax_rate
    ]
    crud_columns = [
      :sellable_id,
      :tax_rate,
      :net_amount,
      :tax_amount,
      :gross_amount
    ]
    config.columns = standard_columns
    config.create.columns = []
    config.update.columns = []
    config.show.columns = crud_columns
    config.list.columns = [
      :id,
      :sellable_id,
      :tax_rate,
      :net_amount,
      :tax_amount,
      :gross_amount
    ]
    
    #--- acttions
    config.actions.exclude :create
    config.actions.exclude :delete
    config.actions.exclude :search
    config.actions.exclude :update
    config.actions.exclude :show
    
    config.label = "Bestell-Positionen"
    columns[:id].label = "Position"
    columns[:sellable_id].label = "Artikel"
  end
  
end
