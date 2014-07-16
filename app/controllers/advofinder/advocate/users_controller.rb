# create a new advocate 
class Advofinder::Advocate::UsersController < Advofinder::Advocate::AdvocateApplicationController
  include AdvocateUsersControllerBase
  
  #--- filters
  prepend_before_filter :set_default_fields

  #--- actions
  
  def new
    @user = build_user
  end
  
end
