module Admin::OrdersHelper
  
  #--- scaffold helpers

  def number_column(record)
    "#{record.short_number}<br />(Ref.-Nr.: #{record.number})"
  end
  
  def buyer_id_column(record)
    link_to(record.buyer.title_and_name, edit_admin_advocate_path(record.buyer))
  end

  def created_at_column(record)
    # l(record.created_at, :format => :default)
    #record.created_at
    I18n.l(record.created_at, :format => "%d.%m.%Y") 
  end

  def invoice_form_column(record, name)
    if record.invoice
      link_to("#{record.invoice.number}", edit_admin_invoice_path(record.invoice))
    else
      'N/A'
    end
  end

  def buyer_id_form_column(record, name)
    link_to(record.buyer.name, edit_admin_advocate_path(record.buyer))
  end
  
  def number_form_column(record, name)
    "#{record.short_number} (#{record.number})"
  end
  
  def net_amount_column(record)
    record.net_amount.format
  end

  def tax_amount_column(record)
    record.tax_amount.format
  end

  def gross_total_column(record)
    record.gross_amount.format
  end

  def gross_total_form_column(record, name)
    record.gross_total.format
    # text_field :record, :gross_total, :disabled => true
  end

  def net_total_form_column(record, name)
    record.net_total.format
    # text_field :record, :gross_total, :disabled => true
  end

  def tax_total_form_column(record, name)
    record.tax_total.format
    # text_field :record, :gross_total, :disabled => true
  end
  
  def status_column(record)
    if record.recurring?
      "abo aktiv"
    else
      record.human_current_state_name
    end
  end
  
  def description_form_column(record, name)
    text_area :record, :description, :size => "80x5"
  end

  def service_period_start_on_column(order)
    object = order
    if order.recurring? && (invoice = order.purchase_invoices.find(:all, :order => "invoices.id ASC").last)
      object = invoice
      "#{l(object.service_period_start_on)} - #{l(object.service_period_end_on)}"
    elsif order.recurring?
      "#{l(object.service_period_start_on)} - #{l(object.service_period_end_on)}"
    else
      "-"
    end
  end

  def buyer_column(record)
    link_to(record.buyer.title_and_name , admin_advocate_path(record.buyer))
  end
  
end
