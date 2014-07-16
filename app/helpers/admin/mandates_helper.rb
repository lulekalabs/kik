module Admin::MandatesHelper
  
  def type_column(record)
    "#{record.class.human_name}"
  end
  
  def action_column(record)
    result = []
    if record.action == "internal"
      result << link_to("#{record.advocate.title_and_name}", polymorphic_path([:edit, :admin, record.advocate]))
    elsif record.action == "external"
      result << "Mandat wurde extern vergeben"
    else
      result << "-"
    end
    result.join(" ")
  end
  
  def kase_column(record)
    if record.kase
      link_to("#{record.kase.to_s}", polymorphic_path([:edit, :admin, record.kase]))
    else
      "-"
    end
  end
  alias_method :kase_id_column, :kase_column
  
  def advocate_column(record)
    if record.advocate
      link_to("#{record.advocate.title_and_name} (#{record.advocate.number})", polymorphic_path([:edit, :admin, record.advocate]))
    else 
      "Anwalt außerhalb von kann-ich-klagen.de"
    end
  end

  def status_column(record)
    record.human_current_state_name
  end
  
end
