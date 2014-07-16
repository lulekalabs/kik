# Common code to render an invoice in advocate account and admin backend
module InvoicesControllerBase

  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
  end
  
  protected
  
  PDF_PATH = "#{"#{RAILS_ROOT}/public/"}images/application/imageuploads/pdfs"
  
  GATEWAY_USERNAME = "kann-ich-klagen"
  GATEWAY_PASSWORD = "ZaYJxCBI" # "lu7ogohu"
  GATEWAY_ACCOUNT_NUMBER = 1010130771
  
  # find the invoice and renders the invoice if cached, signed, or renders it again
  def load_invoice_and_render
    @invoice = load_invoice unless @invoice

    respond_to do |format|
      format.html {
        @pdf = false
        render :template => "advocate/account/invoices/show", :layout => "pdf"
        return
      }
      format.pdf {
        @pdf = true
        if File.exist?(signed_invoice_pdf_path_and_file_name) && params[:generate].blank?
          send_file(signed_invoice_pdf_path_and_file_name, 
            :type => 'application/pdf', :disposition => "inline", 
              :filename => @invoice.human_pdf_filename)
        elsif File.exist?(unsigned_invoice_pdf_path_and_file_name) && params[:generate].blank?
          send_file(unsigned_invoice_pdf_path_and_file_name, 
            :type => 'application/pdf', :disposition => "inline", 
              :filename => @invoice.human_pdf_filename)
        else
          @pdf = params[:debug].blank?
          render_invoice :debug => !params[:debug].blank?
        end
      }
    end
  end
  
  def unsigned_invoice_pdf_file_name(invoice=@invoice)
    "#{invoice.number}.pdf"
  end

  def signed_invoice_pdf_file_name(invoice=@invoice)
    "#{invoice.number}-signed.pdf"
  end

  def unsigned_invoice_pdf_path_and_file_name(invoice=@invoice)
    "#{PDF_PATH}/#{unsigned_invoice_pdf_file_name(invoice)}"
  end

  def signed_invoice_pdf_path_and_file_name(invoice=@invoice)
    "#{PDF_PATH}/#{signed_invoice_pdf_file_name(invoice)}"
  end
  
  # renders the invoice only
  def render_invoice(options={})
    require_pdf_path
    render render_invoice_options(options)
  end
  
  # returns the correct render options used also in generate job
  def render_invoice_options(options={})
    debug = !!options.delete(:debug)
    options.symbolize_keys!
    options = {:template => "advocate/account/invoices/show",
      :save_to_file => "#{PDF_PATH}/#{@invoice.number}.pdf",
      :pdf => @invoice.human_pdf_filename, # @invoice.number
      :layout => "#{Rails.root}/app/views/layouts/pdf.html.erb",
      :show_as_html => debug,
      :footer => {:html => {:template => "#{Rails.root}/app/views/layouts/pdf_footer.pdf.erb"}},
      :margin => {:bottom => 29}}.merge(options)
    options
  end
    
  def load_invoice
    @invoice = PurchaseInvoice.find_by_id_or_number(params[:id])
  end

  # makes sure we have the path to store the PDFs
  def require_pdf_path
    unless File.exist?(PDF_PATH)
      FileUtils.mkdir_p(PDF_PATH)
      FileUtils.chmod(0644, PDF_PATH)
    end
    true
  end
  
  # sign invoice by sending it to https://www.signaturportal.de
  # https://github.com/bigcurl/signaturportal-sign-script
  def sign_invoice
    service = MyServiceHandler.new
    signed_pdf = service.sign(GATEWAY_USERNAME, GATEWAY_PASSWORD, GATEWAY_ACCOUNT_NUMBER, 
      signed_invoice_pdf_file_name, (File.open(unsigned_invoice_pdf_path_and_file_name, "r").read))

    File.open(signed_invoice_pdf_path_and_file_name, "w") do |back_out|
      back_out << signed_pdf
    end

    # chmod 644
    if File.exist?(signed_invoice_pdf_path_and_file_name)
      FileUtils.chmod(0644, signed_invoice_pdf_path_and_file_name)
    end
  end

end