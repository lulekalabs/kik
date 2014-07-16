# Managing advocate's articles
class Advocate::Account::ArticlesController < Advocate::Account::AdvocateAccountApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :build_article
  before_filter :load_article, :only => [:show, :edit, :update, :destroy, :publish, :suspend, :destroy_attachment]
  
  #--- actions
  
  def new
  end

  def index
    do_index
  end
  
  def create
    respond_to do |format|
      format.html {
        if @article.save
          redirect_to advocate_account_articles_path
          return
        end
        render :template => "advocate/account/articles/index"
      }
      format.js {
        @new_dom_id = dom_id(@article, :new)
        if @article.save
          responds_to_parent do
            render :update do |page|
              page.replace @new_dom_id, :partial => "show", :object => @article
            end
          end
        else
          responds_to_parent do
            render :update do |page|
              page.replace_html @new_dom_id, :partial => "new", :object => @article
            end
          end
        end
      }
    end
  end
  
  def edit
    render :template => "advocate/account/articles/edit", :layout => false
  end

  def update
    @article.attributes = params[:article]
    respond_to do |format|
      format.html {
        if @article.save
          redirect_to advocate_account_articles_path
          return
        end
        render :template => "advocate/account/articles/index"
      }
      format.js {
        if @article.save
          responds_to_parent do
            render :update do |page|
              page.replace dom_id(@article), :partial => "show", :object => @article
            end
          end
        else
          responds_to_parent do
            render :update do |page|
              page.replace_html dom_id(@article), :partial => "edit", :object => @article
            end
          end
        end
      }
    end
  end
  
  def destroy
    @article.destroy
    render :nothing => true
  end
  
  def publish
    respond_to do |format|
      format.html {
        render :nothing => true
      }
      format.js {
        if :published == @article.next_state_for_event(:publish) 
          @article.publish! 
        elsif :published == @article.next_state_for_event(:unsuspend)  
          @article.unsuspend!
        end
        render :update do |page|
          page.replace dom_id(@article), :partial => "show", :object => @article
        end
      }
    end
  end
  
  def suspend
    respond_to do |format|
      format.html {
        render :nothing => true
      }
      format.js {
        @article.suspend!
        render :update do |page|
          page.replace dom_id(@article), :partial => "show", :object => @article
        end
      }
    end
  end
  
  def destroy_attachment
    respond_to do |format|
      format.html {
        render :nothing => true
      }
      format.js {
        attachment_name = params[:name]
        @article.send(attachment_name).destroy
        @article.save
        if params[:update] =~ /^(1|true)/
          render :update do |page|
            page.replace dom_id(@article), :partial => "show", :object => @article
          end
        else
          render :nothing => true
        end
      }
    end
  end
  
  protected
  
  def set_default_fields
    Article.default_fields = {
      :title => "Artikel Titel*",
      :body => "Artikel*"
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    defaults = {}
    defaults = defaults.merge(@article.default_fields_with_name(:article)) if @article
    defaults
  end
  helper_method :default_fields
  
  def build_article(options={})
    @article = Article.new((params[:article] || {}).symbolize_keys.merge({:person => current_user.person,
      :law_article => true, :kik_view => kik_realm?, :advofinder_view => af_realm?}).merge(options))
  end
  
  def load_article
    @article = Article.find(params[:id]) if params[:id]
  end

  def do_index
    @articles = current_user.person.articles.editable.created_chronological_descending.published_chronological_descending.find(:all, 
      {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]})
  end

end
