# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  htpasswd :user => "stage", :pass => "staging" if RAILS_ENV == 'staging'

  prepend_before_filter :set_realm
  before_filter :login_required 
  before_filter :store_previous

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  include SslRequirement

  protected
  
  def ssl_supported?
    Project.ssl_supported?
  end
  helper_method :ssl_supported?
  
  # renders a splash screen if action is not permitted for pre-launch
  def check_for_pre_launch
    if Project.pre_launch? && !session[:open_sesame] && !pre_launch_redirect_path.blank?
      redirect_to pre_launch_redirect_path
      return
    end
    true
  end

  # are we in pre launch mode?
  def pre_launch?
    Project.pre_launch? && !session[:open_sesame]
  end
  helper_method :pre_launch?

  def set_realm
    Project.realm = session[:site_realm] || "kik"
  end

  # are we in the advofinder theme
  def af_realm?
    session[:site_realm] == "advofinder"
  end
  helper_method :af_realm?

  # are we in the kik native theme
  def kik_realm?
    session[:site_realm].blank? || session[:site_realm] == "kik"
  end
  helper_method :kik_realm?
  
  # pre launch path
  def pre_launch_redirect_path
    pre_launch_splash_path
  end

  # loads @user and @person instance variables if logged in
  def load_user_and_person
    if logged_in?
      @user = self.current_user
      @person = @user.person if @user
    end
  end
  
  # returns the name of the sub menu partial
  def sub_menu_partial_name
    "sub_menu"
  end
  helper_method :sub_menu_partial_name

  # used in header partial to determine the css class name
  # override in subclass
  def main_menu_class_name
    raise "override main_menu_class_name for header in the controller"
  end
  helper_method :main_menu_class_name

  # back parameter for session id, override in sub controller
  def return_to_previous_param
    :redirect_previous
  end

  # current parameter for session id, override in sub controller
  def return_to_current_param
    :redirect_current
  end

  # saves the redirect back location
  def store_previous
    unless request.xhr?
      session[return_to_previous_param] = session[return_to_current_param]
      session[return_to_current_param] = request.get? ? request.request_uri : request.env["HTTP_REFERER"]
    end
  end

  # url to the previous url location stored in the session
  def return_to_previous_url
    session[return_to_previous_param]
  end
  helper_method :return_to_previous_url

  # url to the current url location stored in the session
  def return_to_current_url
    session[return_to_current_param]
  end
  helper_method :return_to_current_url

  # Redirect to the URI stored by the most recent store_previous call or
  # to the passed default.
  def redirect_previous_or_default(default)
    redirect_to(return_to_previous_url || default)
    session[return_to_previous_param] = nil
    session[return_to_current_param] = nil
  end

  # temporarily sets the template format to something else
  # there is a view helper that works the same, this is used
  # in sessions controller to implement AJAX session login.
  #
  # e.g.
  #   ...
  #   format.js
  #     with_format :html do
  #       render :partial => 'foo' # will render foo.html.erb instead of foo.js.erb
  #     end
  #   end
  #   ...
  #
  def with_format(format)
    old_format = response.template.template_format
    response.template.template_format = format
    yield
    response.template.template_format = old_format
  end

  def discard_flash
    flash.discard
  end

  private

  # override ssl requirement to redirect to a "www." subdomain for https requests
  def ensure_proper_protocol
    return true if ssl_allowed?

    if ssl_required? && !request.ssl?
      host = request.subdomains.empty? ? "www.#{request.host}" : request.host.gsub(request.subdomains.first, "www")
      redirect_to "https://" + host + request.request_uri
      return false
    elsif request.ssl? && !ssl_required?
      redirect_to "http://" + request.host + request.request_uri
      return false
    end
  end
  
end
