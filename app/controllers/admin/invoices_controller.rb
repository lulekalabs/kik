class Admin::InvoicesController < Admin::AdminApplicationController
  include InvoicesControllerBase
  
  #--- active scaffold
  active_scaffold :invoices do |config|
    #--- columns
    standard_columns = [
      :id,
      :buyer_id,
      :buyer_type,
      :buyer,
      :seller_id,
      :seller_type,
      :net_amount,
      :tax_amount,
      :gross_amount,
      :tax_rate,
      :type,
      :number,
      :status,
      # associations
      :line_items,
      :payments,
      :paper_bill,
      :billing_date_on
    ]
    crud_columns = [
      :number,
      :net_amount,
      :tax_amount,
      :gross_amount,
      :tax_rate,
      :service_period_start_on,
      :service_period_end_on
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = [:created_at, :billing_date_on] + crud_columns
    config.list.columns = [
      :created_at, 
      :billing_date_on,
      :number,
      :net_amount,
      :tax_rate,
      :tax_amount,
      :gross_amount,
      :buyer,
      :service_period_start_on, 
      :paper_bill,
      :status
    ]

    config.actions.exclude :create
    config.actions.exclude :update
    config.actions.exclude :delete
    
    # columns[:created_at].label = 'Rechnungsdatum'
    columns[:number].label = 'Rechnungsnr.'
    columns[:number].description = 'Rechnungsnummer. (Referenznr.)'
    
    #--- labels
    config.label = "Rechnungen"
    columns[:number].label = 'Rechnungsnr.'
    columns[:number].description = 'Eindeutige Rechnungsnummer'
    columns[:number].required = true
    
    columns[:gross_amount].label = 'Bruttogesamt'
    columns[:net_amount].label = 'Nettogesamt'
    columns[:tax_amount].label = 'Umsatzstr.-Betrag'
    columns[:tax_rate].label = 'Steuersatz'
    
    #--- actions
    
    # approve payment
    capture_link = ActiveScaffold::DataStructures::ActionLink.new 'Bezahlt Markieren', 
      :action => 'capture_payment', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post, 
      :confirm => "Soll die Rechnung jetzt manuell abgerechnet werden (capture)?"
    def capture_link.label
      return "[Bezahlt Markieren]" if record.next_state_for_event(:payment_captured)
      ''
    end
    config.action_links.add capture_link

    # payment_voided
    void_link = ActiveScaffold::DataStructures::ActionLink.new 'Stornieren', 
      :action => 'void_payment', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post, :security_method => :void_order_authorized?,
      :confirm => "Wollen Sie die Abrechnung der Rechnung wirklich stornieren?"
    def void_link.label
      return "[Stornieren]" if record.next_state_for_event(:payment_voided)
      ''
    end
    config.action_links.add void_link

    # print invoice
    print_invoice = ActiveScaffold::DataStructures::ActionLink.new 'Rechnung Drucken',
      :action => 'print_invoice', :type => :record,
      :position => false, :inline => false, :popup => true, :parameters => {:format => :pdf}
    def print_invoice.label
      return "Rechnung Drucken" if record.paid? || record.authorized?
      ''
    end
    config.action_links.add print_invoice
    
    config.nested.add_link('Positionen', [:line_items])
    config.nested.add_link('Zahlungen', [:payments])
    
    
  end
  
  #--- actions
  
  def capture_payment
    do_invoice_list_action(:payment_captured!)
  end

  def void_payment
    do_invoice_list_action(:payment_voided!)
  end

  def print_invoice
    @invoice = Invoice.find(params[:id])
    load_invoice_and_render
  end

  protected
  
  # Triggers the provided event and updates the order list item.
  # Usage:     do_invoice_list_action(:approve_payment!)
  def do_invoice_list_action(event)
    @invoice = Invoice.find_by_id params[:id]
    raise UserException.new(:invoice_not_found) if @invoice.nil?    
    if @invoice.send("#{event}")
      render :update do |page|
        page.replace element_row_id(:action => 'list', :id => params[:id]), 
          :partial => 'list_record', :locals => { :record => @invoice }
        page << "ActiveScaffold.stripe('#{active_scaffold_tbody_id}');"
      end
    else
      message = render_to_string :partial => 'errors'
      render :update do |page|
        page.alert(message)
      end
    end
  end
  
end
