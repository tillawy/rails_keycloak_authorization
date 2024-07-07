module RailsKeycloakAuthorization
  class PoliciesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include ResourcesHelper

    POLICY_NAME = "RailsKeycloakAuthorizationPolicy"

    def index
      @default_policy_name = POLICY_NAME
      @policies = KeycloakAdmin.realm(realm_name)
                               .authz_policies(openid_client.id, 'role')
                               .find_by(POLICY_NAME, "role")

      @realm_roles =  KeycloakAdmin.realm(realm_name).roles.list
    end

    def create
      KeycloakAdmin
        .realm(realm_name)
        .authz_policies(openid_client.id, 'role')
        .create!(POLICY_NAME,
                 "Default policy for RailsKeycloakAuthorization",
                 "role",
                 "POSITIVE",
                 "UNANIMOUS",
                 true,
                 [{id: params[:keycloak_realm_role_id], required: true}]
        )
    end
  end
end
