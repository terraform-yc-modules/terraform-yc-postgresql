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
2. The `users` variable defines a list of separate DB users with the `permissions` list, which points to a list of databases. This means each user will have access to each database from the `permissions` list.
3. The `settings_options` parameter may be null, in which case the default values will be used.

### Example

See [examples section](./examples/)

### How to configure Terraform for Yandex Cloud

- Install [YC CLI](https://cloud.yandex.com/docs/cli/quickstart)
- Add environment variables for terraform auth in Yandex.Cloud

```
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
export TF_VAR_network_id=_vpc id here_
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | > 3.3 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | >= 0.89.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.98.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.pgpass_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [yandex_dns_recordset.rw](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/dns_recordset) | resource |
| [yandex_mdb_postgresql_cluster.this](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_cluster) | resource |
| [yandex_mdb_postgresql_database.database](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_database) | resource |
| [yandex_mdb_postgresql_user.owner](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_user) | resource |
| [yandex_mdb_postgresql_user.user](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_user) | resource |
| [yandex_client_config.client](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_policy"></a> [access\_policy](#input\_access\_policy) | Access policy from other services to the PostgreSQL cluster. | <pre>object({<br>    data_lens     = optional(bool, null)<br>    web_sql       = optional(bool, null)<br>    serverless    = optional(bool, null)<br>    data_transfer = optional(bool, null)<br>  })</pre> | `{}` | no |
| <a name="input_autofailover"></a> [autofailover](#input\_autofailover) | (Optional) Configuration setting which enables and disables auto failover in the cluster. | `bool` | `true` | no |
| <a name="input_backup_retain_period_days"></a> [backup\_retain\_period\_days](#input\_backup\_retain\_period\_days) | (Optional) The period in days during which backups are stored. | `number` | `null` | no |
| <a name="input_backup_window_start"></a> [backup\_window\_start](#input\_backup\_window\_start) | (Optional) Time to start the daily backup, in the UTC timezone. | <pre>object({<br>    hours   = string<br>    minutes = optional(string, "00")<br>  })</pre> | `null` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | List of PostgreSQL databases.<br><br>    Required values:<br>      - name                - (Required) The name of the database.<br>      - owner               - (Required) Name of the user assigned as the owner of the database. Forbidden to change in an existing database.<br>      - extension           - (Optional) Set of database extensions. <br>      - lc\_collate          - (Optional) POSIX locale for string sorting order. Forbidden to change in an existing database.<br>      - lc\_type             - (Optional) POSIX locale for character classification. Forbidden to change in an existing database.<br>      - template\_db         - (Optional) Name of the template database.<br>      - deletion\_protection - (Optional) A deletion protection. | <pre>list(object({<br>    name                = string<br>    owner               = string<br>    lc_collate          = optional(string, null)<br>    lc_type             = optional(string, null)<br>    template_db         = optional(string, null)<br>    deletion_protection = optional(bool, null)<br>    extensions          = optional(list(string), [])<br>  }))</pre> | n/a | yes |
| <a name="input_default_user_settings"></a> [default\_user\_settings](#input\_default\_user\_settings) | The default user settings. These settings are overridden by the user's settings.<br>    Full description https://cloud.yandex.com/en-ru/docs/managed-postgresql/api-ref/grpc/user_service#UserSettings1 | `map(any)` | `{}` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Protects the cluster from deletion | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | PostgreSQL cluster description | `string` | `"Managed PostgreSQL cluster"` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Disk size for every cluster host | `number` | `20` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Disk type for all cluster hosts | `string` | `"network-ssd"` | no |
| <a name="input_dns_cname_config"></a> [dns\_cname\_config](#input\_dns\_cname\_config) | Creates a CNAME record of connection host in the specified DNS zone.<br><br>    Object values:<br>      - name                - (Required) The DNS name this record set will apply to.<br>      - zone\_id             - (Required) The id of the zone in which this record set will reside<br>      - ttl                 - (Optional) The time-to-live of this record set (seconds). | <pre>object({<br>    name    = string<br>    zone_id = string<br>    ttl     = optional(number, 360)<br>  })</pre> | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment type: PRODUCTION or PRESTABLE | `string` | `"PRODUCTION"` | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | Yandex Cloud Folder ID where the cluster resides | `string` | `null` | no |
| <a name="input_host_master_name"></a> [host\_master\_name](#input\_host\_master\_name) | Name of the master host. | `string` | `null` | no |
| <a name="input_hosts_definition"></a> [hosts\_definition](#input\_hosts\_definition) | A list of PostgreSQL hosts. | <pre>list(object({<br>    name                    = optional(string, null)<br>    zone                    = string<br>    subnet_id               = string<br>    assign_public_ip        = optional(bool, false)<br>    replication_source_name = optional(string, null)<br>    priority                = optional(number, null)<br>  }))</pre> | n/a | yes |
| <a name="input_labels"></a> [labels](#input\_labels) | A set of label pairs to assing to the PostgreSQL cluster. | `map(any)` | `{}` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | (Optional) Maintenance policy of the PostgreSQL cluster.<br>      - type - (Required) Type of maintenance window. Can be either ANYTIME or WEEKLY. A day and hour of window need to be specified with weekly window.<br>      - day  - (Optional) Day of the week (in DDD format). Allowed values: "MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"<br>      - hour - (Optional) Hour of the day in UTC (in HH format). Allowed value is between 0 and 23. | <pre>object({<br>    type = string<br>    day  = optional(string, null)<br>    hour = optional(string, null)<br>  })</pre> | <pre>{<br>  "type": "ANYTIME"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | PostgreSQL cluster name | `string` | `"pgsql-cluster"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | Network id of the PostgreSQL cluster | `string` | n/a | yes |
| <a name="input_owners"></a> [owners](#input\_owners) | List of special PostgreSQL DB users - database owners. These users are created first and assigned to database as owner.<br>    There is also an aditional list for other users with own permissions.<br><br>    Required values:<br>      - name                - (Required) The name of the user.<br>      - password            - (Optional) The user's password. If it's omitted a random password will be generated.<br>      - grants              - (Optional) List of the user's grants.<br>      - login               - (Optional) The user's ability to login.<br>      - conn\_limit          - (Optional) The maximum number of connections per user.<br>      - settings            - (Optional) A user setting options.<br>      - deletion\_protection - (Optional) A deletion protection. | <pre>list(object({<br>    name                = string<br>    password            = optional(string, null)<br>    grants              = optional(list(string), [])<br>    login               = optional(bool, null)<br>    conn_limit          = optional(number, null)<br>    settings            = optional(map(any), {})<br>    deletion_protection = optional(bool, null)<br>  }))</pre> | n/a | yes |
| <a name="input_performance_diagnostics"></a> [performance\_diagnostics](#input\_performance\_diagnostics) | (Optional) PostgreSQL cluster performance diagnostics settings. | <pre>object({<br>    enabled                      = optional(bool, null)<br>    sessions_sampling_interval   = optional(number, 60)<br>    statements_sampling_interval = optional(number, 600)<br>  })</pre> | `{}` | no |
| <a name="input_pg_version"></a> [pg\_version](#input\_pg\_version) | PostgreSQL version | `string` | `"15"` | no |
| <a name="input_pgpass_path"></a> [pgpass\_path](#input\_pgpass\_path) | Location of the .pgpass file. If it's omitted the file will not be created | `string` | `null` | no |
| <a name="input_pooler_config"></a> [pooler\_config](#input\_pooler\_config) | Configuration of the connection pooler.<br>      - pool\_discard - Setting pool\_discard parameter in Odyssey. Values: yes \| no<br>      - pooling\_mode - Mode that the connection pooler is working in. Values: `POOLING_MODE_UNSPECIFIED`, `SESSION`, `TRANSACTION`, `STATEMENT` | <pre>object({<br>    pool_discard = optional(bool, null)<br>    pooling_mode = optional(string, null)<br>  })</pre> | `null` | no |
| <a name="input_postgresql_config"></a> [postgresql\_config](#input\_postgresql\_config) | Map of PostgreSQL cluster configuration.<br>    Details info in a 'PostgreSQL cluster settings' of official documentation.<br>    Link: https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/mdb_postgresql_cluster#postgresql-cluster-settings | `map(any)` | `null` | no |
| <a name="input_resource_preset_id"></a> [resource\_preset\_id](#input\_resource\_preset\_id) | Preset for hosts | `string` | `"s2.micro"` | no |
| <a name="input_restore_parameters"></a> [restore\_parameters](#input\_restore\_parameters) | The cluster will be created from the specified backup.<br>    NOTES:<br>      - backup\_id must be specified to create a new PostgreSQL cluster from a backup.<br>      - time format is 'yyy-mm-ddThh:mi:ss', where T is a delimeter, e.g. "2023-04-05T11:22:33".<br>      - time\_inclusive indicates recovery to nearest recovery point just before (false) or right after (true) the time. | <pre>object({<br>    backup_id      = string<br>    time           = optional(string, null)<br>    time_inclusive = optional(bool, null)<br>  })</pre> | `null` | no |
| <a name="input_security_groups_ids_list"></a> [security\_groups\_ids\_list](#input\_security\_groups\_ids\_list) | List of security group IDs to which the PostgreSQL cluster belongs | `list(string)` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | List of additional PostgreSQL users with own permissions. They are created at the end.<br><br>    Required values:<br>      - name                - (Required) The name of the user.<br>      - password            - (Optional) The user's password. If it's omitted a random password will be generated.<br>      - grants              - (Optional) List of the user's grants.<br>      - login               - (Optional) The user's ability to login.<br>      - conn\_limit          - (Optional) The maximum number of connections per user.<br>      - permissions         - (Optional) List of databases names for an access<br>      - settings            - (Optional) A user setting options.<br>      - deletion\_protection - (Optional) A deletion protection. | <pre>list(object({<br>    name                = string<br>    password            = optional(string, null)<br>    grants              = optional(list(string), [])<br>    login               = optional(bool, null)<br>    conn_limit          = optional(number, null)<br>    permissions         = optional(list(string), [])<br>    settings            = optional(map(any), {})<br>    deletion_protection = optional(bool, null)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_fqdns_list"></a> [cluster\_fqdns\_list](#output\_cluster\_fqdns\_list) | PostgreSQL cluster nodes FQDN list |
| <a name="output_cluster_host_names_list"></a> [cluster\_host\_names\_list](#output\_cluster\_host\_names\_list) | PostgreSQL cluster host name |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | PostgreSQL cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | PostgreSQL cluster name |
| <a name="output_connection_host_cname"></a> [connection\_host\_cname](#output\_connection\_host\_cname) | PostgreSQL cluster connection host CNAME. |
| <a name="output_connection_step_1"></a> [connection\_step\_1](#output\_connection\_step\_1) | 1 step - Install certificate |
| <a name="output_connection_step_2"></a> [connection\_step\_2](#output\_connection\_step\_2) | How connect to PostgreSQL cluster?<br><br>    1. Install certificate<br><br>      mkdir --parents \~/.postgresql && \\<br>      curl -sfL "https://storage.yandexcloud.net/cloud-certs/CA.pem" -o \~/.postgresql/root.crt && \\<br>      chmod 0600 \~/.postgresql/root.crt<br><br>    2. Run connection string from the output value, for example<br><br>      psql "host=rc1a-g2em5m3zc9dxxasn.mdb.yandexcloud.net \\<br>        port=6432 \\<br>        sslmode=verify-full \\<br>        dbname=db-b \\<br>        user=owner-b \\<br>        target\_session\_attrs=read-write" |
| <a name="output_databases"></a> [databases](#output\_databases) | List of databases names. |
| <a name="output_owners_data"></a> [owners\_data](#output\_owners\_data) | List of owners with passwords. |
| <a name="output_users_data"></a> [users\_data](#output\_users\_data) | List of users with passwords. |
<!-- END_TF_DOCS -->
