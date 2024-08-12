module RailsKeycloakAuthorization
  class PoliciesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include ResourcesHelper


    def index
      @default_policy_name = KeycloakAdminRubyAgent.policy_name
      @policies = KeycloakAdminRubyAgent.list_keycloak_policies
      @realm_roles = KeycloakAdminRubyAgent.list_roles
    end

    def create
      KeycloakAdminRubyAgent.create_keycloak_policy(params[:keycloak_realm_role_id], params[:keycloak_policy_name])
      redirect_to policies_path
    end
  end
end
