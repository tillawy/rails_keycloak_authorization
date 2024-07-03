module RailsKeycloakAuthorization
  class ResourcesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout

    def create
      route = Rails.application.routes.named_routes[params[:route_id]]
      KeycloakAdmin
        .realm(realm_name)
        .authz_resources(openid_client.id)
        .create!(
          route.defaults[:controller],
          "urn:#{openid_client.client_id}:resources:controllers", [], "", "", [])
      redirect_to routes_path
    end

    def show
      @route = Rails.application.routes.named_routes[params[:route_id]]
      @keycloak_resource = keycloak_authz_resource(@route.defaults[:controller])
    end
  end
end
