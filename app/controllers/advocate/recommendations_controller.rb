# handles invitations to other advocates
class Advocate::RecommendationsController < Advocate::AdvocateApplicationController
  
  #--- filters
  # ** before_filter :build_recommendation -> advocate_application_controller
  prepend_before_filter :set_default_fields
  
  #--- actions
  
  def new
  end
  
  def create
    if verify_recaptcha(:model => @recommendation, :message => "Sicherheitscode wurde falsch eingeben") && @recommendation.valid?
      @recommendation.deliver!
      redirect_to complete_advocate_recommendations_path
      return
    end
    render :template => "advocate/recommendations/new"
  end
  
  protected
  
  # override from advocate_application_controller
  def build_recommendation
    if logged_in?
      @recommendation = Recommendation.new({
        :sender => @person,
        :sender_gender => @person.gender,
        :sender_academic_title => @person.academic_title,
        :sender_first_name => @person.first_name,
        :sender_last_name => @person.last_name,
        :sender_email => @person.email,
        :ip => request.remote_ip
      }.merge((params[:recommendation] || {}).symbolize_keys))
    else
      @recommendation = Recommendation.new((params[:recommendation] || {}).merge(:ip => request.remote_ip))
    end
  end
  
  def set_default_fields
    Recommendation.default_fields = {
      :sender_first_name => 'Vorname*',
      :sender_last_name =>  'Nachname*',
      :sender_email => 'E-Mail-Adresse*',
      :receiver_first_name => 'Vorname des Empfängers*',
      :receiver_last_name =>  'Nachname des Empfängers*',
      :receiver_email => 'E-Mail-Adresse des Empfängers*',
      :message => 'Hier können Sie, wenn Sie es wünschen, zusätzlich eine persönliche Mitteilung an den Empfänger hinzufügen.'
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    @recommendation.default_fields_with_name if @recommendation
  end
  helper_method :default_fields
  
end
