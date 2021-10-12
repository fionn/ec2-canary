terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.62"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
  required_version = ">= 1"

  #  backend "s3" {
  #  bucket         = "toucan-terraform-state"
  #  key            = "global/terraform.tfstate"
  #  region         = "ap-northeast-1"
  #  encrypt        = true
  #  dynamodb_table = "toucan-terraform-state-locks"
  #}
}
