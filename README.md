# Yandex Cloud Managed PostgreSQL Cluster

## Features

- Create a managed PostgreSQL cluster with a predefined number of DB hosts
- Create a list of users and databases with permissions
- Easy to use in other resources via outputs

## PostgreSQL cluster definition

First, you need to create a VPC network with three subnets.

PostgreSQL module requires the following input variables:
 - VPC network ID.
 - VPC network subnet IDs.
 - PostgreSQL host definitions: List of maps with DB host name, zone name, and subnet ID.
 - Databases: List of databases with database names, owners, and other parameters.
 - Owners: List of database owners.
 - Users: All other users with a list of permissions to databases.

<b>Notes:</b>
1. The `owners` variable defines a list of databases owners. It does not support the `permissions` list because these users will be linked with `databases` via the `owner` parameter. This means each database must have an owner.
2. The `users` variable defines a list of separate DB users with the `permissions` list, which points to a list of databases. This means each user will have an access to each database from the `permissions` list.
3. The `settings_options` parameter may be null, in which case the default values will be used.

### Example

This example creates a single-node PostgreSQL cluster with multiple databases and users:

```
module "db" {
  source     = "../../"
  network_id = "enpneopbt180nusgut3q"

  hosts_definition = [
    {
      name = "db-host-a"
      zone = "ru-central1-a"
      subnet_id = "e9b5udt8asf9r9qn6nf6"
    }
  ]

  owners = [
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

  databases = [
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

  users = [
    {
      name               = "user-a"
      grants             = []
      login              = true
      conn_limit         = 50
      permissions        = ["db-a", "db-b"]
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
      permissions        = ["db-a", "db-b"]
      settings_options   = {
        default_transaction_isolation = "read committed"
        log_min_duration_statement    = 5000
      }
    },
    {
      name               = "user-c"
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
```

### Configuring Terraform for Yandex.Cloud

- Install [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for `terraform auth` in Yandex Cloud:

```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.0.0 or higher |
| <a name="requirement_random"></a> [random](#requirement\_random) | Higher than 3.3 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | Higher than 0.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | N/A |
| <a name="provider_random"></a> [random](#provider\_random) | Higher than 3.3|
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | Higher than 0.8|

## Modules

There are no modules available.

## Resources

| Name | Type |
|------|------|
| [local_file.pgpass_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | Resource |
| [random_string.owners_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | Resource |
| [random_string.users_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | Resource |
| [yandex_mdb_postgresql_cluster.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_cluster) | Resource |
| [yandex_mdb_postgresql_database.database](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_database) | Resource |
| [yandex_mdb_postgresql_user.owner](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_user) | Resource |
| [yandex_mdb_postgresql_user.user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_user) | Resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | Data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_enabled"></a> [access\_enabled](#input\_access\_enabled) | Enables PG cluster access to other services. | `string` | `"enabled"` | No |
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | Access policy to the PostgreSQL cluster. | `map` | <pre>{<br>  "data_lens": true,<br>  "data_transfer": true,<br>  "serverless": true,<br>  "web_sql": true<br>}</pre> | No |
| <a name="input_autofailover"></a> [autofailover](#input\_autofailover) | (Optional) Configuration setting which enables and disables auto failover in the cluster. | `bool` | `true` | No |
| <a name="input_backup_retain_period_days"></a> [backup\_retain\_period\_days](#input\_backup\_retain\_period\_days) | (Optional) Period in days during which backups are stored. | `number` | `14` | No |
| <a name="input_backup_window_start"></a> [backup\_window\_start](#input\_backup\_window\_start) | (Optional) Time to start the daily backup, UTC. | `map` | <pre>{<br>  "hours": "05",<br>  "minutes": "30"<br>}</pre> | No |
| <a name="input_databases"></a> [databases](#input\_databases) | List of PostgreSQL databases.<br><br>    Required values:<br>      - `name`: Name of the database.<br>      - `owner`: Name of the user assigned the database owner role. This cannot be changed in an existing database.<br>      - `extension`: Set of database extensions. See below for the structure.<br>      - `lc\_collate`: POSIX locale for string sorting order. This cannot be changed in an existing database.<br>      - `lc\_type`: POSIX locale for character classification. This cannot be changed in an existing database.<br>      - `template\_db`: Name of the template database. | <pre>list(object({<br>    name               = string<br>    owner              = string<br>    lc_collate         = string<br>    lc_type            = string<br>    template_db        = string<br>    extensions         = list(string)<br>}))</pre> | <pre>[<br>  {<br>    "extensions": [<br>      "uuid-ossp",<br>      "xml2"<br>    ],<br>    "lc_collate": "en_US.UTF-8",<br>    "lc_type": "en_US.UTF-8",<br>    "name": "db-a",<br>    "owner": "owner-a",<br>    "template_db": null<br>  },<br>  {<br>    "extensions": [<br>      "uuid-ossp",<br>      "xml2"<br>    ],<br>    "lc_collate": "en_US.UTF-8",<br>    "lc_type": "en_US.UTF-8",<br>    "name": "db-b",<br>    "owner": "owner-b",<br>    "template_db": null<br>  }<br>]</pre> | No |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protects the cluster from deletion. | `bool` | `true` | No |
| <a name="input_description"></a> [description](#input\_description) | PostgreSQL cluster description | `string` | `"Yandex Managed PostgreSQL cluster"` | No |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for hosts | `number` | `20` | No |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk type for hosts | `string` | `"network-ssd"` | No |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment type: `PRODUCTION` or `PRESTABLE` | `string` | `"PRODUCTION"` | No |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Yandex Cloud Folder ID where the cluster resides| `string` | `null` | No |
| <a name="input_host_master_name"></a> [host\_master\_name](#input\_host\_master\_name) | Name of master DB host | `string` | `"db-host-a"` | No |
| <a name="input_hosts_definition"></a> [hosts\_definition](#input\_hosts\_definition) | List of PostgreSQL hosts | `list(map(any))` | <pre>[<br>  {<br>    "name": "db-host-a",<br>    "subnet_id": null,<br>    "zone": "ru-central1-a"<br>  },<br>  {<br>    "name": "db-host-b",<br>    "replication_source_name": "db-host-1",<br>    "subnet_id": null,<br>    "zone": "ru-central1-b"<br>  },<br>  {<br>    "name": "db-host-c",<br>    "priority": 2,<br>    "subnet_id": null,<br>    "zone": "ru-central1-c"<br>  }<br>]</pre> | No |
| <a name="input_labels"></a> [labels](#input\_labels) | Set of label pairs to assign to the PostgreSQL cluster | `map` | `{}` | No |
| <a name="input_maintenance_enabled"></a> [maintenance\_enabled](#input\_maintenance\_enabled) | Enables the PG cluster maintenance window option. | `string` | `"disabled"` | No |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Maintenance policy of the PostgreSQL cluster | `map` | <pre>{<br>  "day": "MON",<br>  "hour": "5",<br>  "type": "WEEKLY"<br>}</pre> | No |
| <a name="input_name"></a> [name](#input\_name) | DB cluster name | `string` | `"yc-managed-pgsql-cluster"` | No |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Cluster network ID | `string` | N/A | Yes |
| <a name="input_owners"></a> [owners](#input\_owners) | List of PostgreSQL DB owners. These users are created first and assigned to databases as owners.<br>    This is a separate list of PostgreSQL database owners.<br>    There is also an additional list for other users with its own permissions.<br><br>    Notes: <br>     1. `settings\_options` may not be undefined or missing. It is required because it is a list of objects.<br>     2. If you define user setting options as `settings_options = {}`, all values will be default.<br><br>    Required values:<br>      - `Name`: Name of the owner.<br>      - `grants`: List of the owner's grants.<br>      - `login`: Owner's ability to log in.<br>      - `conn\_limit`: Maximum number of connections per user. The default value is 50.<br>      - `settings\_options`: User setting options. | <pre>list(object({<br>    name               = string<br>    grants             = list(string)<br>    login              = bool<br>    conn_limit         = number<br>    settings_options   = map(any)<br>}))</pre> | <pre>[<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "owner-a",<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  },<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "owner-b",<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  }<br>]</pre> | No |
| <a name="input_performance_diagnostics"></a> [performance\_diagnostics](#input\_performance\_diagnostics) | (Optional) Settings for cluster performance diagnostics. | `any` | <pre>{<br>  "enabled": true,<br>  "sessions_sampling_interval": 86400,<br>  "statements_sampling_interval": 86400<br>}</pre> | No |
| <a name="input_pg_version"></a> [pg\_version](#input\_pg\_version) | PostgreSQL version | `string` | `"15"` | No |
| <a name="input_pgsql_config"></a> [pgsql\_config](#input\_pgsql\_config) | Map of PostgreSQL cluster configuration.<br>    You can find the detailed info in the [PostgreSQL cluster settings section](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_cluster#postgresql-cluster-settings) of our official documentation.| `any` | <pre>{<br>  "autovacuum_vacuum_scale_factor": 0.34,<br>  "default_transaction_isolation": "TRANSACTION_ISOLATION_READ_COMMITTED",<br>  "enable_parallel_hash": true,<br>  "max_connections": 395,<br>  "shared_preload_libraries": "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"<br>}</pre> | No |
| <a name="input_pooler_config"></a> [pooler\_config](#input\_pooler\_config) | Configuration of the connection pooler.<br>      - `pool\_discard`: Setting the `pool\_discard` parameter in Odyssey. Possible values are `yes` or `no`.<br>      - `pooling\_mode`: Mode the connection pooler is working in. Possible values are `POOLING_MODE_UNSPECIFIED`, `SESSION`, `TRANSACTION`, and `STATEMENT`. | `map` | <pre>{<br>  "pool_discard": true,<br>  "pooling_mode": "SESSION"<br>}</pre> | No |
| <a name="input_resource_preset_id"></a> [resource\_preset\_id](#input\_resource\_preset\_id) | Preset for hosts | `string` | `"s2.micro"` | No |
| <a name="input_restore_enabled"></a> [restore\_enabled](#input\_restore\_enabled) | Enables the PG cluster restore option. | `string` | `"disabled"` | No |
| <a name="input_restore_parameters"></a> [restore\_parameters](#input\_restore\_parameters) | The cluster will be created from the specified backup.<br>    NOTES:<br>      - If the restore option is enabled, you must provide a valid `backup\_id` for your PostgreSQL.<br>      - The time format is `year-month-dayThour:minutes:secconds`, where T is a delimeter. | <pre>object({ <br>    backup_id      = string<br>    time           = string<br>    time_inclusive = bool<br>  })</pre> | <pre>{<br>  "backup_id": "pg_backup_01",<br>  "time": "2021-02-11T15:04:05",<br>  "time_inclusive": false<br>}</pre> | No |
| <a name="input_security_groups_ids_list"></a> [security\_groups\_ids\_list](#input\_security\_groups\_ids\_list) | List of security group IDs the PostgreSQL cluster belongs to. | `list(string)` | `[]` | No |
| <a name="input_users"></a> [users](#input\_users) | This is a list for additional PostgreSQL users with their own permissions, which are created at the end.<br><br>    Required values:<br>      - `name`: Name of the user.<br>      - `grants`: List of the user's grants.<br>      - `login`: User's ability to log in.<br>      - `conn\_limit`: Maximum number of connections per user. The default value is 50.<br>      - `permissions`: List of databases names for an access.<br>      - `settings\_options`: User setting options. | <pre>list(object({<br>    name               = string<br>    grants             = list(string)<br>    login              = bool<br>    conn_limit         = number<br>    permissions        = list(string)<br>    settings_options   = map(any)<br>}))</pre> | <pre>[<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "user-a",<br>    "permissions": [<br>      "db-a"<br>    ],<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  },<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "user-b",<br>    "permissions": [<br>      "db-a"<br>    ],<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  }<br>]</pre> | No |
| <a name="input_users_settings"></a> [users\_settings](#input\_users\_settings) | Map of users settings.<br><br>    You can find the full description [here](https://cloud.yandex.com/en-ru/docs/managed-postgresql/api-ref/grpc/user_service#UserSettings1).<br><br>    Parameters:<br>      - `default\_transaction\_isolation`: Defines the default isolation level to set for all new SQL transactions.<br>      - `lock\_timeout`: Maximum time (in milliseconds) for any statement to wait for acquiring a lock on an table, index, row, or other database object. The default value is `0`.<br>      - `log\_min\_duration\_statement`: This setting controls logging of the statement duration. The default value is `-1`, which disables such kind of logging.<br>      - `synchronous\_commit`: This setting defines whether the DBMS will commit transactions in a synchronous way.<br>      - `temp\_file\_limit`: Maximum storage space size (in kilobytes) that a single process can use to create temporary files.<br>      - `log\_statement`: This setting specifies which SQL statements should be logged on the user level.<br>      - `prepared\_statements\_pooling`: This setting allows the user to use prepared statements with transaction pooling.<br>      - `catchup\_timeout`: Connection pooler setting that determines the maximum allowed replication lag (in seconds). The pooler will reject connections to the replica with a lag above this threshold. The default value is 0, which disables this feature.<br>      - `wal\_sender\_timeout`: Maximum time (in milliseconds) to wait for WAL replication. It can be only set for PostgreSQL 12+.<br>The replication connections that are inactive for longer than this amount of time will be terminated.<br>      - `idle\_in\_transaction\_session\_timeout`: Sets the maximum allowed idle time (in milliseconds) between queries, when in a transaction. The default value (`0`) disables the timeout.<br>      - `statement\_timeout`: Maximum time (in milliseconds) to wait for statement. The default value (`0`) disables the timeout. | `map` | <pre>{<br>  "catchup_timeout": 0,<br>  "default_transaction_isolation": "read committed",<br>  "idle_in_transaction_session_timeout": 0,<br>  "lock_timeout": 0,<br>  "log_min_duration_statement": 5000,<br>  "log_statement": "none",<br>  "prepared_statements_pooling": false,<br>  "statement_timeout": 0,<br>  "synchronous_commit": "unspecified",<br>  "temp_file_limit": null,<br>  "wal_sender_timeout": 60<br>}</pre> | No |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databases"></a> [databases](#output\_databases) | List of databases names |
| <a name="output_owners_data"></a> [owners\_data](#output\_owners\_data) | List of owner users with passwords |
| <a name="output_pg_cluster_fqdns_list"></a> [pg\_cluster\_fqdns\_list](#output\_pg\_cluster\_fqdns\_list) | List of PostgreSQL cluster node FQDNs |
| <a name="output_pg_cluster_host_names_list"></a> [pg\_cluster\_host\_names\_list](#output\_pg\_cluster\_host\_names\_list) | PostgreSQL cluster host name |
| <a name="output_pg_cluster_id"></a> [pg\_cluster\_id](#output\_pg\_cluster\_id) | PostgreSQL cluster ID |
| <a name="output_pg_cluster_name"></a> [pg\_cluster\_name](#output\_pg\_cluster\_name) | PostgreSQL cluster name |
| <a name="output_pg_connection_step_1"></a> [pg\_connection\_step\_1](#output\_pg\_connection\_step\_1) | Step 1: Install certificate |
| <a name="output_pg_connection_step_2"></a> [pg\_connection\_step\_2](#output\_pg\_connection\_step\_2) | How to connect to PostgreSQL cluster?<br><br>    1. Install certificate:<br><br>      mkdir --parents ~/.postgresql && \<br>      wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \<br>        --output-document ~/.postgresql/root.crt && \<br>      chmod 0600 ~/.postgresql/root.crt<br><br>    2. Run connection string from the output value, for example:<br><br>      psql "host=rc1a-g2em5m3zc9dxxasn.mdb.yandexcloud.net \<br>        port=6432 \<br>        sslmode=verify-full \<br>        dbname=db-b \<br>        user=owner-b \<br>        target\_session\_attrs=read-write" |
| <a name="output_users_data"></a> [users\_data](#output\_users\_data) | List of users with passwords |
<!-- END_TF_DOCS -->
