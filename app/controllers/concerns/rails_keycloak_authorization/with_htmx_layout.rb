module RailsKeycloakAuthorization
  # This concern is to explicitly force htmx layout with routes, layout=htmx
  module WithHtmxLayout
    extend ActiveSupport::Concern
    included do
      before_action do
        if request.params[:layout] == "htmx"
          self.class.layout "rails_keycloak_authorization/htmx"
        else
          self.class.layout false
        end
      end
    end
  end
end