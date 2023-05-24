terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
  }
}

provider "archive" {}

provider "aws" {
  region = "eu-central-1"
  default_tags {
    tags = {
      environment  = var.environment
      project_name = var.project_name
      project_path = var.project_path
      namespace    = var.namespace
    }
  }
}

provider "null" {}
