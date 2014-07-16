# Generates invoice as PDF and signs it
#
# E.g.
#
#   Delayed::Job.enqueue GenerateAndSignInvoiceJob.new(9)
#   Delayed::Job.enqueue GenerateAndSignInvoiceJob.new("2391d00")
#
class GenerateAndSignInvoiceJob < Struct.new(:id)
  include InvoicesControllerBase

  # insert a render_to_string, just like in controllers, into the views, 
  # so that we can render with template and layout
  ActionView::Base.class_eval do
    
    def render_to_string(options={})
      template = self
      template.template_format = :html
      options[:file] = options.delete(:template)
      template.render options
    end
    
  end
  
  def perform
    if load_invoice
      if File.exist?(signed_invoice_pdf_path_and_file_name)
        # do nothing
        puts "-> nothing to do, invoice (#{signed_invoice_pdf_file_name}) is signed."
        return true
      elsif File.exist?(unsigned_invoice_pdf_path_and_file_name)
        # send pdf off to signaturportal.de using SMTP
        puts "-> sending invoice pdf (#{unsigned_invoice_pdf_file_name}) to signaturportal.de."
        InvoiceMailer.deliver_signature(@invoice)
        # soap signing
        puts "-> now signing invoice (#{unsigned_invoice_pdf_file_name}) using SOAP..."
        sign_invoice
        if File.exist?(signed_invoice_pdf_path_and_file_name)
          puts "-> invoice (#{signed_invoice_pdf_file_name}) signed."
        end
      else
        # none exist so generate the invoice pdf 
        puts "-> creating invoice (#{unsigned_invoice_pdf_file_name})..."
        render_invoice
        if File.exist?(unsigned_invoice_pdf_path_and_file_name)
          # send file off to signaturportal.de
          puts "-> sending invoice pdf (#{unsigned_invoice_pdf_file_name}) to signaturportal.de."
          InvoiceMailer.deliver_signature(@invoice)
          puts "-> signing invoice (#{unsigned_invoice_pdf_file_name}) using SOAP..."
          # if generated succcessfully, sign it
          sign_invoice
          if File.exist?(signed_invoice_pdf_path_and_file_name)
            puts "-> invoice (#{signed_invoice_pdf_file_name}) created and signed."
          end
        end
      end
    else
      puts "-> invoice ##{id} not found."
    end
  end    
  
  protected

  # override from base
  def load_invoice
    @invoice = PurchaseInvoice.find_by_id_or_number(id)
  end
  
  # overrides from base
  def render_invoice
    @invoice = load_invoice unless @invoice
    @template = ActionView::Base.new(Rails::Configuration.new.view_path, {:invoice => @invoice, :pdf => true}, self)
    @template.extend FrontApplicationHelper
    require_pdf_path
    @template.send :render, render_invoice_options(
      :save_only => true, :save_to_file => "#{PDF_PATH}/#{@invoice.number}.pdf")
  end
  
end

