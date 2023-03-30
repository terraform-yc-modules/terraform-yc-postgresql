data "yandex_client_config" "client" {}

locals {
  folder_id = var.folder_id == null ? data.yandex_client_config.client.folder_id : var.folder_id
}

# PostgreSQL cluster
resource "yandex_mdb_postgresql_cluster" "this" {
  name                = var.name
  description         = var.description
  environment         = var.environment
  network_id          = var.network_id
  folder_id           = local.folder_id
  labels              = var.labels
  host_master_name    = var.host_master_name
  deletion_protection = var.deletion_protection
  security_group_ids  = var.security_groups_ids_list
  
  config {
    version           = var.pg_version
    resources {
      disk_size       = var.disk_size
      disk_type_id    = var.disk_type
      resource_preset_id = var.resource_preset_id
    }
    
    postgresql_config = var.pgsql_config
    autofailover      = var.autofailover
    backup_retain_period_days = var.backup_retain_period_days
    
    dynamic "access" {
      for_each        = range(var.access_enabled == "enabled" ? 1 : 0)
      content {
        data_lens     = var.access_policy.data_lens
        web_sql       = var.access_policy.web_sql
        serverless    = var.access_policy.serverless
        data_transfer = var.access_policy.data_transfer
      }
    }

    performance_diagnostics  {
      enabled                      = var.performance_diagnostics.enabled
      sessions_sampling_interval   = var.performance_diagnostics.sessions_sampling_interval
      statements_sampling_interval = var.performance_diagnostics.statements_sampling_interval
    }
    
    backup_window_start {
      hours   = var.backup_window_start.hours
      minutes = var.backup_window_start.minutes
    }

    pooler_config {
      pool_discard = var.pooler_config.pool_discard
      pooling_mode = var.pooler_config.pooling_mode
    } 
  }

  dynamic "host" {
    for_each    = var.hosts_definition
    content {
      name      = host.value.name
      zone      = host.value.zone
      subnet_id = host.value.subnet_id
      priority  = try(host.value.priority, null)
      replication_source_name = try(host.value.replication_source_name, null)
    }
  }

  dynamic "restore" {
    for_each         = range(var.restore_enabled == "enabled" ? 1 : 0)
    content {
      backup_id      = var.restore_parameters.backup_id
      time           = var.restore_parameters.time
      time_inclusive = var.restore_parameters.time_inclusive
    }
  }

  dynamic "maintenance_window" {
    for_each = range(var.maintenance_enabled == "enabled" ? 1 : 0)
    content {
      type   = var.maintenance_window.type
      day    = var.maintenance_window.day
      hour   = var.maintenance_window.hour
    }
  }
}

locals {
  pg_cluster_id = "${yandex_mdb_postgresql_cluster.this.id}"
  pgpass_lines = [
    for i, owner in var.owners: "c-${local.pg_cluster_id}.rw.mdb.yandexcloud.net:6432:${var.databases[i]["name"]}:${owner["name"]}:${random_string.owners_passwords[i].result}"
  ]
}

resource "local_file" "pgpass_file" {
  content  = <<-EOT
%{ for line in local.pgpass_lines ~}
${line}"
%{ endfor ~}
  EOT
  filename = "${path.module}/.pgpass"
  file_permission = "0600"
}
