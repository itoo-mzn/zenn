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
| 記事No. | 分野 | 範囲 |
| --- | --- | --- |
| 02 | 分野 1 |  モニタリングとレポート 22% |
| 02 | - | その他 |
| 03 | 分野 2 | 高可用性 8% |
| 03 | 分野 3 | デプロイとプロビジョニング 14% |
| 04 | 分野 5 | セキュリティとコンプライアンス 18% |
| 04 | 分野 6 | ネットワーク 14% |
| 05 | 分野 4 | ストレージおよびデータの管理 12% |
| 05 | 分野 7 | 自動化と最適化 12% |

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
- [X] 5. Udemy(C)の問題を解く (No.1~4)
- [X] 6. (問題で分からない所がある場合)B.サービス別資料で復習+このノートに整理
- [x] サービス郡でドキュメント分ける
- [X] 7. 5と6が完了（1周目）
- [ ] 8. 5と6が完了（2周目）〜5/25
- [ ] 8. 5と6が完了（3周目）〜6/10
- [ ] 8. 5と6が完了（4周目）〜6/20　→本試験6/25あたり
- [ ] 8. 5と6が完了（5周目）無理っぽい

- B見る
  - CloudWatch
  - CloudTrail
  - Config
  - Systems Manager
  - Cognito


## Udemyの結果リスト
| 日付 | No. - n回目 | 正答率 | 備考 |
| --- | --- | --- | --- |
| 4/10 | 1-1 | 43% | 見直し〜4/18 |
| 4/18 | 2-1 | 52% | 見直し〜4/21 |
| 4/21 | 3-1 | 41% | 見直し〜4/25 |
| 4/25 | 4-1 | 46% | 見直し〜5/1, ネットワーク範囲の問題理解できてないので後で復習すること |
| 5/2 | 1-2 | 58% | 見直し〜5/5 (目標5/10)|
|  | 2-2 |  | 見直し〜 (目標5/15)|
|  | 3-2 |  | 見直し〜 (目標5/20)|
|  | 4-2 |  | 見直し〜 (目標5/25)|



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
