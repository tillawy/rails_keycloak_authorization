require 'keycloak-admin'

namespace :'rails-keycloak-authorization' do
  desc "Explaining what the task does"
  task :create_default_scopes do
    keycloak_admin_configure
    realm_name = ENV["KEYCLOAK_AUTH_CLIENT_REALM_NAME"]
    client = KeycloakAdmin.realm(realm_name).clients.find_by_client_id(ENV["KEYCLOAK_AUTH_CLIENT_ID"])
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST", "POST Scope", "")
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("GET", "GET Scope", "")
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("PUT", "PUT Scope", "")
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("PATCH", "PATCH Scope", "")
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("DELETE", "DESTROY Scope", "")
  end

  desc "Explaining what the task does"
  task :create_resources do
    create_resource "Organization"
  end

  desc "Explaining what the task does"
  task :create_policy do
    create_policy
  end

  desc "Explaining what the task does"
  task :create_permission do
    create_permission
  end


  desc "Explaining what the task does"
  task :validate_keycloak_admin_ruby_permissions do
    puts "Validating, Rails::Keycloak::Authorization ...."
    keycloak_admin_configure
    realm_name = ENV["KEYCLOAK_AUTH_CLIENT_REALM_NAME"]
    client = KeycloakAdmin.realm(realm_name).clients.find_by_client_id(ENV["KEYCLOAK_AUTH_CLIENT_ID"])
    client.authorization_services_enabled = true
    KeycloakAdmin.realm(realm_name).clients.update(client)
    # KeycloakAdmin.realm(realm_name).users.list.each{|user| puts user.username}
    # KeycloakAdmin.realm(realm_name).clients.list.each{|client| puts client.client_id}
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).list.each{|scope| puts scope.name }
    KeycloakAdmin.realm(realm_name).authz_resources(client.id).list.each{|scope| puts scope.uris }
    KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').list.each{|scope| puts "Policy #{scope.name}" }
    realm_role =  KeycloakAdmin.realm(realm_name).roles.get("default-roles-dummy")

    scope_1 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_1", "POST scope", "http://asdas")
    scope_2 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_2", "POST scope", "http://asdas")
    resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).create!("Resource", "type", ["/asdf/*", "/tmp/"], true, "display_name", [{id: scope_1.id, name: scope_1.name},{id: scope_2.id, name: scope_2.name}], {"a": ["b", "c"]})
    policy = KeycloakAdmin.realm(realm_name).authz_policies( client.id, 'role').create!("Policy 1", "description", "role", "POSITIVE", "UNANIMOUS", true, [{id: realm_role.id, required: true}])
    scope_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :scope).create!("Scope Permission", "scope description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], [scope_1.id, scope_2.id], "")
    resource_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :resource).create!("Resource Permission", "resource description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], nil, "")
    KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'scope').list.map{|r| puts r.name}
    KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'resource').list.map{|r| puts r.name}


    KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'scope').delete(scope_permission.id)
    KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'resource').delete(resource_permission.id)
    KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').delete(policy.id)
    KeycloakAdmin.realm(realm_name).authz_resources(client.id).delete(resource.id)
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).delete(scope_1.id)
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).delete(scope_2.id)
    puts "Validation, Rails::Keycloak::Authorization done."
  end

  def keycloak_admin_configure
    KeycloakAdmin.configure do |config|
      config.use_service_account = true
      config.server_url          = ENV["KEYCLOAK_SERVER_URL"]
      config.server_domain       = ENV["KEYCLOAK_SERVER_DOMAIN"]
      config.client_id           = ENV["KEYCLOAK_ADMIN_CLIENT_ID"]
      config.client_realm_name   = ENV["KEYCLOAK_ADMIN_REALM_NAME"]
      config.client_secret       = ENV["KEYCLOAK_ADMIN_CLIENT_SECRET"]
      config.logger              = Rails.logger
      config.rest_client_options = { timeout: 5, verify_ssl: false }
    end
  end

  def realm_name
    ENV["KEYCLOAK_AUTH_CLIENT_REALM_NAME"]
  end

  def create_resource(model_name)
    resource_name = model_name.downcase.pluralize
    keycloak_admin_configure
    client = KeycloakAdmin.realm(realm_name).clients.find_by_client_id(ENV["KEYCLOAK_AUTH_CLIENT_ID"])
    scopes = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).list.reverse
    KeycloakAdmin.realm(realm_name)
                 .authz_resources(client.id)
                 .create!(model_name,
                          "type",
                          ["/#{resource_name}/*", "/#{resource_name}"],
                          true,
                          "#{resource_name.capitalize} Resource",
                          scopes.map{|scope| {id: scope.id, name: scope.name} },
                          { "model": resource_name }
                 )
  end

  def create_policy
    keycloak_admin_configure
    realm_role =  KeycloakAdmin.realm(realm_name).roles.get("default-roles-dummy")
    client = KeycloakAdmin.realm(realm_name).clients.find_by_client_id(ENV["KEYCLOAK_AUTH_CLIENT_ID"])
    KeycloakAdmin
      .realm(realm_name)
      .authz_policies(client.id, 'role')
      .create!("Policy 1",
               "description",
               "role",
               "POSITIVE",
               "UNANIMOUS",
               true,
               [{id: realm_role.id, required: true}]
      )
  end
  def create_permission
    keycloak_admin_configure
    client = KeycloakAdmin.realm(realm_name).clients.find_by_client_id(ENV["KEYCLOAK_AUTH_CLIENT_ID"])
    resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).find_by(client.id, "Organization", "", "", "", "").first
    policy = KeycloakAdmin.realm(realm_name).authz_policies( client.id, 'role').find_by(client.id, "Policy 1", "role").first
    scope_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :scope).create!("Organizations Scope Permission", "scope description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], ["POST", "GET", "PATCH", "PUT", "DELETE"], "")
  end


end