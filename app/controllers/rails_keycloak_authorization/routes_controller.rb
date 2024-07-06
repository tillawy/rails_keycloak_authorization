module RailsKeycloakAuthorization
  class RoutesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include WithRoutesReader

    before_action :set_route, only: [:show]

    def index
      @routes = available_route_names.map {|name| Rails.application.routes.named_routes.get(name) }
    end

    def show
    end

    private


    def set_route
      @route = Rails.application.routes.named_routes[params[:id]]
    end
  end
end
