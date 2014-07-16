module Admin::UsersHelper
  
  def person_column(record)
    if record.person
      link_to "#{record.person.title_and_name} (#{record.person.class.human_name})",
        polymorphic_path([:edit, :admin, record.person])
    else
      "-"
    end
  end
  
  def person_form_column(record, name)
    html = ""
    html << '<div style="margin-top:7px;"></div>'
    html << link_to("#{record.person.salutation_and_title_and_name} (#{record.person.class.human_name})", 
      polymorphic_path([:edit, :admin, record.person]))
    html
  end
  
  def status_search_column(record, options)
    select :record, :status, options_for_select(['open', 'closed']), {:include_blank => as_('- select -')}, options
  end

end
