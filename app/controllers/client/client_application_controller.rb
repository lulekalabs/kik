# Entails all client ("Mandanten", "Rechtssuchende") pages
class Client::ClientApplicationController < FrontApplicationController

  #--- filters
  before_filter :check_for_pre_launch, :except => [:show , :kodex , :legal_advice_cost ]

  def dictionary
    @entries = Article.published.dictionary.find(:all, 
      :conditions => ["articles.title LIKE ?", query_filter],
      :order => "articles.title ASC, articles.created_at ASC")
  end

  protected
  
  def main_menu_class_name
    ""
  end
  
  # override
  def sub_menu_partial_name
    "shared/sub_menu_empty"
  end
  
  def query_filter
    params[:filter] ? "#{params[:filter]}%" : "%"
  end  

  def query_filter_in_words
    params[:filter] ? "\"#{params[:filter].humanize}\"" : nil
  end
  helper_method :query_filter_in_words

end
