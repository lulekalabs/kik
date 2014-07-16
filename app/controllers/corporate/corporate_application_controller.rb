# Covers the pages under "Unternehmen"
class Corporate::CorporateApplicationController < FrontApplicationController
  
  #--- filters
  before_filter :check_for_pre_launch, :only => [  ]

  #--- layout
  layout :choose_layout
  
  protected
  
  def main_menu_class_name
    ""
  end
  
  # override
  def sub_menu_partial_name
#    action_name == "sitemap" ? 'shared/sub_menu_empty' : "pages/sub_menu"
    "shared/sub_menu_empty"
  end  

  # returns true if appears in a popup
  def popup?
    !!(params[:popup] && params[:popup] =~ /1|true/i)
  end
  helper_method :popup?

  def choose_layout
    if af_realm?
      popup? ? "popup" : "advofinder"
    else
      popup? ? "popup" : "front"
    end
  end
  
end
