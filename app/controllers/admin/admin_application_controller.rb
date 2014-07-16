class Admin::AdminApplicationController < ApplicationController
  helper :front_application
  
  #--- filters
  before_filter :jquery_noconflict

  #--- layout
  layout 'admin'

  #--- active scaffold
  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
    config.dhtml_history = true
    
    config.search.link.page = false
    config.search.link.inline = true
    config.delete.link.page = false
    config.delete.link.inline = true
  end

  #--- actions
  
  def index
  end
  
  protected

  def ssl_required?
    Project.ssl_supported?
  end
  
  def user_class
    AdminUser
  end
  
  def user_session_param
    :admin_user_id
  end
  
  def return_to_param
    :admin_return_to
  end
  
  def account_controller
    '/admin'
  end

  def account_login_path
    new_admin_session_path
  end
  
  # Triggers the provided event and updates the list item.
  # Usage:     do_list_action(:suspend!)
  def do_list_action(event)
    @record = active_scaffold_config.model.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    if @record.send("#{event}")
      render :update do |page|
        page.replace element_row_id(:action => 'list', :id => params[:id]), 
          :partial => 'list_record', :locals => { :record => @record }
        page << "ActiveScaffold.stripe('#{active_scaffold_tbody_id}');"
      end
    else
      message = render_to_string :partial => 'errors'
      render :update do |page|
        page.alert(message)
      end
    end
  end

  # returns the name of the sub menu partial
  def sub_menu_partial_name
    "shared/sub_menu_empty"
  end
  helper_method :sub_menu_partial_name
  
  # for not clashing with prototype
  def jquery_noconflict
    ActionView::Helpers::PrototypeHelper.const_set(:JQUERY_VAR, 'jQuery')
  end
  
end
