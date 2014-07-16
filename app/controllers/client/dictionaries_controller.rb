# Hosts the dictionary entries
class Client::DictionariesController < Client::ClientApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :check_for_pre_launch , :except => [:index, :create]
  before_filter :load_entry_or_redirect, :except => [:index, :create]
  before_filter :build_contact, :only => [:index, :create]
  
  #--- layout
  layout :choose_print_layout
  
  #--- actions
  
  def index
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      @entries = Article.published.dictionary.find(:all, 
        :conditions => ["articles.title LIKE ?", query_filter],
          :order => "articles.title ASC, articles.created_at ASC")
    end
  end

  def create
    if @dictionary_suggestion.valid?
      @dictionary_suggestion.subject = "Vorschlag Rechtsbegriff: #{@dictionary_suggestion.subject}"
      @dictionary_suggestion.message = ""
      @dictionary_suggestion.deliver!
      flash[:notice] = "Vielen Dank für Ihre Anfrage. Wir bearbeiten Ihre Anfrage innerhalb der nächsten 2-3 Werktage."
      redirect_to client_dictionaries_path
      return
    else
      render :action => "index"
    end
  end

  def show
  end
  
  def print
  end
  
  protected

  def load_entry_or_redirect
    Article.send(:with_scope, :find => {:conditions => ["articles.advofinder_view = ? OR articles.kik_view = ?", af_realm?, kik_realm?]}) do
      unless params[:id] && (@entry = Article.find(params[:id])) && @entry.dictionary?
        redirect_to client_dictionaries_path
        return
      end
    end
  end
  
  def load_tags
    @tags = Article.tag_counts_on(:tags, 
      :conditions => ["articles.status in (?) AND articles.dictionary = ?", 'published', true])
  end
  
  # borrowed from corporate/contacts in order to submit the dictionary entry
  def build_contact(options={})
    if logged_in?
      @dictionary_suggestion = DictionarySuggestion.new({
        :sender => @person,
        :sender_first_name => @person.first_name,
        :sender_last_name => @person.last_name,
        :sender_email => @person.email
      }.merge((params[:dictionary_suggestion] || {}).symbolize_keys))
    else
      @dictionary_suggestion = DictionarySuggestion.new((params[:dictionary_suggestion] || {}).symbolize_keys)
    end
    @dictionary_suggestion.attributes = options
    @dictionary_suggestion.validate_message = false
    @dictionary_suggestion
  end
  
  def set_default_fields
    DictionarySuggestion.default_fields = {
      :sender_first_name => "Vorname*",
      :sender_last_name => "Nachname*",
      :sender_email => "E-Mail-Adresse*",
      :subject => "Rechtsbegriff*",
      :message => "Schreiben Sie hier Ihr Anliegen*"
    }
  end
  
  # returns a flat hash of all default fields
  def default_fields
    @dictionary_suggestion.default_fields_with_name(:dictionary_suggestion) if @dictionary_suggestion
  end
  helper_method :default_fields
  
end
