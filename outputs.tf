output "pg_cluster_id" {
  description = "PostgreSQL cluster ID"
  value       = yandex_mdb_postgresql_cluster.this.id
}

output "pg_cluster_name" {
  description = "PostgreSQL cluster name"
  value       = yandex_mdb_postgresql_cluster.this.name
}

output "pg_cluster_host_names_list" {
  description = "PostgreSQL cluster host name"
  value       = ["${yandex_mdb_postgresql_cluster.this.host[*].name}"]
}

output "pg_cluster_fqdns_list" {
  description = "PostgreSQL cluster nodes FQDN list"
  value       = ["${yandex_mdb_postgresql_cluster.this.host[*].fqdn}"]
}

output "owners_data" {
  description = "A list of owners users with passwords."
  value = [
    for i, owner in var.owners: {
      user     = "${owner["name"]}"
      password = "${random_string.owners_passwords[i].result}"
    }
  ]
}

output "users_data" {
  description = "A list of users with passwords."
  value = [
    for i, user in var.users: {
      user     = "${user["name"]}"
      password = "${random_string.users_passwords[i].result}"
    }
  ]
}

output "databases" {
  description = "A list of databases names."
  value = [ for db in var.databases : db.name ]
}

output "pg_connection_step_1" {
  description = "1 step - Install certificate"
  value = "mkdir --parents ~/.postgresql && wget 'https://storage.yandexcloud.net/cloud-certs/CA.pem' --output-document ~/.postgresql/root.crt && chmod 0600 ~/.postgresql/root.crt"
}    
output "pg_connection_step_2" {
  description = <<EOF
    How connect to PostgreSQL cluster?

    1. Install certificate
    
      mkdir --parents ~/.postgresql && \
      wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" \
        --output-document ~/.postgresql/root.crt && \
      chmod 0600 ~/.postgresql/root.crt
    
    2. Run connection string from the output value, for example
    
      psql "host=rc1a-g2em5m3zc9dxxasn.mdb.yandexcloud.net \
        port=6432 \
        sslmode=verify-full \
        dbname=db-b \
        user=owner-b \
        target_session_attrs=read-write"
    
  EOF
  value = "psql 'host=c-${local.pg_cluster_id}.rw.mdb.yandexcloud.net port=6432 sslmode=verify-full dbname=${var.databases[0]["name"]} user=${var.databases[0]["owner"]} target_session_attrs=read-write'"
}