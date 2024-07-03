
# RailsKeycloakAuthorization.keycloak_realm = "master"
RailsKeycloakAuthorization.client_id = ENV.fetch("KEYCLOAK_AUTH_CLIENT_ID", "dummy-client")
RailsKeycloakAuthorization.keycloak_server_url = ENV.fetch("KEYCLOAK_SERVER_URL", "http://localhost:8080")
RailsKeycloakAuthorization.keycloak_realm = ENV.fetch("KEYCLOAK_AUTH_CLIENT_REALM_NAME", "dummy")
RailsKeycloakAuthorization.match_patterns = [
  /^\/organizations(\.json)?/,
  /^\/api/
]
