class Admin::JournalistEnrollmentsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :journalist_enrollment do |config|
    #--- columns
    standard_columns = [
      :id,
      :gender,
      :academic_title_id,
      :first_name,
      :last_name,
      :email,
      :type,
      :state,
      :name,
      :press_release_per_email,
      :press_release_per_fax,
      :press_release_per_mail,
      :created_at,
      :udated_at,
      :activated_at,
      :person
    ]
    crud_columns = [
      :person,
      :press_release_per_email,
      :press_release_per_fax,
      :press_release_per_mail,
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:name, :state, :activated_at, :created_at]

    #--- actions
    config.actions.exclude :create

    # activate
    do_activate_link = ActiveScaffold::DataStructures::ActionLink.new 'Aktivieren', 
      :action => 'activate', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Newsletter jetzt aktivieren?"
    def do_activate_link.label
      return "[Aktivieren]" if :active == record.next_state_for_event(:activate)
      ''
    end
    config.action_links.add do_activate_link

    # deactivate
    do_deactivate_link = ActiveScaffold::DataStructures::ActionLink.new 'Deaktivieren', 
      :action => 'deactivate', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Newsletter jetzt deaktivieren?"
    def do_deactivate_link.label
      return "[Deaktivieren]" if :deleted == record.next_state_for_event(:delete)
      ''
    end
    config.action_links.add do_deactivate_link

    config.action_links.add 'export', :label => 'Exportieren', :type => :table, 
      :action => 'export', :inline => false, :position => false

    # labels
    config.label = "Presseverteiler"
    #config.create.label = "Neuer Presseverteiler"
    config.update.label = "Editiere Presseverteiler"
    
    config.columns[:press_release_per_email].form_ui = :checkbox
    config.columns[:press_release_per_fax].form_ui = :checkbox
    config.columns[:press_release_per_mail].form_ui = :checkbox
    config.columns[:press_release_per_email].label = "Pressemitteilung per Email"
    config.columns[:press_release_per_fax].label = "Pressemitteillung per Fax"
    config.columns[:press_release_per_mail].label = "Pressemitteilung per Post"
    
  end 

  #--- actions
  
  def activate
    @record = Enrollment.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    
    if :active == @record.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end

  def deactivate
    @record = Enrollment.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    
    if :deleted == @record.next_state_for_event(:delete)
      do_list_action(:delete!)
      return
    end
    render :nothing => true
  end
  
  def export
    @records = JournalistEnrollment.visible
    
    file_name = "#{RAILS_ROOT}/tmp/presseverteiler_#{Time.now.to_i}.csv"
    stream = File.open(file_name, 'wb')

    CSV::Writer.generate(stream) do |csv|
      # header
      csv << [Enrollment.human_attribute_name(:type),
        Enrollment.human_attribute_name(:email),
        Enrollment.human_attribute_name(:status),
        Enrollment.human_attribute_name(:created_at),
        Enrollment.human_attribute_name(:activated_at),
        Enrollment.human_attribute_name(:deleted_at)]
      
      # body
      @records.each do |enrollment|
        row = []
        row << enrollment.to_s
        row << enrollment.email
        row << enrollment.human_current_state_name
        row << (enrollment.created_at ? I18n.l(enrollment.created_at) : "-")
        row << (enrollment.activated_at ? I18n.l(enrollment.activated_at) : "-")
        row << (enrollment.deleted_at ? I18n.l(enrollment.deleted_at) : "-")
        csv << row
      end
      
    end
    stream.close
    send_file file_name, :type => 'application/excel', :disposition => 'attachment',
      :encoding => "utf8"
  end
  
  protected
  
  def conditions_for_collection
    ['enrollments.type IN (?)', ['JournalistEnrollment']]
  end
  
  def before_update_save(record)
    record.attributes = params[:record]
    record.email_confirmation = record.email
    if record && record.person
      record.person.attributes = params[:person] 
      record.gender = record.person.gender
      record.academic_title_id = record.person.academic_title_id
      record.first_name = record.person.first_name
      record.last_name = record.person.last_name
      record.email = record.person.email
      record.person.email_confirmation = record.person.email
      record.person.save
      record.person.business_address.save if record.person.business_address
    end
  end
  
end
