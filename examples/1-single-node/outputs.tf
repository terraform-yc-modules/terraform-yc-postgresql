output "postgresql_cluster_id" {
  description = "PostgreSQL cluster ID"
  value       = try(module.db.cluster_id, null)
}

output "postgresql_cluster_name" {
  description = "PostgreSQL cluster name"
  value       = try(module.db.cluster_name, null)
}

output "postgresql_cluster_host_names_list" {
  description = "PostgreSQL cluster host name list"
  value       = try(module.db.cluster_host_names_list, null)
}

output "postgresql_cluster_fqdns_list" {
  description = "PostgreSQL cluster FQDNs list"
  value       = try(module.db.cluster_fqdns_list, null)
}

output "db_owners" {
  description = "A list of DB owners users with password."
  sensitive   = true
  value       = try(module.db.owners_data, null)
}

output "db_users" {
  description = "A list of separate DB users with passwords."
  sensitive   = true
  value       = try(module.db.users_data, null)
}

output "postgresql_databases" {
  description = "A list of database names."
  value       = try(module.db.databases, null)
}

output "postgresql_connection_step_1" {
  description = "1 step - Install certificate"
  value       = try(module.db.connection_step_1, null)
}
output "postgresql_connection_step_2" {
  description = "2 step - Execute psql command for a connection to the cluster"
  value       = try(module.db.connection_step_2, null)
}