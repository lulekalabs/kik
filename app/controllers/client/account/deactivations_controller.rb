# Handles the deactivation account views
class Client::Account::DeactivationsController < Client::Account::ClientAccountApplicationController
  include SessionsControllerBase
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :build_message
  after_filter :discard_flash
  
  #--- actions
  
  def show
  end
  
  def create
    @user.attributes = params[:user]
    if self.valid?
      if user = User.authenticate(@user.login, @user.password)
        @message.deliver!
        user.suspend!
        current_user = nil
        destroy_session
        return
      else
        if @user.password.blank? && @user.password_confirmation.blank?
          flash[:error] = "Passwort und die Bestätigung Ihres Passworts muss ausgefüllt werden."
        else
          flash[:error] = "Passwort und die Bestätigung Ihres Passworts wurden nicht korrekt eingegeben."
        end
      end
    end
    render :template => "client/account/deactivations/show"
  end
  
  protected
  
  def set_default_fields
    DeactivationMessage.default_fields = {
      :message => "Grund für die Deaktivierung",
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    defaults = {}
    defaults = defaults.merge(@message.default_fields_with_name(:deactivation_message)) if @message
    defaults
  end
  helper_method :default_fields
  
  # builds deactivation message
  def build_message(options={})
    @message = DeactivationMessage.new((params[:deactivation_message] || {}).symbolize_keys.merge({
      :sender => current_user.person}).merge(options))
  end

  # all valid?
  def valid?
    ur = @user.valid?
    mr = @message.valid?
    ur && mr
  end
  
  def discard_flash
    flash.discard
  end

end
