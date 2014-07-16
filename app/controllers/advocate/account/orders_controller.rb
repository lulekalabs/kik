# Product purchasing process
class Advocate::Account::OrdersController < Advocate::Account::AdvocateAccountApplicationController

  #--- filters
  before_filter :load_cart, :only => [:new, :create]
  before_filter :verify_cart, :only => [:new, :create]
  before_filter :build_billing_address, :only => [:new, :create]
  before_filter :build_order, :only => [:new, :create]
  before_filter :build_credit_card, :only => [:new, :create]
  before_filter :load_and_verify_order, :only => [:show]
  before_filter :can_purchase_subscription, :only => [:new, :create]
  
  #--- actions
  
  def new
    if params[:editing]
      @edit = !(@billing_address.valid? and @order.valid?)
      @review = !@edit
    else
      @edit = true
      @review = false
    end
  end

  def create
    if params[:_change]
      # User selects "Daten ändern", so return to order entry
      @edit = true
      @review = false
      @billing_address.valid?
      render :action => "new"
      return
    end
    
    if @billing_address.valid? and @order.valid?
      @billing_address.save
      
      @payment_object = case @order.preferred_payment_method.to_s
      when /debit/ then DebitBankPayment.new
      when /invoice/ then InvoicePayment.new 
      when /paypal/ then PaypalPayment.new
      end
      
      subscription_start_on = @person.new_recurring_product_subscription_start_on
      previous_order = @person.last_active_recurring_order
      @payment = @order.recurring(@payment_object, {:ip => request.remote_ip, 
        :bank_account_owner_name => @order.bank_account_owner_name, :bank_account_number => @order.bank_account_number,
          :bank_routing_number => @order.bank_routing_number, :bank_name => @order.bank_name, 
            :bank_location => @order.bank_location, :paypal_account => @order.paypal_account,
              :interval => {:length => Project.default_recurring_options[:interval][:length], :unit => Project.default_recurring_options[:interval][:unit]}, 
                :duration => {:start_date => subscription_start_on, 
                  :occurrences => Project.default_recurring_options[:duration][:occurrences]}})

      if @payment.success?
        @cart.empty!
        store_cart(@cart)
        
        # update previous order
        if previous_order
          if recurring_payment = previous_order.payments.recurring.first
            # the subscription package was changed, so make sure, we can bill once more
            # at the end of the service period
            recurring_payment.update_attributes({:duration_occurrences => 1})
            previous_order.update_attributes({:cancel_on_service_period_end => true})
          end
        end
        
        flash[:notice] = "Vielen Dank für Ihre Bestellung."
        redirect_to advocate_account_order_path(@order)
        return
      else
        # @order.save  # shall we save unsucssesful orders?
        flash[:error] = "Es gab Fehler bei der Bestellung: #{@payment.message}."
      end
    end
    render :action => "new"
  end

  def show
    @payment = @order.payments.last
    if @payment.payment_type == :debit_bank
      @order.preferred_payment_method = "debit"

      @order.bank_account_owner_name = @payment.bank_account_owner_name
      @order.bank_account_number = @payment.bank_account_number
      @order.bank_routing_number = @payment.bank_routing_number
      @order.bank_name = @payment.bank_name
      @order.bank_location = @payment.bank_location
    elsif @payment.payment_type == :paypal
      @order.preferred_payment_method = "paypal"
      @order.paypal_account = @payment.paypal_account
    else
      @order.preferred_payment_method = "invoice"
    end
  end

  protected
  
  # load an order of :id and see if it belongs to this user
  def load_and_verify_order
    @order = Order.find_by_id(params[:id])
    if !@order || @order.buyer != @person
      redirect_to advocate_account_products_path
      return false
    end
    true
  end
  
  # checks to see if we have a filled cart that we can order
  def verify_cart
    if !@cart || (@cart && @cart.empty?)
      redirect_to advocate_account_products_path
      return false
    end
    true
  end
  
  # builds and returns the order
  def build_order
    if params[:order]
      if params[:order][:preferred_billing_method] =~ /pdf_and_paper/
        paper_invoice_item = Product.find_by_sku("X001")
        @order = @person.purchase @cart.line_items, paper_invoice_item
      else
        @order = @person.purchase @cart.line_items
      end
    elsif @person.preferred_billing_method.to_s =~ /pdf_and_paper/
      paper_invoice_item = Product.find_by_sku("X001")
      @order = @person.purchase @cart.line_items, paper_invoice_item
    else
      @order = @person.purchase @cart.line_items
    end
    
    @order.attributes = params[:order]
    @order.evaluate
    
    @order.preferred_payment_method = @person.preferred_payment_method || "debit" unless @order.preferred_payment_method
    @order.preferred_billing_method = @person.preferred_billing_method || "pdf" unless @order.preferred_billing_method
    
    @order.tax_number = @person.tax_number unless @order.tax_number

    @order.bank_account_owner_name = @person.bank_account_owner_name unless @order.bank_account_owner_name
    @order.bank_account_number = @person.bank_account_number unless @order.bank_account_number
    @order.bank_routing_number = @person.bank_routing_number unless @order.bank_routing_number
    @order.bank_name = @person.bank_name unless @order.bank_name
    @order.bank_location = @person.bank_location unless @order.bank_location
    @order.paypal_account = @person.paypal_account unless @order.paypal_account
    @order
  end

  def build_credit_card
    @credit_card = ActiveMerchant::Billing::CreditCard.new({
      :first_name => @person.first_name,
      :last_name => @person.last_name
    }.merge(params[:credit_card] || {}))
  end
  
  def build_billing_address(options={})
    unless @person.billing_address
      @billing_address = @person.build_billing_address(options.merge({
        :company_name => @person.company_name, :academic_title_id => @person.academic_title_id, :gender => @person.gender,
          :first_name => @person.first_name, :last_name => @person.last_name,
            :street => @person.business_address.street, :street_number => @person.business_address.street_number,
              :note => @person.business_address.note, :postal_code => @person.business_address.postal_code,
                :city => @person.business_address.city, :country_code => @person.business_address.country_code,
                  :email => @person.email}.merge((((params[:person] || {})[:billing_address_attributes]) || {}).symbolize_keys)))
    else
      @person.attributes = params[:person]
      @billing_address = @person.billing_address
    end
    @billing_address
  end

  # tests if we can purchase a new subscription
  def can_purchase_subscription
    desired_subscription = @order.line_item_products.select(&:is_subscription?).first
    active_subscription = @person.last_active_product_subscription
    if new_order = @person.next_recurring_order
      if new_subscription = new_order.line_item_products.select(&:is_subscription?).first
        flash[:error] = "Ein Paketwechsel für \"#{new_subscription.name}\" wurde bereits gebucht und steht in der Leistungperiode zum #{I18n.l(new_order.service_period_start_on, :format => "%d.%m.%Y")} bereit"
      end
      redirect_to package_advocate_account_profile_path
      return
    elsif desired_subscription.is_similar_to?(active_subscription)
      flash[:warning] = "Das gewünschte Paket ist bereits gebucht: \"#{desired_subscription.name}\""
      redirect_to package_advocate_account_profile_path
      return
    elsif !(desired_subscription.is_different_to?(active_subscription) && (desired_subscription.is_superior_to?(active_subscription) || self.can_cancel_product_subscription?))
      if term_end_on = @person.last_active_recurring_product_subscription_term_period_end_on
        flash[:error] = "Wechsel erst am Ende der Mindestlaufzeit zum #{I18n.l(term_end_on, :format => "%d.%m.%Y")} möglich"
      end
      redirect_to package_advocate_account_profile_path
      return
    end
  end
  
end
