class Admin::BarAssociationsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :bar_association do |config|
    #--- columns
    standard_columns = [
      :id,
      :name
    ]
    crud_columns = [
      :name
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:name, :created_at, :updated_at]
    
    config.label = "Rechtsanwaltskammern"
    config.create.label = "Neue Rechtsanwaltskammer"
    config.update.label = "Editiere Rechtsanwaltskammer"
  end 
  
  protected
  
end
