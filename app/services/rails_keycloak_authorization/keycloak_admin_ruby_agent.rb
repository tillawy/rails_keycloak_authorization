module RailsKeycloakAuthorization
  class KeycloakAdminRubyAgent
    class << self
      def initialize
        super
        keycloak_admin_configure
      end

      def create_keycloak_scope(keycloak_scope_name)
        KeycloakAdmin
          .realm(realm_name)
          .authz_scopes(openid_client.id)
          .create!(
            keycloak_scope_name,
            "RKA #{keycloak_scope_name}",
            ""
          )
      end

      def create_keycloak_resource(route_id)
        route = WithRoutesReader.route(route_id)
        resource_name = resource_name_for(route.defaults[:controller])

        KeycloakAdmin
          .realm(realm_name)
          .authz_resources(openid_client.id)
          .create!(
            resource_name,
            type_for(openid_client.client_id),
            [],
            true,
            "RKA #{resource_name}",
            [])
      end

      def keycloak_resource(controller_name)
        resource_name = resource_name_for(controller_name)
        KeycloakAdmin
          .realm(realm_name)
          .authz_resources(openid_client.id)
          .find_by(resource_name,
                   type_for(openid_client.client_id),
                   "",
                   "",
                   "")
          .first
      rescue
        nil
      end

      def realm_name
        ENV.fetch("KEYCLOAK_AUTH_CLIENT_REALM_NAME")
      end

      def openid_client
        KeycloakAdmin
          .realm(realm_name)
          .clients
          .find_by_client_id(ENV.fetch("KEYCLOAK_AUTH_CLIENT_ID"))
      end

      def type_for(openid_client_id)
        "urn:#{openid_client_id}:rka:resources:controllers"
      end
      def resource_name_for(controller_name)
        "#{controller_name}_controller"
      end

      def keycloak_admin_configure
        KeycloakAdmin.configure do |config|
          config.use_service_account = true
          config.server_url = ENV.fetch("KEYCLOAK_SERVER_URL")
          config.server_domain = ENV.fetch("KEYCLOAK_SERVER_DOMAIN")
          config.client_id = ENV.fetch("KEYCLOAK_ADMIN_CLIENT_ID")
          config.client_realm_name = ENV.fetch("KEYCLOAK_ADMIN_REALM_NAME")
          config.client_secret = ENV.fetch("KEYCLOAK_ADMIN_CLIENT_SECRET")
          config.logger = Rails.logger
          config.rest_client_options = { timeout: 5, verify_ssl: Rails.env.production? }
        end
      end
    end

    def self.attach_scope_to_resource(keycloak_scope_name, keycloak_resource_id)
      KeycloakAdmin.realm(realm_name)
                   .authz_resources(openid_client.id)
                   .update(keycloak_resource_id, scopes: [{name: keycloak_scope_name}])
    end
  end
end

