class Admin::AdvocatesController < Admin::AdminApplicationController

  #--- filters
  before_filter :load_advocate, :only => [:show_create_contacts, :create_contacts]

  #--- active scaffold
  active_scaffold :advocate do |config|
    #--- columns
    standard_columns = [
      :id,
      :type,
      :gender,
      :academic_title_id,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :company_url,
      :company_name,
      :newsletter,
      :referral_source,
      :publisher,
      :state,
      :image_url,
      :image,
      :logo,
      # professions
      :profession_advocate,
      :profession_mediator,
      :profession_notary,
      :profession_tax_accountant,
      :profession_patent_attorney,
      :profession_cpa,
      :profession_affiant_accountant,
      # associations
      :bar_association,
      :bar_association_id,
      :primary_expertise_id,
      :secondary_expertise_id, 
      :tertiary_expertise_id,
      :business_address,
      :concession,
      :terms_of_service,
      :created_at,
      :activated_at,
      :title_and_name,
      :total_contacts_count, 
      :premium_contacts_count,
      :promotion_contacts_count,
      :overdrawn_contacts_count
    ]
    crud_columns = [
      :gender,
      :academic_title_id,
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :company_url,
      :company_name,
      :image,
      :logo,
      :newsletter,
      :referral_source,
      :publisher,
      
      # professions
      :profession_advocate,
      :profession_mediator,
      :profession_notary,
      :profession_tax_accountant,
      :profession_patent_attorney,
      :profession_cpa,
      :profession_affiant_accountant,
      # associations
      :bar_association_id,
      :primary_expertise_id,
      :secondary_expertise_id,
      :tertiary_expertise_id, 
      :business_address
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns + [:concession, :terms_of_service, :created_at, :activated_at]
    config.list.columns = [:image_url, :title_and_name, :email, :total_contacts_count, :state, :created_at]

    #--- actions
    config.actions.exclude :create
    
    #--- action links
    
    # activate
    do_activate_link = ActiveScaffold::DataStructures::ActionLink.new 'Aktivieren', 
      :action => 'activate', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Anwalt jetzt aktivieren?"
    def do_activate_link.label
      return "[Aktivieren]" if record.user && record.user.current_state == :inactive && record.user.next_state_for_event(:activate)
      ''
    end
    config.action_links.add do_activate_link

    # approve
    do_approve_link = ActiveScaffold::DataStructures::ActionLink.new 'Zulassen', 
      :action => 'approve', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Anwalt jetzt zur weiteren Registrierung zulassen?"
    def do_approve_link.label
      return "[Zulassen]" if record.user && record.user.current_state == :preapproved && record.user.next_state_for_event(:approve)
      ''
    end
    config.action_links.add do_approve_link

    config.nested.add_link('Mandate', [:mandates], :page => false, :inline => true, :position => :after)

=begin    
    config.action_links.add :search, :label => 'Suche', :parameters => {:action => "show_search"}, 
      :page => false, :inline => true, :position => :top
=end

    class CreateContactsConfirm < DHTMLConfirm

      def onclick_handler(controller, link_id)
        # "alert($('#{link_id}').href);return false;"
        "Modalbox.show($('#{link_id}').href, {title: $('#{link_id}').innerHTML, width: 400});return false;"
        # "Modalbox.show('/admin/advocates/4/show_create_contacts?_method=get', {title: this.title, width: 400});return false;"
      end

    end

    config.action_links.add :create_contacts, :label => 'Freikontakte', :type => :record, :inline => true, 
      :dhtml_confirm => CreateContactsConfirm.new, :action => "show_create_contacts"
    
    #--- labels
    config.columns[:publisher].form_ui = :checkbox
    config.columns[:newsletter].form_ui = :checkbox
    
    config.columns[:gender].label = "Anrede"
    config.columns[:academic_title_id].label = "Titel"
    config.columns[:first_name].label = "Vorname"
    config.columns[:last_name].label = "Nachname"
    config.columns[:title_and_name].label = "Name"
    config.columns[:email].label = "Email Adresse"
    config.columns[:phone_number].label = "Kontakt Telefon"
    config.columns[:company_name].label = "Name der Kanzlei"
    config.columns[:company_url].label = "URL der Kanzlei"
    config.columns[:bar_association_id].label = "Rechtsanwaltskammer"
    config.columns[:referral_source].label = "Erfahren Durch"
    config.columns[:publisher].label = "Herausgeber"
    config.columns[:publisher].description = "Vergibt das Recht Artikel freizugeben"

    config.columns[:image_url].label        = "Bild"
    #config.columns[:image].label            = "Bild"

    #--- professions
    config.columns[:profession_advocate].label = "Rechtsanwalt"
    config.columns[:profession_mediator].label = "Mediator"
    config.columns[:profession_notary].label = "Notar"
    config.columns[:profession_tax_accountant].label = "Steuerberater"
    config.columns[:profession_patent_attorney].label = "Patentanwalt"
    config.columns[:profession_cpa].label = "Wirtschaftsprüfer"
    config.columns[:profession_affiant_accountant].label = "Vereidigter Buchprüfer"

    config.columns[:profession_advocate].form_ui = :checkbox
    config.columns[:profession_mediator].form_ui = :checkbox
    config.columns[:profession_notary].form_ui = :checkbox
    config.columns[:profession_tax_accountant].form_ui = :checkbox
    config.columns[:profession_patent_attorney].form_ui = :checkbox
    config.columns[:profession_cpa].form_ui = :checkbox
    config.columns[:profession_affiant_accountant].form_ui = :checkbox

#    config.create.multipart = true
    config.update.multipart = true
  end  

  #--- actions
  
  def activate
    @record = Person.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record.user && @record.user.current_state == :inactive && @record.user.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end

  def approve
    @record = Person.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record.user && @record.user.current_state == :preapproved && @record.user.next_state_for_event(:approve)
      do_list_action(:approve!)
      return
    end
    render :nothing => true
  end
  
  def destroy_asset
    if @record = Advocate.find_by_id(params[:id])
      if params[:select] =~ /^image/
        @record.image.destroy
      elsif params[:select] =~ /^logo/
        @record.logo.destroy
      end
      @record.save
      redirect_to edit_admin_advocate_path(@record)
    end
  end
  
  def show_create_contacts
    @promotion_contact_booking = PromotionContactBooking.new
    render :layout => false
  end
  
  def create_contacts
    @promotion_contact_booking = PromotionContactBooking.new({:person => @advocate}.merge(params[:promotion_contact_booking].symbolize_keys || {}))
    if @promotion_contact_booking.valid?
      @promotion_contact_booking.create!
      respond_to do |format|
        format.js {
          render :update do |page|            
            page.redirect_to admin_advocates_path
          end
        }
        format.html {
          redirect_to admin_advocates_path
        }
      end
      return
    else
      respond_to do |format|
        format.html { render :nothing => true }
        format.js {
          render :update do |page|            
            page.replace dom_id(@advocate, :show_create_contacts), :partial => "show_create_contacts"
            page << "Modalbox.resizeToContent()"
          end
        }
      end
    end
  end

  protected
  
  def load_advocate
    @advocate = Advocate.find(params[:id])
  end
  
  def conditions_for_collection
    ['people.type IN (?)', ['Advocate']]
  end
  
  # Triggers the provided event and updates the list item.
  # Usage:     do_list_action(:suspend!)
  def do_list_action(event)
    @record = active_scaffold_config.model.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    if @record.user && @record.user.send("#{event}")
      render :update do |page|
        page.replace element_row_id(:action => 'list', :id => params[:id]), 
          :partial => 'list_record', :locals => {:record => @record}
        page << "ActiveScaffold.stripe('#{active_scaffold_tbody_id}');"
      end
    else
      message = render_to_string :partial => 'errors'
      render :update do |page|
        page.alert(message)
      end
    end
  end
  
end

class CreateContacts
  
end

