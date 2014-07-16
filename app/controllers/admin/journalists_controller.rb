class Admin::JournalistsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :journalist do |config|
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
      :fax_number,
      :newsletter,
      :press_release_per_email,
      :press_release_per_fax,
      :press_release_per_mail,
      :publisher,
      :address
    ]
    crud_columns = [
      :gender,
      :academic_title_id,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :fax_number,
      :newsletter,
      :press_release_per_email,
      :press_release_per_fax,
      :press_release_per_mail,
      :address
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:last_name, :first_name, :gender, :academic_title_id, :email, :type, :created_at]
    
    #--- actions
    config.actions.exclude :create
    
    #=== labels
    config.label = "Journalist"
    config.columns[:newsletter].form_ui = :checkbox
    config.columns[:newsletter].label = "Presseverteiler Aufnehmen"
    config.columns[:publisher].form_ui = :checkbox
    config.columns[:publisher].label = "Herausgeber"
    config.columns[:publisher].description = "Vergibt das Recht Artikel freizugeben"
    config.columns[:academic_title_id].label = "Titel"
    
    config.columns[:press_release_per_email].form_ui = :checkbox
    config.columns[:press_release_per_fax].form_ui = :checkbox
    config.columns[:press_release_per_mail].form_ui = :checkbox
    config.columns[:press_release_per_email].label = "Pressemitteilung per Email"
    config.columns[:press_release_per_fax].label = "Pressemitteillung per Fax"
    config.columns[:press_release_per_mail].label = "Pressemitteilung per Post"
    
  end  
  
  protected
  
  def conditions_for_collection
    ['people.type IN (?)', ['Journalist']]
  end
  
  def before_update_save(record)
    record.attributes = params[:record]
    record.email_confirmation = record.email
    record.business_address.save if record.business_address
  end
  
end
