# Rails Keycloak Authorization

![Github Actions CI workflow](https://github.com/tillawy/rails_keycloak_authorization/actions/workflows/ruby.yml/badge.svg)


Rails middleware to authorize requests using [Keycloak](https://www.keycloak.org) and gem [keycloak-admin-ruby](https://github.com/looorent/keycloak-admin-ruby).

This gem uses JWT token to authorize requests.
To read more how this gem works:

 * [Keycloak authorization services](https://www.keycloak.org/docs/latest/authorization_services/index.html#_service_overview)
 * [Policy Enforcement Point (PEP)](https://www.keycloak.org/docs/latest/authorization_services/index.html#_enforcer_overview)
  

For the moment it only support permission_resource_format=uri. it does not support permission_resource_format=resource.

It does **not** support rails cookie-based-sessions, so it is only suitable for APIs.

This gem uses regular-expression for URLs matching, so it is very powerful and flexible. 

## How it works

This gem is a middleware that checks if the request is authorized by Keycloak. 
It will check if the request's token is valid and if the user has the required roles to access the requested resource.

Keycloak setup for authorization has many options, the following conventions were followed building this gem:

| Rails component   | Keycloak component  |
|-------------------|---------------------|
| Controller        | Authz Resource      |
| Controller Action | Authz Scope         |
| Route             | permission subject  |


## Flow

```mermaid
sequenceDiagram
    actor User
    User->>Application: Request ${URL} with ${JWT_TOKEN}
    create participant Keycloak
    Application-->>Keycloak: is ${JWT_TOKEN} authorized for ${URL}?
    note right of Keycloak: Keycloak will validate the token <br/> and check if the user has the required roles
    destroy Keycloak
    Keycloak-->>Application: ${JWT_TOKEN} is authorized for ${URL}
    destroy Application
    Application-->>User: Response ${URL} with ${DATA}
```


## Configuration

In order to use this gem, you need to configure it in an initializer file. You can create a new file in `config/initializers/rails_keycloak_authorization.rb` with the following content:

```ruby
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
```

Add the route to the UI helper `config/routes.rb`:

```
# make sure to change the constraint to suite your security
mount RailsKeycloakAuthorization::Engine, at: "/rka", constraints: lambda { |request| request.remote_ip == "127.0.0.1" }
```


## How to easily test it?

Create development environment with Keycloak and Tofu:
 * checkout the source-code of this project
   * `git checkout https://github.com/tillawy/rails_keycloak_authorization.git`
   * `cd rails_keycloak_authorization`
 * Run keycloak in a [Docker](https://docs.docker.com/get-docker/) container
   * `cd docker`
   * `docker-compose up`
   * verify keycloak is running at `http://localhost:8080`, username: `admin`, password: `admin`
 * Run tofu to setup keycloak realm & client
   * `brew install opentofu`  
   * `cd ../tofu` 
   * `tofu -chdir=tofu init`
   * `tofu -chdir=tofu apply -auto-approve` 

Running the previous steps should:
 * Start Keycloak server
 * Create realm called: `Dummy`
 * Create openid-client called: `dummy-client` in realm `dummy` with:
   * client secret `dummy-client-super-secret-xxx`
   * valid_redirect_uri `http://localhost:3000/*`
 * Create user `test@test.com` with password `test`
 * Create openid-client called: `keycloak-admin` in realm `master` with:
   * client secret `keycloak-admin-client-secret-xxx`
   * role to manager users in realm `dummy`

Run the server:

  `bundle exec rails s`

make the first request (should fail) `Authorization Failed`:

```shell
bash test/curl/test.curl.bash
```

How let us setup Authorization:

 * Open rka http://localhost:3000/rka/management/
 * On the first tab `Rails Routes`
 * The first route `/organizations(.:format)`, click inspect
 * Click on `Create Resource?` to create Authz Resource for controller 
 * Click on `Create Scope?` to create resource for controller action
 * Click on `Attach scope index to resource` to attach the scope (action: index) to the resource (controller: organizations_controller)
 * Select the second tab `Keycloak Policies`
 * From the Role dropdown list select `default-roles-dummy`
 * Click `Create`
 * Select the third tab `Keycloak Permissions`
 * From the Policy dropdown list select `RKA-Policy`
 * From the Resource dropdown list select `organization_controllers`
 * Another dropdown will appear Select Scope, select `index`
 * Click `Create`

Now let us run the test `bash test/curl/test.curl.bash` again, it should pass.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "rails_keycloak_authorization"
```

And then execute:
```bash
$ bundle
```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
