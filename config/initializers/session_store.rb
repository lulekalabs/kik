# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_kik_session',
  :secret      => '9acfa6fa1d11321476e05c0e47d323fa194fbc0647e6abebcfa4fb84e280d036aae1a665ef2e3a2bd90c963c0dc46379a200d8d0c1083cf4ab606f99f3e39eb9'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
ActionController::Base.session_store = :active_record_store
