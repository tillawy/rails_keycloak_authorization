module RailsKeycloakAuthorization
  class KeycloakAdminRubyAgent
    class << self

      POLICY_NAME = "RKA-Policy"

      def initialize
        super
        keycloak_admin_configure
      end

      def policy_name
        POLICY_NAME
      end

      def list_keycloak_resources_for_controllers
        KeycloakAdmin.realm(realm_name)
                     .authz_resources(openid_client.id)
                     .find_by("",
                              resource_type_for_controller,
                              "",
                              "",
                              "")
      end

      def list_keycloak_permissions
        KeycloakAdmin.realm(realm_name)
                     .authz_permissions(openid_client.id, "scope")
                     .find_by(nil, nil)
      end

      def list_keycloak_policies
        KeycloakAdmin.realm(realm_name)
                     .authz_policies(openid_client.id, 'role')
                     .find_by(POLICY_NAME, "role")
      end

      def create_keycloak_policy(keycloak_realm_role_id, policy_name)
        KeycloakAdmin
          .realm(realm_name)
          .authz_policies(openid_client.id, 'role')
          .create!(policy_name,
                   "#{POLICY_NAME} default policy",
                   "role",
                   "POSITIVE",
                   "UNANIMOUS",
                   true,
                   [{id: keycloak_realm_role_id, required: true}]
          )
      end

      def list_policies

      end

      def list_roles
        KeycloakAdmin.realm(realm_name).roles.list
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
            resource_type_for_controller,
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
                   resource_type_for_controller,
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

      def resource_type_for_controller
        type_for(openid_client.client_id)
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

