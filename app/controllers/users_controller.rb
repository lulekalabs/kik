class UsersController < FrontApplicationController
  
  #--- filters
  after_filter :discard_flash
  before_filter :load_user, :only => [:change_password, :update_change_password]
  
  #--- actions
  
  # :get /user/forgot_password
  def forgot_password
    respond_to do |format|
      format.js {
      }
      format.html {
      }
    end
  end
  
  # :post /user/create_new_password
  def create_new_password
    if @user = User.find_by_credential(params[:user][:login])
      @user.create_reset_password
      # flash[:notice] = "Sie erhalten in Kürze ein neues Passwort per E-Mail."
      respond_to do |format|
        format.js {
        }
        format.html {
          redirect_to forgot_password_complete_users_path
          return
        }
      end
    end
    flash[:error] = "Benutzername, E-Mail oder Benutzerkennung konnte nicht gefunden werden."
    respond_to do |format|
      format.js {
      }
      format.html {
        render :template => "users/forgot_password"
      }
    end
  end
  
  def forgot_password_complete
  end

  def change_password
  end

  # :put /users/<reset-code>/update_change_password
  def update_change_password
    @user.attributes = params[:user]
    # @user.password_required!
    @user.persist = true
    @user.password_is_generated = false
    @user.password_required!
    if @user.save
      # self.current_user = nil 
      flash[:notice] = "Ihr Passwort wurde erfolgreich geändert."
      # redirect_to(new_session_path)
      redirect_to change_password_complete_users_path
      return
    end
    render :template => "users/change_password"
  end
  
  def complete_change_password
  end
  
  protected
  
  def ssl_required?
    Project.ssl_supported?
  end
  
  def main_menu_class_name
    ""
  end
  
  # override
  def sub_menu_partial_name
    "pages/sub_menu"
  end
  
  def load_user
    if params[:id]
      @user = User.find_by_credential(params[:id])
    else
      @user = current_user
    end
  end
  
end
