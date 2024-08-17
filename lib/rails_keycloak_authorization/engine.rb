module RailsKeycloakAuthorization
  class Engine < ::Rails::Engine
    require 'keycloak-admin'
    isolate_namespace RailsKeycloakAuthorization
    initializer "rails_keycloak_authorization.middleware" do |app|
      app.middleware.use RailsKeycloakAuthorization::Middleware
    end
    initializer "rails_keycloak_authorization.assets.precompile" do |app|
      app.config.assets.precompile += %w( rails_keycloak_authorization/application.css )
    end
  end
end
