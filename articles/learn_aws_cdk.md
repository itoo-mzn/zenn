---
title: "AWS CDK"
emoji: "🐙"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

# AWS CDKとは
AWS Cloud Development Kit (AWS CDK)

AWSのリソースをTypescriptやPython等のコードで定義するフレームワーク。
コードで定義したリソースがCloudFormationテンプレートに変換され、デプロイされる。

CDK の対応言語は以下の５つです。(2020年5月現在)
- Typescript
- JavaScript
- Python
- Java
- C#

# 手順

## 参考資料
基本的には、公式のチュートリアルを参考にする。
https://cdkworkshop.com/15-prerequisites/200-account.html

随時、下記も確認。
https://dev.classmethod.jp/articles/aws-cdk-101-typescript/

## IAMユーザーを作成
1. 管理者ユーザでAWSアカウントにサインイン
2. IAMコンソールに移動して 新しいユーザーを作成
3. ユーザーの名前を入力（cdk-workshop）
4. 権限を設定。(既存のポリシーを直接添付する → AdministratorAccess)
5. 資格情報を設定(profile名もcdk-workshopにした)
```
aws configure --profile cdk-workshop

AWS Access Key ID [None]: <type key ID here>
AWS Secret Access Key [None]: <type access key>
Default region name [None]: <choose region (ap-notrheast-3 = 大阪にしてみた)>
Default output format [None]: <leave blank>
```
profileが追加されているか確認(AWS CLIのprofileを確認)
```
cat ~/.aws/credentials
```

## 前提環境確認
nodeは10.13.0以上でないといけない。
```
node --version
v16.3.0
```

Typesctiptを使えるか。
```
tsc --v
Version 4.3.5
```

cdkコマンドが使えるか。
```
cdk --version
1.117.0 (build 0047c98)
```

ディレクトリ作成。(cdk-sample)
```
mkdir cdk-sample
```

## 初期化
雛形を作成。
```
cdk init --language typescript
```




