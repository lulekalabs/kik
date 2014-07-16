# parent to all portal pages, for now includes also home page
class PagesController < FrontApplicationController

  #--- actions
  def single_home
  end
  
  def index
  end
  
  def pre_launch_splash
  end
  
  def open_sesame
    session[:open_sesame] = request.remote_ip
    redirect_to "/"
  end

  def close_sesame
    session[:open_sesame] = nil
    redirect_to "/" # advocate_path
  end

  # reset the realm so we are in kik native theme
  def set_kik_realm
    Project.realm = "kik"
    session[:site_realm] = Project.realm
    redirect_to "/"
  end

  # set the theme to advofinder
  def set_af_realm
    Project.realm = "advofinder"
    session[:site_realm] = Project.realm
    redirect_to "/"
  end
  
  protected
  
  def main_menu_class_name
    ""
  end
  
  # override
  def sub_menu_partial_name
    "pages/sub_menu"
  end
  
end
