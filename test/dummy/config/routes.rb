Rails.application.routes.draw do
  resources :organizations
  root "oauth#new"

  get "/oauth/keycloak", to: "oauth#new", as: "oauth_login"
  get "/oauth/:provider/callback", to: "oauth#create"
  get "/oauth/failure", to: "oauth#failure"

  get "/internal", to: "main#internal"
  get "/public", to: "main#public"

  mount RailsKeycloakAuthorization::Engine, at: "/rka"
end
