# remote-state

TerraformのstateファイルをAWSのS3上に保管するためのコード

ほかと組み合わせると良い

一例として、以下のような構成にするとよい感じ(該当箇所はglobal/s3になる)

```sh
.
├── stage
│   ├── vpc
│   ├── services
│   │   ├── frontend-app
│   │   └── backend-app
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       └── main.tf
│   └── data-storage
│       ├── mysql
│       └── redis
├── prod
│   ├── vpc
│   ├── services
│   │   ├── frontend-app
│   │   └── backend-app
│   └── data-storage
│       ├── mysql
│       └── redis
├── mgmt
│   ├── vpc
│   └── services
│       ├── bastion-host
│       └── jenkins
└── global
    ├── iam
    └── s3
```

## 作成とデストロイ

`terraform apply`すればよい、というわけでもないため、以下のような手順で作成とデストロイを行う事

なお、一度作っておけば使い回せるので、基本的にはそれぞれ一回ずつ実行されるイメージ

### TerraformステートのバックエンドをS3に作る

1. S3バケットとDynamoDBテーブルを作成するTerraformコードを書き、ローカルバックエンドを利用してコードをデプロイ
2. 新しく作成されたS3バケットとDynamoDBテーブルを使用するよう、Terraformコードにbackend設定を追記し、ローカルのステートファイルをS3にコピーするため`terraform init`を実行

### S3バケットとDynamoDBテーブルを削除する

1. Terraformコードからbackend設定を削除し、Terraformステートをローカルディスクにコピーするために`terraform init`を実行
2. S3バケットとDynamoDBテーブルを削除するため`terraform destroy`を実行

## ファイル編集

テンプレートには仮の値を入れているので、使用する段にあたって値を変更する必要がある

### backend.hcl

`bucket`と`daynamodb_table`と、あれば`profile`の記載を変更する

```hcl
# 使用するbucketの名前に変える
bucket         = "terraform-up-and-running-state-exercise" 
region         = "ap-northeast-1"
# 使用するtableの名前に変える
dynamodb_table = "terraform-up-and-running-locks"
encrypt        = true
# profileがあれば記載すること。なければ不要
# profile        = "exercise-user"
```

### main.tf

変更箇所のみ抜粋する
コメントのある箇所を直していけば良い

```tf
provider "aws" {
  region  = "ap-northeast-1"
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

# ~

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

```

### outputs.tf

これは特に弄る必要はない

## 実行コマンド

`backend.hcl`にbackendブロックの設定を書いているので、以下のコマンドで実行すること

```sh
terraform init -backend-config=<backend.hclの相対パス>
```


