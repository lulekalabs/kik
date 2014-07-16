module Admin::ClientsHelper
  
  def title_and_name_column(record)
    unless record.salutation_and_title_and_name.blank?
      "#{record.salutation_and_title_and_name} (#{record.number})"
    else
      "#{record.user_id} (#{record.number})"
    end
  end
  
end
