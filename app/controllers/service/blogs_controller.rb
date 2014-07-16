# Hosts blog and blog posts
class Service::BlogsController < Service::ServiceApplicationController
  
  #--- filters
  # before_filter :check_for_pre_launch
  before_filter :load_post_or_redirect, :except => [:index, :feed]
  before_filter :load_tags
  before_filter :load_archive_range
  
  #--- layout
  layout :choose_print_layout

  #--- actions
  
  def index
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @posts = if search_tag_list.blank?
        Article.published.blog.find(:all, {
          :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
      else
        Article.published.find_tagged_with(search_tag_list, {:match_all => false, 
          :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
      end
    end
  end

  def feed
    @title = af_realm? ? "RSS-Feed von advofinder.de" : "RSS-Feed von kann-ich-klagen.de"
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @posts = Article.published.blog.find(:all, {
        :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
    end
    render :layout => false
  end

  def show
  end
  
  def print
  end

  protected
  
  def load_post_or_redirect
    unless params[:id] && (@post = Article.find(params[:id])) && @post.blog?
      redirect_to service_blogs_path
      return
    end
  end
  
  def load_tags
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @tags = Article.tag_counts_on(:tags, :conditions => ["articles.status in (?) AND articles.blog = ?", 'published', true])
    end
  end
  
  def load_archive_range
    @archive_range = Article.archive_range(Article.published.blog.find(:all, :select => "articles.created_at"))
  end
  
  # override
  def sub_menu_partial_name
    "shared/sub_menu_empty"
  end  
  
end
