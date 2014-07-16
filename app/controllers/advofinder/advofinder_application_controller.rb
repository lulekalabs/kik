# Manages the entire Advofinder service
class Advofinder::AdvofinderApplicationController < ApplicationController
  helper :all # include all helpers, all the time

  #--- filters
  prepend_before_filter :check_for_pre_launch
  prepend_before_filter :check_for_af_realm
  skip_before_filter :login_required
  before_filter :load_user_and_person

  #--- layout
  layout 'advofinder'
  
  #--- actions
  def index
  end
  
  def what
  end
  
  def system
  end
  
  protected
  
  def ssl_allowed?
    ssl_supported?
  end

  def user_class
    User
  end
  
  def client_class
    Client # <- replace by AdvofinderClient
  end

  def advocate_class
    Advocate # <- replace by AdvofinderAdvocate
  end
  
  def user_session_param
    :user_id
  end
  
  def return_to_param
    :return_to
  end
  
  def account_controller
    new_session_path
  end

  def account_login_path
    new_session_path
  end

  def main_menu_class_name
    "start"
  end

  def sub_menu_partial_name
    "shared/sub_menu_empty"
  end
  
  # make sure page is accessible only in advofinder realm
  def check_for_af_realm
    unless af_realm?
      respond_to do |format|
        format.js {
          render :update do |page|
            page.redirect_to "/"
          end
        }
        format.all {
          redirect_to "/"
        }
      end
      return false
    end
  end
  
  # make sure we are dealing with a client advocate
  def login_advofinder_client_required
    login_required
    if logged_in? && current_user.person && !current_user.person.is_a?(client_class)
      redirect_to "/"
    end
  end

  def build_advocate_search_filter(options={})
    @search_filter = AdvocateSearchFilter.new({:sort_order => "people.grade_point_average IS NOT NULL DESC, people.grade_point_average ASC"}.merge((params[:search_filter] || {}).symbolize_keys).merge({
      :finder_class => Advocate, :person => logged_in? ? current_user.person : nil}).merge(options))
    @search_filter.topics << @topic if @topic
    @search_filter.city = params[:city_name] if params[:city_name]
    @search_filter.province_code = params[:province_code] if params[:province_code]
    @search_filter
  end

end
