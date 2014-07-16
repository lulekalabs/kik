# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
 config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

config.action_mailer.default_url_options = {:host => "www.kann-ich-klagen.de"}

ActionMailer::Base.smtp_settings = {
  :address            => "mail.progra.de",
  :port               => 25,
  :perform_deliveries => true,
  :domain             => "kann-ich-klagen.de",
  :authentication     => :plain,
  :user_name          => 'mailrobot@kann-ich-klagen.de',
  :password           => 'admin'
}

# setup for each request
config.to_prepare do
end

# setup after rails is initialized
config.after_initialize do 
  #--- geokit
  GeoKit::default_units = :kms
  GeoKit::default_formula = :sphere
  GeoKit::Geocoders::timeout = 3

  GeoKit::Geocoders::google     = 'ABQIAAAA3jIP-UwrX5YmhumykFl2_RQBS54mPD3Wd_0anbXRVo4KTc4CyhRIApbRy6hAEkCWI2INCjaK9Yh2rg'

  GeoKit::Geocoders::geocoder_us = false 
  GeoKit::Geocoders::geocoder_ca = false

  GeoKit::Geocoders::provider_order = [:google]
  GeoKit::Geocoders::ip_provider_order = [:ip] # [:maxmind_ip, :ip]
  
  #--- override recurring for Merchant Sidekick interval set to once every 5 days
  Project.default_recurring_options = {:interval => {:length => 30, :unit => :day}, 
    :duration => {:occurrences => 999}}
  Product.monthly_term_days = 30
  Product.anual_term_days = 365
end

