locals {
  owners_passwords = {
    for i, owner in var.owners: "${owner["name"]}" => "${random_string.owners_passwords[i].result}"
  }
  users_passwords = {
    for i, user in var.users: "${user["name"]}" => "${random_string.users_passwords[i].result}"
  }
}

# PostgreSQL databases owners
resource "yandex_mdb_postgresql_user" "owner" {
  for_each   = length(var.owners) > 0 ? { for owner in var.owners: owner.name => owner } : {}

  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = lookup(each.value, "name", null)
  password   = "${local.owners_passwords[each.value.name]}"
  grants     = lookup(each.value, "grants", null)
  login      = lookup(each.value, "login", null)
  conn_limit = lookup(each.value, "conn_limit", null)
  settings   = {
    default_transaction_isolation       = lookup(each.value.settings_options, "default_transaction_isolation", var.users_settings.default_transaction_isolation)
    lock_timeout                        = lookup(each.value.settings_options, "lock_timeout", var.users_settings.lock_timeout)
    log_min_duration_statement          = lookup(each.value.settings_options, "log_min_duration_statement", var.users_settings.log_min_duration_statement)
    synchronous_commit                  = lookup(each.value.settings_options, "synchronous_commit", var.users_settings.synchronous_commit)
    temp_file_limit                     = lookup(each.value.settings_options, "temp_file_limit", var.users_settings.temp_file_limit)
    log_statement                       = lookup(each.value.settings_options, "log_statement", var.users_settings.log_statement)
    prepared_statements_pooling         = lookup(each.value.settings_options, "prepared_statements_pooling", var.users_settings.prepared_statements_pooling)
    catchup_timeout                     = lookup(each.value.settings_options, "catchup_timeout", var.users_settings.catchup_timeout)
    wal_sender_timeout                  = lookup(each.value.settings_options, "wal_sender_timeout", var.users_settings.wal_sender_timeout)
    idle_in_transaction_session_timeout = lookup(each.value.settings_options, "idle_in_transaction_session_timeout", var.users_settings.idle_in_transaction_session_timeout)
    statement_timeout                   = lookup(each.value.settings_options, "statement_timeout", var.users_settings.statement_timeout)
  }
}

# Additional PostgreSQL users with own permissions
resource "yandex_mdb_postgresql_user" "user" {
  for_each   = length(var.users) > 0 ? { for user in var.users: user.name => user } : {}

  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = lookup(each.value, "name", null)
  password   = "${local.users_passwords[each.value.name]}"
  grants     = lookup(each.value, "grants", null)
  login      = lookup(each.value, "login", null)
  conn_limit = lookup(each.value, "conn_limit", null)

  dynamic "permission" {
    for_each = lookup(each.value, "permissions", [])
    content {
      database_name = permission.value
    }
  }

  settings   = {
    default_transaction_isolation       = lookup(each.value.settings_options, "default_transaction_isolation", var.users_settings.default_transaction_isolation)
    lock_timeout                        = lookup(each.value.settings_options, "lock_timeout", var.users_settings.lock_timeout)
    log_min_duration_statement          = lookup(each.value.settings_options, "log_min_duration_statement", var.users_settings.log_min_duration_statement)
    synchronous_commit                  = lookup(each.value.settings_options, "synchronous_commit", var.users_settings.synchronous_commit)
    temp_file_limit                     = lookup(each.value.settings_options, "temp_file_limit", var.users_settings.temp_file_limit)
    log_statement                       = lookup(each.value.settings_options, "log_statement", var.users_settings.log_statement)
    prepared_statements_pooling         = lookup(each.value.settings_options, "prepared_statements_pooling", var.users_settings.prepared_statements_pooling)
    catchup_timeout                     = lookup(each.value.settings_options, "catchup_timeout", var.users_settings.catchup_timeout)
    wal_sender_timeout                  = lookup(each.value.settings_options, "wal_sender_timeout", var.users_settings.wal_sender_timeout)
    idle_in_transaction_session_timeout = lookup(each.value.settings_options, "idle_in_transaction_session_timeout", var.users_settings.idle_in_transaction_session_timeout)
    statement_timeout                   = lookup(each.value.settings_options, "statement_timeout", var.users_settings.statement_timeout)
  }

  depends_on = [
    yandex_mdb_postgresql_database.database
  ]

}


