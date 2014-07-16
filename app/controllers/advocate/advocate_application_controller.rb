# parent for all advocate controllers
class Advocate::AdvocateApplicationController < FrontApplicationController
  
  #--- filters
  before_filter :check_for_pre_launch, :only => [:help, :open_questions ] 
  before_filter :build_recommendation, :only => [:new, :create, :update, :confirm]

  protected
  
  def main_menu_class_name
    "advocate"
  end

  def sub_menu_partial_name
    "advocate/sub_menu"
  end
  
  # builds recommendation if necessary
  # override in subclass, like users_controller and recommendations_controller
  def build_recommendation
  end

end
