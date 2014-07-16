module Admin::VouchersHelper
  
  def expires_at_column(record)
    record.expires_at && record.expires_at < Time.now.utc ? 
      content_tag(:span, record.expires_at, :style => "color:#ff0000;") : 
        content_tag(:span, record.expires_at, :style => "")
  end
  
  def multiple_redeemable_column(record)
    record.multiple_redeemable ? "Ja" : "Nein"
  end
  
end
