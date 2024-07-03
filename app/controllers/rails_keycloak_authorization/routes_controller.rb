module RailsKeycloakAuthorization
  class RoutesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout

    before_action :set_route, only: [ :show ]

    def index
      @routes = route_names.map {|name| Rails.application.routes.named_routes.get(name) }
    end

    def show
      # @keycloak_resource = keycloak_authz_resource(@route.defaults[:controller])
    end

    # def authz_resource
    #   @keycloak_resource = keycloak_authz_resource(@route.defaults[:controller])
    # end

    private
    def route_names
      Rails.application.routes.named_routes.names.filter{|r| !r.to_s.include?("rails_")}
    end

    def set_route
      @route = Rails.application.routes.named_routes[params[:id]]
    end
  end
end
