---
title: "分野1 デプロイ"
emoji: "⛴"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["AWS","DVA"]
published: false
---
# コードサービス
| 工程 | 内容 | 対応サービス |
| ---- | ---- | ---- |
| 1. ソース | ソースコードのチェックイン、コードレビュー | CodeCommit |
| 2. ビルド | コンパイル、単体テスト、コードメトリクス、コンテナイメージ作成 | CodeBuild |
| 3. テスト | 他システムとの統合テスト、負荷テスト、UIテスト | - |
| 4. デプロイ | 本番環境へのデプロイ | CodeDeploy |
| 5. モニタリング | - | X-Ray, CloudWatch |
| 1~4.  | - | CodePipeline |

### CI, CDの定義
CI = 1. ソース　〜　2. ビルド
CD = 1. ソース　〜　4. デプロイ

## デプロイに関する一般的なパターン
1. 複数のAZと複数のリージョン
2. ヘルスチェックとフェイルオーバーメカニズム
3. ステートレスアプリケーション：セッション状態はセッションサーバーorDBに保存

# デプロイ
ElasticBeanstalk
アプリケーション実行環境の自動構築

OpsWork
インフラストラクチャを管理する

CloudFormation
インフラストラクチャを定義する

# CloudFormation
## テンプレート
- 作成するリソースをJSON or YAML形式で定義する
- スタックの設計図

### テンプレートのセクション
TmpleteFormatVersion (任意)
Description：説明(任意)
Metadata (任意)
Parameters (任意)
Mappings (任意)
Resources：リソース(必須)
Outputs (任意)


## スタック
- テンプレートから作成できる
- スタック更新の進行状況をモニタリングする。失敗した場合、スタック全体がロールバックされる

## 要素
組み込み関数
疑似パラメータ
カスタムリソース
条件式

# サーバレス
サーバのことを考えなくて済む。(AWS管理)
通常、「Lamda」と他のAWSサービスを組み合わせる。

サーバーレスプラットフォーム
- コンピューティング：Lambda
実行時間中のみ課金される
- APIプロキシ：API Gateway
- ストレージ：S3
- DB：DynamoDB
- メッセージング：SNS, SQS
- オーケストレーション：Step Functions
- 分析：Kinesis, Athena
- 開発者用ツール：ツール

## SAM（サーバーレスアプリケーションモデル）
サーバーレスに最適化された、CloudFormationの拡張機能