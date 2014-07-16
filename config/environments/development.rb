# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.default_url_options = {:host => "localhost:3000"}

=begin
ActionMailer::Base.smtp_settings = {
  :address            => "smtp.codecuisine.de",
  :port               => 587, # 25,
  :perform_deliveries => true,
  :domain             => "kik.codecuisine.de",
  :authentication     => :plain,
  :user_name          => 'kik@codecuisine.de',
  :password           => 'batF6vllBv'
}
=end

# setup for each request
config.to_prepare do
  Project.pre_launch = false
  
  #--- geokit
  GeoKit::default_units = :kms
  GeoKit::default_formula = :sphere
  GeoKit::Geocoders::timeout = 3

  GeoKit::Geocoders::google     = 'ABQIAAAA3jIP-UwrX5YmhumykFl2_RTJQa0g3IQ9GZqIMmInSLzwtGDKaBSG8ZDHOTJL2qdtpxep7fkFAsL6Qw'

  GeoKit::Geocoders::geocoder_us = false 
  GeoKit::Geocoders::geocoder_ca = false

  GeoKit::Geocoders::provider_order = [:google]
  GeoKit::Geocoders::ip_provider_order = [:ip] # [:maxmind_ip, :ip]

  #--- override recurring for Merchant Sidekick interval set to once every 5 days
  Project.default_recurring_options = {:interval => {:length => 5, :unit => :day}, 
    :duration => {:occurrences => 999}}
  Product.monthly_term_days = 5
  Product.anual_term_days = 15
end

# setup after rails is initialized
config.after_initialize do 
end

#--------------------------------------------------------------------------------------------------
# development specific required libraries (development env only!)
#--------------------------------------------------------------------------------------------------
config.gem "ruby-debug"

