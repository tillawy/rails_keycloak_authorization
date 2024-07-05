module RailsKeycloakAuthorization
  class RoutesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout

    before_action :set_route, only: [:show]

    def index
      @routes = route_names.map {|name| Rails.application.routes.named_routes.get(name) }
    end

    def show
    end

    private
    def route_names
      Rails.application.routes.named_routes.names.filter do |r|
        !r.to_s.include?("rails_")
      end
    end

    def set_route
      @route = Rails.application.routes.named_routes[params[:id]]
    end
  end
end
