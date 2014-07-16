class RecurringOrdersJob

  def perform
    #--- invoice payments -> authorize'em
    Order.recurring.with_invoice_payment.sufficient_occurrances.due(Date.today).each do |order|
      begin
        buyer = order.buyer
        quantity = buyer.overdrawn_contact_transactions.uncleared.within(order.service_period_start_on, order.service_period_end_on).sum(:amount)
        if (product = Product.find_by_sku("K001")) && quantity > 0
          cart = Cart.new("EUR")
          cart.add(product, quantity)
          payment = order.authorize_recurring nil, :add_line_items => cart.line_items
          if payment.success?
            buyer.overdrawn_contact_transactions.uncleared.within(order.service_period_start_on, order.service_period_end_on).each do |ct|
              ct.update_attributes({:cleared_at => Time.now.utc})
            end
          end
        else
          order.authorize_recurring
        end
      rescue Merchant::Sidekick::RecurringPaymentError => ex
        order.description ||= ""
        order.description += "\r\n\r\n" + ex.message
        order.cancel!
      end
    end

    #--- debit bank payments -> pay'em 
    Order.recurring.with_debit_bank_payment.sufficient_occurrances.due(Date.today).each do |order|
      begin
        buyer = order.buyer
        quantity = buyer.overdrawn_contact_transactions.uncleared.within(order.service_period_start_on, order.service_period_end_on).sum(:amount)
        if (product = Product.find_by_sku("K001")) && quantity > 0
          cart = Cart.new("EUR")
          cart.add(product, quantity)
          payment = order.pay_recurring nil, :add_line_items => cart.line_items
          if payment.success?
            buyer.overdrawn_contact_transactions.uncleared.within(order.service_period_start_on, order.service_period_end_on).each do |ct|
              ct.update_attributes({:cleared_at => Time.now.utc})
            end
          end
        else
          order.pay_recurring
        end
      rescue Merchant::Sidekick::RecurringPaymentError => ex
        order.description ||= ""
        order.description += "\r\n\r\n" + ex.message
        order.cancel!
      end
    end
  end

end  
