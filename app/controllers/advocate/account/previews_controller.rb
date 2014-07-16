# Preview of public profile
class Advocate::Account::PreviewsController < Advocate::Account::AdvocateAccountApplicationController
  
  #--- filters
  before_filter :load_advocate
  
  #--- actions
  
  def show
  end
  
  def reviews
    @reviews = @advocate.reviews.visible.created_chronological_descending
  end
  
  def messages
    @messages = @advocate.advomessages.visible.created_chronological_descending
  end
  
  def articles
    @articles = @advocate.articles.law_article.published.published_chronological_descending
  end
  
  protected
  
  def load_advocate
    @advocate = @person
  end
  
end
