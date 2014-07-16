# manages advocate instances
class Advocate::UsersController < Advocate::AdvocateApplicationController
  include AdvocateUsersControllerBase

  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :load_current_registering_user_or_redirect, :only => [:confirm]
  before_filter :load_pending_user_or_redirect, :only => [:activate]
  before_filter :load_user_or_redirect, :only => [:update]

  #--- actions

  def index
  end

  def new
    @user = build_user
  end 
  
  def create
    @user = build_user
    # Note: We have to validate both, even though, in User there is a validates_associated :person
    #       apparently, there is a bug with validates_associated :person, :message => nil
    if @user.valid? && @person.valid?
      @user.register!
      self.current_registering_user = @user
      redirect_to confirm_advocate_users_path
      return
    end
    render :template => "advocate/users/new"
  end
  
  # confirmed registration
  def confirm
  end
  
  # finished activation
  def complete
  end
  
  # landing page to active registration
  def activate
    activate_and_redirect_to activated_advocate_users_path
  end
  
  # resend activation
  def resend
    if @user = User.find_by_activation_code(params[:id])
      @user.resend_registered
      flash[:notice] = "Die E-Mail zur Bestätigung und Aktivierung Ihrer Anmeldung wurde Ihnen erneut gesendet."
    end
    redirect_to confirm_advocate_users_path
  end
  
  # activate
  def update
    activate_and_redirect_to advocate_path
  end
  
  protected

end
