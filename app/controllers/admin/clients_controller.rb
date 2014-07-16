class Admin::ClientsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :client do |config|
    #--- columns
    standard_columns = [
      :id,
      :type,
      :gender,
      :academic_title_id,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :newsletter,
      :remedy_insured,
      :referral_source,
      :author,
      :title_and_name   
    ]
    crud_columns = [
      :gender,
      :academic_title_id,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :newsletter,
      :remedy_insured,
      :referral_source,
      :publisher
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:title_and_name, :email, :created_at]
    
    #--- actions
    config.actions.exclude :create

    #=== labels
    config.columns[:publisher].form_ui = :checkbox
    config.columns[:publisher].label = "Herausgeber"
    config.columns[:publisher].description = "Vergibt das Recht Artikel freizugeben"
    config.columns[:academic_title_id].label = "Titel"
    config.columns[:title_and_name].label = "Name"
    
    #--- actions
    config.nested.add_link('Mandate', [:mandates])
    
  end  
  
  protected
  
  def conditions_for_collection
    ['people.type IN (?)', ['Client']]
  end
  
end
