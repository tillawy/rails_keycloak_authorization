module RailsKeycloakAuthorization
  class Engine < ::Rails::Engine
    isolate_namespace RailsKeycloakAuthorization
    initializer "rails_keycloak_authorization.middleware" do |app|
      app.middleware.use RailsKeycloakAuthorization::Middleware
    end
  end
end
