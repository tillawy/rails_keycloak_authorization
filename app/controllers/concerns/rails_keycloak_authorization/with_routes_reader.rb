# frozen_string_literal: true

module RailsKeycloakAuthorization
  module WithRoutesReader
    extend ActiveSupport::Concern
    def available_route_names
      names = Rails.application.routes.named_routes.names.filter do |route_name|
        route_name.present? && !%w[rails action_mailbox active_storage auth root].any? { |exclude| route_name.to_s.include?(exclude) }
      end
      names.uniq
    end
  end
end

