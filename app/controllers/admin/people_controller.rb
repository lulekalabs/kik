class Admin::PeopleController < Admin::AdminApplicationController

  #--- active scaffold
  active_scaffold :person do |config|
    #--- columns
    standard_columns = [
      :id,
      :type,
      :gender,
      :title,
      :first_name,
      :last_name,
      :email,
      :phone_number,
#      :company_url,
#      :company_name,
      :newsletter,
#      :remedy_insured,
      :referral_source,
      # associations
#      :bar_association,
#      :expertises
      :author,
    ]
    crud_columns = [
      :gender,
      :title,
      :first_name,
      :last_name,
      :email,
      :phone_number,
#      :company_url,
#      :company_name,
      :newsletter,
#      :remedy_insured,
      :referral_source,
      # associations
#      :bar_association,
#      :expertises
      :author
    ]
    config.columns = standard_columns
    config.create.columns = crud_columns
    config.update.columns = crud_columns
    config.show.columns = crud_columns
    config.list.columns = [:first_name, :last_name, :title, :gender, :type, :created_at]
    
    config.columns[:author].form_ui = :checkbox
  end  
  
end
