# parent for all front application controllers
class FrontApplicationController < ApplicationController
  helper :all # include all helpers, all the time

  #--- filters
  skip_before_filter :login_required
  before_filter :load_user_and_person
  
  #--- layout
  layout :choose_layout

  #--- actions
  
  def account
    if logged_in? && current_user.person.is_a?(Advocate)
      redirect_to advocate_account_path
    else
      redirect_to client_account_path
    end
  end

  def kik_realm_required
    unless kik_realm?
      redirect_to "/"
    end
  end

  protected

  def ssl_allowed?
    ssl_supported?
  end

  def user_class
    User
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
  
  # filters the search tags from parameters
  def search_tag_list
    unless @search_tag_list
      result = []
      result += params[:tags] ? params[:tags].split("+") : []
      if params[:topic]
        if topic = Topic.find_by_name(params[:topic])
          result += topic.tag_list
        end
      end
      @search_tag_list = result
    end
    @search_tag_list
  end
  helper_method :search_tag_list
  
  def search_tag_list_in_words
    search_tag_list.map(&:humanize).to_sentence
  end
  helper_method :search_tag_list_in_words
  
  # helps to sort out the articles archive
  def find_options_for_published_filter
    if params[:month] && params[:year]
      {:conditions => ["(articles.published_at >= ? AND articles.published_at <= ?)",
        Time.parse("#{params[:year]}/#{params[:month]}/01"), 
          Time.parse("#{params[:year]}/#{params[:month]}/01").end_of_month]}
    else
      {}
    end  
  end
  
  # Helper to choose a layout based on conditions
  def choose_print_layout
    ["print"].include?(action_name) ? "print" : (af_realm? ? "advofinder" : "front")
  end
  
  # set default fields used on start page and questions/new
  def set_kase_default_fields
    Kase.default_fields = {
      :description => "Sie möchten wissen, ob Sie im Recht sind und suchen einen passenden Anwalt, der Sie berät und vertritt? Formulieren Sie bitte hier Ihre Frage und beschreiben Sie Ihren Fall. Sie erhalten dann in Kürze Bewerbungen von interessierten und sofort verfügbaren Anwälten, die Sie in Ruhe vergleichen können. Ist ein passender Anwalt dabei, können Sie ihn unverbindlich kontaktieren und die Einzelheiten einer möglichen Beratung besprechen. Eine Verpflichtung einen Anwalt zu beauftragen besteht zu keiner Zeit.",

      :summary => "Bitte beschreiben Sie Ihre Frage in einem kurzen Satz.",
      :action_description => "Welche rechtlichen Schritte haben Sie bereit unternommen? Ist bereits ein Anwalt eingeschaltet oder läuft ein Gerichtsverfahren?",
      :postal_code => "PLZ*"
    }
  end

  def store_cart(cart)
    session[:cart] = cart.to_yaml
  end    

  def load_cart
    #--- leave this for YAML parser bug
    CartLineItem
    Product
    #--- until here
    return @cart = YAML.load(session[:cart].to_s)
    @cart = Cart.new
  end

  # url to account depending on signed in user /client/account or /advocate/account
  def account_url
    if current_user && current_user.person
      current_user.person.is_a?(Advocate) ? advocate_account_url : client_account_url
    else
      "/"
    end
  end
  alias_method :account_url, :account_path
  helper_method :account_url
  helper_method :account_path

  # sets layout based on realm
  def choose_layout
    af_realm? ? "advofinder" : "front"
  end

end
