# main.tf
data "yandex_client_config" "client" {}

module "db" {
  source = "../../"
 
  network_id               = "enpneopbt180nusgut3q"

  name                     = "pgsql-multi-cluster"
  description              = "Yandex Managed PostgreSQL HA cluster"
  pg_version               = "15"
  environment              = "PRODUCTION"
  maintenance_enabled      = "enabled"
  deletion_protection      = false

  host_master_name         = "master"
  hosts_definition = [
    {
      name      = "master"
      zone      = "ru-central1-a"
      subnet_id = "e9b5udt8asf9r9qn6nf6"
    },
    {
      name      = "slave_1"
      zone      = "ru-central1-b"
      subnet_id = "e2lu07tr481h35012c8p"
      replication_source_name = "master"
    },
    {
      name      = "slave_2"
      zone      = "ru-central1-c"
      subnet_id = "b0c7h1g3ffdcpee488at"
      priority  = 2
    }
  ]

  owners = [
    {
      name               = "owner-c"
      grants             = []
      login              = true
      conn_limit         = 50
      settings_options   = {}
    },
    {
      name               = "owner-b"
      grants             = []
      login              = true
      conn_limit         = 50
      settings_options   = {}
    },
    {
      name               = "owner-a"
      grants             = []
      login              = true
      conn_limit         = 50
      settings_options   = {}
    }
  ]

  databases = [
    {
      name               = "db-a"
      owner              = "owner-b"
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
    },
    {
      name               = "db-c"
      owner              = "owner-a"
      lc_collate         = "en_US.UTF-8"
      lc_type            = "en_US.UTF-8"
      template_db        = null
      extensions         = ["uuid-ossp", "xml2"]
    },
    {
      name               = "db-d"
      owner              = "owner-c"
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
      settings_options   = {}
    },
    {
      name               = "user-b"
      grants             = []
      login              = true
      conn_limit         = 50
      permissions        = ["db-a", "db-b", "db-c"]
      settings_options   = {}
    },
    {
      name               = "user-c"
      grants             = []
      login              = true
      conn_limit         = 50
      permissions        = ["db-a"]
      settings_options   = {}
    },
    {
      name               = "user-d"
      grants             = []
      login              = true
      conn_limit         = 50
      permissions        = ["db-c", "db-d"]
      settings_options   = {}
    }
  ]
}
