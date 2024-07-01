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
      @app.call(env) unless should_process?(env["REQUEST_URI"])

      authorize!(env['REQUEST_URI'], env['REQUEST_METHOD'], env['HTTP_AUTHORIZATION'])

      [200, {}, ["Hello Middleware, Rails::Keycloak::Authorization!"]]
    end

    def should_process?(request_uri)
      RailsKeycloakAuthorization.match_patterns.detect{|r| r.match(request_uri)}
    end

    def authorize!(request_uri, request_method, authorization)
      uri = URI("#{RailsKeycloakAuthorization.keycloak_server_url}/realms/#{RailsKeycloakAuthorization.keycloak_realm}/protocol/openid-connect/token")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = Rails.env.production?
      request = Net::HTTP::Post.new(
        uri,
        initheader = {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Authorization' => authorization,
        }
      )
      request.body = URI.encode_www_form( {
                                            audience: "#{RailsKeycloakAuthorization.client_id}",
                                            grant_type: "urn:ietf:params:oauth:grant-type:uma-ticket",
                                            permission: "#{request_uri}##{request_method}",
                                            response_mode: "permissions",
                                            permission_resource_format: "uri",
                                            permission_resource_matching_uri: true
                                          })
      res = http.request(request)
      puts "Response #{res.code} #{res.message}: #{res.body}"
      raise "Authorization failed" unless res.is_a?(Net::HTTPSuccess)
    end
  end
end
