module RailsKeycloakAuthorization
  class ResourcesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include ResourcesHelper

    def create
      route = Rails.application.routes.named_routes[params[:route_id]]
      resource_name = resource_name_for_controller(route.defaults[:controller])
      KeycloakAdmin
        .realm(realm_name)
        .authz_resources(openid_client.id)
        .create!(
          resource_name,
          "urn:#{openid_client.client_id}:resources:controllers", [], "", "", [])
      redirect_to resource_path(route.name)
    end

    def new
      @route = Rails.application.routes.named_routes[params[:route_id]]
    end

    def show
      @route = Rails.application.routes.named_routes[params[:id]]
      @keycloak_resource = keycloak_authz_resource(@route.defaults[:controller])
    end
  end
end
