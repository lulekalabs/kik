# Simple scaffold to display messages
class Admin::NewslettersController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :enrollment do |config|
    #--- columns
    standard_columns = [
      :id,
      :academic_title_id,
      :person_id,
      :gender,
      :first_name,
      :last_name,
      :email,
      :press_release_per_email,
      :press_release_per_fax,
      :press_release_per_mail,
      :state,
      :type,
      :activated_at,
      :deleted_at,
      :created_at,
      :updated_at
    ]
    crud_columns = [
      :academic_title_id,
      :gender,
      :first_name,
      :last_name,
      :email,
      :press_release_per_email,
      :press_release_per_fax,
      :press_release_per_mail,
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:type, :email, :state, :created_at, :activated_at, :deleted_at]

    # links
    do_activate_link = ActiveScaffold::DataStructures::ActionLink.new 'Aktivieren', 
      :action => 'activate', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Newsletter jetzt aktivieren?"
    def do_activate_link.label
      return "[Aktivieren]" if record.current_state == :pending && record.next_state_for_event(:activate)
      return "[Aktivieren]" if record.current_state == :passive && record.next_state_for_event(:activate)
      ''
    end
    config.action_links.add do_activate_link

    config.action_links.add 'export', :label => 'Exportieren', :type => :table, 
      :action => 'export', :inline => false, :position => false

    # labels
    config.columns[:press_release_per_email].form_ui = :checkbox
    config.columns[:press_release_per_fax].form_ui = :checkbox
    config.columns[:press_release_per_mail].form_ui = :checkbox
    

#    config.actions = [:list, :show, :delete]
    config.label = "Newsletter"
    config.columns[:type].label = "Art"

    config.columns[:press_release_per_email].label = "Newsletter als Email"
    config.columns[:press_release_per_fax].label = "Newsletter als Fax"
    config.columns[:press_release_per_mail].label = "Newsletter als Email"

    #--- actions
    config.actions.exclude :create

  end 
  
  def activate
    @record = Enrollment.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    
    if (@record.current_state == :pending || @record.current_state == :passive) && @record.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end
  
  def export
    @records = Enrollment.visible.without_journalist_enrollments
    
    file_name = "#{RAILS_ROOT}/tmp/newsletter_#{Time.now.to_i}.csv"
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
    ['enrollments.type != ?', JournalistEnrollment.name]
  end
  
  
end
