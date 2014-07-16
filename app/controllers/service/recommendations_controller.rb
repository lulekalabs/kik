# service recommendations
class Service::RecommendationsController < Service::ServiceApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :build_recommendation
  
  #--- actions
  
  def new
  end
  
  def create
    if @recommendation.valid?
      @recommendation.deliver!
      redirect_to complete_service_recommendations_path
      return
    end
    render :template => "service/recommendations/new"
  end
  
  protected
  
  # override from advocate_application_controller
  def build_recommendation
    if logged_in?
      @recommendation = Recommendation.new({
        :sender => @person,
        :sender_first_name => @person.first_name,
        :sender_last_name => @person.last_name,
        :sender_email => @person.email
      }.merge((params[:recommendation] || {}).symbolize_keys))
    else
      @recommendation = Recommendation.new(params[:recommendation] || {})
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
      :message => 'Hier können Sie, wenn Sie wünschen, zusätzlich eine persönliche Nachricht für den Empfänger hinzufügen.'
    }
  end
  # returns a flat hash of all default fields
  def default_fields
    @recommendation.default_fields_with_name if @recommendation
  end
  helper_method :default_fields
  
end
