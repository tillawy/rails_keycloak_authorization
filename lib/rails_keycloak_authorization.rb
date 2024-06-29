require "rails_keycloak_authorization/version"
require "rails_keycloak_authorization/engine"

module RailsKeycloakAuthorization
  mattr_accessor :keycloak_realm
  mattr_accessor :keycloak_admin_url
  mattr_accessor :keycloak_admin_username
  mattr_accessor :keycloak_admin_password
  class Middleware
    def initialize(app)
      @app = app
    end
    def call(env)
      puts "Rails::Keycloak::Authorization.keycloak_realm:"
      puts RailsKeycloakAuthorization.keycloak_realm
      # [200, {}, ["Hello Middleware, Rails::Keycloak::Authorization!"]]
      @app.call(env)
    end
  end
end
