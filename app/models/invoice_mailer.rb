#
# signaturportal.de
# login: kann-ich-klagen
# pw: tilura7e
#
class InvoiceMailer < Notifier

  PDF_PATH = "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/pdfs"

  def signature(invoice)
    setup_email(invoice)
    @subject     = "#{invoice.buyer.title_and_name}, Ihre Rechnung #{invoice.human_number} vom #{I18n.l(invoice.created_at.to_date)}"
    part :content_type => "text/plain", 
      :body => render_message("signature", :invoice => invoice, :customer => invoice.buyer)  
    attachment :content_type => "application/pdf", :filename => invoice.human_pdf_filename,
      :body => File.read("#{PDF_PATH}/#{invoice.number}.pdf")
  end
  
  protected
  
  def setup_email(invoice)
    load_settings("signaturportal_#{Project.realm}")
    @recipients  = "#{invoice.buyer.first_name} #{invoice.buyer.last_name} <#{invoice.buyer.email}>"
    @from        = self.signaturportal_email
    @subject     = "#{self.site_url} "
    
    @sent_on         = Time.now.utc
    @body[:invoice]  = invoice
    @body[:customer] = invoice.buyer
  end

end
