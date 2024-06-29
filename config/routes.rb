RailsKeycloakAuthorization::Engine.routes.draw do
  get "/", {controller: :management, action: :index }
end
