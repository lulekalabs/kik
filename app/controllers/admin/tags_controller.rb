# Manages the administration of tags
class Admin::TagsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :tag do |config|
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
    config.list.columns = [:name]

    config.label = "Stichworte"
    
    config.list.per_page = 10000
    config.list.sorting = [{:name => :asc}]
    
  end 
  
  protected
  
end
