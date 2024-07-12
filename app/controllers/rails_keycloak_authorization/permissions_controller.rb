module RailsKeycloakAuthorization
  class PermissionsController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include ResourcesHelper

    def index
      @permissions = KeycloakAdminRubyAgent.list_keycloak_permissions
      @resources = KeycloakAdminRubyAgent.list_keycloak_resources_for_controllers
      @policies = KeycloakAdminRubyAgent.list_keycloak_policies
    end

    def resource_scopes_select
      @resource_scopes = KeycloakAdmin
                          .realm(realm_name)
                          .authz_scopes(openid_client.id, params[:keycloak_resource_id])
                          .list
    end

    def create
      resource = KeycloakAdmin.realm(realm_name).authz_resources(openid_client.id).get(params[:keycloak_resource_id] )
      scope = KeycloakAdmin.realm(realm_name).authz_scopes(openid_client.id, resource.id).get(params[:keycloak_scope_id])
      KeycloakAdmin
        .realm(realm_name)
        .authz_permissions(openid_client.id, :scope)
        .create!(
          "RKA #{resource.name} #{scope.name} ",
          "RailsKeycloakRails permission #{resource.name}",
          "UNANIMOUS",
          "POSITIVE",
          [ params[:keycloak_resource_id] ],
          [ params[:keycloak_policy_id] ],
          [ params[:keycloak_scope_id] ],
          "scope"
        )
    end
  end
end