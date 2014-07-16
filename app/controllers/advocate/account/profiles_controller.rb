# Managing advocate's profile
class Advocate::Account::ProfilesController < Advocate::Account::AdvocateAccountApplicationController
  
  #--- filters
  prepend_before_filter :set_default_fields
  before_filter :load_person
  before_filter :build_billing_address, :only => [:payment, :update]
  before_filter :build_voucher, :only => [:package, :redeem_voucher]
  after_filter :discard_flash
  
  #--- actions
  
  def show
  end
  
  def update
    @person.attributes = params[:person]
    if params[:select] =~ /^package_select_package/
      if @person.valid?
        sku = params[:person] ? params[:person][:desired_product_sku] : nil
        if sku && @product = Product.find_by_sku(sku)
          @cart ||= Cart.new("EUR")
          @cart.add(@product)
          store_cart(@cart)
          respond_to do |format|
            format.html {
              redirect_to new_advocate_account_order_path
            }
            format.js {
              render :update do |page|
                page.redirect_to new_advocate_account_order_path
              end
            }
          end
          return
        end
      end
    else
      self.save if self.valid?
    end
    render_show
  end
  
  def create_enrollment
    @person.newsletter = true
    if @person.enrollment? && @person.enrollment.pending?
      @person.enrollment.register!  # fire register again to resend activation link
    else
      @person.create_enrollment(false)
    end
    @person.reload
    params[:select] = "base"
    render_show
  end
  
  def destroy_enrollment
    @person.destroy_enrollment
    @person.reload
    params[:select] = "base"
    render_show
  end
  
  def destroy_image
    @person.image.destroy
    @person.save
    render_show
  end
  
  def update_password
    @user.attributes = params[:user]
    @user.persist = true
    @user.password_is_generated = false
    @user.password_required!
    if @user.valid?
      @user.save 
      flash[:notice] = "Ihre Passwort wurde erfolgreich geändert."
    end
    render_show
  end
  
  def redeem_voucher
    @voucher = if found = Voucher.find_by_code_confirmation_attributes((params[:voucher] || {}).symbolize_keys.merge(:consignee => @person))
      found.validate_code_confirmation = true
      found.consignee_confirmation = @person
      found.validate_verification_code = false
      found
    else
      @voucher
    end
    
    respond_to do |format|
      format.html {
        if @voucher.redeem!
          flash[:notice] = "Ihr Gutschein wurde erfolgreich eingelöst."
          redirect_to redirect_url
          return
        end
        render :template => template_name
      }
      format.js {
        @valid = @voucher.redeem!
        @voucher = build_voucher if @valid
        @person.reload if @valid
        flash[:notice] = "Ihr Gutschein wurde erfolgreich eingelöst." if @valid
        render :update do |page|
          page.replace dom_id(@person), :partial => partial_name, :locals => {:edit => !@valid}
          if @valid
            page.replace "header-welcome", :partial => "shared/header_welcome"
          end
        end
      }
    end
  end
  
  protected
  
  def set_default_fields
    User.default_fields = {
      :current_password => "Altes Passwort*",
      :password => "Neues Passwort*",
      :password_confirmation => "Passwort wiederholen*",
    }
    
    Person.default_fields = {
      :first_name          =>  "Vorname*" ,
      :last_name           =>  "Nachname*" , 
      :company_name        =>  "Kanzleiname" ,
      :phone_number        =>  "Telefonnummer für Rückfragen*",
      :company_url         =>  "Internet-Adresse (URL) der Kanzlei-Website",
      :email               =>  "E-Mail-Adresse*",
      :referral_source     =>  "Wie haben Sie von kann-ich-klagen.de erfahren?"
    }
    
    BusinessAddress.default_fields = {
      :street              =>  "Straße der Kanzlei*" ,
      :street_number       =>  "Hausnr. der Kanzlei*" ,
      :postal_code         =>  "PLZ der Kanzlei*" ,
      :city                =>  "Ort der Kanzlei*"
    }
    
    Voucher.default_fields = {
      :code => "Gutscheincode"
    }
  end

  # returns a flat hash of all default fields
  def default_fields
    defaults = {}
    defaults = defaults.merge(@user.default_fields_with_name(:user)) if @user
    defaults = defaults.merge(@person.default_fields_with_name(:person)) if @person
    defaults = defaults.merge(@person.default_fields_with_name(:person_business_address_attributes)) if @person.business_address
    defaults = defaults.merge(@voucher.default_fields_with_name(:voucher)) if @voucher
    defaults
  end
  helper_method :default_fields
  
  def render_show
    
    if params[:sidebar_select] =~ /image/ 
      @error_header_message = "Fehler in Mein Profilbild"
    elsif params[:sidebar_select] =~ /change_password/ 
      @error_header_message = "Fehler in Mein Passwort ändern"
    end
    
    respond_to do |format|
      format.html {
        if self.valid?
          redirect_to redirect_url
          return
        end
        render :template => template_name
      }
      format.js {
        @valid = self.valid?
        if params[:iframe] =~ /^(1|true)/
          responds_to_parent do
            render :update do |page|
              page.replace dom_id(@person), :partial => partial_name, :locals => {:edit => !@valid}
              page.replace dom_id(@person, :image), :partial => "shared/profiles/image"
            end
          end
        else
          render :update do |page|
            page.replace dom_id(@person), :partial => partial_name, :locals => {:edit => !@valid}
            page.replace dom_id(@person, :image), :partial => "shared/profiles/image"
          end
        end
      }
    end
  end
  
  def template_name
    case params[:select].to_s
    when /details/ then "advocate/account/profiles/details"
    when /contact/ then "advocate/account/profiles/contact"
    when /payment/ then "advocate/account/profiles/payment"
    when /package/ then "advocate/account/profiles/package"
    else
      "advocate/account/profiles/show"
    end
  end
  helper_method :template_name
  
  def partial_name
    case params[:select].to_s
    when /details/ then "advocate/account/profiles/details"
    when /contact/ then "advocate/account/profiles/contact"
    when /payment/ then "advocate/account/profiles/payment"
    when /package/ then "advocate/account/profiles/package"
    else
      "advocate/account/profiles/show"
    end
  end
  helper_method :partial_name

  def redirect_url
    case params[:select].to_s
    when /details/ then details_advocate_account_profile_path
    when /contact/ then contact_advocate_account_profile_path
    when /payment/ then payment_advocate_account_profile_path
    when /package/ then package_advocate_account_profile_path
    else
      advocate_account_profile_path
    end
  end
  
  def save
    ar = @person.business_address ? @person.business_address.save : true
    br = @person.billing_address ? @person.billing_address.save : true
    pr = @person.save
    ar && br && pr
  end
  
  def valid?
    @user.valid? && @person.valid? && (@person.business_address && @person.business_address.valid?)
  end

  def load_person
    # @user and @person is already loaded through login_required
    # @person.company_assets.build(:person => current_user.person) if @person.company_assets.empty?
  end
  
  def selected_action
    params[:select].to_s.blank? ? (action_name == "show" ? "base" : '') : params[:select].to_s
  end
  helper_method :selected_action
  
  def build_billing_address(options={})
    unless @person.billing_address
      @person.build_billing_address(options.merge({
        :company_name => @person.company_name, :academic_title_id => @person.academic_title_id, :gender => @person.gender,
          :first_name => @person.first_name, :last_name => @person.last_name,
            :street => @person.business_address.street, :street_number => @person.business_address.street_number,
              :note => @person.business_address.note, :postal_code => @person.business_address.postal_code,
                :city => @person.business_address.city, :country_code => @person.business_address.country_code,
                  :email => @person.email}))
    end
  end

  def build_voucher
    @voucher = PromotionContactVoucher.new((params[:voucher] || {})) do |voucher|
      voucher.validate_code_confirmation = true
      voucher.validate_verification_code = false
    end
  end
  
end
