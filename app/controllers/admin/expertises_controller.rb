# Edits "Fachgebiete"
class Admin::ExpertisesController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :expertise do |config|
    #--- columns
    standard_columns = [
      :id,
      :name,
      :type,
      :tag_list_s,
      :position,
      :expertise_only
    ]
    crud_columns = [
      :name,
      :tag_list_s,
      :position,
#      :expertise_only
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:name, :tag_list_s, :position, :created_at]
    
    config.columns[:expertise_only].form_ui = :checkbox
    
    config.label = "Fachanwaltschaften"
    config.create.label = "Neues Rechtsgebiet"
    config.update.label = "Editiere Rechtsgebiet"
    
    config.columns[:tag_list_s].label       = "Stichwörter"
    config.columns[:tag_list_s].description = "Kommasepararierte Stichwortvergabe"
    config.columns[:position].description = "Kann leer bleiben, nur wichtig für Änderung Sortierreihenfolge"
    
    config.columns[:expertise_only].label       = "Nur Fachgebiet"
    
    config.list.per_page = 100
    config.list.sorting = [{:name => :asc}]
    
  end 
  
  protected
  
  def before_create_save(record)
    record.topic_only = false
    record.expertise_only = true
  end

  def before_update_save(record)
    record.topic_only = false
    record.expertise_only = true
  end
  
  def conditions_for_collection
    ['topics.topic_only = ? AND topics.expertise_only = ?', false, true]
  end
  
end
