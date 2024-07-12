# frozen_string_literal: true

module RailsKeycloakAuthorization
  module WithRoutesReader
    extend ActiveSupport::Concern
    extend self

    def available_routes
      available_route_names.map do |name|
        Rails.application.routes.named_routes.get(name)
      end
    end

    def route(route_name)
      Rails.application.routes.named_routes[route_name]
    end

    def available_route_names
      names = Rails.application.routes.named_routes.names.filter do |route_name|
        route_name.present? && !%w[rails action_mailbox active_storage auth root].any? { |exclude| route_name.to_s.include?(exclude) }
      end
      names.uniq
    end
  end
end

