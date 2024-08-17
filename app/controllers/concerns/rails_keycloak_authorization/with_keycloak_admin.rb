module RailsKeycloakAuthorization
  module WithKeycloakAdmin
    extend ActiveSupport::Concern
    included do
      before_action :keycloak_admin_configure
    end

 
    def realm_name
      RailsKeycloakAuthorization.keycloak_auth_client_realm_name
    end
    private


    def openid_client
      KeycloakAdmin.realm(realm_name).clients.find_by_client_id(RailsKeycloakAuthorization.keycloak_auth_client_id)
    end

    def keycloak_admin_configure
      KeycloakAdmin.configure do |config|
        config.use_service_account = true
        config.server_url          = RailsKeycloakAuthorization.keycloak_server_url
        config.server_domain       = RailsKeycloakAuthorization.keycloak_server_domain
        config.client_realm_name   = RailsKeycloakAuthorization.keycloak_admin_realm_name
        config.client_id           = RailsKeycloakAuthorization.keycloak_admin_client_id
        config.client_secret       = RailsKeycloakAuthorization.keycloak_admin_client_secret
        config.logger              = Rails.logger
        config.rest_client_options = { timeout: 3, verify_ssl: Rails.env.production? }
      end
    end
  end
end
