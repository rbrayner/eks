terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0" # https://www.terraform.io/language/expressions/version-constraints
        }
    }
}
provider "aws" {
    region = var.aws_region

    default_tags {
        tags = {
            Environment = "Test"
            Name        = "EKS Demo"
        }
    }
}
