class MainController < ApplicationController
  def index
    render json: { message: 'Hello from Rails::Keycloak::Authorization' }
  end
end
