module RailsKeycloakAuthorization
  class ScopesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout

    def index
      @scopes = KeycloakAdmin
                  .realm(realm_name)
                  .authz_scopes(openid_client.id, params[:keycloak_resource_id])
                  .list
    end

    def show
      @keycloak_scope_name = params[:keycloak_scope_name]
      @keycloak_resource_id = params[:keycloak_resource_id]

      @available_scope = KeycloakAdmin
                          .realm(realm_name)
                          .authz_scopes(openid_client.id)
                          .search(params[:keycloak_scope_name])
                          .first

      @resource_scope = KeycloakAdmin
                 .realm(realm_name)
                 .authz_scopes(openid_client.id, params[:keycloak_resource_id])
                 .list
                 .detect{|s| s.name == params[:keycloak_scope_name]}
    end

    def new
      @keycloak_scope_name = params[:keycloak_scope_name]
      @keycloak_resource_id = params[:keycloak_resource_id]
    end

    def attach
      keycloak_scope_name = params[:keycloak_scope_name]
      keycloak_resource_id = params[:keycloak_resource_id]

      KeycloakAdminRubyAgent.attach_scope_to_resource(keycloak_scope_name, keycloak_resource_id)
      redirect_to scope_path("scope", keycloak_resource_id: keycloak_resource_id, keycloak_scope_name: keycloak_scope_name)
    end

    def create
      scope = KeycloakAdminRubyAgent.create_keycloak_scope(params[:keycloak_scope_name])
      redirect_to scope_path(scope.id, keycloak_resource_id: params[:keycloak_resource_id], keycloak_scope_name: params[:keycloak_scope_name])
    end
  end
end