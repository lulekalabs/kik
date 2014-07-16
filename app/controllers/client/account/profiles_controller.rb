# Edit client's profile
class Client::Account::ProfilesController < Client::Account::ClientAccountApplicationController
  
  #--- filters
  before_filter :load_person
  
  #--- actions
  
  def show
  end
  
  def update
    @person.attributes = params[:person]
    self.save if self.valid?
    render_show
  end
  
  def create_enrollment
    @person.newsletter = true
    if @person.enrollment? && @person.enrollment.pending?
      @person.enrollment.register!  # fire register again to resend activation link
    else
      @person.create_enrollment(false)
    end
    @person.reload
    render_show
  end
  
  def destroy_enrollment
    @person.destroy_enrollment
    @person.reload
    render_show
  end
  
  def destroy_image
    @person.image.destroy
    @person.save
    render_show
  end
  
  def update_password
    @user.attributes = params[:user]
    @user.persist = true
    @user.password_is_generated = false
    @user.password_required!
    if @user.valid?
      @user.save 
      flash[:notice] = "Ihr Passwort wurde erfolgreich geändert."
    end
    render_show
  end
  
  protected
  
  def set_default_fields
    User.default_fields = {
      :current_password => "Altes Passwort*",
      :password => "Neues Passwort*",
      :password_confirmation => "Passwort wiederholen*",
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    defaults = {}
    defaults = defaults.merge(@user.default_fields_with_name(:user)) if @user
    defaults
  end
  helper_method :default_fields
  
  def render_show
    if params[:sidebar_select] =~ /image/ 
      @error_header_message = "Fehler in Mein Profilbild"
    elsif params[:sidebar_select] =~ /change_password/ 
      @error_header_message = "Fehler in Mein Passwort ändern"
    end
    
    respond_to do |format|
      format.html {
        if self.valid?
          redirect_to client_account_profile_path
          return
        end
        render :template => "client/account/profiles/show"
      }
      format.js {
        @valid = self.valid?
        if params[:iframe] =~ /^(1|true)/
          responds_to_parent do
            render :update do |page|
              page.replace dom_id(@person), :partial => "client/account/profiles/show", :locals => {:edit => !@valid}
            end
          end
        else
          render :update do |page|
            page.replace dom_id(@person), :partial => "client/account/profiles/show", :locals => {:edit => !@valid}
          end
        end
      }
    end
  end
  
  def save
    ar = @person.personal_address ? @person.personal_address.save : true
    pr = @person.save
    ar && pr
  end
  
  def valid?
    @user.valid? && @person.valid? && (@person.personal_address && @person.personal_address.valid?)
  end
  
  def load_person
    @person = current_user.person
    @person.build_personal_address(:country_code => "DE") unless @person.personal_address
  end
  
end
