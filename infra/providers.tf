# Define las versiones compatibles de Terraform y del proveedor AWS.
terraform {
  required_version = ">= 1.15.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.57.0"

    }
  }
}

# Configura la región donde se administran los recursos de AWS.
provider "aws" {
  region = "us-east-1"
}
