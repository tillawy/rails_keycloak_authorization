RailsKeycloakAuthorization::Engine.routes.draw do
  root "management#index"
  resources :routes, only: [:index, :show] do
    get "authz_resource", on: :member, to: "resources#show"
  end
  resources :resources, only: [:create]
end
