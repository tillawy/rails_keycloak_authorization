RailsKeycloakAuthorization::Engine.routes.draw do
  root "management#index"
  resources :routes, only: [:index, :show]
  resources :policies, only: [:index, :create]
  resources :permissions, only: [:index, :create]
  resources :resources, only: [:create, :show, :new, :index]
  resources :scopes, only: [:index, :show, :new, :create] do
    post :attach, on: :member
  end
end
