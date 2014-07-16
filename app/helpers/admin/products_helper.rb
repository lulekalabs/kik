module Admin::ProductsHelper

  def active_column(record)
    record.active? ? "Ja" : "Nein"
  end

  def subscription_column(record)
    record.is_subscription? ? "Ja" : "Nein"
  end
  
  def contacts_column(record)
    if record.flat?
      "unbegrenzt"
    elsif record.contacts.nil?
      "-"
    else
      result = "#{record.contacts}"
    end
  end

  def tax_rate_column(record)
    number_to_percentage(record.tax_rate, :precision => 1)
  end

end
