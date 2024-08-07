require_relative "lib/rails_keycloak_authorization/version"

Gem::Specification.new do |spec|
  spec.name        = "rails_keycloak_authorization"
  spec.version     = RailsKeycloakAuthorization::VERSION
  spec.authors     = ["Mohammed O. Tillawy"]
  spec.email       = ["tillawy@gmail.com"]
  spec.homepage    = "https://github.com/tillawy/rails_keycloak_authorization.git"
  spec.summary     = "RailsKeycloakAuthorization, Rack Based, Policy Enforcement Point (PEP) implementation"
  spec.description = "RailsKeycloakAuthorization adds Rack Based, Policy Enforcement Point (PEP) implementation to authorize requests before they reach the controllers. It is designed to work with Keycloak Authorization Services."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/tillawy/rails_keycloak_authorization.git"
  spec.metadata["changelog_uri"] = "https://github.com/tillawy/rails_keycloak_authorization.git"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3.4"
  spec.add_dependency "keycloak-admin", ">= 1.1.3"
  # spec.add_runtime_dependency "keycloak-admin"
end
