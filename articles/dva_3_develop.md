---
title: "分野3 AWSサービスを使用した開発"
emoji: "🛠"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["AWS","DVA"]
published: false
---

# S3
APIとベストプラクティスを理解することを推奨。
バケット
- リージョンを選択
- 一意のバケット名が必要。（全世界で）
署名付きURL
CORS

下記2つの違い
- S3 ACL：オブジェクトレベルorバケットレベルでアクセス許可を付与する。
- バケットポリシー：

# DynamoDB
NoSQLデータベース

データの整合性
- 結果整合性
- 強い整合性
を選択できる

プライマリキー
セカンダリインデックス
グローバルセカンダリインデックス

スループット
- 読み込みキャパシティユニット（RCU）
1RCU = 1秒あたり 4KB の 強力な整合性 のある読み込み 1回
1RCU = 1秒あたり 4KB の 結果整合性 のある読み込み 2回
- 書き込みキャパシティユニット（WCU）
1WCU = 1秒あたり 1KB(1,024B) の書き込み 1回

## DynamoDBストリーム
- 条件付き書き込みオペレーション
- バージョン番号を使用したオプティミスティックロック
- バッチオペレーション

## DAX(DynamoDB Accelerator)
キャッシュ

グローバルテーブル：データレプリケーション


# SNS, SQS, Step Functions
違い、類似点

SNS パブリッシュ/サブスクライブ=1:N
SQS 送信/受信=1:1

属性を知らないと解けない
VisibilityTimeout
RecieveMessageTimeSecoundsなど

# API Gateway
APIを作成するフルマネージメントサービス
書き3つに使用可能
- EC2
- Lambda
- パブリックにアドレス指定できるWebサービス

キャッシュ機能もある

# CloudFront, ElastiCache
キャッシュ戦略の違い

CloudFront : CDN
- 署名付きURL
- 署名付きCookie

ElastiCache : Redis, Memcached

# ECS, ECR, EKS, Fargate

# 開発ツールとSDK
- SDK
- IDEツールキット: AWS Cloud9もある
- コマンドライン
