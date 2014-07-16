# controller to handle site login
class SessionsController < FrontApplicationController
  include SessionsControllerBase

  #--- filters
  skip_before_filter :login_required, :only => [:new, :create]
  after_filter :discard_flash

  # render new.rhtml
  def new
    render :template => request.xhr? ? "sessions/new_modal" : "sessions/new"
  end
  
  def create
    create_session
  end

  def destroy
    destroy_session
  end

  protected 
  
  def ssl_required?
    Project.ssl_supported?
  end
  
  def main_menu_class_name
    ""
  end
  
  # override
  def sub_menu_partial_name
    "pages/sub_menu"
  end
  
  # override from SessionsControllerBase
  def remember_me?
    true
  end

  # code executed before redirect_to authentication_success_url happens
  def after_authentication_success(user)
    # update contacts count
    if user.person && user.person.is_a?(Advocate)
      user.person.update_contacts_count
    end
    
    # redirect to change password
    if user.password_is_generated?
      redirect_to change_password_users_path
      # redirect_back_or_default change_password_users_path
      return
    end
  end
  
  # override from session controller base
  def authentication_success_url
    account_url
  end

  private
  
  def authenticate_user(login, password, options={})
    user_class.authenticate(params[:user][:login], params[:user][:password])
  end

end
