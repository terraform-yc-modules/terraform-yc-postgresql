output "pg_cluster_id" {
  description = "PostgreSQL cluster ID"
  value       = try(module.db.pg_cluster_id, null)
}

output "pg_cluster_name" {
  description = "PostgreSQL cluster name"
  value       = try(module.db.pg_cluster_name, null)
}

output "pg_cluster_host_names_list" {
  description = "PostgreSQL cluster host name list"
  value       = try(module.db.pg_cluster_host_names_list, null)
}

output "pg_cluster_fqdns_list" {
  description = "PostgreSQL cluster FQDNs list"
  value       = try(module.db.pg_cluster_fqdns_list, null)
}

output "db_owners" {
  description = "A list of DB owners users with password."
  value       = try(module.db.owners_data, null)
}

output "db_users" {
  description = "A list of separate DB users with passwords."
  value       = try(module.db.users_data, null)
}

output "pg_databases" {
  description = "A list of database names."
  value       = try(module.db.databases, null)
}

output "pg_connection_step_1" {
  description = "1 step - Install certificate"
  value       = try(module.db.pg_connection_step_1, null)
}
output "pg_connection_step_2" {
  description = "2 step - Execute psql command for a connection to the cluster"
  value       = try(module.db.pg_connection_step_2, null)
}