# Client account area for all sub controllers
class Client::Account::ClientAccountApplicationController < Client::ClientApplicationController
  
  #--- filters
  before_filter :login_required
  before_filter :client_account_required
  
  #--- actions
  
  def show
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
    "client/account/sub_menu"
  end
  
  # makes sure the current user is an advocate
  def client_account_required
    if logged_in? && !current_user.person.is_a?(Client)
      redirect_to account_path
      return
    end
  end
  
end
