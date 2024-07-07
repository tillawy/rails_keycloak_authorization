module RailsKeycloakAuthorization
  class PermissionsController < ApplicationController
    include WithKeycloakAdmin
    include WithHtmxLayout
    include ResourcesHelper

    def index
      puts KeycloakAdmin.realm(realm_name)
                        .authz_permissions(openid_client.id, "scope")
                        .find_by(scope_permission.name, resource.id, "POST_1")
                        .first.name
    end

    def create

    end
  end
end