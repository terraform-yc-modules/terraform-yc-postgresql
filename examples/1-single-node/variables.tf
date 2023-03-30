# Variables
variable "name" {
  description = "Name db cluster"
  type        = string
  default     = "yc-managed-pgsql-cluster"
}

variable "environment" {
  description = "Environment type: PRODUCTION or PRESTABLE"
  type        = string
  default     = "PRODUCTION"
  validation {
    condition     = contains(["PRODUCTION", "PRESTABLE"], var.environment)
    error_message = "Release channel should be PRODUCTION (stable feature set) or PRESTABLE (early bird feature access)."
  }
}

variable "network_id" {
  description = "Cluster network id"
  type        = string
}

variable "description" {
  description = "PostgreSQL cluster description" 
  type        = string
  default     = "Yandex Managed PostgreSQL cluster"
}

variable "folder_id" {
  description = "Folder id in Yandex cloud that contains our cluster"
  type        = string
  default     = null
}

variable "labels" {
  description = "A set of label pairs to assing to the PostgreSQL cluster."
  type        = map
  default     = {}
}

variable "host_master_name" {
  description = "Name of master DB host." 
  type        = string
  default     = "db-host-a"
}

variable "security_groups_ids_list" {
  description = "A list of security group IDs to which the PostgreSQL cluster belongs"
  type        = list(string)
  default     = []
  nullable    = true
}

variable "deletion_protection" {
  description = "Inhibits deletion of the cluster."
  type        = bool
  default     = true
}

variable "pg_version" {
  description = "Postgres version"
  type        = string
  default     = "15"
  validation {
    condition     = contains(["11", "11-1c", "12", "12-1c", "13", "13-1c", "14", "14-1c", "15"], var.pg_version)
    error_message = "Allowed PostgreSQL versions are 11, 11-1c, 12, 12-1c, 13, 13-1c, 14, 14-1c, 15."
  }
}

variable "disk_size" {
  description = "Disk size for hosts"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Disk type for hosts"
  type        = string
  default     = "network-ssd"
}

variable "resource_preset_id" {
  description = "Preset for hosts"
  type        = string
  default     = "s2.micro"
}

variable "access_enabled" {
  description = "Enable PG cluster access to other services."
  type = string
  default = "enabled"
  validation {
    condition     = contains(["enabled", "disabled"], var.access_enabled)
    error_message = "Access option flag should have 'enabled' or 'disabled' values."
  }
}
variable "access_policy" {
  description = "Access policy to the PostgreSQL cluster."
  type        = map
  default     = {
    data_lens = true
    web_sql   = true
    serverless    = true
    data_transfer = true
  }
}

variable "restore_enabled" {
  description = "Enable PG cluster restore option"
  type        = string
  default     = "disabled"
  validation {
    condition     = contains(["enabled", "disabled"], var.restore_enabled)
    error_message = "Restore option flag should have 'enabled' or 'disabled' values."
  }
}
variable "restore_parameters" {
  description = <<EOF
    The cluster will be created from the specified backup.
    NOTES:
      - If restore option is enabled, you must provide a valid backup_id for your PostgreSQL.
      - Time format is 'year-month-dayThour:minutes:secconds', where T is a delimeter.
  EOF
  type        = object({ 
    backup_id      = string
    time           = string
    time_inclusive = bool
  })
  default     = { 
    backup_id = "pg_backup_01"
    time = "2021-02-11T15:04:05" 
    time_inclusive = false
  }
}

variable "maintenance_enabled" {
  description = "Enable PG cluster maintenance window option"
  type        = string
  default     = "disabled"
  validation {
    condition     = contains(["enabled", "disabled"], var.maintenance_enabled)
    error_message = "Maintenance option flag should have 'enabled' or 'disabled' values."
  }
}
variable "maintenance_window" {
  description = "(Optional) Maintenance policy of the PostgreSQL cluster."
  type        = map
  default     = {
    type      = "WEEKLY"
    day       = "MON"
    hour      = "5"
  }
}

variable "performance_diagnostics" {
  description = "(Optional) Cluster performance diagnostics settings."
  type        = any
  default     = {
    enabled = true
    sessions_sampling_interval = 86400
    statements_sampling_interval = 86400
  }
}

variable "autofailover" {
  description = "(Optional) Configuration setting which enables/disables autofailover in cluster."
  type        = bool
  default     = true
}

variable "backup_retain_period_days" {
  description = "(Optional) The period in days during which backups are stored."
  type        = number
  default     = 14
}

variable "backup_window_start" {
  description = "(Optional) Time to start the daily backup, in the UTC timezone."
  type        = map
  default     = {
    hours     = "05"
    minutes   = "30"
  }
}

variable "pooler_config" {
  description = <<EOF
    Configuration of the connection pooler.
      - pool_discard - Setting pool_discard parameter in Odyssey. Values: yes | no
      - pooling_mode - Mode that the connection pooler is working in. Values: `POOLING_MODE_UNSPECIFIED`, `SESSION`, `TRANSACTION`, `STATEMENT`
  EOF
  type        = map
  default     = {
    pool_discard = true
    pooling_mode = "SESSION"
  }
}

variable "hosts_definition" {
  description = "A list of PostgreSQL hosts."
  type = list(map(any))
  default = [
    {
      name = "db-host-a"
      zone = "ru-central1-a"
      subnet_id = null
    },
    { 
      name = "db-host-b"
      zone = "ru-central1-b"
      subnet_id = null
      replication_source_name = "db-host-1"
    },
    {
      name = "db-host-c"
      zone = "ru-central1-c"
      subnet_id = null
      priority = 2
    } 
  ]
}
 
variable "pgsql_config" {
  description = <<EOF
    A map of PostgreSQL cluster configuration.
    Details info in a 'PostgreSQL cluster settings' of official documentation.
    Link: https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_cluster#postgresql-cluster-settings
  EOF
  type        = any
  default     = {}
}

variable "databases" {
  description = <<EOF
    A list of PostgreSQL databases.

    Required values:
      - name        - The name of the database.
      - owner       - Name of the user assigned as the owner of the database. Forbidden to change in an existing database.
      - extension   - Set of database extensions. The structure is documented below
      - lc_collate  - POSIX locale for string sorting order. Forbidden to change in an existing database.
      - lc_type     - POSIX locale for character classification. Forbidden to change in an existing database.
      - template_db - Name of the template database.
  EOF
  type = list(object({
    name               = string
    owner              = string
    lc_collate         = string
    lc_type            = string
    template_db        = string
    extensions         = list(string)
}))
  default = [
    {
      name               = "db-a"
      owner              = "owner-a"
      lc_collate         = "en_US.UTF-8"
      lc_type            = "en_US.UTF-8"
      template_db        = null
      extensions         = ["uuid-ossp", "xml2"]
    },
    {
      name               = "db-b"
      owner              = "owner-b"
      lc_collate         = "en_US.UTF-8"
      lc_type            = "en_US.UTF-8"
      template_db        = null
      extensions         = ["uuid-ossp", "xml2"]
    }
  ]
}

resource "random_string" "owners_passwords" {
  count   = length(var.owners)
  length  = 16
  special = true
  override_special = "-_()[]{}!@#$%^&"
}

resource "random_string" "users_passwords" {
  count   = length(var.users)
  length  = 16
  special = true
  override_special = "-_()[]{}!@#$%^&"
}


variable "owners" {
  description = <<EOF
    A list of PostgreSQL DB owners. These users are created first and assigned to database as owner.
    It is a separate list of PostgreSQL databases owners.
    There is also an aditional list for other users with own permissions.

    NOTE: 
     1. settings_options could not be undefined and missing It is required due to this is a list of objects!
     2. Define user settings options as `settings_options = {}` and all values will be default!

    Required values:
      - name             - The name of the owner.
      - grants           - List of the owner's grants.
      - login            - Owner's ability to login.
      - conn_limit       - The maximum number of connections per user. (Default 50)
      - settings_options - A user setting options.
  EOF
  type = list(object({
    name               = string
    grants             = list(string)
    login              = bool
    conn_limit         = number
    settings_options   = map(any)
}))
  default = [
    {
      name               = "owner-a"
      grants             = []
      login              = true
      conn_limit         = 50
      settings_options   = {
        default_transaction_isolation = "read committed"
        log_min_duration_statement    = 5000
      }
    },
    {
      name               = "owner-b"
      grants             = []
      login              = true
      conn_limit         = 50
      settings_options   = {
        default_transaction_isolation = "read committed"
        log_min_duration_statement    = 5000
      }
    }
  ]
}

variable "users" {
  description = <<EOF
    This is a list for additional PostgreSQL users with own permissions. They are created at the end.

    Required values:
      - name             - The name of the user.
      - grants           - A list of the user's grants.
      - login            - User's ability to login.
      - conn_limit       - The maximum number of connections per user. (Default 50)
      - permissions      - A list of databases names for an access
      - settings_options - A user setting options.
  EOF
  type = list(object({
    name               = string
    grants             = list(string)
    login              = bool
    conn_limit         = number
    permissions        = list(string)
    settings_options   = map(any)
}))
  default = [
    {
      name               = "user-a"
      grants             = []
      login              = true
      conn_limit         = 50
      permissions        = ["db-a"]
      settings_options   = {
        default_transaction_isolation = "read committed"
        log_min_duration_statement    = 5000
      }
    },
    {
      name               = "user-b"
      grants             = []
      login              = true
      conn_limit         = 50
      permissions        = ["db-a"]
      settings_options   = {
        default_transaction_isolation = "read committed"
        log_min_duration_statement    = 5000
      }
    }
  ]
}

variable "users_settings" {
  description = <<EOF
  A map of users settings.
  
  Full description https://cloud.yandex.com/en-ru/docs/managed-postgresql/api-ref/grpc/user_service#UserSettings1
  
  Parameters:
    - default_transaction_isolation - defines the default isolation level to be set for all new SQL transactions.
    - lock_timeout - The maximum time (in milliseconds) for any statement to wait for acquiring a lock on an table, index, row or other database object (default 0)
    - log_min_duration_statement - This setting controls logging of the duration of statements. (default -1 disables logging of the duration of statements.)
    - synchronous_commit - This setting defines whether DBMS will commit transaction in a synchronous way.
    - temp_file_limit - The maximum storage space size (in kilobytes) that a single process can use to create temporary files.
    - log_statement - This setting specifies which SQL statements should be logged (on the user level).
    - prepared_statements_pooling - This setting allows user to use prepared statements with transaction pooling.
    - catchup_timeout - The connection pooler setting. It determines the maximum allowed replication lag (in seconds). Pooler will reject connections to the replica with a lag above this threshold. Default value is 0, which disables this feature.
    - wal_sender_timeout - The maximum time (in milliseconds) to wait for WAL replication (can be set only for PostgreSQL 12+). Terminate replication connections that are inactive for longer than this amount of time.
    - idle_in_transaction_session_timeout - Sets the maximum allowed idle time (in milliseconds) between queries, when in a transaction. Value of 0 (default) disables the timeout.
    - statement_timeout - The maximum time (in milliseconds) to wait for statement. Value of 0 (default) disables the timeout.
  EOF
  type        = map
  default     = {
    default_transaction_isolation       = "read committed"
    log_min_duration_statement          = 5000
    lock_timeout                        = 0                 
    synchronous_commit                  = "unspecified"     
    temp_file_limit                     = null
    log_statement                       = "none"
    prepared_statements_pooling         = false
    catchup_timeout                     = 0                 // disabled
    wal_sender_timeout                  = 60
    statement_timeout                   = 0                 // disabled
    idle_in_transaction_session_timeout = 0                 // disabled
  }
}
