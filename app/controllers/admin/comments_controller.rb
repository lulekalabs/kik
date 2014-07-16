# Manages the administration of comments
class Admin::CommentsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :comment do |config|
    #--- columns
    standard_columns = [
      :id,
      :message,
      :created_at,
      :updated_at,
      :commentable
    ]
    crud_columns = [
      :message
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:commentable, :person, :message, :commentable, :created_at]

    #--- actions
    config.actions.exclude :create
    
    # approve
    do_approve_link = ActiveScaffold::DataStructures::ActionLink.new 'Zulassen', 
      :action => 'approve', :type => :record, :crud_type => :update,
      :position => false, :inline => true, :method => :post,
      :confirm => "Wollen Sie den Nachtrag jetzt zur weiteren Bearbeitung zulassen?"
    def do_approve_link.label
      return "[Zulassen]" if record.current_state == :created && record.next_state_for_event(:activate)
      ''
    end
    config.action_links.add do_approve_link
    
    config.label = "Nachträge und Antworten"
    
  end 
  
  def approve
    @record = Comment.find_by_id params[:id]
    
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :created && @record.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end
  
  protected
  
end
