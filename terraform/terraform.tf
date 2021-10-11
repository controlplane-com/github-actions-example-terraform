terraform {

  backend "remote" {
    organization = "TERRAFORM_ORG"

    workspaces {
      prefix = "WORKSPACE_PREFIX"
    }
  }

  required_providers {
    cpln = {
      version = "1.0.1"
      source  = "controlplane.com/com/cpln"
    }
  }
}

variable "org" {
  type    = string
  default = ""
}

variable "token" {
  type    = string
  default = ""
}

variable "image" {
  type    = string
  default = ""
}

variable "gvc" {
  type    = string
  default = ""
}

variable "workload" {
  type    = string
  default = ""
}

provider "cpln" {
  org   = var.org
  token = var.token
}

resource "cpln_gvc" "gvc" {

  name        = var.gvc
  description = "GVC created by Terraform"

  # Available locations: aws-eu-central-1, aws-us-west-2, azure-eastus2, gcp-us-east1
  locations = ["gcp-us-east1"]
}

resource "cpln_workload" "workload" {

  gvc = cpln_gvc.gvc.name

  name        = var.workload
  description = "Workload created by Terraform"

  container {
    name  = "app-image"
    image = "/org/${var.org}/image/${var.image}"
    port  = 8080
  }

  options {
    capacity_ai     = false
    timeout_seconds = 5

    autoscaling {
      metric          = "concurrency"
      target          = 100
      max_scale       = 1
      min_scale       = 1
      max_concurrency = 500
    }
  }

  firewall_spec {
    external {
      inbound_allow_cidr = ["0.0.0.0/0"]
    }
  }
}


