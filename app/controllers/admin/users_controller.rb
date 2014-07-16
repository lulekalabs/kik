class Admin::UsersController < Admin::AdminApplicationController

  #--- filters
  skip_before_filter :login_required, :only => [:forgot_password, :create_new_password, :forgot_password_complete]
  after_filter :discard_flash
  # before_filter :load_user, :only => [:change_password, :update_change_password]

  #--- layout
  layout :choose_layout

  #--- active scaffold
  active_scaffold :user do |config|
    #--- columns
    standard_columns = [
      :id,
      :login,
      :login_confirmation,
      :email,
      :email_confirmation,
      :state,
      :activated_at,
      :deleted_at,
      # assocations
      :person
    ]
    crud_columns = [
      :login,
      :password,
      :password_confirmation,
      :person
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns + [:state]
    config.list.columns = [:login, :person, :state, :activated_at]
    
    #--- actions
    config.actions.exclude :create

    #--- action links
    
    # suspend
    toggle_suspend_link = ActiveScaffold::DataStructures::ActionLink.new 'Sperren', 
      :action => 'toggle_suspend', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie wirklich den Status des Benutzers ändern?"
    def toggle_suspend_link.label
      return "[Sperren]" if record.next_state_for_event(:suspend)
      return "[Reaktivieren]" if record.next_state_for_event(:unsuspend)
      ''
    end
    config.action_links.add toggle_suspend_link

    # activate
    do_activate_link = ActiveScaffold::DataStructures::ActionLink.new 'Aktivieren', 
      :action => 'activate', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Benutzer jetzt aktivieren?"
    def do_activate_link.label
      return "[Aktivieren]" if record.current_state == :inactive && record.next_state_for_event(:activate)
      ''
    end
    config.action_links.add do_activate_link

    # approve
    do_approve_link = ActiveScaffold::DataStructures::ActionLink.new 'Zulassen', 
      :action => 'approve', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Benutzer jetzt zur weiteren Registrierung zulassen?"
    def do_approve_link.label
      return "[Zulassen]" if record.current_state == :preapproved && record.next_state_for_event(:approve)
      ''
    end
    config.action_links.add do_approve_link

    
  end

  #--- actions

  def toggle_suspend
    @record = User.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    
    if @record.next_state_for_event(:suspend)
      do_list_action(:suspend!)
      return
    elsif @record.next_state_for_event(:unsuspend)
      do_list_action(:unsuspend!) 
      return
    elsif @record.current_state == :screening && @record.next_state_for_event(:accept)
      do_list_action(:accept!) 
      return
    end
    render :nothing => true
  end

  def activate
    @record = User.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    
    if @record.current_state == :inactive && @record.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end
  
  def approve
    @record = User.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record.current_state == :preapproved && @record.next_state_for_event(:approve)
      do_list_action(:approve!)
      return
    end
    render :nothing => true
  end
  
  # :get /admin/user/forgot_password
  def forgot_password
    respond_to do |format|
      format.js {
      }
      format.html {
      }
    end
  end
  
  # :post /admin/user/create_new_password
  def create_new_password
    if @user = AdminUser.find_by_credential(params[:user][:login])
      @user.create_reset_password
      # flash[:notice] = "Sie erhalten in Kürze ein neues Passwort per E-Mail."
      respond_to do |format|
        format.js {
        }
        format.html {
          redirect_to forgot_password_complete_admin_users_path
          return
        }
      end
    end
    flash[:error] = "Benutzername, E-Mail oder Benutzerkennung konnte nicht gefunden werden."
    respond_to do |format|
      format.js {
      }
      format.html {
        render :template => "admin/users/forgot_password"
      }
    end
  end
  
  def forgot_password_complete
  end
  
  protected

  def before_create_save(record)
    @record.register! if @record.valid?
    if @record.errors.empty?
      @record.activate!
    end
  end

  def load_user
    if params[:id]
      @user = AdminUser.find_by_credential(params[:id])
    else
      @user = current_user
    end
  end
  
  def choose_layout
    %w(forgot_password create_new_password forgot_password_complete).include?(action_name) ? 'front' : 'admin'
  end
  
  def main_menu_class_name
    # dummy to display session login in front layout
  end
  helper_method :main_menu_class_name

end
