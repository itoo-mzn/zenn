---
title: "AWS SOA取得 計画"
emoji: "⏰"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["AWS","SOA"]
published: false
---
# 目標
6/27(日)までにAW SOAを取得する。
※ 1~2週間前には事前に受験予約すること。

## 割引
- **模試**無料クーポンがあるから使うこと！
- **本試験**半額クーポンがあるから使うこと！

# 勉強時間
## 目安
100〜150時間前後

## 確保する勉強時間
- 受験日（仮） : 6/13(日)
- 受験日までの日数 : 72日(4/2~)
  - 平日 : 50日ぐらい ✕ 2時間 = 100時間
  - 休日 : 20日ぐらい ✕ 5時間 = 100時間

# SOA-C02
実技試験を伴う。
7~9月の間にリリースされる。
今回は、過去の受験者の知見を活用したいので、**C01を受ける。**

# 出題範囲(SOA-C01)
分野 1: モニタリングとレポート 22%
分野 2: 高可用性 8%
分野 3: 展開とプロビジョニング 14%
分野 4: ストレージおよびデータの管理 12%
分野 5: セキュリティとコンプライアンス 18%
分野 6: ネットワーク 14%
分野 7: 自動化と最適化 12%

[公式試験ガイド](https://d1.awsstatic.com/ja_JP/training-and-certification/docs-sysops-associate/AWS-Certified-SysOps-Administrator-Associate_Exam-Guide.pdf)

# 教材
A. [AWS 認定 – 試験準備ワークショップ](https://www.aws.training/Details/Video?id=41299)
試験の攻略法を確認します
- 解答を選択する際の観点
- 問題の狙いを見極める方法
- アーキテクチャ設計の原則(超重要)

B.  [AWS サービス別資料(Black Belt)](https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-service-cut/)

C.  [AWS 認定SysOpsアドミニストレーター アソシエイト模擬試験問題集（全4回分260問）](https://www.udemy.com/course/aws-sysops-53195-q/)
全体的にとても難しく、感覚としては公式の試験で10問に1問出るぐらいの難易度の問題をひたすら集めたような問題集になっています。なのでAWSサービスを概念や各機能の目的などがちゃんと理解できないないと解けない問題ばかりで学習コストが結構重いです。

補足 : [これだけでOK！AWS認定ソリューションアーキテクト – アソシエイト試験突破講座（購入済）](https://www.udemy.com/course/aws-associate/learn/quiz/4628740#overview)

D. [AWS ハンズオン](https://aws.amazon.com/jp/aws-jp-introduction/aws-jp-webinar-hands-on/)

E. [AWS チュートリアル](https://aws.amazon.com/jp/getting-started/hands-on/?awsf.getting-started-category=*all)

# 勉強方法
- [x] 1. 出題範囲を確認
- [x] 2. [試験問題サンプル](https://d1.awsstatic.com/ja_JP/training-and-certification/docs-sysops-associate/AWS-Certified-SysOps-Administrator-Associate_Sample-Questions.pdf)を解く
- [x] 3. 試験準備ワークショップ(A)で抑えるべきサービスと原則を確認
- [x] 4. サービス別資料(B)を一読
- [ ] 5. Udemy(C)の問題を解く
- [ ] 6. (問題で分からない所がある場合)B.サービス別資料で復習+このノートに整理
- [ ] 7. 5と6が完了（1周目）
- [ ] 8. 5と6が完了（2周目）
- [ ] 8. 5と6が完了（3周目）
- [ ] 8. 5と6が完了（4周目）
- [ ] 8. 5と6が完了（5周目）

## Udemyの結果リスト
| 日付 | No. - n回目 | 点 | 備考 |
| --- | --- | --- | --- |
| 4/10 | 1-1 |  |  |
| 4/10 | 2-1 |  |  |
| 4/11 | 3-1 |  |  |
| 4/11 | 4-1 |  |  |


# 過去の受験者の感想
## <学習が特に必要な分野>
・セキュリティレポートの作成方法
・AWS Artifactとはなにか
・タグによるリソースの管理
・脆弱性チェックの深い理解
・IAMの組織アカウントに関する深い理解
・CLIのコマンド実行時のエラーへの対処方法(InsufficientErrorなど)

# BlackBelt
### 最重要
- service catalog
- WAF
- Organizations
- VPC

### 重要
- Powershell
- IAM2
- AWS support
- AWS Shield
  - Standard、Advanced、WAF、でそれぞれ何がブロック出来るのか、IDS、IPSとの使い分け
- AWS Artifact
  - 発行できるレポート
- EC2
  - トラブルシューティング(起動できない、insufficientエラー)、EC2Rescue
- RDS
  - メンテナンスが発生する対象、メンテナンス時の影響
- CLI
  - 各サービスを利用する為のCLIを色々と
- VPCフローログ
  - Logの見方



# 分野 1: モニタリングとレポート 22%

## Cloudwatch (重要)
  - 他サービスとの連携
  - CloudWatch events、alert機能の理解、データの流れの理解、メトリクス(カスタムメトリクス含む)　の仕組みと導入方法
  - 標準メトリクスが利用されるケースは？
  - カスタムメトリクスが利用されるケースは？
  　標準メトリクスでは収集できないメトリクス
  　→　具体的には？わからない
  - CloudWatch EventsによりSNS通知をトリガー(実行)できます。
### Cloudwatch Logs
logs特定のフレーズ、値、またはパターンを⾒つけるためにログをリアルタイムでモニタリングする

## Cloudtrail
証跡ログをとる。
  - ユースケース
  - Cloudwatch logs、CloudWatch eventsとの連携
  - API呼び出しの関する調査・記録の問題はcloudtrailが関連する可能性大。

## Config
AWS リソースの構成情報、変更履歴を記録
### マネージドルール
知らん。調べること
例：未承認の AMI から起動された EC2インスタンスを検知する


# 分野 2: 高可用性 8%

## Route53
DNS（＝ドメイン名とIPアドレスを変換（名前解決）するシステム）。
### レコード情報
### トラフィックルーティング

## CloudFront
CDN。
  - クライアントからオリジンまでのデータの流れ 、暗号化処理
## Elastic Load Balancing
  - ALB、ELB、NLBで出来る事出来ない事
  - ASG、EC2を含めたデータの流れ、Connection Draining、証明書を使ったデータの暗号化、X-Forwarded-For
### スティッキーセッション
　複数のEC2インスタンスを起動している場合、Cookie を使用してユーザーのリクエストを追跡し、後続のリクエストを同じインスタンスに送信し続ける機能。
　（どのインスタンスにリクエストするかわからないので、スティッキーセッションを設定しないと、ユーザは再ログイン（セッションの頻繁な切断）を頻繁に求められる。）
  
- EC2 AutoScaling

# 分野 3: デプロイとプロビジョニング 14%
## ElasticBeanstalk
## Opsworks
## Cloudformation(重要)
  - (変更セットやドリフト等、スタック管理の機能やテンプレートの理解(セクション、組み込み関数)

# 分野 4: ストレージおよびデータの管理 12%
## S3(重要)
- バージョン管理
  - バケットポリシー(JSON記述も理解)、4XX or5XX系のエラーに関するトラブルシューティング、マルチアップロード、S3通知機能、クロスオリジンリソース共有(CORS)
## EBS
## EFS

# 分野 5: セキュリティとコンプライアンス 18%
## IAM ※特に重要
### IAMロール
一時的にアクセスを許可。
  - 権利の委譲
  - **原則：アクセスキーよりIAMロール**
- Guard Duty
セキュリティの観点から脅威を検知
  - 仕様、ユースケース

# 分野 6: ネットワーク 14%
## VPC(IGW, NAT, VPCエンドポイント)
### VPCピアリング
2つのVPC間をセキュアに通信できる。
（例：異なるアカウントによって所有され、かつ別のリージョンのVPCで稼働されているインスタンス に、パブリックインターネットを通過せずにアクセスできる。）

- DirectConnect
- VPN

**原則：セキュリティグループは、許可のみ行う。**
**原則：ネットワークACLは、明示的な拒否を行う。**

# 分野 7: 自動化と最適化 12%
## Lambda

## TrustedAdvisor(重要)
AWS環境を分析し、最適化するためのベストプラクティスを提供。
### コスト最適化
使われていないリソース (= 無駄なコスト) を検出するほか、利用状況を分析して、コスト削減が期待できる割引プランをおすすめ。
- EC2 リザーブドインスタンスの最適化
- アイドル状態の Amazon RDS DB インスタンス
- 使用率の低い Amazon EC2 Instances
- 関連付けられていない Elastic IP Address
### パフォーマンス
パフォーマンス低下に繋がる使い方をしていないかどうかチェックするほか、もっと効率がよい AWS の機能を使う余地がある場合にお知らせ。
- Amazon EC2 から EBS スループット最適化
- EC2 インスタンスセキュリティグループルールの増大
- 使用率の高い Amazon EC2インスタンス
- 利用率が高すぎる Amazon EBS マグネティックボリューム
### セキュリティ
セキュリティリスクのある設定になっていないかどうかチェックするほか、現在よりもセキュリティを高められる推奨の設定があればおすすめ。
- セキュリティグループ - 開かれたポート
- AWS CloudTrail ロギング
- Amazon EBS パブリックスナップショット
- IAM アクセスキーローテーション
- ルートアカウントの MFA
- 公開されたアクセスキー
### フォールトトレランス
過去データから復旧できるようにバックアップを取得しているか、AWS の機能を活用して冗長構成を取れているか、などの点をチェックする。
- Load Balancer の最適化
- Amazon RDS Multi-AZ
- Amazon Route 53 フェイルオーバーリソースレコードセット
- AWS Direct Connect 接続の冗長性
- Amazon EBS スナップショット
### サービス制限
AWS サービス制限の一部 (39 項目) に対して、現在の利用状況と制限値を比較して差分をチェック。
- そもそもサービス制限とは: AWS は各サービスにおいて、ア
カウント毎に利用可能なリソース (EC2 インスタンス台数、
リージョンあたりの VPC 数など) に制限をかけている。

## コスト管理
  - Cost Exploler、Billing Manager、AWS 使用状況レポート、組織内にアカウント招待、削除の際の流れ
  - EC2 スポットブロック：スポットインスタンスを1~6時間継続して利用できることが担保された入札形式。

## Cost Explorer

## Systems Manager
サーバ群を管理する多機能なツールセットの総称。
（範囲が広すぎてどこまでが"AWS Systems Manager"というサービスの中に収めるべきなのかよくわからない）
  - パッチ適用、シークレットデータの格納

## StepFunctions
### ステートマシン
？
### ワークフロー
可視化のツール。