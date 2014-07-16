module Admin::PaymentsHelper
  
  def payable_id_column(record)
    link_to "#{record.payable_type.humanize}", admin_invoice_path(record.payable_id)
  end
  
  def success_column(record)
    result = "#{record.class.human_name} " 
    result += record.success? ? "erledigt" : "abgelehnt"
    result
  end
  
  def interval_length_column(record)
    I18n.t("{{count}} #{record.interval_unit || :month}", :count => record.interval_length || 0, :scope => :pluralizations)
  end
  
  def amount_column(record)
    record.amount ? record.amount.format : "-"
  end
  
  def action_column(record)
    case record.action
    when "recurring" then "abo"
    when "authorized" then "authorisiert"
    when "paid" then "bezahlt"
    else
      record.action
    end
  end
  
end
