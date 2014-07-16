class Advofinder::Client::ClientApplicationController < Advofinder::AdvofinderApplicationController
  
  #--- filters
  # prepend_before_filter :login_advofinder_client_required
  prepend_before_filter :login_required
  
end
