terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "ndaje"
      ManagedBy = "terraform"
    }
  }
}


# Numéro du compte AWS, pour un nom de bucket unique au monde
data "aws_caller_identity" "current" {}

# Le bucket qui stockera l'état Terraform
resource "aws_s3_bucket" "tfstate" {
  bucket = "ndaje-tfstate-${data.aws_caller_identity.current.account_id}"

  # Empêche de le supprimer par erreur
  lifecycle {
    prevent_destroy = true
  }
}

# Garde les anciennes versions de l'état
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Chiffre les fichiers stockés
resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloque tout accès public
resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}