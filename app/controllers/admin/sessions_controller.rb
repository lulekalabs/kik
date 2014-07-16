class Admin::SessionsController < Admin::AdminApplicationController
  include SessionsControllerBase
  helper :front_application

  #--- layout (override)
  layout 'front'

  #--- filters
  skip_before_filter :login_required, :only => [:new, :create]

  # render new.rhtml
  def new
  end
  
  def create
    create_session
  end

  def destroy
    destroy_session
  end

  protected 
  
  # override from SessionsControllerBase
  def remember_me?
    false
  end

  private
  
  def authenticate_user(login, password, options={})
    user_class.authenticate(params[:user][:login], params[:user][:password])
  end

  def main_menu_class_name
    # dummy to display session login in front layout
  end
  helper_method :main_menu_class_name
  
end
