class Service::NewslettersController < Service::ServiceApplicationController

  #--- filters
  # before_filter :check_for_pre_launch
  prepend_before_filter :set_default_fields
  before_filter :load_current_enrollment_or_redirect, :only => [:complete]
#  after_filter :clear_current_enrollment, :only => [:complete]
  before_filter :build_enrollment, :only => [:new, :create, :cancel]
  
  #--- actions
  
  def new
  end
  
  def cancel
  end
  
  def create
    if @enrollment.valid?
      @enrollment.register!
      self.current_enrollment = @enrollment
      redirect_to complete_service_newsletters_path
      return
    end
    render :template => 'service/newsletters/new'
  end
  
  def complete
    # shown after the user submits to receive newsletter
  end
  
  def activate
    if (@enrollment = Enrollment.find_by_activation_code(params[:id])) && @enrollment.pending?
      @enrollment.activate!
    else
      flash[:warning] = "Newsletter Abonnement konnte nicht gefunden werden."
      redirect_to new_service_newsletter_path
      return
    end
  end
  
  # request for removal
  def remove
    if params[:enrollment][:type].blank?
      flash[:error] = "Es wurde keine Newsletter-Zielgruppe angegeben."
    elsif enrollment_class == Enrollment && !(@enrollments = Enrollment.find_all_by_email(params[:enrollment][:email])).empty?
      # delete all
      @enrollments.each {|e| e.deactivate!}
      flash[:notice] = "Der Newsletter für die eingegebene E-Mail-Adresse #{params[:enrollment][:email]} wurde abbestellt."
    elsif (@enrollment = enrollment_class.find_by_email(params[:enrollment][:email]))
      @enrollment.deactivate!
      flash[:notice] = "Der Newsletter für die eingegebene E-Mail-Adresse #{params[:enrollment][:email]} wurde abbestellt."
    else
      flash[:error] = "Für die eingegebene E-Mail-Adresse #{params[:enrollment][:email]} existiert keine Bestellung, die abbestellt werden könnte. Bitte prüfen Sie die eingegebene E-Mail-Adresse."
    end
    redirect_to cancel_service_newsletters_path
    return
  end
  
  def deactivate
    if (@enrollment = Enrollment.find_by_activation_code(params[:id])) && @enrollment.active?
      @enrollment.deactivate!
    else
      flash[:error] = "Es wurde kein aktives Newsletter Abonnement gefunden."
      redirect_to new_service_newsletter_path
      return
    end
  end
  
  def resend
    if @enrollment = Enrollment.find_by_activation_code(params[:id])
      @enrollment.resend_activation
      flash[:notice] = "Eine E-Mail zur Aktivierung Ihres Newsletters wurde Ihnen erneut zugestellt."
    end
    redirect_to complete_service_newsletters_path
  end

  protected
  
  # override
  def sub_menu_partial_name
    "service/newsletters/sub_menu"
  end  
  
  # override from advocate_application_controller
  def build_enrollment
    if logged_in?
      @enrollment = enrollment_class.new({
        :first_name => @person.first_name,
        :last_name => @person.last_name,
        :email => @person.email,
        :type => "Enrollment"
      }.merge((params[:enrollment] || {}).symbolize_keys))
    else
      @enrollment = enrollment_class.new({:type => "Enrollment"}.merge(params[:enrollment] || {}).symbolize_keys)
    end
  end
  
  def set_default_fields
    Enrollment.default_fields = {
      :first_name => 'Vorname',
      :last_name =>  'Nachname',
      :email => 'E-Mail-Adresse*',
      :email_confirmation => 'E-Mail-Adresse wiederholen*'
    }
  end
  
  # returns a flat hash of all default fields
  def default_fields
    @enrollment.default_fields_with_name if @enrollment
  end
  helper_method :default_fields

  # derived from parameter, if not Enrollment
  def enrollment_class
    (params[:enrollment].blank? || params[:enrollment][:type].blank? ? 'Enrollment' : params[:enrollment][:type]).constantize
  end

  # hash key for enrollment in the session
  def enrollment_session_param
    :enrollment_id
  end
  
  def current_enrollment
    @current_enrollment ||= load_enrollment_from_session unless @current_enrollment == false
  end

  def current_enrollment=(enrollment)
    session[enrollment_session_param] = enrollment ? enrollment.id : nil
    @current_enrollment = enrollment || false
  end
  
  def clear_current_enrollment
    self.current_enrollment = nil
  end

  def load_current_enrollment_or_redirect
    unless @enrollment = self.current_enrollment
      redirect_to new_service_newsletter_path
      return false
    end
  end
  
  private
  
  def load_enrollment_from_session
    self.current_enrollment = Enrollment.find_by_id(session[enrollment_session_param]) if session[enrollment_session_param]
  end

end
