module Admin::InvoicesHelper

  def tax_rate_column(record)
    "#{record.tax_rate}%" 
  end
  
  def net_amount_column(record)
    record.net_amount.format
  end

  def tax_amount_column(record)
    record.tax_amount.format
  end

  def gross_amount_column(record)
    record.gross_amount.format
  end
  
  def status_column(record)
    record.status ? record.human_current_state_name : '-'
  end
  
  def number_show_column(record)
    "#{record.short_number} (Ref.-Nr.: #{record.number})"
  end
  
  def service_period_start_on_column(invoice)
    object = invoice
    order = invoice.order
    if order.recurring?
      "#{l(object.service_period_start_on)} - #{l(object.service_period_end_on)}"
    elsif order.recurring?
      "#{l(object.service_period_start_on)} - #{l(object.service_period_end_on)}"
    else
      "-"
    end
  end
  
  def number_column(record)
    "#{record.short_number}<br/>(Ref.-Nr.: #{record.number})"
  end

  def paper_bill_column(record)
    record.line_item_products.any?(&:is_paper_bill?) ? "Ja" : "Nein"
  end

  def number_form_column(record, name)
    "#{record.short_number} (#{record.number})"
  end
  
  def created_at_column(record)
    I18n.l(record.created_at, :format => "%d.%m.%Y") 
  end
  
  def billing_date_on_column(record)
    record.billing_date_on ? I18n.l(record.billing_date_on, :format => "%d.%m.%Y") : "-"
  end
  
  def buyer_column(record)
    link_to(record.buyer.title_and_name , admin_advocate_path(record.buyer))
  end
  
end
