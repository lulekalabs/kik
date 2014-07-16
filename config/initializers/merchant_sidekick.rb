#--- Money + ExchangeRate
Money.default_currency = "EUR"

#--- active merchant
ActiveMerchant::Billing::CreditCard.require_verification_value = true

#--- merchant sidekick
LineItem.tax_rate_class_name = "TaxRate"
