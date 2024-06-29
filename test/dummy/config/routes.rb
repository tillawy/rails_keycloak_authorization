Rails.application.routes.draw do
  resources :organizations
  root "main#index"
  mount RailsKeycloakAuthorization::Engine => "/rka"
end
