# base controller for all service related pages
class Service::ServiceApplicationController < FrontApplicationController
  
  #--- actions
  
  def show
  end
  
  def complete
  end
  
  def newsletter
  end
  
  def blog
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @articles = if search_tag_list.blank?
        Article.published.blog.find(:all, {
          :order => "articles.published_at ASC"}.merge(find_options_for_published_filter))
      else
        Article.published.find_tagged_with(search_tag_list, {:match_all => false, 
          :order => "articles.published_at ASC"}.merge(find_options_for_published_filter))
      end
      @tags = Article.tag_counts_on(:tags, :conditions => ["articles.status in (?) AND articles.blog = ?", 'published', true])
    end
  end
  
  def tags
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @tags = Article.tag_counts_on(:tags, :conditions => ["articles.status in (?)", 'published'], 
        :order => "tags.name ASC", :limit => 150)
      if params[:q]
        @tag = params[:q]
        @articles = Article.tagged_with @tag
      end
    end
  end
  
  protected
  
  def main_menu_class_name
    ""
  end
  
  # override
  def sub_menu_partial_name
    "shared/sub_menu_empty"
  end  
  
end
