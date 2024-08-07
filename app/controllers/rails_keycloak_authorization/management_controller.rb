module RailsKeycloakAuthorization
  class ManagementController < ApplicationController
    layout false

    def index
      render layout: "rails_keycloak_authorization/htmx"
    end
  end
end
