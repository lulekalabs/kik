# Amin for responses (Bewerbungen)
class Admin::ResponsesController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :response do |config|
    #--- columns
    standard_columns = [
      :id,
      :person,
      :kase,
      :description,
      :status
    ]
    crud_columns = [
      :kase,
      :description
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:id, :person, :kase, :description, :status]

    config.label = "Bewerbungen"
    config.columns[:person].label = "Anwalt"
    config.columns[:kase].label = "Frage"
    
    #--- actions
    config.actions.exclude :create
    
    # approve
    do_approve_link = ActiveScaffold::DataStructures::ActionLink.new 'Zulassen', 
      :action => 'approve', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie die Bewerbung jetzt zur weiteren Bearbeitung zulassen?"
    def do_approve_link.label
      return "[Zulassen]" if record.current_state == :created && record.next_state_for_event(:approve)
      ''
    end
    config.action_links.add do_approve_link
    
  end 
  
  def activate
    @record = Response.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :created && @record.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end

  def approve
    @record = Response.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :created && @record.next_state_for_event(:approve)
      do_list_action(:approve!)
      return
    end
    render :nothing => true
  end
  
end
