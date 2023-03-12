variable "yc_token" {
  type = string
}

variable "datadog_api_key" {
  type = string
}

variable "datadog_app_key" {
  type = string
}

variable "datadog_api_url" {
  type = string
}

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "3.10.0"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone  = "ru-central1-a"
  token = var.yc_token
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = var.datadog_api_url
}
