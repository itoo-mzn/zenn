---
title: "AWS DVA取得に向けて"
emoji: "⏰"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["AWS","DVA"]
published: false
---

# 目標
6/27(日)までにAW DVAを取得する。
※ 1~2週間前には事前に受験予約すること。

# 勉強時間
## 目安
100〜150時間前後

## 確保する勉強時間
- 受験日（仮） : 6/13(日)
- 受験日までの日数 : 72日(4/2~)
  - 平日 : 50日ぐらい ✕ 2時間 = 100時間
  - 休日 : 20日ぐらい ✕ 5時間 = 100時間

# 出題範囲
| 分野| 比重 |
| ---- | ---- |
|1. デプロイ（展開） |22%|
|2. セキュリティ |26%|
|3. AWSサービスを使用した開発 |30%|
|4. リファクタリング |10%|
|5. モニタリングとトラブルシューティング|12%|

[公式試験ガイド](https://d1.awsstatic.com/ja_JP/training-and-certification/docs-dev-associate/AWS-Certified-Developer-Associate_Exam-Guide.pdf)

# 教材
A. [AWS 認定 – 試験準備ワークショップ](https://www.aws.training/Details/eLearning?id=62521)
試験の攻略法を確認します
- 解答を選択する際の観点
- 問題の狙いを見極める方法
- アーキテクチャ設計の原則(超重要)

B.  [AWS サービス別資料(Black Belt)](https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-service-cut/)

C.  [AWS 認定デベロッパー アソシエイト模擬試験問題集（5回分325問）](https://www.udemy.com/course/aws-31955/)
全体的にとても難しく、感覚としては公式の試験で10問に1問出るぐらいの難易度の問題をひたすら集めたような問題集になっています。なのでAWSサービスを概念や各機能の目的などがちゃんと理解できないないと解けない問題ばかりで学習コストが結構重いです。

補足 : [これだけでOK！AWS認定ソリューションアーキテクト – アソシエイト試験突破講座（購入済）](https://www.udemy.com/course/aws-associate/learn/quiz/4628740#overview)

# 勉強方法
1. 出題範囲を確認
2. [試験問題サンプル](https://d1.awsstatic.com/ja_JP/training-and-certification/docs-dev-associate/AWS-Certified-Developer-Associate_Sample-Questions.pdf)を解く
3. 試験準備ワークショップで抑えるべきサービスと原則を確認
4. サービス別資料を一読
5. Udemyの問題を解く
6. (問題で分からない所がある場合)サービス別資料で復習

- サービス別資料（優先順）
<!-- ・Lambda -->
<!-- ・API Gateway -->
<!-- ・Codeシリーズ -->
<!-- ・ECS、ECR、Fargate -->
<!-- ・DynamoDB -->
<!-- ・ElastiCache -->
・Cognito
<!-- ・AWS Elastic Beanstalk -->
<!-- ・X-ray -->
<!-- ・SQS -->
・Kinesis シリーズ
<!-- ・Serverless Application Model(SAM) -->
・Serverless モニタリング
・実践的 Serverless セキュリティプラクティス
<!-- ・AWS CloudFormation -->
・AWS CloudTrail & AWS Config
・AWS OpsWorks
<!-- ・AWS Key Management Service -->
<!-- ・SNS -->
<!-- ・AWS Step Functions -->
<!-- ・CloudWatch -->
<!-- ・CloudFront -->
<!-- ・AWS Secrets Manager -->
・AWS AppSync
<!-- S3 -->
<!-- STS(Security Token Service) -->
<!-- IAM -->

# Tips
## 出題範囲
- とにかくLambda、API Gateway、Codeシリーズからの出題が多かったです。後は、Dynamo DB、ElastiCache、Cognito辺りでしょうか。

## 役立った原則
- スケールアップよりもスケールアウト
- アンマネージドサービスよりもマネージド
- リソースや API を直接公開する事は避け、AWS エッジサービスや API ゲートウェイを使用する
- サーバーにセッション状態を保存していては優れたアーキテクチャにはならない
- インフラストラクチャを疎結合化する
- サーバーレス化する