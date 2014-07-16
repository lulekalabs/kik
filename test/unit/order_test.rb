require File.dirname(__FILE__) + '/../test_helper'

class OrderTest < ActiveSupport::TestCase
  fixtures :all
  
  def setup
    DebitBankPayment.test = true
    Paygate.test = true

    ActionMailer::Base.deliveries.clear
    
    @advocate = people(:aaron)
    @cart= Cart.new("EUR")
  end
  
  def test_should_order_recurring_with_debit_bank_payment
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      monthly_20_abo_product = Product.find_by_sku("P020")
      paper_invoice_product = Product.find_by_sku("X001")
    
      @order = @advocate.purchase monthly_20_abo_product, paper_invoice_product
      @order.evaluate
    
      @order.preferred_payment_method = "debit"
      @order.preferred_billing_method = "pdf"
      @order.tax_number = "DE123456789"
      @order.bank_account_owner_name = "Aaron S. Schweizer"
      @order.bank_account_number = "576956"
      @order.bank_routing_number = "72151650"
      @order.bank_name = "Sparkasse Ingolstadt"
      @order.bank_location = "Ingolstadt"

      assert_equal true, @order.valid?
    
      @payment_object = DebitBankPayment.new
    
      assert_difference "PurchaseOrder.count" do
        assert_difference "DebitBankPayment.count" do
          assert_difference "BillingAddress.count" do
            assert_no_difference "PurchaseInvoice.count" do
              @payment = @order.recurring(@payment_object, {:ip => "192.168.1.1", 
                :bank_account_owner_name => @order.bank_account_owner_name, :bank_account_number => @order.bank_account_number,
                  :bank_routing_number => @order.bank_routing_number, :bank_name => @order.bank_name, :bank_location => @order.bank_location,
                    :interval => {:length => 1, :unit => :month}, 
                      :duration => {:start_date => Date.today, :occurrences => 999}})
              assert_equal :pending, @order.current_state
              assert_equal "recurring", @payment.action
              assert_equal @order, @payment.payable
              assert_equal 1, @payment.interval_length
              assert_equal "month", @payment.interval_unit
              
              puts ActionMailer::Base.deliveries.first.subject
              puts ActionMailer::Base.deliveries.first.body
              
              assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
              assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
              assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
              
              @advocate.reload
              assert @advocate.premium_contact_transactions
              assert_equal 20, @advocate.premium_contact_transactions.first.amount
            end
          end
        end
      end
      assert_equal true, @payment.success?
    end
  end

  def test_should_order_recurring_with_invoice_payment
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      monthly_20_abo_product = Product.find_by_sku("P020")
      paper_invoice_product = Product.find_by_sku("X001")
    
      @order = @advocate.purchase monthly_20_abo_product, paper_invoice_product
      @order.evaluate
    
      @order.preferred_payment_method = "invoice"
      @order.preferred_billing_method = "pdf"
      @order.tax_number = "DE123456789"

      assert_equal true, @order.valid?
    
      @payment_object = InvoicePayment.new
    
      assert_difference "PurchaseOrder.count" do
        assert_difference "InvoicePayment.count" do
          assert_difference "BillingAddress.count" do
            assert_no_difference "PurchaseInvoice.count" do
              @payment = @order.recurring(@payment_object, {:ip => "192.168.1.1", 
                :interval => {:length => 1, :unit => :month}, 
                  :duration => {:start_date => Date.today, :occurrences => 999}})
              assert_equal :pending, @order.current_state
              assert_equal "recurring", @payment.action
              assert_equal @order, @payment.payable
              assert_equal 1, @payment.interval_length
              assert_equal "month", @payment.interval_unit
              
              assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
              assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
              assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
              
              @advocate.reload
              assert @advocate.premium_contact_transactions
              assert_equal 20, @advocate.premium_contact_transactions.first.amount
            end
          end
        end
      end
      assert_equal true, @payment.success?
    end
  end

  def test_should_order_recurring_flat_package_with_invoice_payment
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      flat_abo_product = Product.find_by_sku("P001")
    
      @order = @advocate.purchase flat_abo_product
      @order.evaluate
    
      @order.preferred_payment_method = "invoice"
      @order.preferred_billing_method = "pdf"
      @order.tax_number = "DE123456789"

      assert_equal true, @order.valid?
    
      @payment_object = InvoicePayment.new
    
      assert_difference "PurchaseOrder.count" do
        assert_difference "InvoicePayment.count" do
          assert_difference "BillingAddress.count" do
            assert_no_difference "PurchaseInvoice.count" do
              @payment = @order.recurring(@payment_object, {:ip => "192.168.1.1", 
                :interval => {:length => 1, :unit => :month}, 
                  :duration => {:start_date => Date.today, :occurrences => 999}})
              assert_equal :pending, @order.current_state
              assert_equal "recurring", @payment.action
              assert_equal @order, @payment.payable
              assert_equal 1, @payment.interval_length
              assert_equal "month", @payment.interval_unit
              
              assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
              assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
              assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
              
              @advocate.reload
              assert_equal false, @advocate.premium_contact_transactions.empty?
              assert_equal 0, @advocate.premium_contact_transactions.first.amount
              assert_equal true, @advocate.premium_contact_transactions.first.flex
            end
          end
        end
      end
      assert_equal true, @payment.success?
    end
  end
  
  def test_should_cancel_order
    create_recurring_order_and_payment
    assert_equal :pending, @order.current_state
    assert @advocate.premium_contact_transactions
    assert_equal 20, @advocate.premium_contact_transactions.first.amount
    assert_equal 20, @advocate.premium_contacts_count
    @order.cancel!
    assert_nil @order.billing_due_on

    @advocate.update_contacts_count
    @advocate.reload
    assert_equal 0, @advocate.premium_contacts_count
  end

  def test_should_pay_recurring_with_invoice
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      assert_difference "PurchaseOrder.count" do
        assert_difference "PurchaseInvoice.count", 3 do
          
          #--- 1st period -- no billing -- no payment
          create_recurring_order_and_payment(:invoice)
          @advocate.reload
          assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
          assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
          assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
          @advocate.update_contacts_count
          @advocate.reload
          assert_equal 20, @advocate.premium_contacts_count, "should have booked initial package"
          
          pretend_now_is Time.parse("Tue Mar 26 15:05:58 UTC 2011") do
            assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
          end

          pretend_now_is Time.parse("Tue Mar 27 15:05:58 UTC 2011") do
            assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
          end
          
          #--- 2nd period -- 1st billing -- 1st payment
          pretend_now_is Time.parse("Mar 26 15:05:58 UTC 2011") do
            @cart.add(Product.find_by_sku("K001"), 7)
            @payment = @order.pay_recurring(nil, :add_line_items => @cart.line_items)
            assert_equal "89,13 €", @payment.amount.format
            assert_equal 3, @payment.payable.line_items.size, "should have one more line item"
            assert_equal true, @payment.success?
    
            @advocate.update_contacts_count
            @advocate.reload
            assert_equal 20, @advocate.premium_contacts_count, "should have contacts in period Mar 26 through April 25"
      
            assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
            assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
            assert_equal Date.parse("Tue, 26 Feb 2011"), @order.purchase_invoices.last.service_period_start_on
            assert_equal Date.parse("Fri, 25 Mar 2011"), @order.purchase_invoices.last.service_period_end_on
            @order.reload
            assert_equal Date.parse("Fri, 26 Apr 2011"), @order.billing_due_on

            pretend_now_is Time.parse("Tue Apr 26 16:07:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
            end
          end                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
          
          #--- 3rd period -- 2nd billing -- 2nd payment
          pretend_now_is Time.parse("Apr 26 15:05:58 UTC 2011") do
            @payment = @order.pay_recurring
            assert_equal "47,48 €", @payment.amount.format
            assert_equal true, @payment.success?
            assert_equal 2, @payment.payable.line_items.size, "should have one more line item"
    
            @advocate.update_contacts_count
            @advocate.reload
            assert_equal 20, @advocate.premium_contacts_count, "should have contacts in period Apr 26 through May 25"

            assert_equal Date.parse("Tue, 26 Mar 2011"), @order.purchase_invoices.last.service_period_start_on
            assert_equal Date.parse("Fri, 25 Apr 2011"), @order.purchase_invoices.last.service_period_end_on
            @order.reload
            assert_equal Date.parse("Fri, 26 May 2011"), @order.billing_due_on

            pretend_now_is Time.parse("Tue May 28 19:21:38 UTC 2011") do
              assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
            end
          end
          
          #--- 4th period -- 3rd billing -- 3rd payment
          pretend_now_is Time.parse("May 26 15:05:58 UTC 2011") do
            assert_difference "LineItem.count", 3 do
              @cart.empty!
              @cart.add(Product.find_by_sku("K001"), 21)
              @payment = @order.pay_recurring(nil, :add_line_items => @cart.line_items)
              assert_equal "172,43 €", @payment.amount.format
              assert_equal 3, @payment.payable.line_items.size, "should have one more line item"
              assert_equal true, @payment.success?
            end
            @advocate.update_contacts_count
            @advocate.reload
            assert_equal 20, @advocate.premium_contacts_count, "should have contacts in period May 26 through Jun 25"

            assert_equal Date.parse("Tue, 26 Apr 2011"), @order.purchase_invoices.last.service_period_start_on
            assert_equal Date.parse("Fri, 25 May 2011"), @order.purchase_invoices.last.service_period_end_on
            @order.reload
            assert_equal Date.parse("Fri, 26 Jun 2011"), @order.billing_due_on

            pretend_now_is Time.parse("Tue Jun 26 16:07:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
            end
          end
        end
      end
    end
  end

  def test_should_authorize_recurring_with_invoice
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      assert_difference "PurchaseOrder.count" do
        assert_difference "PurchaseInvoice.count", 2 do
          assert_difference "Payment.count", 5 do
            
            #--- 1st period -- no billing -- no payment
            create_recurring_order_and_payment(:invoice)
            assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
            assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
            assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
            @advocate.reload
            assert_equal 20, @advocate.premium_contacts_count, "should have booked contacts as we ordered"
          
            #--- 2nd period -- 1st billing -- 1st payment
            pretend_now_is Time.parse("Mar 26 15:05:58 UTC 2011") do
              @cart.add(Product.find_by_sku("K001"), 21)
              @payment = @order.authorize_recurring nil, :add_line_items => @cart.line_items
              @invoice = @payment.payable
              assert_equal "172,43 €", @payment.amount.format
              assert_equal "172,43 €", @invoice.total.format
              assert_equal 3, @payment.payable.line_items.size, "should have one more line item"
              assert_equal true, @payment.success?

              @advocate.update_contacts_count
              @advocate.reload
              assert_equal 0, @advocate.premium_contacts_count, "should have expired contacts of period Feb 26 through Mar 25"
      
              assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
              assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
              assert_equal Date.parse("Tue, 26 Feb 2011"), @order.purchase_invoices.last.service_period_start_on
              assert_equal Date.parse("Fri, 25 Mar 2011"), @order.purchase_invoices.last.service_period_end_on
              @order.reload
              assert_equal Date.parse("Fri, 26 Apr 2011"), @order.billing_due_on, "should change billing date"

              pretend_now_is Time.parse("Tue Apr 26 16:07:58 UTC 2011") do
                assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
              end
          
              # capture 1st payment
              @payment = @invoice.capture
              assert_equal true, @payment.success?
              assert_equal "172,43 €", @payment.amount.format
              assert_equal "capture", @payment.action
              assert_equal Date.parse("Fri, 27 Feb 2011"), @invoice.billing_date_on
              
              @advocate.update_contacts_count
              @advocate.reload
              assert_equal 20, @advocate.premium_contacts_count, "should have contacts in period Mar 26 through April 25"

              @order.reload
              assert_equal Date.parse("Fri, 26 Apr 2011"), @order.billing_due_on, "should not change from authorize"
            end
          
            #--- 3rd period -- 2nd billing -- 2nd payment
            pretend_now_is Time.parse("Apr 26 15:05:58 UTC 2011") do
              @cart.empty!
              @cart.add(Product.find_by_sku("K001"), 1)
              @payment = @order.authorize_recurring nil, :add_line_items => @cart.line_items
              @invoice = @payment.payable
              assert_equal "53,43 €", @payment.amount.format
              assert_equal "53,43 €", @invoice.total.format
              assert_equal 3, @payment.payable.line_items.size, "should have one more line item"
              assert_equal true, @payment.success?
    
              @advocate.reload
              @advocate.update_contacts_count
              assert_equal 0, @advocate.premium_contacts_count, "should have expired contacts of period Mar 26 through Apr 25"
      
              assert_equal Date.parse("Tue, 26 Mar 2011"), @order.service_period_start_on
              assert_equal Date.parse("Fri, 25 Apr 2011"), @order.service_period_end_on
              assert_equal Date.parse("Tue, 26 Mar 2011"), @order.purchase_invoices.last.service_period_start_on
              assert_equal Date.parse("Fri, 25 Apr 2011"), @order.purchase_invoices.last.service_period_end_on
              @order.reload
              assert_equal Date.parse("Fri, 26 May 2011"), @order.billing_due_on, "should change billing date"

              pretend_now_is Time.parse("Tue May 26 16:07:58 UTC 2011") do
                assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
              end
          
              # capture 2nd payment
              @payment = @invoice.capture
              assert_equal true, @payment.success?
              assert_equal "53,43 €", @payment.amount.format
              assert_equal "capture", @payment.action
              assert_equal Date.parse("27 Mar 2011"), @invoice.billing_date_on

              @advocate.reload
              @advocate.update_contacts_count
              
              assert_equal 20, @advocate.premium_contacts_count, "should have contacts in period Apr 26 through May 25"

              @order.reload
              assert_equal Date.parse("Fri, 26 May 2011"), @order.billing_due_on, "should not change from authorize"
            end
          end
        end
      end
    end
  end
  
  def test_recurring_orders_job
    assert_difference "PurchaseOrder.count", 2 do
      pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
        @rechnung_order, @rechnung_payment = create_recurring_order_and_payment(:invoice)
        assert_equal Date.parse("Fri, 26 Mar 2011"), @rechnung_order.billing_due_on

        @debit_order, @debit_payment = create_recurring_order_and_payment(:debit)
        assert_equal Date.parse("Fri, 26 Mar 2011"), @debit_order.billing_due_on
      
        assert_difference "PurchaseInvoice.count", 2 do
          pretend_now_is Time.parse("Mar 26 15:05:58 UTC 2011") do
            RecurringOrdersJob.new.perform
          end
        end

        assert_no_difference "PurchaseInvoice.count" do
          pretend_now_is Time.parse("Mar 26 16:05:58 UTC 2011") do
            RecurringOrdersJob.new.perform
          end
        end
      
        @rechnung_order.reload
        assert_equal :authorized, @rechnung_order.purchase_invoices.first.current_state
        assert_equal Date.parse("Fri, 26 Apr 2011"), @rechnung_order.billing_due_on

        @debit_order.reload
        assert_equal :paid, @debit_order.purchase_invoices.last.current_state
        assert_equal Date.parse("Fri, 26 Apr 2011"), @debit_order.billing_due_on
      
      end
    end
  end
  
  def test_generate_and_sign_invoice_job_with_invoice_payment
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      assert_difference "PurchaseOrder.count" do
        assert_difference "PurchaseInvoice.count" do
          assert_difference "Delayed::Job.count", 1 do
          
            #--- 1st period -- no billing -- no payment
            create_recurring_order_and_payment(:invoice)
            @advocate.reload
            assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
            assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
            assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
          
            pretend_now_is Time.parse("Tue Mar 26 15:05:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
            end

            pretend_now_is Time.parse("Tue Mar 27 15:05:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_invoice_payment.due(Date.today)
            end
          
            #--- 2nd period -- 1st billing -- 1st payment
            @cart.add(Product.find_by_sku("K001"), 7)
            @payment = @order.pay_recurring(nil, :add_line_items => @cart.line_items)
            assert_equal "89,13 €", @payment.amount.format
            assert_equal 3, @payment.payable.line_items.size, "should have one more line item"
            assert_equal true, @payment.success?

            # run job manually as delayed jobs daemon is not running
            ActionMailer::Base.deliveries.clear
            assert_equal true, @payment.payable.is_a?(Invoice), "should have paid invoice"
            assert_equal :paid, @payment.payable.current_state, "should be paid"
            @invoice = @payment.payable
            assert_equal "2011.02.1", @invoice.human_number
            GenerateAndSignInvoiceJob.new(@invoice.id).perform
            assert_equal 1, ActionMailer::Base.deliveries.size
          end
        end
      end
    end
  end

  def test_generate_and_sign_invoice_job_with_flex_abo_and_debit_bank_payment
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      assert_difference "PurchaseOrder.count" do
        assert_difference "PurchaseInvoice.count" do
          assert_difference "Delayed::Job.count", 1 do
          
            #--- 1st period -- no billing -- no payment
            create_recurring_order_and_payment_with_sku_list(:debit, "P001", "X001")
            @advocate.reload
            assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
            assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
            assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
          
            pretend_now_is Time.parse("Tue Mar 26 15:05:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_debit_bank_payment.due(Date.today)
            end

            pretend_now_is Time.parse("Tue Mar 27 15:05:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_debit_bank_payment.due(Date.today)
            end
          
            #--- 2nd period -- 1st billing -- 1st payment
            @cart.add(Product.find_by_sku("K001"), 7)
            @payment = @order.pay_recurring(nil, :add_line_items => @cart.line_items)
            assert_equal "47,60 €", @payment.amount.format
            assert_equal 3, @payment.payable.line_items.size, "should have one more line item"
            assert_equal true, @payment.success?

            # run job manually as delayed jobs daemon is not running
            ActionMailer::Base.deliveries.clear
            assert_equal true, @payment.payable.is_a?(Invoice), "should have paid invoice"
            assert_equal :paid, @payment.payable.current_state, "should be paid"
            @invoice = @payment.payable
            assert_equal "2011.02.1", @invoice.human_number
            GenerateAndSignInvoiceJob.new(@invoice.id).perform
            assert_equal 1, ActionMailer::Base.deliveries.size
          end
        end
      end
    end
  end

  def test_generate_and_sign_invoice_job_with_flat_abo_and_debit_bank_payment
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      assert_difference "PurchaseOrder.count" do
        assert_difference "PurchaseInvoice.count" do
          assert_difference "Delayed::Job.count", 1 do
          
            #--- 1st period -- no billing -- no payment
            create_recurring_order_and_payment_with_sku_list(:debit, "S999")
            @advocate.reload
            assert_equal Date.parse("Tue, 26 Feb 2011"), @order.service_period_start_on
            assert_equal Date.parse("Fri, 25 Mar 2011"), @order.service_period_end_on
            assert_equal Date.parse("Fri, 26 Mar 2011"), @order.billing_due_on
          
            pretend_now_is Time.parse("Tue Mar 26 15:05:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_debit_bank_payment.due(Date.today)
            end

            pretend_now_is Time.parse("Tue Mar 27 15:05:58 UTC 2011") do
              assert_equal [@order], Order.recurring.with_debit_bank_payment.due(Date.today)
            end
          
            #--- 2nd period -- 1st billing -- 1st payment
            #@cart.add(Product.find_by_sku("K001"), 7)
            @payment = @order.pay_recurring(nil, :add_line_items => @cart.line_items)
            assert_equal "77,23 €", @payment.amount.format
            assert_equal 1, @payment.payable.line_items.size, "should have one more line item"
            assert_equal true, @payment.success?

            # run job manually as delayed jobs daemon is not running
            ActionMailer::Base.deliveries.clear
            assert_equal true, @payment.payable.is_a?(Invoice), "should have paid invoice"
            assert_equal :paid, @payment.payable.current_state, "should be paid"
            @invoice = @payment.payable
            assert_equal "2011.02.1", @invoice.human_number
            
            GenerateAndSignInvoiceJob.new(@invoice.id).perform
            assert_equal 1, ActionMailer::Base.deliveries.size
          end
        end
      end
    end
  end
  
  def test_should_order_multiple_subscriptions
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      @order1, @payment1 = create_recurring_order_and_payment_with_sku_list(:debit, "P020", "X001")
      assert_equal 2, ActionMailer::Base.deliveries.size
      assert_equal "Bestätigung für Prof. Aaron Schweizer: 20er-Paket Monatsabo erworben", 
        ActionMailer::Base.deliveries.first.subject
      @payment1 = @order1.pay_recurring
      assert_equal true, @payment1.success?, "should be paid"
    end
    
    ActionMailer::Base.deliveries.clear
    
    pretend_now_is Time.parse("Apr 5 15:05:58 UTC 2011") do
      @order2, @payment2 = create_recurring_order_and_payment_with_sku_list(:debit, "S040")
      assert_equal 2, ActionMailer::Base.deliveries.size
      assert_equal "Bestätigung für Prof. Aaron Schweizer: Wechsel in 40er-Paket Jahresabo",
        ActionMailer::Base.deliveries.first.subject
      puts ActionMailer::Base.deliveries.first.body
    end
  end

  def test_should_create_recurring_payment
    pretend_now_is Time.parse("Tue Feb 26 15:05:58 UTC 2011") do
      @order, @payment = create_recurring_order_and_payment_with_sku_list(:invoice, "P020", "X001")
      assert_equal false, @payment.new_record?, "should not be new record"
      @payment = Payment.find_by_id(@payment.id)
      assert_equal 999, @payment.duration_occurrences
      assert_equal Date.parse("02/26/2011"), @payment.duration_start_date
      assert_equal 1, @payment.interval_length
      assert_equal "month", @payment.interval_unit
      assert_equal "47,48 €", @payment.amount.format
    end
  end
  
  protected
  
  def create_recurring_order_and_payment(type = :debit)
    monthly_20_abo_product = Product.find_by_sku("P020")
    paper_invoice_product = Product.find_by_sku("X001")
  
    @order = @advocate.purchase monthly_20_abo_product, paper_invoice_product
    @order.evaluate
  
    if type == :debit
      @order.preferred_payment_method = "debit"
      @order.preferred_billing_method = "pdf"
      @order.tax_number = "DE123456789"
      @order.bank_account_owner_name = "Aaron S. Schweizer"
      @order.bank_account_number = "576956"
      @order.bank_routing_number = "72151650"
      @order.bank_name = "Sparkasse Ingolstadt"
      @order.bank_location = "Ingolstadt"

      @payment_object = DebitBankPayment.new
    elsif type == :invoice
      @order.preferred_payment_method = "invoice"
      @order.preferred_billing_method = "pdf"
      @order.tax_number = "DE123456789"

      @payment_object = InvoicePayment.new
    end 

    assert_equal true, @order.valid?
  
    @payment = @order.recurring(@payment_object, {:ip => "192.168.1.1", 
      :bank_account_owner_name => @order.bank_account_owner_name, :bank_account_number => @order.bank_account_number,
        :bank_routing_number => @order.bank_routing_number, :bank_name => @order.bank_name, :bank_location => @order.bank_location,
          :interval => {:length => 1, :unit => :month}, 
            :duration => {:start_date => Date.today, :occurrences => 999}})
            
    assert_equal :pending, @order.current_state
    @advocate.reload
    return @order, @payment
  end

  def create_recurring_order_and_payment_with_sku_list(type = :debit, *args)
    products = []
    args.each do |sku|
      products << Product.find_by_sku(sku)
    end
    products.compact!
  
    assert_equal false, products.empty?, "should have a sku list"
  
    @order = @advocate.purchase products
    @order.evaluate
  
    if type == :debit
      @order.preferred_payment_method = "debit"
      @order.preferred_billing_method = "pdf"
      @order.tax_number = "DE123456789"
      @order.bank_account_owner_name = "Aaron S. Schweizer"
      @order.bank_account_number = "576956"
      @order.bank_routing_number = "72151650"
      @order.bank_name = "Sparkasse Ingolstadt"
      @order.bank_location = "Ingolstadt"

      @payment_object = DebitBankPayment.new
    elsif type == :invoice
      @order.preferred_payment_method = "invoice"
      @order.preferred_billing_method = "pdf"
      @order.tax_number = "DE123456789"

      @payment_object = InvoicePayment.new
    end 

    assert_equal true, @order.valid?
  
    @payment = @order.recurring(@payment_object, {:ip => "192.168.1.1", 
      :bank_account_owner_name => @order.bank_account_owner_name, :bank_account_number => @order.bank_account_number,
        :bank_routing_number => @order.bank_routing_number, :bank_name => @order.bank_name, :bank_location => @order.bank_location,
          :interval => {:length => 1, :unit => :month}, 
            :duration => {:start_date => Date.today, :occurrences => 999}})
            
    assert_equal :pending, @order.current_state
    @advocate.reload
    return @order, @payment
  end
  
end
