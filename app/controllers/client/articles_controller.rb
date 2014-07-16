# Host to all articles related to expertises, aka "Artikel zu Rechtsthemen"
class Client::ArticlesController < Client::ClientApplicationController

  #--- filters
  before_filter :check_for_pre_launch , :except  => [:index, :print, :show]
  before_filter :load_topics
  before_filter :load_topic
  before_filter :load_tags
  before_filter :load_article_or_redirect, :except => [:index]
  before_filter :load_archive_range, :only => [:index, :show]
  
  #--- layout
  layout :choose_print_layout
  
  #--- actions
  
  def index
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @articles = if @topic
        Article.published.law_article.find(:all, {
          :order => "articles.published_at DESC"}.merge(
            Article.find_options_for_find_by_topic_name(@topic.name, find_options_for_published_filter)))
      elsif search_tag_list.blank?
        Article.published.law_article.find(:all, {
          :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
      else
        @articles = Article.published.law_article.find_tagged_with(self.tag_list, {:match_all => false,
          :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
      end
    end
  end
  
  def show
  end
  
  def print
  end
  
  protected

  def tag_list
    search_tag_list.blank? ? @topics_tag_list : search_tag_list
  end

  def load_article_or_redirect
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      unless params[:id] && (@article = Article.find(params[:id]))
        redirect_to client_articles_path
        return
      end
    end
  end
  
  def load_tags
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @tags = Article.tag_counts_on(:tags, {#:tags => @topics_tag_list, 
        :conditions => ["articles.status in (?) AND articles.law_article = ?", 'published', true]})
    end
  end

  # loads all topics and collects all topic tags into @topics_tag_list
  def load_topics
    @topics = Topic.find_all_visible(:order => "position ASC, name ASC")
    @topics_tag_list = []
    @topics.each {|t| @topics_tag_list += t.tag_list}
    @topics_tag_list.uniq!
  end

  def load_topic
    @topic = Topic.find_by_name(params[:topic]) if params[:topic]
  end

  def load_archive_range
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @archive_range = Article.archive_range(Article.published.law_article.find(:all, :select => "articles.created_at"))
    end
  end
  
end
