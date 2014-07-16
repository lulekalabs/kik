class Advofinder::Advocate::ProfilesController < Advofinder::Advocate::AdvocateApplicationController

  #--- filters
  prepend_before_filter :login_required
  before_filter :load_advocate
  before_filter :count_visit, :only => [:show, :profile]
  
  #--- actions
  
  def show 
    render :template => "advofinder/advocate/profiles/profile"
  end
    
  # Tab "Profil"
  def profile
  end
  
  # Tab "Bewertungen"
  def reviews
    @reviews = @advocate.reviews.visible
  end
  
  # Tab "Mitteilungen"
  def messages
    @messages = @advocate.advomessages.visible.created_chronological_descending
  end
  
  # Tab "Artikel"
  def articles
    @articles = @advocate.articles.law_article.published.published_chronological_descending
  end
  
  protected
  
  def load_advocate
    @advocate = advocate_class.find(params[:id]) if params[:id]
  end

  def count_visit
    @advocate.visit(current_user.person) if logged_in?
  end

end
