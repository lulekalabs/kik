# holds all help pages, like "what is..."
class HelpPagesController < PagesController
  
  #--- actions
  
  def what
    if af_realm?
      render :template => "advofinder/help_pages/what"
    else
      render :template => "help_pages/what"
    end
  end
  
  def how
    if af_realm?
      render :template => "advofinder/help_pages/how"
    else
      render :template => "help_pages/how"
    end
  end
  
  def tips_and_infos
    if af_realm?
      render :template => "advofinder/help_pages/tips_and_infos", :layout => "modal"
    else
      render :template => "help_pages/tips_and_infos", :layout => "modal"
    end
  end
  
  protected
  
  def main_menu_class_name
    action_name
  end

  # override
  def sub_menu_partial_name
    "shared/sub_menu_empty"
  end
  
end
