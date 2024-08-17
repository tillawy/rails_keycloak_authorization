require "test_helper"

class RailsKeycloakAuthorizationTest < ActionDispatch::IntegrationTest
  test "it has a version number" do
    assert RailsKeycloakAuthorization::VERSION
  end

  def setup
    RailsKeycloakAuthorization.keycloak_auth_client_realm_name = ENV.fetch("KEYCLOAK_AUTH_CLIENT_REALM_NAME", "dummy")
    RailsKeycloakAuthorization.keycloak_auth_client_id         = ENV.fetch("KEYCLOAK_AUTH_CLIENT_ID", "dummy-client")
    RailsKeycloakAuthorization.keycloak_server_url             = ENV.fetch("KEYCLOAK_SERVER_URL", "http://localhost:8080")
    RailsKeycloakAuthorization.keycloak_server_domain          = ENV.fetch("KEYCLOAK_ADMIN_SERVER_DOMAIN", "localhost")
    RailsKeycloakAuthorization.keycloak_admin_realm_name       = ENV.fetch("KEYCLOAK_ADMIN_REALM_NAME", "master")
    RailsKeycloakAuthorization.keycloak_admin_client_id        = ENV.fetch("KEYCLOAK_ADMIN_CLIENT_ID", "keycloak-admin")
    RailsKeycloakAuthorization.keycloak_admin_client_secret    = ENV.fetch("KEYCLOAK_ADMIN_CLIENT_SECRET", "keycloak-admin-client-secret-xxx")
    RailsKeycloakAuthorization.match_patterns                  = [
      /^\/organizations(\.json)?/,
      /internal/
    ]
  end

  test "middleware not intervening on non-protected URIs" do
    get "/public"
    assert_response 200
    assert_equal "{\"message\":\"Public, any User can access\"}", response.body
  end

  test "Authentication failure on missing Authorization header" do
    get "/organizations.json"
    assert_response 403
    assert_equal "Authentication Failed", response.body
  end

  test "Authorization failure on keycloak authorization failure" do
    mock = Minitest::Mock.new
    mock.expect(:request, Net::HTTPForbidden.new("1.1", 403, "Forbidden"), [Net::HTTP::Post])
    mock.expect(:use_ssl=, nil, [false])
    mock.expect(:read_timeout=, nil, [1])
    Net::HTTP.stub(:new, mock) do
      get "/organizations.json", headers: { "Authorization" => "BAD TOKEN" }
      assert_response 403
      assert_equal "Authorization Failed", response.body
    end
    mock.verify
  end

  test "Authorization success on keycloak authorization success" do
    mock = Minitest::Mock.new
    mock.expect(:request, Net::HTTPSuccess.new("1.1", 200, "OK"), [Net::HTTP::Post])
    mock.expect(:use_ssl=, nil, [false])
    mock.expect(:read_timeout=, nil, [1])
    Net::HTTP.stub(:new, mock) do
      get "/internal", headers: { "Authorization" => "BAD TOKEN" }
      assert_response 200
      assert_equal +"{\"message\":\"Internal, any User can access\"}", response.body
    end
    mock.verify
  end

end
