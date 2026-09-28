locals {
  network = "${var.environment}-vpc"

  db_pwd_secret = "${var.environment}-database-password"
  db_version    = "POSTGRES_18"
  edition       = "ENTERPRISE"
  tier          = "db-g1-small"
  db_name       = "webshop"
  app_user      = "webshop"

  password_version = 1
}

data "google_compute_network" "vpc" {
  name = local.network
}

#* ====================================================================
#* === Database - PostgreSQL-18
#* ====================================================================

resource "google_sql_database_instance" "postgres" {
  name             = "${var.environment}-postgres"
  region           = var.default_region
  database_version = local.db_version

  # GCP sponsor me when :/
  deletion_protection = false

  settings {
    edition           = local.edition
    tier              = local.tier
    availability_type = "ZONAL"
    disk_autoresize   = true

    ip_configuration {
      ipv4_enabled    = false # No public IP!
      private_network = data.google_compute_network.vpc.id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled = true # daily automatic backups
    }
  }
}

resource "google_sql_database" "webshop" {
  name     = local.db_name
  instance = google_sql_database_instance.postgres.name
}

# NOTE: IDK if this will bite me back in the future
# seems pretty cool though...
ephemeral "random_password" "app_user" {
  length  = 16
  special = true
}

resource "google_sql_user" "app" {
  name                = local.app_user
  instance            = google_sql_database_instance.postgres.name
  password_wo         = ephemeral.random_password.app_user.result
  password_wo_version = local.password_version
  deletion_policy     = "ABANDON"
}


resource "google_secret_manager_secret_version" "app_password" {
  secret                 = "projects/${var.project_id}/secrets/${local.db_pwd_secret}"
  secret_data_wo         = ephemeral.random_password.app_user.result
  secret_data_wo_version = local.password_version
}
