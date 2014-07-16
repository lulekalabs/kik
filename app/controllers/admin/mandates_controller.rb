class Admin::MandatesController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :mandate do |config|
    #--- columns
    standard_columns = [
      :id,
      :client_id,
      :advocate_id,
      :kase_id,
      :response_id,
      :type,
      :action,
      :status,
      :created_at,
      :updated_at,
      :accepted_at,
      :declined_at
    ]
    crud_columns = [
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:type, :advocate, :client, :kase, :created_at, :accepted_at, :declined_at, :status]
    
    #--- scaffold actions
    config.actions.exclude :create
    config.actions.exclude :update
    config.actions.exclude :show
    
    config.label = "Erhaltene und Vergebene Mandate"

    # exclude in article
    config.subform.columns.exclude :kase_id
    
  end 
  
  protected
  
end
