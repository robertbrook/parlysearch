# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_parlysearch_session',
  :secret      => '60b4c3c8921e3266a16b4e1b0397a8814f931e698f94222455ab4519e042139140a032d8246c15fa0045ec67b944127268441775135f1aed6f7eca4dd330e01d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
