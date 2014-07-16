# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

config.action_mailer.default_url_options = {:host => "test.tst"}

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

# setup for each request
config.to_prepare do
  #--- geokit
  GeoKit::default_units = :kms
  GeoKit::default_formula = :sphere
  GeoKit::Geocoders::timeout = 3

  GeoKit::Geocoders::google     = 'ABQIAAAA3jIP-UwrX5YmhumykFl2_RTJQa0g3IQ9GZqIMmInSLzwtGDKaBSG8ZDHOTJL2qdtpxep7fkFAsL6Qw'

  GeoKit::Geocoders::geocoder_us = false 
  GeoKit::Geocoders::geocoder_ca = false

  GeoKit::Geocoders::provider_order = [:google]
  GeoKit::Geocoders::ip_provider_order = [:ip] # [:maxmind_ip, :ip]
end

# setup after rails is initialized
config.after_initialize do 
end

#--------------------------------------------------------------------------------------------------
# development specific required libraries (development env only!)
#--------------------------------------------------------------------------------------------------
config.gem "mocha", :version => ">=0.9.10"
config.gem "ruby-debug"

