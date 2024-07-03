module RailsKeycloakAuthorization
  module ResourcesHelper
    def resource_name_for_controller(controller_name)
      "#{controller_name}_controller"
    end
  end
end
