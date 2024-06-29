Rails.application.routes.draw do
  mount RailsKeycloakAuthorization::Engine => "/rails_keycloak_authorization"
end
