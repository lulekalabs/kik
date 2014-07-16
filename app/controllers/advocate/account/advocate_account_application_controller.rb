# Handles the advocate account "Mein Bereich"
class Advocate::Account::AdvocateAccountApplicationController < Advocate::AdvocateApplicationController

  #--- filters
  before_filter :login_required
  before_filter :advocate_account_required

  #--- actions
  
  def show
  end

  def bills
    @invoices = current_user.person.purchase_invoices.paid.find(:all, :limit => 5, 
      :order => "invoices.paid_at DESC") 
  end

  protected

  def ssl_allowed?
    ssl_supported?
  end

  def ssl_required?
    ssl_supported?
  end
  
  def main_menu_class_name
    "my_site"
  end

  def sub_menu_partial_name
    "advocate/account/sub_menu"
  end

  # makes sure the current user is an advocate
  def advocate_account_required
    if logged_in? && !current_user.person.is_a?(Advocate)
      redirect_to account_path
      return
    end
  end
  
end
