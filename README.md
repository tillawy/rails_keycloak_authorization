# Rails Keycloak Authorization

Rails middleware to authorize requests using [Keycloak](https://www.keycloak.org).

## How it works

This gem is a middleware that checks if the request is authorized by Keycloak. 
It will check if the request's token is valid and if the user has the required roles to access the requested resource.

```mermaid
sequenceDiagram
    actor User
    User->>Application: Request ${URL} with ${TOKEN}
    create participant Keycloak
    Application-->>Keycloak: is ${TOKEN} authorized for ${URL}?
    destroy Keycloak
    Keycloak-->>Application: ${TOKEN} is authorized for ${URL}
    destroy Application
    Application-->>User: Response ${URL} with ${DATA}
```

## Configuration

In order to use this gem, you need to configure it in an initializer file. You can create a new file in `config/initializers` with the following content:

```ruby
# The Keycloak realm 
RailsKeycloakAuthorization.keycloak_realm = ENV.fetch("KEYCLOAK_AUTH_CLIENT_REALM_NAME", "dummy")
# The client id in the realm
RailsKeycloakAuthorization.client_id = ENV.fetch("KEYCLOAK_AUTH_CLIENT_ID", "dummy-client")
# Keycloak server url
RailsKeycloakAuthorization.keycloak_server_url = ENV.fetch("KEYCLOAK_SERVER_URL", "http://localhost:8080")
# Patterns that are protected by the middleware
RailsKeycloakAuthorization.match_patterns = [
  /^\/organizations(\.json)?/,
  /^\/api/,
  /internal/
]
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

Running the previous steps will:
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
   * http://localhost:8080/rka/


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
