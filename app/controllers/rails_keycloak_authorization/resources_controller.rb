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

    def index
      @route_names = Rails.application.routes.named_routes.names
      @controller_names = @route_names.map { |route_name|
        Rails.application.routes.named_routes[route_name].defaults[:controller]
      }.filter{|route_name|
        !route_name.nil? && !route_name.include?("rails") && !route_name.include?("action_mailbox") && !route_name.include?("active_storage") && !route_name.include?("oauth") }.uniq
      @resources = KeycloakAdmin.realm(realm_name).authz_resources(openid_client.id).list
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
