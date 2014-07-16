class Admin::VoucherRedemptionsController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :voucher_redemption do |config|
    #--- columns
    standard_columns = [
      :id,
      :person_id,
      :voucher_id,
      :redeemed_at
    ]
    crud_columns = [
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:person_id, :redeemed_at, :voucher_id]
    
    #--- scaffold actions
    config.actions.exclude :create
    config.actions.exclude :update
    config.actions.exclude :show
    
    config.label = "Eingelöste Gutscheine"

    # exclude in article
    config.subform.columns.exclude :voucher_id
    
  end 
  
  protected
  
end
