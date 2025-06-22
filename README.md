# Terraform-template
Terraformのテンプレートファイル

# AWS

EC2を立ち上げるだけのテンプレートファイル。

## awsでユーザー設定を行う

アクセス対象のアカウントで、以下の設定を行うこと

- 必要ならIAMユーザーを作成
- ユーザーにグループを紐づける
- Terraform用の権限を付与する
  - マルチアカウントのアクセス許可で、「Administrator Access」を付与する

## aws-cliによる認証

`aws-cli`を用いてログインをする

まずは`aws-cli`をインストールする

```sh
brew insatll awscli

aws --version
```

以下のコマンドで`config`情報を作成する

```sh
aws configure sso --profile <profile-name>
```

`~/.aws/config`が作成される

以下は一例
```ini
[profile my-sso-user]
sso_start_url = https://your-org.awsapps.com/start
sso_region = ap-northeast-1
sso_account_id = 123456789012
sso_role_name = TerraformAccessRole
region = ap-northeast-1
```

一度認証したら、あとは以下のコマンドでログインをすれば良い

```sh
aws sso login --profile <profile-name>
```

## Terraformの準備

基本的なファイルは用意しているので、`AWS`ディレクトリに移動して、`Terraform`のコマンドを入力すれば良い

```sh
# 移動
cd AWS

# 初期化
terraform init

# プラン確認
terraform plan

# リソースを作成する
terraform apply
```

AWSのコンソールにアクセスしたら、EC2が作成されていることが確認できる

## Terraformのお片付け

インスタンスを作成してそのままにしておくと、課金されてしまう

そのため、遊び終わったらインスタンスを削除しておきたい

以下のコマンドで実現できる

```sh
terraform destroy
```




