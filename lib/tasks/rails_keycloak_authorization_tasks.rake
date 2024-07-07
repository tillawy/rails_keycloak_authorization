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
    KeycloakAdmin.realm(realm_name).authz_scopes(client.id).list.each{|scope| puts scope.name }
    KeycloakAdmin.realm(realm_name).authz_resources(client.id).list.each{|scope| puts scope.uris }
    KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').list.each{|scope| puts "Policy #{scope.name}" }

    realm_role =  KeycloakAdmin.realm(realm_name).roles.get("default-roles-dummy")

    scope_1 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_1", "POST 1 scope", "http://asdas")
    scope_2 = KeycloakAdmin.realm(realm_name).authz_scopes(client.id).create!("POST_2", "POST 2 scope", "http://asdas")
    puts KeycloakAdmin.realm(realm_name).authz_scopes(client.id).search("POST")
    puts KeycloakAdmin.realm(realm_name).authz_scopes(client.id).get(scope_1.id)

    # resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).create!(
    #   "Dummy Resource",
    #   "type",
    #   ["/asdf/*", "/tmp/"],
    #   true,
    #   "display_name",
    #   [{id: scope_1.id, name: scope_1.name},{id: scope_2.id, name: scope_2.name}],
    #   {"a": ["b", "c"]}
    # )
    resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).create!("Dummy Resource", "type", ["/asdf/*", "/tmp/"], true, "display_name", [], {"a": ["b", "c"]})

    resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).find_by("Dummy Resource", "", "", "", "").first


    puts KeycloakAdmin.realm(realm_name).authz_resources(client.id).get(resource.id).scopes.count
    puts KeycloakAdmin.realm(realm_name).authz_resources(client.id).get(resource.id).uris.count
    puts KeycloakAdmin.realm(realm_name).authz_resources(client.id).update(resource.id,
                                                                           {
                                                                             "name": "Dummy Resource",
                                                                             "type": "type",
                                                                             "owner_managed_access": true,
                                                                             "display_name": "display_name",
                                                                             "attributes": {"a":["b","c"]},
                                                                             "uris": [ "/asdf/*" , "/tmp/45" ],
                                                                             "scopes":[
                                                                               {name: scope_1.name},{name: scope_2.name}
                                                                             ],
                                                                             "icon_uri": "https://icon.ico"
                                                                           }
                                                                           )

    puts KeycloakAdmin.realm(realm_name).authz_resources(client.id).update(resource.id,
                                                                           {
                                                                             "name": "Dummy Resource",
                                                                             "scopes":[
                                                                               {name: scope_1.name}
                                                                             ]
                                                                           }
    )

    policy = KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').create!("Policy 1", "description", "role", "POSITIVE", "UNANIMOUS", true, [{id: realm_role.id, required: true}])
    puts KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').find_by("Policy 1", "role").first.name
    puts KeycloakAdmin.realm(realm_name).authz_policies(client.id, 'role').get(policy.id).name
    scope_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :scope).create!("Dummy Scope Permission", "scope description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], [scope_1.id, scope_2.id], "")
    resource_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :resource).create!("Dummy Resource Permission", "resource description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], nil, "")
    resource_permissions = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "", resource.id).list
    puts resource_permissions.length
    resource_scopes = KeycloakAdmin.realm(realm_name).authz_scopes(client.id, resource.id).list
    puts resource_scopes.length
    KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'scope').list.map{|r| puts r.name}
    KeycloakAdmin.realm(realm_name).authz_permissions(client.id, 'resource').list.map{|r| puts r.name}
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(resource_permission.name, nil).first.name
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(resource_permission.name, resource.id).first.name
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id).first.name
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, resource.id, "POST_1").first.name
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "resource").find_by(nil, resource.id).first.name
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(nil, resource.id).first.name
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(nil, resource.id, "POST_1").first.name
    puts KeycloakAdmin.realm(realm_name).authz_permissions(client.id, "scope").find_by(scope_permission.name, nil).first.name
    # KeycloakAdmin.realm(realm_name).authz_permissions(client.id).find_by(resource_permission.name, resource.id, "scope", nil )

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
    resource = KeycloakAdmin.realm(realm_name).authz_resources(client.id).find_by(client.id, "Organization", "", "", "").first
    policy = KeycloakAdmin.realm(realm_name).authz_policies( client.id, 'role').find_by("Policy 1", "role").first
    scope_permission = KeycloakAdmin.realm(realm_name).authz_permissions(client.id, :scope).create!("Organizations Scope Permission", "scope description", "UNANIMOUS", "POSITIVE", [resource.id], [policy.id], ["POST", "GET", "PATCH", "PUT", "DELETE"], "")
  end


end