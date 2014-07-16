# Manages the question process
class Admin::QuestionsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :question do |config|
    #--- columns
    standard_columns = [
      :id,
      :summary,
      :description,
      :action_description,
      :contract_period,
      :postal_code,
      :province_code,
      :status,
      :topics,
      :mandated,
      :accessors_count,
      :referrer,
      :person
    ]
    crud_columns = [
      :summary,
      :description,
      :action_description, 
      :contract_period,
      :postal_code,
      :province_code,
      :topics
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns + [:referrer]
    config.list.columns = [:id, :person, :summary, :accessors_count, :mandated, :referrer, :created_at, :opened_at, :status]

    config.actions.exclude :create
    
    config.label = "Fragen"
    config.columns[:topics].label               = "Zuweisung von Rechtsthemen"

    #--- actions
    # approve
    do_approve_link = ActiveScaffold::DataStructures::ActionLink.new 'Zulassen', 
      :action => 'approve', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie die Frage jetzt zur weiteren Bearbeitung zulassen?"
    def do_approve_link.label
      return "[Zulassen]" if record.current_state == :preapproved && record.next_state_for_event(:approve)
      ''
    end
    config.action_links.add do_approve_link

    # activate
    do_activate_link = ActiveScaffold::DataStructures::ActionLink.new 'Aktivieren', 
      :action => 'activate', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie die Frage jetzt aktivieren (macht normalerweise der Rechtsuchende)?"
    def do_activate_link.label
      return "[Aktivieren]" if record.current_state == :created && record.next_state_for_event(:activate)
      ''
    end
    config.action_links.add do_activate_link

    config.nested.add_link('Mandate', [:mandates])


    config.list.per_page = 50
    config.list.sorting = [{:id => :desc}]
  end 
  
  def activate
    @record = Question.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :created && @record.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end

  def approve
    @record = Question.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :preapproved && @record.next_state_for_event(:approve)
      do_list_action(:approve!)
      return
    end
    render :nothing => true
  end

  protected 
  
  # workaround for STI problem
  # we save the record manually, then all works fine
  def before_update_save(record)
    @record.attributes = params[:record]
  end
  
end
