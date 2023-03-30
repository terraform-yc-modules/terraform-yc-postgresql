# Yandex.Cloud Managed PostgreSQL cluster

## Features

- Create a Managed PostgreSQL cluster with predefined number of DB hosts
- Create a list of users and databases with permissions
- Easy to use in other resources via outputs

## PostgreSQL cluster definition

At first you need to create VPC network with three subnets!

PostgreSQL module requires a following input variables:
 - VPC network id
 - VPC network subnets ids
 - PostgreSQL hosts definitions - a list of maps with DB host name, zone name and subnet id.
 - Databases - a list of databases with database name, owner and other parameters
 - Owners - a list of database owners
 - Users - all other users with a list of permisions to databases.

<b>Notes:</b>
1. `owners` variable defines a list of databases owners. It doesn't support `permissions` list because these users will be linked with `databases` via `owner` parameter. So each database must have it's owner!
2. `users` variable defines a list of separate db users with a `permissions` list, which indicates to a list of databases. So each user will have an access to each database from a `permissions` list.
3. Users `settings_options` parameter might be null, in this case default values will be used.

### Example

This example creates a single node PostgreSQL cluster with a bunch of databases and users.

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

### Configure Terraform for Yandex.Cloud

- Install [YC cli](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | > 3.3 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | > 0.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | > 3.3 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | > 0.8 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.pgpass_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_string.owners_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [random_string.users_passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [yandex_mdb_postgresql_cluster.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_cluster) | resource |
| [yandex_mdb_postgresql_database.database](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_database) | resource |
| [yandex_mdb_postgresql_user.owner](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_user) | resource |
| [yandex_mdb_postgresql_user.user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_user) | resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_enabled"></a> [access\_enabled](#input\_access\_enabled) | Enable PG cluster access to other services. | `string` | `"enabled"` | no |
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | Access policy to the PostgreSQL cluster. | `map` | <pre>{<br>  "data_lens": true,<br>  "data_transfer": true,<br>  "serverless": true,<br>  "web_sql": true<br>}</pre> | no |
| <a name="input_autofailover"></a> [autofailover](#input\_autofailover) | (Optional) Configuration setting which enables/disables autofailover in cluster. | `bool` | `true` | no |
| <a name="input_backup_retain_period_days"></a> [backup\_retain\_period\_days](#input\_backup\_retain\_period\_days) | (Optional) The period in days during which backups are stored. | `number` | `14` | no |
| <a name="input_backup_window_start"></a> [backup\_window\_start](#input\_backup\_window\_start) | (Optional) Time to start the daily backup, in the UTC timezone. | `map` | <pre>{<br>  "hours": "05",<br>  "minutes": "30"<br>}</pre> | no |
| <a name="input_databases"></a> [databases](#input\_databases) | A list of PostgreSQL databases.<br><br>    Required values:<br>      - name        - The name of the database.<br>      - owner       - Name of the user assigned as the owner of the database. Forbidden to change in an existing database.<br>      - extension   - Set of database extensions. The structure is documented below<br>      - lc\_collate  - POSIX locale for string sorting order. Forbidden to change in an existing database.<br>      - lc\_type     - POSIX locale for character classification. Forbidden to change in an existing database.<br>      - template\_db - Name of the template database. | <pre>list(object({<br>    name               = string<br>    owner              = string<br>    lc_collate         = string<br>    lc_type            = string<br>    template_db        = string<br>    extensions         = list(string)<br>}))</pre> | <pre>[<br>  {<br>    "extensions": [<br>      "uuid-ossp",<br>      "xml2"<br>    ],<br>    "lc_collate": "en_US.UTF-8",<br>    "lc_type": "en_US.UTF-8",<br>    "name": "db-a",<br>    "owner": "owner-a",<br>    "template_db": null<br>  },<br>  {<br>    "extensions": [<br>      "uuid-ossp",<br>      "xml2"<br>    ],<br>    "lc_collate": "en_US.UTF-8",<br>    "lc_type": "en_US.UTF-8",<br>    "name": "db-b",<br>    "owner": "owner-b",<br>    "template_db": null<br>  }<br>]</pre> | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Inhibits deletion of the cluster. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | PostgreSQL cluster description | `string` | `"Yandex Managed PostgreSQL cluster"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for hosts | `number` | `20` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk type for hosts | `string` | `"network-ssd"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment type: PRODUCTION or PRESTABLE | `string` | `"PRODUCTION"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Folder id in Yandex cloud that contains our cluster | `string` | `null` | no |
| <a name="input_host_master_name"></a> [host\_master\_name](#input\_host\_master\_name) | Name of master DB host. | `string` | `"db-host-a"` | no |
| <a name="input_hosts_definition"></a> [hosts\_definition](#input\_hosts\_definition) | A list of PostgreSQL hosts. | `list(map(any))` | <pre>[<br>  {<br>    "name": "db-host-a",<br>    "subnet_id": null,<br>    "zone": "ru-central1-a"<br>  },<br>  {<br>    "name": "db-host-b",<br>    "replication_source_name": "db-host-1",<br>    "subnet_id": null,<br>    "zone": "ru-central1-b"<br>  },<br>  {<br>    "name": "db-host-c",<br>    "priority": 2,<br>    "subnet_id": null,<br>    "zone": "ru-central1-c"<br>  }<br>]</pre> | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of label pairs to assing to the PostgreSQL cluster. | `map` | `{}` | no |
| <a name="input_maintenance_enabled"></a> [maintenance\_enabled](#input\_maintenance\_enabled) | Enable PG cluster maintenance window option | `string` | `"disabled"` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Maintenance policy of the PostgreSQL cluster. | `map` | <pre>{<br>  "day": "MON",<br>  "hour": "5",<br>  "type": "WEEKLY"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Name db cluster | `string` | `"yc-managed-pgsql-cluster"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Cluster network id | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | A list of PostgreSQL DB owners. These users are created first and assigned to database as owner.<br>    It is a separate list of PostgreSQL databases owners.<br>    There is also an aditional list for other users with own permissions.<br><br>    NOTE: <br>     1. settings\_options could not be undefined and missing It is required due to this is a list of objects!<br>     2. Define user settings options as `settings_options = {}` and all values will be default!<br><br>    Required values:<br>      - name             - The name of the owner.<br>      - grants           - List of the owner's grants.<br>      - login            - Owner's ability to login.<br>      - conn\_limit       - The maximum number of connections per user. (Default 50)<br>      - settings\_options - A user setting options. | <pre>list(object({<br>    name               = string<br>    grants             = list(string)<br>    login              = bool<br>    conn_limit         = number<br>    settings_options   = map(any)<br>}))</pre> | <pre>[<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "owner-a",<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  },<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "owner-b",<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  }<br>]</pre> | no |
| <a name="input_performance_diagnostics"></a> [performance\_diagnostics](#input\_performance\_diagnostics) | (Optional) Cluster performance diagnostics settings. | `any` | <pre>{<br>  "enabled": true,<br>  "sessions_sampling_interval": 86400,<br>  "statements_sampling_interval": 86400<br>}</pre> | no |
| <a name="input_pg_version"></a> [pg\_version](#input\_pg\_version) | Postgres version | `string` | `"15"` | no |
| <a name="input_pgsql_config"></a> [pgsql\_config](#input\_pgsql\_config) | A map of PostgreSQL cluster configuration.<br>    Details info in a 'PostgreSQL cluster settings' of official documentation.<br>    Link: https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_cluster#postgresql-cluster-settings | `any` | <pre>{<br>  "autovacuum_vacuum_scale_factor": 0.34,<br>  "default_transaction_isolation": "TRANSACTION_ISOLATION_READ_COMMITTED",<br>  "enable_parallel_hash": true,<br>  "max_connections": 395,<br>  "shared_preload_libraries": "SHARED_PRELOAD_LIBRARIES_AUTO_EXPLAIN,SHARED_PRELOAD_LIBRARIES_PG_HINT_PLAN"<br>}</pre> | no |
| <a name="input_pooler_config"></a> [pooler\_config](#input\_pooler\_config) | Configuration of the connection pooler.<br>      - pool\_discard - Setting pool\_discard parameter in Odyssey. Values: yes \| no<br>      - pooling\_mode - Mode that the connection pooler is working in. Values: `POOLING_MODE_UNSPECIFIED`, `SESSION`, `TRANSACTION`, `STATEMENT` | `map` | <pre>{<br>  "pool_discard": true,<br>  "pooling_mode": "SESSION"<br>}</pre> | no |
| <a name="input_resource_preset_id"></a> [resource\_preset\_id](#input\_resource\_preset\_id) | Preset for hosts | `string` | `"s2.micro"` | no |
| <a name="input_restore_enabled"></a> [restore\_enabled](#input\_restore\_enabled) | Enable PG cluster restore option | `string` | `"disabled"` | no |
| <a name="input_restore_parameters"></a> [restore\_parameters](#input\_restore\_parameters) | The cluster will be created from the specified backup.<br>    NOTES:<br>      - If restore option is enabled, you must provide a valid backup\_id for your PostgreSQL.<br>      - Time format is 'year-month-dayThour:minutes:secconds', where T is a delimeter. | <pre>object({ <br>    backup_id      = string<br>    time           = string<br>    time_inclusive = bool<br>  })</pre> | <pre>{<br>  "backup_id": "pg_backup_01",<br>  "time": "2021-02-11T15:04:05",<br>  "time_inclusive": false<br>}</pre> | no |
| <a name="input_security_groups_ids_list"></a> [security\_groups\_ids\_list](#input\_security\_groups\_ids\_list) | A list of security group IDs to which the PostgreSQL cluster belongs | `list(string)` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | This is a list for additional PostgreSQL users with own permissions. They are created at the end.<br><br>    Required values:<br>      - name             - The name of the user.<br>      - grants           - A list of the user's grants.<br>      - login            - User's ability to login.<br>      - conn\_limit       - The maximum number of connections per user. (Default 50)<br>      - permissions      - A list of databases names for an access<br>      - settings\_options - A user setting options. | <pre>list(object({<br>    name               = string<br>    grants             = list(string)<br>    login              = bool<br>    conn_limit         = number<br>    permissions        = list(string)<br>    settings_options   = map(any)<br>}))</pre> | <pre>[<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "user-a",<br>    "permissions": [<br>      "db-a"<br>    ],<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  },<br>  {<br>    "conn_limit": 50,<br>    "grants": [],<br>    "login": true,<br>    "name": "user-b",<br>    "permissions": [<br>      "db-a"<br>    ],<br>    "settings_options": {<br>      "default_transaction_isolation": "read committed",<br>      "log_min_duration_statement": 5000<br>    }<br>  }<br>]</pre> | no |
| <a name="input_users_settings"></a> [users\_settings](#input\_users\_settings) | A map of users settings.<br><br>    Full description https://cloud.yandex.com/en-ru/docs/managed-postgresql/api-ref/grpc/user_service#UserSettings1<br><br>    Parameters:<br>      - default\_transaction\_isolation - defines the default isolation level to be set for all new SQL transactions.<br>      - lock\_timeout - The maximum time (in milliseconds) for any statement to wait for acquiring a lock on an table, index, row or other database object (default 0)<br>      - log\_min\_duration\_statement - This setting controls logging of the duration of statements. (default -1 disables logging of the duration of statements.)<br>      - synchronous\_commit - This setting defines whether DBMS will commit transaction in a synchronous way.<br>      - temp\_file\_limit - The maximum storage space size (in kilobytes) that a single process can use to create temporary files.<br>      - log\_statement - This setting specifies which SQL statements should be logged (on the user level).<br>      - prepared\_statements\_pooling - This setting allows user to use prepared statements with transaction pooling.<br>      - catchup\_timeout - The connection pooler setting. It determines the maximum allowed replication lag (in seconds). Pooler will reject connections to the replica with a lag above this threshold. Default value is 0, which disables this feature.<br>      - wal\_sender\_timeout - The maximum time (in milliseconds) to wait for WAL replication (can be set only for PostgreSQL 12+). Terminate replication connections that are inactive for longer than this amount of time.<br>      - idle\_in\_transaction\_session\_timeout - Sets the maximum allowed idle time (in milliseconds) between queries, when in a transaction. Value of 0 (default) disables the timeout.<br>      - statement\_timeout - The maximum time (in milliseconds) to wait for statement. Value of 0 (default) disables the timeout. | `map` | <pre>{<br>  "catchup_timeout": 0,<br>  "default_transaction_isolation": "read committed",<br>  "idle_in_transaction_session_timeout": 0,<br>  "lock_timeout": 0,<br>  "log_min_duration_statement": 5000,<br>  "log_statement": "none",<br>  "prepared_statements_pooling": false,<br>  "statement_timeout": 0,<br>  "synchronous_commit": "unspecified",<br>  "temp_file_limit": null,<br>  "wal_sender_timeout": 60<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databases"></a> [databases](#output\_databases) | A list of databases names. |
| <a name="output_owners_data"></a> [owners\_data](#output\_owners\_data) | A list of owners users with passwords. |
| <a name="output_pg_cluster_fqdns_list"></a> [pg\_cluster\_fqdns\_list](#output\_pg\_cluster\_fqdns\_list) | PostgreSQL cluster nodes FQDN list |
| <a name="output_pg_cluster_host_names_list"></a> [pg\_cluster\_host\_names\_list](#output\_pg\_cluster\_host\_names\_list) | PostgreSQL cluster host name |
| <a name="output_pg_cluster_id"></a> [pg\_cluster\_id](#output\_pg\_cluster\_id) | PostgreSQL cluster ID |
| <a name="output_pg_cluster_name"></a> [pg\_cluster\_name](#output\_pg\_cluster\_name) | PostgreSQL cluster name |
| <a name="output_pg_connection_step_1"></a> [pg\_connection\_step\_1](#output\_pg\_connection\_step\_1) | 1 step - Install certificate |
| <a name="output_pg_connection_step_2"></a> [pg\_connection\_step\_2](#output\_pg\_connection\_step\_2) | How connect to PostgreSQL cluster?<br><br>    1. Install certificate<br><br>      mkdir --parents ~/.postgresql && \<br>      wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \<br>        --output-document ~/.postgresql/root.crt && \<br>      chmod 0600 ~/.postgresql/root.crt<br><br>    2. Run connection string from the output value, for example<br><br>      psql "host=rc1a-g2em5m3zc9dxxasn.mdb.yandexcloud.net \<br>        port=6432 \<br>        sslmode=verify-full \<br>        dbname=db-b \<br>        user=owner-b \<br>        target\_session\_attrs=read-write" |
| <a name="output_users_data"></a> [users\_data](#output\_users\_data) | A list of users with passwords. |
<!-- END_TF_DOCS -->