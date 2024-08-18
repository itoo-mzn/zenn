---
title: "Terraform"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Terraform"]
published: false
---

# AWS CLI の設定

Terraform から AWS リソースを操作（作成など）しようとすると、まず AWS CLI の設定が必要。
それを実行できる権限を持ったアカウントで Terraform を実行できるようにする。

大きく 2 つの方法がある。

1. 環境変数`AWS_PROFILE`を設定する
   認証情報自体は aws configure で profile に紐づけておく。
   この方法は、今起動しているシェルだけに適応されるので、ターミナルで別タブで実行するなら再度`export AWS_PROFILE={プロファイル名}`の実行が必要。
   https://zenn.dev/wakkunn/articles/be748e71d405d1

2. `awsp`を使う
   https://github.com/johnnyopao/awsp

# Terraform CLI

## おおまかな操作手順

よく使うコマンドとその手順は下記。

```sh
terraform init # 初回のみ

terraform fmt
terraform validate
terraform plan
terraform apply

terraform destroy # 削除したい場合
```

:::message
コマンドを実行すると、その直下の tf ファイルがすべて読み込まれて実行される。
そのため、module を使うときにはそのモジュールが用意している tf ファイルを指定して、コマンド実行ディレクトリで認識できるようにする。

```tf:main.tf
# sqsモジュールを使う
module "sqs" {
  source = "./module/sqs"
  （略）
}
```

:::

## terraform init

実行が必要なタイミングは下記。

- Terraform プロジェクトを新規作成したとき
- Git から落としてきたとき
- main ファイル（terraform、provider） に変更を加えたとき

複数回実行しても安全。

（メモ：.terraform.lock.hcl ファイルと、.terraform ディレクトリが作られた）

**TODO**: 詳しくはあとで理解する。
https://developer.hashicorp.com/terraform/cli/commands/init

## terraform plan

- `-/+` : 破棄して再作成 することを意味する。

## terraform apply

- apply が完了するまで、**ロックファイルによる排他制御**が行われる。

## terraform show

状態をすべて表示。

## terraform state list

リソースを一覧表示。

## terraform console

## terraform output

リソースを作成済の状態で実行する。output している値を確認できる。

## terraform state rm

import の逆。管理下（state）から除外したい場合に使う。

# tfstate

## 詳細

**TODO**: このチュートリアルやること。
https://developer.hashicorp.com/terraform/tutorials/cli/state-cli

:::message alert
tfstate は手動で変更してはいけない。
:::

## tfstate の保存先

重要ファイルである tfstate（terraform.tfstate ファイル） の保存先としては大きく 2 通りある。

1. HCP Terraform を保存先に設定
   設定後は、git push をトリガーに、plan + apply できる。
   https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-remote
   https://developer.hashicorp.com/terraform/language/settings/cloud

上記のチュートリアルで作った HCP Terraform の project は[ここ](https://developer.hashicorp.com/terraform/language/settings/cloud)。

2. S3 などを backend として保存先に指定
   S3 のバージョニング機能を使うと、tfstate ファイルの削除対策ができる。

デフォルトでは local が backend として設定される。

# import

**TODO**: このチュートリアルやること。
https://developer.hashicorp.com/terraform/tutorials/cli/state-import

# HCP Terraform (旧 Terraform Cloud)

https://developer.hashicorp.com/terraform/cloud-docs

# Terraform Language

https://developer.hashicorp.com/terraform/language

## variable

動的に変えたい値を、外部から注入するために使う。

- type

  - string
  - number
  - bool
  - list []
  - map {}
  - set

- セット方法

  - CLI の`-var`オプション。
  - `terraform.tfvars` ファイル (or `*.auto.tfvars` に一致するファイル)に記載の変数は自動的に読み込まれる。
    CLI で`-var-file`オプションで他のファイルを名前で指定することもできる。
  - 環境変数`TF_VAR_{変数名}`を設定。

- 機密情報の場合は、`sensitive`属性を true に。

## locals

variable とは違い、静的な値を定義するために使う。
ただし、locals の値自体には variable を使って動的に変えることもできる。
（例：`name_suffix = "${var.project_name}-${var.environment}"`）

## output

- variable と同様、機密情報の場合は`sensitive`属性を true に。

## resource

これから作るリソース。
定義は、provider が提供している。

## data

既存のリソースを読み込む。
自分で勝手に定義できるものでなく、resource と同様、provider が提供しているもの。

## module

モジュール内で変数形式で受け取るように待機しておき、モジュールを呼び出す側から注入できる。
その変数というのは、モジュール側で variable として定義は必要。

#### モジュール

```tf:module/sqs/main.tf
resource "aws_sqs_queue" "terraform_queue" {
  name = var.name
  （略）
}
```

```tf:module/sqs/variables.tf
variable "name" {
  type = string
}
```

#### モジュールを使う側

```tf:main.tf
module "sqs" {
  source = "./module/sqs"
  name   = "terraform-test-sqs" // module内ではこの値がname変数として使われる
}
```
