module Admin::ResponsesHelper
  
  def kase_column(record)
    link_to("#{record.kase.number}: #{record.kase.summary}", admin_question_path(record.kase))
  end

  def person_column(record)
    link_to("#{record.person.title_and_name}", admin_advocate_path(record.person))
  end

  def status_column(record)
    record.human_current_state_name
  end

  def id_column(record)
    record.number
  end

  # translates current state
  def status_column(record)
    result = record.human_current_state_name
    if record.close_reason
      if record.closed? && record.advocate_cancel?
        result += " (#{link_to(record.person.title_and_name, admin_advocate_path(record.person))} sagt: \"#{record.human_close_reason}\")"
      elsif record.closed? && record.mandated?
        result += " (#{link_to(record.person.title_and_name, admin_advocate_path(record.person))} sagt: \"#{record.human_close_reason}\")"
      end
    end
    result
  end
  
end
