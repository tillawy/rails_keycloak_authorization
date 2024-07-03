module RailsKeycloakAuthorization
  module WithKeycloakAdmin
    extend ActiveSupport::Concern
    included do
      before_action :keycloak_admin_configure
    end

    private

    def keycloak_authz_resource(controller_name)
      resource_name = resource_name_for_controller(controller_name)
      KeycloakAdmin
        .realm(realm_name)
        .authz_resources(openid_client.id)
        .find_by(resource_name, "urn:#{openid_client.client_id}:resources:controllers", "", "", "")
        .first
    rescue
      nil
    end



    def realm_name
      ENV.fetch('KEYCLOAK_AUTH_CLIENT_REALM_NAME')
    end

    def openid_client
      KeycloakAdmin.realm(realm_name).clients.find_by_client_id(ENV["KEYCLOAK_AUTH_CLIENT_ID"])
    end

    def keycloak_admin_configure
      KeycloakAdmin.configure do |config|
        config.use_service_account = true
        config.server_url          = ENV["KEYCLOAK_SERVER_URL"]
        config.server_domain       = ENV["KEYCLOAK_SERVER_DOMAIN"]
        config.client_id           = ENV["KEYCLOAK_ADMIN_CLIENT_ID"]
        config.client_realm_name   = ENV["KEYCLOAK_ADMIN_REALM_NAME"]
        config.client_secret       = ENV["KEYCLOAK_ADMIN_CLIENT_SECRET"]
        config.logger              = Rails.logger
        config.rest_client_options = { timeout: 3, verify_ssl: Rails.env.production? }
      end
    end
  end
end