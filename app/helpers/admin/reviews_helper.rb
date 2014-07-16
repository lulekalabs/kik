module Admin::ReviewsHelper
  
  def status_column(record)
    "#{record.human_current_state_name}"
  end
  
  def id_column(record)
    record.number
  end
  
end
