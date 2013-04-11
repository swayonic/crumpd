# Be sure to restart your server when you modify this file.

# Mpd::Application.config.session_store :cookie_store, key: '_mpd_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
#Mpd::Application.config.session_store :active_record_store

require 'action_dispatch/middleware/session/dalli_store'
Mpd::Application.config.session_store :dalli_store,
  :memcache_server => ['127.0.0.1'],
  :namespace => 'sessions',
  :key => '_simpd_session',
  :expire_after => 1.days
