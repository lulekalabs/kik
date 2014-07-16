# Simple scaffold to display messages
class Admin::MessagesController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :message do |config|
    #--- columns
    standard_columns = [
      :id,
      :sender_id,
      :receiver_id,
      :subject,
      :message,
      :status,
      :type,
      :created_at,
      :updated_at
    ]
    crud_columns = [
      :subject,
      :message
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:id, :type, :sender_id, :receiver_id, :subject, :status, :created_at]

    config.list.per_page = 500
    config.list.sorting = [{:created_at => :desc}]

    config.actions = [:list, :show]
    config.label = "Nachrichten"
    config.columns[:type].label = "Art"
    config.columns[:sender_id].label = "Absender"
    config.columns[:receiver_id].label = "Empfänger"
    config.columns[:subject].label = "Betreff"
    config.columns[:message].label = "Inhalt"
    config.columns[:created_at].label = "Gesendet Am"
    
    # complete
    do_complete_link = ActiveScaffold::DataStructures::ActionLink.new 'Erledigt', 
      :action => 'complete', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie den Vorgang als erledigt markieren?"
    def do_complete_link.label
      return "[Erledigt]" if record && record.current_state == :delivered && record.next_state_for_event(:complete)
      ''
    end
    config.action_links.add do_complete_link
    
  end 
  
  def complete
    @record = Message.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :delivered && @record.next_state_for_event(:complete)
      do_list_action(:complete!)
      return
    end
    render :nothing => true
  end
  
  protected

  # Triggers the provided event and updates the list item.
  # Usage:     do_list_action(:suspend!)
  def do_list_action(event)
    @record = active_scaffold_config.model.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?    
    if @record && @record.send("#{event}")
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
