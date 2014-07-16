# Holds press releases
class Press::ReleasesController < Press::PressApplicationController

  #--- filters
  before_filter :check_for_pre_launch
  before_filter :load_release_or_redirect, :except => [:index]
  before_filter :load_tags
  before_filter :load_archive_range
  
  #--- layout
  layout :choose_print_layout

  #--- actions
  
  def index
    @releases = if search_tag_list.blank?
      Article.published.press_release.find(:all, {
        :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
    else
      Article.published.press_release.find_tagged_with(search_tag_list, {:match_all => false, 
        :order => "articles.published_at DESC"}.merge(find_options_for_published_filter))
    end
  end

  def show
  end

  def print
  end
  
  protected

  def load_release_or_redirect
    unless params[:id] && (@release = Article.find(params[:id])) && @release.press_release?
      redirect_to press_releases_path
      return
    end
  end
  
  def load_tags
    @tags = Article.tag_counts_on(:tags, 
      :conditions => ["articles.status in (?) AND articles.press_release = ?", 'published', true])
  end

  def load_archive_range
    @archive_range = Article.archive_range(Article.published.press_release.find(:all, :select => "articles.created_at"))
  end
  
end
