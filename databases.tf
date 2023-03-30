# PostgreSQL databases
resource "yandex_mdb_postgresql_database" "database" {
  for_each   = length(var.databases) > 0 ? { for db in var.databases: db.name => db } : {}

  cluster_id = yandex_mdb_postgresql_cluster.this.id
  name       = lookup(each.value, "name", null)
  owner      = lookup(each.value, "owner", null)
  lc_collate = lookup(each.value, "lc_collate", null)
  lc_type    = lookup(each.value, "lc_type", null)
  
  dynamic "extension" {
    for_each = lookup(each.value, "extension", [])
    content {
      name   = extension.value
    }
  }

  depends_on = [
    yandex_mdb_postgresql_user.owner
  ]
}