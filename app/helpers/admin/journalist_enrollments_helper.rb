module Admin::JournalistEnrollmentsHelper
  
  def name_column(record)
    record.to_person.title_and_name
  end
  
  def state_column(record)
    record.human_current_state_name
  end

  def gender_column(record)
    case record.gender
      when /f/ then "Frau"
      else "Herr"
    end
  end

  def gender_form_column(record, name)
    select(:record, :gender, collect_for_gender_select(false))
  end
  
  def academic_title_id_column(record)
    record.academic_title ? record.academic_title.name : "[Kein Titel]"
  end
  
  def academic_title_id_form_column(record, name)
    select(:record, :academic_title_id, collect_for_academic_title_select(true, false))
  end
  
  
end
