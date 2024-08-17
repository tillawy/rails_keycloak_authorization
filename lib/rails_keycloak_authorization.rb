require "rails_keycloak_authorization/version"
require "rails_keycloak_authorization/engine"

module RailsKeycloakAuthorization
  mattr_accessor :keycloak_server_url
  mattr_accessor :keycloak_server_domain
  mattr_accessor :keycloak_admin_realm_name
  mattr_accessor :keycloak_admin_client_id
  mattr_accessor :keycloak_admin_client_secret
  mattr_accessor :keycloak_auth_client_id
  mattr_accessor :keycloak_auth_client_realm_name
  mattr_accessor :match_patterns

  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if should_process?(env["REQUEST_URI"],)
        if !env["HTTP_AUTHORIZATION"]
          [403, {}, ["Authentication Failed"]]
        elsif authorize!(env['REQUEST_URI'], env['HTTP_AUTHORIZATION'])
          @app.call(env)
        else
          [403, {}, ["Authorization Failed"]]
        end
      else
        @app.call(env)
      end
    end

    def should_process?(request_uri)
      RailsKeycloakAuthorization.match_patterns.detect do |r|
        r.match(request_uri)
      end
    end

    def authorize!(request_uri, http_authorization)
      route = Rails.application.routes.recognize_path(request_uri)
      uri = uri(RailsKeycloakAuthorization.keycloak_server_url, RailsKeycloakAuthorization.keycloak_auth_client_realm_name)
      request = http_request(uri, http_authorization, route)
      response = http_client(uri).request(request)
      response.is_a?(Net::HTTPSuccess)
    end

    def http_request(uri, http_authorization, route)
      request = Net::HTTP::Post.new(uri, {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Authorization' => http_authorization,
      })
      permission = "#{route[:controller]}_controller##{route[:action]}"
      request.body = URI.encode_www_form({
                                           audience: "#{RailsKeycloakAuthorization.keycloak_auth_client_id}",
                                           grant_type: grant_type,
                                           permission: permission,
                                           response_mode: "permissions",
                                           permission_resource_format: "id",
                                           permission_resource_matching_uri: false
                                         })
      request
    end

    def grant_type
      "urn:ietf:params:oauth:grant-type:uma-ticket"
    end

    def uri(keycloak_server_url, keycloak_realm)
      URI("#{keycloak_server_url}/realms/#{keycloak_realm}/protocol/openid-connect/token")
    end

    def http_client(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = Rails.env.production?
      http.read_timeout = ENV.fetch("KEYCLOAK_AUTHORIZATION_TIMEOUT", 1).to_i
      http
    end
  end
end
