
# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers #{RAILS_ROOT}/lib/jobs #{RAILS_ROOT}/app/observers )
  config.load_once_paths += %W( #{RAILS_ROOT}/app/observers )
  
  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem "money", :version => "=1.7.1"
  config.gem "uuidtools", :version => ">=1.0.7"
  config.gem "builder", :version => ">=2.1.2"
  config.gem 'crypt', :version => '1.1.4', :lib => 'crypt/blowfish'
  
#  config.gem "rmagick", :version => ">=2.9.2"
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  config.plugins = [:validates_email_format_of, :acts_as_readable, :all]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :reading_observer

  config.action_controller.session = {
    :session_key => '_kik_session',
    :secret      => '6f2dd3df5a49d0dca81c89d47da2c63033b367f37d21cc2d80bd254a934738e97e9496508840d5fb78f3fefa40b220be5ac6d444f8dca54bd143b4059d9053a0'
  }

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Berlin'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  config.i18n.default_locale = :de
  
  config.action_controller.resources_path_names = {:new => 'neu', :edit => 'bearbeiten', :complete => 'fertig'}
  
  # plugin order 
  config.plugins = config.plugins = [:all, :active_scaffold]

  # ActiveRecord optimistic locking
  # http://api.rubyonrails.com/classes/ActiveRecord/Locking/Optimistic/ClassMethods.html
  # turned off as orders and invoice would throw error due to ?bug? lock_version
  config.active_record.lock_optimistically = false

  # recpatch
  ENV['RECAPTCHA_PUBLIC_KEY']  = '6LeQHQsAAAAAALTXlrEmZTacxyt9urjRD_ZRK8mf'
  ENV['RECAPTCHA_PRIVATE_KEY'] = '6LeQHQsAAAAAAF-K0shwTmtgFuWUjx1_ei_0Xbhm'
end
