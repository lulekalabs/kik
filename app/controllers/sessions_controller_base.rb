# all methods that are shared between front application sessions in 
# front application and account application
module SessionsControllerBase
  def self.included(base)
    base.send :helper_method, :remember_me?
    base.extend(ClassMethods)
    base.send :alias_method_chain, :ssl_required?, :supported
  end
  
  module ClassMethods
  end
  
  protected

  #--- constants
  MESSAGE_LOGIN_ERROR = "Login und Passwort stimmen leider nicht überein"
  MESSAGE_LOGIN_SUCCESS = "Anmeldung war erfolgreich"
  MESSAGE_LOGOUT_SUCCESS = "Abmeldung war erfolgreich"
  
  #--- helpers
  
  def authentication_success_url
    # override in controller, to tell where we should en up after successfully creating the session
  end
  
  # intercept ssl_supported? from ssl_requirement
  def ssl_required_with_supported?
    ssl_supported? ? ssl_required_without_supported? : false
  end

  # called from session/create to initiate the session
  def create_session
    self.current_user = authenticate_user(params[:user][:login], params[:user][:password], :trace => true)
    
    # store remember me in token
    if logged_in?
      if params[:user][:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[cookie_auth_token] = {
          :value => self.current_user.remember_token, :expires => self.current_user.remember_token_expires_at
        }
      end
      
      # callback :after_authentication_success
      self.send(:after_authentication_success, self.current_user) if self.respond_to?(:after_authentication_success)
      
      if !performed? && request.xhr?
        render :update do |page|
          # JS code to close modal
          # update page header to show user information
        end
      elsif !performed?
        flash[:notice] = MESSAGE_LOGIN_SUCCESS
        redirect_back_or_default(authentication_success_url || '/')
      end
    else
      # callback :after_authentication_error
      self.send(:after_authentication_error, self.current_user) if self.respond_to?(:after_authentication_error)
      if !performed? && request.xhr?
        render :update do |page|
          # JS code to re-display login dialog
        end
      elsif !performed?
        flash[:error] = user_class.is_suspended?(params[:user][:login], params[:user][:password]) ? 
          "Login nicht möglich, da Benutzer gesperrt wurde." : 
            MESSAGE_LOGIN_ERROR
        render :action => 'new'
      end
    end
  end
  
  # called from session/destroy to tear down the user session
  def destroy_session(redirect_location='/')
    self.current_user.forget_me if logged_in?
    reset_session
    cookies.delete cookie_auth_token
    if redirect_location
      flash[:notice] = MESSAGE_LOGOUT_SUCCESS
      redirect_to(redirect_location)
    end
  end

  # returns true if a remember me check box option in the login view should be provided
  def remember_me?
    raise 'Must define remember_me? method'
  end
  
  private
  
  def authenticate_user(login, password, options={})
    user_class.authenticate(params[:user][:login], params[:user][:password], :trace => true)
  end
  
end