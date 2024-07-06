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
                 .detect{|s| s == params[:keycloak_scope_name]}
    end

    def new
      @keycloak_scope_name = params[:keycloak_scope_name]
      @keycloak_resource_id = params[:keycloak_resource_id]
    end

    def attach
      KeycloakAdmin.realm(realm_name).authz_resources(client.id).update(resource.id,
                                                                             {
                                                                               "uris": [ "/asdf/*" , "/tmp/45" ],
                                                                             }
      )
    end
    def create
      scope = KeycloakAdmin
        .realm(realm_name)
        .authz_scopes(openid_client.id)
        .create!(params[:keycloak_scope_name], params[:keycloak_scope_name], "")

      redirect_to scope_path(scope.id, keycloak_resource_id: params[:keycloak_resource_id], keycloak_scope_name: params[:keycloak_scope_name])
    end
  end
end