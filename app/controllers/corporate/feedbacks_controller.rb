# handles generic feedback, inherits from contact controller
class Corporate::FeedbacksController < Corporate::ContactsController
  include ContactsControllerBase
  
  #--- filters
  before_filter :load_current_contact_or_redirect, :only => :complete
  after_filter :clear_current_contact, :only => :complete
  
  #--- actions

  def new
    respond_to do |format|
      format.html {}
      format.js {}
    end
  end
  
  def create
    respond_to do |format|
      format.html {
        if @contact.valid?
          @contact.deliver!
          self.current_contact = @contact
          redirect_to complete_corporate_contacts_path
          return
        end
        render :template => 'corporate/feedbacks/new'
        return
      }
      format.js {
        if @contact.valid?
          @contact.deliver!
          self.current_contact = @contact
          render :update do |page|
            page.replace_html 'feedback_content', :partial => 'corporate/feedbacks/complete'
          end
          return
        end
        render :update do |page|
          page['feedback_content'].replace :partial => "corporate/feedbacks/new"
        end
      }
    end
  end
  
    
  protected
  
  def build_contact
    if logged_in?
      @contact = Feedback.new({
        :sender => @person,
        :sender_first_name => @person.first_name,
        :sender_last_name => @person.last_name,
        :sender_email => @person.email
      }.merge((params[:contact] || {}).symbolize_keys))
    else
      @contact = Feedback.new((params[:contact] || {}).symbolize_keys)
    end
  end
  
  def set_default_fields
    Feedback.default_fields = {
      :sender_first_name => "Vorname",
      :sender_last_name => "Nachname",
      :sender_email => "E-Mail-Adresse*",
      :subject => "Betreff*",
      :message => "Schreiben Sie hier Ihr Anliegen*"
    }
  end
  
  # loads current contact if any or redirects to new
  def load_current_contact_or_redirect
    unless self.current_contact
      redirect_to new_corporate_feedback_path
      return false
    end
    true
  end
  
end
