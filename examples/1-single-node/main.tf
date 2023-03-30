# main.tf
data "yandex_client_config" "client" {}

module "db" {
  source = "../../"
 
  network_id          = "enpneopbt180nusgut3q"
  maintenance_enabled = "enabled"

  hosts_definition = [
    {
      name      = "master"
      zone      = "ru-central1-a"
      subnet_id = "e9b5udt8asf9r9qn6nf6"
    }
  ]

  // databases and owners will be created using default values

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
    },
    {
      name               = "user-d"
      grants             = []
      login              = true
      conn_limit         = 50
      permissions        = ["db-b"]
      settings_options   = {}
    }
  ]

}