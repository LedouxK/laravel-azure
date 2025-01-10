terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "devtest" {
  name = "t-clo-901-rms-0"
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-laravel"
  resource_group_name = data.azurerm_resource_group.devtest.name
  location           = data.azurerm_resource_group.devtest.location
  os_type            = "Linux"
  sku_name           = "B1"
}

resource "azurerm_mysql_flexible_server" "mysql" {
  name                = "mysql-laravel-app"
  resource_group_name = data.azurerm_resource_group.devtest.name
  location           = data.azurerm_resource_group.devtest.location
  
  administrator_login    = "laravel"
  administrator_password = random_password.mysql_password.result
  
  sku_name              = "B_Standard_B1s"
  version               = "8.0.21"
  
  zone                  = "1"
}

resource "azurerm_mysql_flexible_database" "database" {
  name                = "laravel"
  resource_group_name = data.azurerm_resource_group.devtest.name
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation          = "utf8mb4_unicode_ci"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-laravel-${random_string.unique.result}"
  resource_group_name = data.azurerm_resource_group.devtest.name
  location           = data.azurerm_resource_group.devtest.location
  service_plan_id    = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      php_version = "8.2"
    }
    always_on = true
  }

  app_settings = {
    "APP_KEY"           = base64encode(random_string.app_key.result)
    "APP_ENV"           = "production"
    "APP_DEBUG"         = "false"
    "DB_CONNECTION"     = "mysql"
    "DB_HOST"          = azurerm_mysql_flexible_server.mysql.fqdn
    "DB_PORT"          = "3306"
    "DB_DATABASE"      = azurerm_mysql_flexible_database.database.name
    "DB_USERNAME"      = azurerm_mysql_flexible_server.mysql.administrator_login
    "DB_PASSWORD"      = azurerm_mysql_flexible_server.mysql.administrator_password
  }
}

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

resource "random_string" "app_key" {
  length  = 32
  special = true
}

resource "random_password" "mysql_password" {
  length  = 16
  special = true
} 