module AuthenticatedSystem
  protected
  
    def user_session_param
      raise 'Must define a user_session_param method'
    end
  
    def return_to_param
      raise 'Must define a return_to_param method'
    end
    
    def user_class
      raise 'Must define a user_class method'
    end 
    
    def account_controller
      raise 'Must define an account_controller method'
    end

    def account_login_path
      raise 'Must define an URL path to the login dialog'
    end
    
    def cookie_auth_token
      "#{user_session_param}_auth_token".to_sym
    end

    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !!current_user
    end

    # Accesses the current user from the session. 
    # Future calls avoid the database because nil is not equal to false.
    def current_user
      @current_user ||= (login_from_session || login_from_basic_auth || login_from_cookie) unless @current_user == false
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      session[user_session_param] = new_user ? new_user.id : nil
      @current_user = new_user || false
    end

    def current_customer
      return current_user.customer if current_user
      nil
    end

    # Check if the user is authorized
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorized?
    #    current_user.login != "bob"
    #  end
    def authorized?
      logged_in?
    end

    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      authorized? || access_denied
    end

    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
      respond_to do |format|
        format.html do
          store_location
          redirect_to account_login_path
        end
        format.any do
          request_http_basic_authentication 'Web Password'
        end
      end
    end

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[return_to_param] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      redirect_to(session[return_to_param] || default)
      session[return_to_param] = nil
    end
    
    def return_to_url
      session[return_to_param]
    end

    def return_to_url_or_default(default)
      return_to_url || default
    end

    def store_shopping_location
      session[:return_to_shopping] = request.request_uri
    end

    def redirect_back_to_shopping_or_default(default)
      redirect_to(session[:return_to_shopping] || default)
      session[:return_to_shopping] = nil
    end

    def return_to_shopping_url
      session[:return_to_shopping]
    end

    def return_to_shopping_url_or_default(default)
      return_to_shopping_url || default
    end

    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :current_customer, :logged_in?, :return_to_url, :return_to_url_or_default, :store_shopping_location, :redirect_back_to_shopping_or_default, :return_to_shopping_url, :return_to_shopping_url_or_default
    end

    # Called from #current_user.  First attempt to login by the user id stored in the session.
    def login_from_session
      self.current_user = user_class.find_by_id(session[user_session_param]) if session[user_session_param]
    end

    # Called from #current_user.  Now, attempt to login by basic authentication information.
    def login_from_basic_auth
      authenticate_with_http_basic do |username, password|
        self.current_user = user_class.authenticate(username, password)
      end
    end

    # Called from #current_user.  Finaly, attempt to login by an expiring token in the cookie.
    def login_from_cookie
      user = cookies[cookie_auth_token] && user_class.find_by_remember_token(cookies[cookie_auth_token])
      if user && user.remember_token?
        cookies[cookie_auth_token] = { :value => user.remember_token, :expires => user.remember_token_expires_at }
        self.current_user = user
      end
    end
end
