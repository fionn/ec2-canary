resource "aws_s3_bucket" "terraform_state" {
  # Do not change, used in terraform block
  bucket = "${local.common_tags.Project}-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.common_tags
}

resource "aws_dynamodb_table" "terraform_state_locks" {
  # Do not change, used in terraform block
  name         = "${local.common_tags.Project}-terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.common_tags
}
