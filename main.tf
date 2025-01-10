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

variable "docker_image" {}
variable "docker_registry_url" {}
variable "docker_registry_username" {}
variable "docker_registry_password" {}

resource "azurerm_resource_group" "rg" {
  name     = "rg-laravel-app"
  location = "West Europe"
}

resource "azurerm_container_registry" "acr" {
  name                = "acrlaravel${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  sku                = "Basic"
  admin_enabled      = true
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "asp-laravel"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  os_type            = "Linux"
  sku_name           = "B1"
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-laravel-${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  service_plan_id    = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      docker_image     = var.docker_image
      docker_image_tag = "latest"
    }
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = var.docker_registry_url
    "DOCKER_REGISTRY_SERVER_USERNAME"     = var.docker_registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = var.docker_registry_password
    "APP_KEY"                            = "${base64encode(random_string.app_key.result)}"
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