class Admin::TopicsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :topic do |config|
    #--- columns
    standard_columns = [
      :id,
      :name,
      :type,
      :tag_list_s,
      :position
    ]
    crud_columns = [
      :name,
      :tag_list_s
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:name, :tag_list_s, :created_at]
    
    config.label = "Rechtsgebiete"
    config.create.label = "Neues Rechtsgebiet"
    config.update.label = "Editiere Rechtsgebiet"
    
    config.columns[:tag_list_s].label       = "Stichwörter"
    config.columns[:tag_list_s].description = "Kommasepararierte Stichwortvergabe"
    config.columns[:position].description = "Kann leer bleiben, nur wichtig für Änderung Sortierreihenfolge"

    # exclude in article
    config.subform.columns.exclude :position, :tag_list_s
    
    config.list.per_page = 100
    config.list.sorting = [{:name => :asc}]
  
  end 
  
  protected
  
  def before_create_save(record)
    record.topic_only = true
    record.expertise_only = false
  end

  def before_update_save(record)
    record.topic_only = true
    record.expertise_only = false
  end
  
  def conditions_for_collection
    ['topics.topic_only = ? AND topics.expertise_only = ?', true, false]
  end
end
