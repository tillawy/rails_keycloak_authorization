class MainController < ApplicationController
  def index
    render json: { message: 'Hello from Rails::Keycloak::Authorization' }
  end

  def internal
    render json: { message: 'Internal, any User can access' }
  end

  def public
    render json: { message: 'Public, any User can access' }
  end
end
