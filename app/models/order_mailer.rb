class OrderMailer < Notifier

  # Ticket #860
  def confirmation(order)
    setup_email(order)
    if order.buyer.current_product_subscription
      @subject = "Bestätigung für #{order.buyer.title_and_name}: Wechsel in #{@product_subscription.name}"
    else
      @subject = "Bestätigung für #{order.buyer.title_and_name}: #{@product_subscription.name} erworben"
    end
  end

  # obsolete
  def paid(order)
    setup_email(order)
    @subject = "#{order.buyer.title_and_name}, Ihre bestellten Inklusivkontakte sind jetzt auf kann-ich-klagen.de verfügbar"
  end

  # Ticket ?
  def canceled(order)
    setup_email(order)
    @subject = "#{order.buyer.title_and_name}, Ihre Bestellung auf kann-ich-klagen.de wurde storniert"
  end

  def notify(order)
    setup_email(order)
    @recipients    = self.admin_email
    @from          = self.admin_email
    if order.buyer.current_product_subscription
      @subject = "#{order.buyer.salutation_and_title_and_last_name} ist in das #{@product_subscription.name} gewechselt"
    else
      @subject = "#{order.buyer.salutation_and_title_and_last_name} hat #{@product_subscription.name} bestellt"
    end
  end

  protected
  
  def setup_email(order)
    load_settings
    @recipients  = "#{order.buyer.first_name} #{order.buyer.last_name} <#{order.buyer.email}>"
    @from        = self.admin_email
    @subject     = "#{self.site_url} "
    
    @sent_on         = Time.now.utc
    @body[:order]    = order
    @body[:customer] = order.buyer
    @body[:product_subscription] = @product_subscription = order.line_item_product_subscriptions.first
  end
    
end
