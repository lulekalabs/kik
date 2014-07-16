# Bewertungen
class Admin::ReviewsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :review do |config|
    #--- columns
    standard_columns = [
      :id,
      :reviewer,
      :reviewee,
      :grade_point_average,
      :status,
      :v, :v1, :v2, :v3, :v4, :v5,
      :z, :z1, :z2, :z3, :z4, :z5,
      :m, :m1, :m2, :m3, :m4, :m5,
      :e, :e1, :e2, :e3, :e4, :e5,
      :a, :a1, :a2, :a3, :a4, :a5,
      :created_at,
      :updated_at,
      :opened_at,
      :closed_at
    ]
    crud_columns = [
      :v, :v1, :v2, :v3, :v4, :v5,
      :z, :z1, :z2, :z3, :z4, :z5,
      :m, :m1, :m2, :m3, :m4, :m5,
      :e, :e1, :e2, :e3, :e4, :e5,
      :a, :a1, :a2, :a3, :a4, :a5,
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:id, :reviewee, :reviewer, :gpa, :status, :created_at, :opened_at]

    config.label = "Bewertungen"
    config.columns[:reviewee].label = "Anwalt"
    config.columns[:reviewer].label = "Rechtsuchender"
    
    #--- actions
    config.actions.exclude :create
    
    # approve
    do_approve_link = ActiveScaffold::DataStructures::ActionLink.new 'Zulassen', 
      :action => 'approve', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie die Bewertung jetzt zur weiteren Bearbeitung zulassen?"
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
      :confirm => "Wollen Sie die Bewertung jetzt aktivieren (macht normalerweise der Rechtsuchende)?"
    def do_activate_link.label
      return "[Aktivieren]" if record.current_state == :created && record.next_state_for_event(:activate)
      ''
    end
    config.action_links.add do_activate_link

    # cancel
    do_activate_link = ActiveScaffold::DataStructures::ActionLink.new 'Schließen', 
      :action => 'cancel', :type => :record, :crud_type => :update,
      :position => false, :inline => true,
      :method => :post,
      :confirm => "Wollen Sie die Bewertung jetzt schließen?"
    def do_activate_link.label
      return "[Schließen]" if record.current_state == :open && record.next_state_for_event(:cancel)
      ''
    end
    config.action_links.add do_activate_link
    
  end 
  
  def activate
    @record = Review.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :created && @record.next_state_for_event(:activate)
      do_list_action(:activate!)
      return
    end
    render :nothing => true
  end

  def approve
    @record = Review.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :preapproved && @record.next_state_for_event(:approve)
      do_list_action(:approve!)
      return
    end
    render :nothing => true
  end

  def cancel
    @record = Review.find_by_id params[:id]
    raise UserException.new(:record_not_found) if @record.nil?
    
    if @record && @record.current_state == :open && @record.next_state_for_event(:cancel)
      do_list_action(:cancel!)
      return
    end
    render :nothing => true
  end
  
  protected
  
end
