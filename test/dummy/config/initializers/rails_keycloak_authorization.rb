
RailsKeycloakAuthorization.keycloak_auth_client_realm_name = ENV.fetch("KEYCLOAK_AUTH_CLIENT_REALM_NAME", "dummy")
RailsKeycloakAuthorization.keycloak_auth_client_id         = ENV.fetch("KEYCLOAK_AUTH_CLIENT_ID", "dummy-client")
RailsKeycloakAuthorization.keycloak_server_url             = ENV.fetch("KEYCLOAK_SERVER_URL", "http://localhost:8080")
RailsKeycloakAuthorization.keycloak_server_domain          = ENV.fetch("KEYCLOAK_ADMIN_SERVER_DOMAIN", "localhost")
RailsKeycloakAuthorization.keycloak_admin_realm_name       = ENV.fetch("KEYCLOAK_ADMIN_REALM_NAME", "master")
RailsKeycloakAuthorization.keycloak_admin_client_id        = ENV.fetch("KEYCLOAK_ADMIN_CLIENT_ID", "keycloak-admin")
RailsKeycloakAuthorization.keycloak_admin_client_secret    = ENV.fetch("KEYCLOAK_ADMIN_CLIENT_SECRET", "keycloak-admin-client-secret-xxx")
RailsKeycloakAuthorization.match_patterns                  = [
  /^\/organizations(\.json)?/,
  /^\/api/,
  /internal/
]
