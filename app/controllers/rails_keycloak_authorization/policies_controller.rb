module RailsKeycloakAuthorization
  class PoliciesController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include ResourcesHelper

    def index

    end
  end
end
