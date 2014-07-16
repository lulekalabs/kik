# Handles the registration of journalists
class Press::JournalistsController < Press::PressApplicationController
  include ContactsControllerBase
  
  #--- filters
  # before_filter :check_for_pre_launch, :only => [:new, :create]
  prepend_before_filter :set_default_fields
  before_filter :build_journalist
  before_filter :build_enrollment, :only => [:cancel, :remove]
  before_filter :load_current_contact_or_redirect, :only => :complete
  after_filter :clear_current_contact, :only => :complete
  
  def new
  end
  
  def create
    if @person.save
      @person.business_address.save if @person.business_address
      self.current_contact = @person
      redirect_to complete_press_journalists_path
      return
    end
    render :template => "press/journalists/new"
  end
  
  def complete
  end
  
  def cancel
  end
  
  # request for removal
  def remove
    if (@enrollment = JournalistEnrollment.find_by_email(params[:enrollment][:email])) && @enrollment.active?
      # @enrollment.deactivation!
      @enrollment.delete!
      flash[:notice] = "Die eingebene E-Mail-Adresse #{@enrollment.email} wurde aus dem Presseverteiler ausgetragen."
    else
      flash[:error] = "Die eingegebene E-Mail-Adresse kann keinem Eintragung im Presseverteiler zugeordnet werden. Sollten Sie Hilfe benötigen, stehen wir Ihnen gern per E-Mail zur Verfügung."
      build_enrollment
      @enrollment.valid? if @enrollment
      render :template => "press/journalists/cancel"
      return
    end
    redirect_to cancel_press_journalists_path
    return
  end
  
  protected

  def sub_menu_partial_name
    "press/journalists/sub_menu"
  end  

  def contact_class
    Journalist
  end
  
  def set_default_fields
    Journalist.default_fields = {
      :first_name          =>  "Vorname*" ,
      :last_name           =>  "Nachname*" , 
      :phone_number        =>  "Telefonnummer für Rückfragen*",
      :fax_number          =>  "Faxnummer",
      :company_name        =>  "Redaktion/Verlag*" ,
      :media               =>  "Medium*" ,
      :email               =>  "E-Mail-Adresse*",
      :email_confirmation  =>  "E-Mail-Adresse wiederholen*"
    }
    
    BusinessAddress.default_fields = {
      :postal_code => "Postleitzahl*",
      :city => "Ort*",
      :street => "Straße*",
      :street_number => "Hausnummer*",
    }
    
    Enrollment.default_fields = {
      :first_name => 'Vorname',
      :last_name =>  'Nachname',
      :email => 'E-Mail-Adresse*',
      :email_confirmation => 'E-Mail-Adresse wiederholen*'
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    if action_name =~ /cancel|remove/i
      @enrollment.default_fields_with_name(:enrollment) if @enrollment
    else
      @person.default_fields_with_name(:person, 
        @address.default_fields_with_name(:person_business_address_attributes)) if @person && @address
    end
  end
  helper_method :default_fields
  
  # builds @journalist instance for new and create
  def build_journalist
    if logged_in?
      @person = Journalist.new({
        :first_name => @person.first_name,
        :last_name => @person.last_name,
        :email => @person.email,
        :email_confirmation => @person.email,
        :phone_number => @person.phone_number,
        :company_name => @person.company_name,
        :newsletter => true
      }.merge((params[:person] || {}).symbolize_keys))
      
      @address = @person.build_business_address({:country_code => "DE"})
    else
      @person = Journalist.new((params[:person] || {}).symbolize_keys.merge({:newsletter => true}))
      @address = if @person.business_address
        @person.business_address.attributes = {:country_code => "DE"}
        @person.business_address
      else
        @person.build_business_address({:country_code => "DE"})
      end
    end
  end

  # loads current contact if any or redirects to new
  def load_current_contact_or_redirect
    unless self.current_contact
      redirect_to new_press_journalist_path
      return false
    end
    true
  end

  # override from advocate_application_controller
  def build_enrollment(options={})
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
  
  def enrollment_class
    Enrollment
  end
  
end
