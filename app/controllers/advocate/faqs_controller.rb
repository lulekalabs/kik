# Host for Help & Faqs for advocates
class Advocate::FaqsController < Advocate::AdvocateApplicationController

  #--- filters
  before_filter :check_for_pre_launch
  before_filter :load_faq_or_redirect, :except => [:index]
  before_filter :load_tags
  
  #--- layout
  layout :choose_print_layout
  
  #--- actions
  
  def index
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @articles = if search_tag_list.blank?
        Article.published.faq.advocate_view.find(:all, {
          :order => "articles.published_at ASC"})
      else
        Article.published.faq.advocate_view.find_tagged_with(search_tag_list, {:match_all => false, 
          :order => "articles.published_at ASC"})
      end
    end
    render :template => "client/faqs/index"
  end
  
  def show
    render :template => "client/faqs/show"
  end
  
  def print
    render :template => "client/faqs/print"
  end
  
  protected

  def load_faq_or_redirect
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      unless params[:id] && (@article = Article.find(params[:id])) && @article.faq?
        redirect_to advocate_faqs_path
        return
      end
    end
  end
  
  def load_tags
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @tags = Article.tag_counts_on(:tags, 
        :conditions => ["articles.status in (?) AND articles.faq = ? AND articles.advocate_view = ?", 'published', true, true])
    end
  end

end
