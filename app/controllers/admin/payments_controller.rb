class Admin::PaymentsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :payments do |config|
    #--- columns
    standard_columns = [
      :id,
      :payable_id,
      :payable_type,
      :success,
      :reference,
      :message,
      :action,
      :params,
      :test,
      :amount,
      :position,
      :type,
      :interval_length,
      :interval_unit,
      :duration_start_date,
      :duration_occurrences
    ]
    crud_columns = [
      :payable_id,
      :success,
      :reference,
      :message,
      :action,
      :params,
      :test,
      :amount,
      :position
    ]
    config.columns = standard_columns
    config.show.columns = crud_columns
    config.list.columns = [
      :position,
      :success,
      :reference,
      :message,
      :test,
      :interval_length,
#      :interval_unit,
      :duration_start_date,
      :duration_occurrences,
      :action,
      :amount
    ]
    
    #--- acttions
    config.actions.exclude :create
    config.actions.exclude :delete
    config.actions.exclude :search
    config.actions.exclude :update
    config.actions.exclude :show

  end
end
