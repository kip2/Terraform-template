provider "aws" {
  region = "ap-northeast-1"
  # todo: profilegがなければ不要。あるなら変更する
  profile = "exercise-user"
}

resource "aws_s3_bucket" "terraform_state" {
  # todo: bucket名を変更する
  bucket = "terraform-up-and-running-state-exercise"

  # 誤ってS3バケットを削除するのを防止
  lifecycle {
    prevent_destroy = true
  }
}

# ステートファイルの完全な履歴が見れるように、バージョニングを有効化
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# デフォルトでサーバサイド暗号化を有効化
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 明示的にこのS3バケットに対する全パブリックアクセスをブロック
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  # todo: 名前を変更する
  name         = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

terraform {
  backend "s3" {
    # todo: keyの値を変更する
    key = "global/s3/terraform.tfstate"
  }
}
