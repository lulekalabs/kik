# This is the place for now to keep track of advocate invoices 
class Advocate::Account::InvoicesController < Advocate::Account::AdvocateAccountApplicationController
  include InvoicesControllerBase

  #--- filters
  before_filter :check_for_pre_launch  

  #--- layout
  # layout "pdf"

  #--- actions

  def show
    load_invoice_and_render
  end

end
