# holds all press related stuff
class Press::PressApplicationController < FrontApplicationController

  #--- filters
  before_filter :check_for_pre_launch, :only => [:releases, :reviews]

  def show
    @releases = Article.published.press_release.find(:all, {
      :order => "articles.published_at DESC", :limit => 4})
  end

  def releases
    @releases = Article.published.press_release.find(:all, {
      :order => "articles.published_at DESC"})
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
