# advofinder clients can create an advocate profile
class Advofinder::Client::AdvocatesController < Advofinder::Client::ClientApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields, :only => [:new, :create]
  before_filter :build_advocate, :only => [:new, :create]
  before_filter :load_advocate, :except => [:new, :create, :update, :index, :reviewed, :unreviewed]
  
  #--- actions
  
  def new
  end

  # Tab "Profil"
  def profile
    @advocate.visit(current_user.person) if logged_in?
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

  def set_default_fields
    Advocate.default_fields = {
      :first_name          =>  "Vorname*" ,
      :last_name           =>  "Nachname*" , 
      :company_name        =>  "Kanzleiname" ,
      :phone_number        =>  "Telefonnummer für Rückfragen*",
      :company_url         =>  "Internet-Adresse (URL) der Kanzlei-Website",
      :email               =>  "E-Mail-Adresse*",
      :referral_source     =>  "Wie haben Sie von #{af_realm? ? "advofinder.de" : "kann-ich-klagen.de"} erfahren?",
      :email  => "E-Mail-Adresse*"
      #:email_confirmation  =>  "E-Mail-Adresse wiederholen*"
    }
    
    BusinessAddress.default_fields = {
      :street              =>  "Straße der Kanzlei*" ,
      :street_number       =>  "Hausnr. der Kanzlei*" ,
      :postal_code         =>  "PLZ der Kanzlei*" ,
      :city                =>  "Ort der Kanzlei*"
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    defaults = {}
    defaults.merge!(@advocate.default_fields_with_name(:advocate)) if @advocate
    defaults.merge!(@address.default_fields_with_name(:advocate_business_address_attributes)) if @address
    defaults
  end
  helper_method :default_fields

  def build_advocate(options={})
    @advocate = Advocate.new
    @person = @user.person = Advocate.new
    
    @address = @advocate.build_business_address({:country_code => "DE"})
    @advocate.attributes = {:profession_advocate => true}.merge(params[:advocate] || {}).merge(options[:advocate] || {})

    @advocate
  end
  
end
