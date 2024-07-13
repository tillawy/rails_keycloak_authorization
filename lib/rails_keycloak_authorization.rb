require "rails_keycloak_authorization/version"
require "rails_keycloak_authorization/engine"

module RailsKeycloakAuthorization
  mattr_accessor :keycloak_realm
  mattr_accessor :keycloak_server_url
  mattr_accessor :keycloak_admin_username
  mattr_accessor :keycloak_admin_password
  mattr_accessor :match_patterns
  mattr_accessor :client_id

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
      RailsKeycloakAuthorization.match_patterns.detect { |r| r.match(request_uri) }
    end

    def authorize!(request_uri, http_authorization)
      route = Rails.application.routes.recognize_path(request_uri)
      uri = uri(RailsKeycloakAuthorization.keycloak_server_url, RailsKeycloakAuthorization.keycloak_realm)
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
                                           audience: "#{RailsKeycloakAuthorization.client_id}",
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
      http.read_timeout = 1
      http
    end
  end
end
