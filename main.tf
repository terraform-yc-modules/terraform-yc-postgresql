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

  disk_encryption_key_id = var.disk_encryption_key_id
  host_group_ids         = var.host_group_ids

  lifecycle {
    precondition {
      condition     = var.maintenance_windows == null || var.maintenance_window == null || try(var.maintenance_window.type == "ANYTIME" && var.maintenance_window.day == null && var.maintenance_window.hour == null, false)
      error_message = "Set maintenance_window to null or leave it at its default when using maintenance_windows."
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts.cluster[*]
    content {
      create = timeouts.value.create
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

  config {
    version                   = var.pg_version
    postgresql_config         = var.postgresql_config
    backup_retain_period_days = var.backup_retain_period_days

    resources {
      disk_size          = var.disk_size
      disk_type_id       = var.disk_type
      resource_preset_id = var.resource_preset_id
    }

    dynamic "access" {
      for_each = range(var.access_policy == null ? 0 : 1)
      content {
        data_lens     = var.access_policy.data_lens
        web_sql       = var.access_policy.web_sql
        serverless    = var.access_policy.serverless
        data_transfer = var.access_policy.data_transfer
        yandex_query  = var.access_policy.yandex_query
      }
    }

    dynamic "performance_diagnostics" {
      for_each = range(var.performance_diagnostics == null ? 0 : 1)
      content {
        enabled                      = var.performance_diagnostics.enabled
        advanced_mode                = var.performance_diagnostics.advanced_mode
        sessions_sampling_interval   = var.performance_diagnostics.sessions_sampling_interval
        statements_sampling_interval = var.performance_diagnostics.statements_sampling_interval
      }
    }

    dynamic "backup_window_start" {
      for_each = range(var.backup_window_start == null ? 0 : 1)
      content {
        hours   = var.backup_window_start.hours
        minutes = var.backup_window_start.minutes
      }
    }

    dynamic "disk_size_autoscaling" {
      for_each = var.disk_size_autoscaling[*]
      content {
        disk_size_limit           = disk_size_autoscaling.value.disk_size_limit
        planned_usage_threshold   = disk_size_autoscaling.value.planned_usage_threshold
        emergency_usage_threshold = disk_size_autoscaling.value.emergency_usage_threshold
      }
    }

    dynamic "managed_repack" {
      for_each = var.managed_repack[*]
      content {
        enabled = managed_repack.value
      }
    }

    dynamic "pooler_config" {
      for_each = range(var.pooler_config == null ? 0 : 1)
      content {
        pooling_mode = var.pooler_config.pooling_mode
      }
    }
  }

  dynamic "host" {
    for_each = var.hosts_definition
    content {
      name                    = host.value.name
      zone                    = host.value.zone
      subnet_id               = host.value.subnet_id
      assign_public_ip        = host.value.assign_public_ip
      priority                = host.value.priority
      replication_source_name = host.value.replication_source_name
    }
  }

  dynamic "restore" {
    for_each = range(var.restore_parameters == null ? 0 : 1)
    content {
      backup_id      = var.restore_parameters.backup_id
      time           = var.restore_parameters.time
      time_inclusive = var.restore_parameters.time_inclusive
    }
  }

  dynamic "maintenance_window" {
    for_each = range(var.maintenance_window == null || var.maintenance_windows != null ? 0 : 1)
    content {
      type = var.maintenance_window.type
      day  = var.maintenance_window.day
      hour = var.maintenance_window.hour
    }
  }

  dynamic "maintenance_windows" {
    for_each = var.maintenance_windows[*]
    content {
      type = maintenance_windows.value.type

      dynamic "slot" {
        for_each = maintenance_windows.value.slots
        content {
          day                            = slot.value.day
          start_time                     = slot.value.start_time
          duration                       = slot.value.duration
          allow_temporary_unavailability = slot.value.allow_temporary_unavailability
        }
      }
    }
  }

}

resource "yandex_dns_recordset" "rw" {
  count = var.dns_cname_config != null ? 1 : 0

  zone_id = var.dns_cname_config["zone_id"]
  name    = "${var.dns_cname_config["name"]}."
  type    = "CNAME"
  ttl     = var.dns_cname_config["ttl"]
  data    = ["c-${yandex_mdb_postgresql_cluster.this.id}.rw.mdb.yandexcloud.net"]
}
