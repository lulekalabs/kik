# Lists all magazine reviews "Pressespiegel"
class Press::ReviewsController < Press::PressApplicationController

  #--- filters
  before_filter :load_tags
  
  #--- actions
  
  def index
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      if search_tag_list.blank?
        @reviews = Article.published.press_review.find(:all, {
          :order => "articles.published_at DESC"})
      else
        @reviews = Article.published.press_review.find_tagged_with(self.search_tag_list, {:match_all => false,
          :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
      end
    end
  end
  
  def show
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @review = Article.published.press_review.find(params[:id])
    end
  end
  
  protected
  
  def load_tags
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @tags = Article.tag_counts_on(:tags, 
        :conditions => ["articles.status in (?) AND articles.press_review = ?", 'published', true])
    end
  end

end
