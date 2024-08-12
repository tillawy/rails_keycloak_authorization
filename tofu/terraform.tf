terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "4.4.0"
    }
  }
}

provider "keycloak" {
  client_id                = "admin-cli"
  username                 = "admin"
  password                 = "admin"
  url                      = "http://localhost:8080"
  tls_insecure_skip_verify = true
}

resource "keycloak_realm" "dummy-realm" {
  depends_on = [
  ]

  realm = "dummy"
  enabled = true
  display_name = "Dummy"
  display_name_html = "<b>Dummy Realm</b>"
  registration_allowed = true
  reset_password_allowed = true
  login_with_email_allowed = true
  duplicate_emails_allowed = false
  edit_username_allowed = false
  registration_email_as_username = true
  verify_email = true

  smtp_server {
    auth {
      username = "xxxxxxxxxxxxxx"
      password = "yyyyyyyyyyyyyy"
    }
    from = "user@domain.com"
    from_display_name = "No Reply"
    host = "smtp.server.address"
    port = "587"
    envelope_from = "Envelop from"
    reply_to = "noreply@dummy.com"
    reply_to_display_name = "none"
    ssl = false
    starttls = true
  }
}

locals {
  master_realm_id = "master"
  realm_id = "dummy"
  groups = []
  user_groups = {}
}

# create groups
resource "keycloak_group" "groups" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  for_each = toset(local.groups)
  realm_id = local.realm_id
  name     = each.key
}

resource "keycloak_group" "parent_group" {
  realm_id = keycloak_realm.dummy-realm.id
  name     = "company-1-group"
}

resource "keycloak_group" "management_group" {
  realm_id = keycloak_realm.dummy-realm.id
  parent_id = keycloak_group.parent_group.id
  name      = "management-group"
}


resource "keycloak_group_memberships" "management_group_memebers" {
  realm_id = keycloak_realm.dummy-realm.id
  group_id = keycloak_group.management_group.id

  members  = [
    keycloak_user.manager_with_initial_password.username
  ]
}


resource "keycloak_role" "management_role" {
  realm_id    = keycloak_realm.dummy-realm.id
  client_id   = keycloak_openid_client.dummy-client.id
  name        = "management-client-role"
  description = "Management Client Role"
}



resource "keycloak_group_roles" "management_group_roles" {
  realm_id    = keycloak_realm.dummy-realm.id
  group_id = keycloak_group.management_group.id

  role_ids = [
    keycloak_role.management_role.id
  ]
}



resource "keycloak_group" "employees_group" {
  realm_id = keycloak_realm.dummy-realm.id
  parent_id = keycloak_group.parent_group.id
  name      = "employees-group"
}

resource "keycloak_group_memberships" "employees_group_memebers" {
  realm_id = keycloak_realm.dummy-realm.id
  group_id = keycloak_group.employees_group.id

  members  = [
    keycloak_user.employee_with_initial_password.username
  ]
}


# create users
resource "keycloak_user" "users" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  for_each       = local.user_groups
  realm_id       = local.realm_id
  username       = "${each.key}@domain.com"
  enabled        = true
  email          = "${each.key}@domain.com"
  email_verified = true
  first_name     = each.key
  last_name      = each.key
  initial_password {
    value = each.key
  }
}

# configure use groups membership
resource "keycloak_user_groups" "user_groups" {
  for_each  = local.user_groups
  realm_id  = local.realm_id
  user_id   = keycloak_user.users[each.key].id
  group_ids = [for g in each.value : keycloak_group.groups[g].id]
}


# create groups openid client scope
resource "keycloak_openid_client_scope" "groups" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id               = local.realm_id
  name                   = "groups"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "groups" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id        = local.realm_id
  client_scope_id = keycloak_openid_client_scope.groups.id
  name            = "groups"
  claim_name      = "groups"
  full_path       = false
}

resource "keycloak_user" "test_user_with_initial_password" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id   = keycloak_realm.dummy-realm.id
  username   = "test@test.com"
  enabled    = true

  email      = "test@test.com"
  first_name = "tester"
  last_name  = "lastname"

  email_verified = true

  attributes = {
    foo = "bar"
    multivalue = "value1##value2"
  }

  initial_password {
    value     = "test"
    temporary = false
  }
}



resource "keycloak_user" "manager_with_initial_password" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id   = keycloak_realm.dummy-realm.id
  username   = "manager@test.com"
  enabled    = true

  email      = "manager@test.com"
  first_name = "manager"
  last_name  = "management"

  email_verified = true

  attributes = {
    foo = "bar"
    multivalue = "value1##value2"
  }

  initial_password {
    value     = "secret"
    temporary = false
  }
}



resource "keycloak_user" "employee_with_initial_password" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id   = keycloak_realm.dummy-realm.id
  username   = "employee@test.com"
  enabled    = true

  email      = "employee@test.com"
  first_name = "employee"
  last_name  = "department"

  email_verified = true

  attributes = {
    foo = "bar"
    multivalue = "value1##value2"
  }

  initial_password {
    value     = "secret"
    temporary = false
  }
}



# create openid client
resource "keycloak_openid_client" "dummy-client" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id                     = local.realm_id
  client_id                    = "dummy-client"
  name                         = "Dummy Client"
  description                  = "Dummy Client Description"
  enabled                      = true
  client_secret                = "dummy-client-super-secret-xxx"
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  service_accounts_enabled     = true
  root_url                     = "http://localhost:3000"
  authorization {
    policy_enforcement_mode          = "ENFORCING"
    decision_strategy                = "UNANIMOUS"
    allow_remote_resource_management = true
  }
  valid_redirect_uris          = [
    "http://localhost:3000/*"
  ]
}

resource "keycloak_openid_client" "keycloak-admin-client" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id                     = local.master_realm_id
  client_id                    = "keycloak-admin"
  name                         = "keycloak-admin"
  access_type                  = "CONFIDENTIAL"
  description                  = "Keycloak Rails Description"
  client_secret                = "keycloak-admin-client-secret-xxx"
  enabled                      = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true
  service_accounts_enabled     = true
  standard_flow_enabled        = false
  valid_redirect_uris          = []
  web_origins = []
}

data "keycloak_realm" "master-realm" {
  realm = "master"
}

data "keycloak_openid_client" "dummy-realm" {
  depends_on = [
    keycloak_realm.dummy-realm
  ]
  realm_id  = data.keycloak_realm.master-realm.id
  client_id = "dummy-realm"
}

data "keycloak_role" "client_role_manage_users" {
  realm_id    = data.keycloak_realm.master-realm.id
  client_id   = data.keycloak_openid_client.dummy-realm.id
  name        = "manage-users"
}

resource "keycloak_openid_client_service_account_role" "admin-client-service-account-role-manage-users" {
  realm_id                = data.keycloak_realm.master-realm.id
  service_account_user_id = keycloak_openid_client.keycloak-admin-client.service_account_user_id
  client_id               = data.keycloak_openid_client.dummy-realm.id
  role                    = data.keycloak_role.client_role_manage_users.name
}

data "keycloak_role" "client_role_manage_clients" {
  realm_id    = data.keycloak_realm.master-realm.id
  client_id   = data.keycloak_openid_client.dummy-realm.id
  name        = "manage-clients"
}

resource "keycloak_openid_client_service_account_role" "admin-client-service-account-role-manage-clients" {
  realm_id                = data.keycloak_realm.master-realm.id
  service_account_user_id = keycloak_openid_client.keycloak-admin-client.service_account_user_id
  client_id               = data.keycloak_openid_client.dummy-realm.id
  role                    = data.keycloak_role.client_role_manage_clients.name
}

data "keycloak_role" "client_role_manage_authorization" {
  realm_id    = data.keycloak_realm.master-realm.id
  client_id   = data.keycloak_openid_client.dummy-realm.id
  name        = "manage-authorization"
}

resource "keycloak_openid_client_service_account_role" "admin-client-service-account-role-manage-authorization" {
  realm_id                = data.keycloak_realm.master-realm.id
  service_account_user_id = keycloak_openid_client.keycloak-admin-client.service_account_user_id
  client_id               = data.keycloak_openid_client.dummy-realm.id
  role                    = data.keycloak_role.client_role_manage_authorization.name
}


data "keycloak_role" "client_role_query_realm" {
  realm_id    = data.keycloak_realm.master-realm.id
  client_id   = data.keycloak_openid_client.dummy-realm.id
  name        = "view-realm"
}

resource "keycloak_openid_client_service_account_role" "admin-client-service-account-role-query-realm" {
  realm_id                = data.keycloak_realm.master-realm.id
  service_account_user_id = keycloak_openid_client.keycloak-admin-client.service_account_user_id
  client_id               = data.keycloak_openid_client.dummy-realm.id
  role                    = data.keycloak_role.client_role_query_realm.name
}

