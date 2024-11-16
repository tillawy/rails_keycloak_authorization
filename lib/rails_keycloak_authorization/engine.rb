module RailsKeycloakAuthorization
  class Engine < ::Rails::Engine
    isolate_namespace RailsKeycloakAuthorization
    initializer "rails_keycloak_authorization.middleware" do |app|
      app.middleware.use RailsKeycloakAuthorization::Middleware
    end
    initializer "rails_keycloak_authorization.assets.precompile" do |app|
      app.config.assets.precompile += %w( rails_keycloak_authorization/application.css )
    end

    initializer "rails_keycloak_authorization.importmap", before: "importmap" do |app|
      RailsKeycloakAuthorization.importmap.draw root.join("config/importmap.rb")
      RailsKeycloakAuthorization.importmap.cache_sweeper watches: root.join("app/javascript")

      ActiveSupport.on_load(:action_controller_base) do
        before_action { RailsKeycloakAuthorization.importmap.cache_sweeper.execute_if_updated }
      end
    end

  end
end
