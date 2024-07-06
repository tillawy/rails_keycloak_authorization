RailsKeycloakAuthorization::Engine.routes.draw do
  root "management#index"
  resources :routes, only: [:index, :show]
  resources :resources, only: [:create, :show, :new, :index]
  resources :scopes, only: [:index, :show, :new, :create] do
    post :attach, on: :collection
  end
end
