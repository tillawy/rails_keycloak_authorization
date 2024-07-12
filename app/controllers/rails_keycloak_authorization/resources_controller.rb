module RailsKeycloakAuthorization
  class ResourcesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include ResourcesHelper
    include WithRoutesReader

    def create
      KeycloakAdminRubyAgent.create_keycloak_resource(params[:route_id])
      redirect_to resource_path(params[:route_id])
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
      @route = route(params[:route_id])
    end

    def show
      @route = route(params[:id])
      @keycloak_resource = KeycloakAdminRubyAgent.keycloak_resource(@route.defaults[:controller])
    end
  end
end
