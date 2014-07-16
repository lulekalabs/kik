class Admin::DelayedJobsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold "Delayed::Job" do |config|
    #--- columns
    standard_columns = [
      :id,
      :priority,
      :attempts,
      :handler,
      :last_error,
      :run_at,
      :schedule,
      :period,
      :locked_at,
      :failed_at,
      :locked_by,
      :created_at,
      :updated_at
    ]
    crud_columns = []
    config.columns = standard_columns
    config.show.columns = crud_columns
    config.list.columns = [
      :priority,
      :attempts,
      :handler,
      :last_error,
      :run_at,
      :schedule,
      :period,
      :locked_by,
      :locked_at,
      :failed_at,
      :created_at,
      :updated_at
    ]

    #--- sorting
    list.sorting = {:schedule => 'DESC'}
    
    #--- scaffold actions
    config.actions.exclude :create
    config.actions.exclude :update
    config.actions.exclude :show
    
    config.label = "Job Schedule"
    
    config.action_links.add 'reset', :label => 'Reset', :type => :table, 
      :action => 'reset', :inline => false, :position => false, :confirm => "Sollen die Jobs nochmal gestartet werden?"
    
  end  
  
  def reset
    Delayed::Job.destroy_all
    system("rake jobs:schedule")
    redirect_to admin_delayed_jobs_path
  end
  
  protected
  
  def list_authorized?
    true
#    current_user && current_user.has_role?(:admin)
  end

  def create_authorized?
    true
#    current_user && current_user.has_role?(:admin)
  end

  def update_authorized?
    true
#    current_user && current_user.has_role?(:admin)
  end

  def delete_authorized?
    true
#    current_user && current_user.has_role?(:admin)
  end
  
end
