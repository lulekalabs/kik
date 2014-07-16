class Admin::OrdersController < Admin::AdminApplicationController
  
  active_scaffold :orders do |config|

    #--- columns
    standard_columns = [
      :id,
      :buyer_id,
      :buyer_type,
      :seller_id,
      :seller_type,
      #:invoice_id,
      :net_cents,
      :tax_cents,
      :gross_total,
      :gross_cents,
      :net_total,
      :net_cents,
      :tax_total,
      :tax_cents,
      :currency,
      :tax_rate,
      :type,
      :status,
      :number,
      :description,
      :created_at,
      # associations
      :line_items,
      :invoices,
      :service_period_start_on,
      :service_period_end_on
    ]
    config.columns = standard_columns
    config.update.columns = [:number, :description, :buyer_id, :net_total, :tax_total, :gross_total]
    config.list.columns = [:created_at, :number, :net_amount, :tax_amount, :gross_total, :buyer, :service_period_start_on, :status]
    config.show.columns = [:number, :description, :net_amount, :tax_amount, :gross_amount, :status]
    
    #--- sorting
    list.sorting = {:created_at => 'DESC'}
    
    #--- actions
    # payment_voided
    cancel_link = ActiveScaffold::DataStructures::ActionLink.new 'Stornieren', 
      :action => 'cancel_order', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post, :security_method => :cancel_order_authorized?,
      :confirm => "Wollen Sie die Bestellung wirklich stornieren?"
    def cancel_link.label
      return "[Stornieren]" if record.next_state_for_event(:cancel)
      ''
    end
    config.action_links.add cancel_link

    config.nested.add_link('Rechnungen', [:invoices])
    config.nested.add_link('Positionen', [:line_items])
    config.nested.add_link('Zahlungen', [:payments])
    
    #--- labels
    columns[:number].label = 'Bestellnr.'
    columns[:number].description = 'Bestellnummer. (Referenznr.)'
    columns[:number].required = true
    
    columns[:gross_total].label = 'Brutto-Gesamt'
    columns[:net_total].label = 'Netto-Gesamt'
    columns[:tax_total].label = 'Umsatzstr.-Betrag'
    columns[:buyer_id].label = 'Kundenname'
    columns[:created_at].label = 'Bestelldatum'
    columns[:description].label = 'Beschreibung'
    columns[:service_period_start_on].label = 'Aktueller Leistungszeitraum'
    #columns[:invoice].label = 'Rechnung'
    
    #--- scaffold actions
    config.actions.exclude :create
    config.actions.exclude :delete
    config.actions.exclude :show
#    config.actions.exclude :update


  end
  
  #--- actions
  
  def cancel_order
    do_order_list_action(:cancel!)
  end
  
  protected

  # Called by active scaffold in a transaction before saving the record. Used to update related objects.
  def before_update_save(record)
    @record.capture if /1/.match(params[:approve_payment_only].to_s)
    @record.process_shipping! if /1/.match(params[:process_shipping_only].to_s)
    @record.void if /1/.match(params[:void_only].to_s)
    @record.ship! if /1/.match(params[:ship_only].to_s)
    @record.confirm_return! if /1/.match(params[:ship_only].to_s)
  end
  
  def cancel_order_authorized?
    true
  end

  def approve_payment_authorized?
    true
  end

  def process_shipping_authorized?
    true
  end

  def void_order_authorized?
    true
  end
  
  def ship_order_authorized?
    true
  end
  
  def do_order_list_action(event)
    @order = Order.find_by_id params[:id]
    raise UserException.new(:order_not_found) if @order.nil?    
    if @order.send("#{event}")
      render :update do |page|
        page.replace element_row_id(:action => 'list', :id => params[:id]), 
          :partial => 'list_record', :locals => { :record => @order }
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
