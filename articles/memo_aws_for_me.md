---
title: "AWSメモ"
emoji: "🐡"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["AWS"]
published: false
---

# 目的
AWSにおいて備忘録を残す。

---


# IAM

## アクセスキー
ルートユーザー or IAMユーザー の長期的な認証情報。
アクセスキーID + シークレットアクセスキー で構成される。
**アクセスキーを使うことで、外部からAWSのサービスへプログラムアクセスができる**。

## ポリシー
`IAMユーザ、IAMグループ、IAMロール`、`AWSリソース`に関連づけることによってアクセス許可を定義することができるオブジェクト。

ポリシーには色々な種類（ポリシータイプ）がある。
- アイデンティティベースのポリシー
  - 管理ポリシー
    - **AWS管理ポリシー**
      AWSにより事前定義された管理ポリシーで、編集不可。
      複数のIAMユーザー、IAMグループ、IAMロールに関連付けできる。
    - **カスタマー管理ポリシー**
      AWS管理ポリシーでは要件を満たせない場合等に、自分で定義するポリシー。
  - **インラインポリシー**
    1つのIAMエンティティ (IAMユーザー、IAMグループ、IAMロール)に直接埋め込まれるポリシー。
    インラインポリシーより、カスタマー管理ポリシーを使うことが推奨されている。（1つ1つのインラインポリシーを管理するのでなく、1つのカスタマー管理ポリシーで管理するほうが良いため。）
- リソースベースのポリシー
  - AWS IAMロールの信頼ポリシー、Amazon S3のバケットポリシー、Amazon SNSトピックのアクセス許可、Amazon SQSキューのアクセス許可
- パーミッションバウンダリー
  - AWS IAMアクセス許可の境界、AWS Organizationsサービスコントロールポリシー (SCP)
- **アクセスコントロールポリシー** (**ACL**)
  - Amazon S3のバケットのACL、Amazon VPCのサブネットのACL
- セッションポリシー

## IAMグループ
IAMユーザーの集合。
**IAMグループに関連付けられたIAMポリシーは所属するIAMユーザーに継承される**。

## IAMロール
**AWSリソースの操作権限を付与**するための仕組み。
**AWSサービスやアプリケーション等のエンティティに対して**、「**一時的なセキュリティ認証情報**」を渡す。
簡単に言うと、あるAWSサービス（リソース）に対してアタッチしたいIAMポリシーを1つにまとめたもの（集合、塊）。

:::message
#### 一時的なセキュリティ認証情報 (temporary security credentials)
有効期限付きのアクセスキーID + シークレットアクセスキー + セキュリティトークン で構成される。

#### AWS Security Token Service (STS)
一時的なセキュリティ認証情報を生成するサービス。

##### AssumeRole 
**STSで利用できるAPI Actionの1つ**。
**既存のIAMユーザーの認証情報を用いて、IAMロールの「一時的なセキュリティ認証情報」を取得する**。
:::

https://d1.awsstatic.com/webinars/jp/pdf/services/20190129_AWS-BlackBelt_IAM_Part1.pdf
https://d1.awsstatic.com/webinars/jp/pdf/services/20190130_AWS-BlackBelt_IAM_Part2.pdf
https://qiita.com/Batchi/items/a2dde3d2df27568cc078


---


# エッジサービス
AWSのエッジロケーションから提供されるサービス群。AWSサービスをユーザーに近い場所から提供。
（Route53やCloudFront、WAFなど）

# CloudFront
CDN (Content Delivery Network) サービス。
CDNとは、オリジンサーバーからウェブコンテンツのコピーを取得した複数の「キャッシュサーバー」が、オリジンサーバーの代理でウェブコンテンツを配信する仕組みのこと。
（キャッシュサーバーは世界中に配置されている。）
「オリジンサーバー」とは、オリジナルのウェブコンテンツが存在するサーバーのこと。

オリジンサーバーでなく、キャッシュサーバーからウェブコンテンツを配信できるようになる仕組みを実現しているのは、DNSの設定。
通常は、ウェブサーバーなどでは以下のようにDNSのAレコードを設定することでインターネットからアクセスできるようにしています。
`www.example.jp IN A 192.168.100.10`
これは「www.example.jpのウェブコンテンツを取得したい場合は、192.168.100.10というIPアドレス（インターネット上の住所）にアクセスして下さい」といった意味のDNSの設定です。

たいしてCDNでは、以下のようにDNSのCNAMEレコードを利用することによって、キャッシュサーバーへアクセスが向くように設定します。
`www.example.jp IN CNAME cache.exampe.com`
「www.example.jpのウェブコンテンツは、cache.exampe.comという名前のサーバー（キャッシュサーバー）からダウンロードできます」というのが、このDNSレコードの意味です。

#### ビヘイビア
URLパスごとのキャッシュ動作(Behavior)。


---


# VPC


https://aws.amazon.com/jp/premiumsupport/knowledge-center/public-load-balancer-private-ec2/




# セキュリティグループ
・Amazon EC2 インスタンスに適用可能なAWS標準のファイアウォール機能であり、EC2インスタンスへのアクセスを"許可"したり、トラフィックを"制御"することができます。

注意点
インバウンド：未設定の場合通信は全て遮断し、許可した通信のみを通過させます。 ＊デフォルトですべて拒否
アウトバウンド：自動的にデフォルトのセキュリティグループが適用されます。 ＊デフォルトですべて許可


---


# CodePipeline

## ステージとは？
CodePipelineでは監視やデプロイなど個々のアクションをステージと呼びます。ステージは全部で６種類あります。

ステージ名	処理内容	主な対象
source	監視対象を選ぶ	S3, ECR, CodeCommit, Github
build	イメージをビルドする	CodeBuild, Jenkins
test	イメージのテストを行う	CodeBuild, Jenkins
deploy	新しいサービスを始動する	CodeDeploy, S3, ECS
approval	手動で承認をすると次のステージに進める	手動
invoke	呼び出し	Lambda, Step Functions
CodePipelineでは上記のうちの2つ以上を設定する必要があります。

## ソースステージとは？
監視対象を選択するステージをソースステージと呼びます。上記のsourceにあたる部分です。

例えば、ソースステージにCodeCommitを選択すれば、指定のレポジトリのブランチで変更を検知した場合に、設定してある自動化プロセスが発火します。

## アーティファクトとは何か？
CodePipelneを設定する中で頻繁に出てくるワードに「アーティファクト」があります。

アーティファクトとはひとまとまりのデータのことです。（オブジェクトに似たイメージ）
artifact = 人工物。
ここでいうartifactは、（*人*ではないが、*隣人*に近い意味で）その前のステージ（工程）が作ったもの という風に理解した。

コードやイメージなど①受け取ったデータを、必要に応じて処理を施し、②次のステージに渡していくときに、これらのデータにそれぞれアーティファクト名をつけて、どのアーティファクトを渡すか指定します。

各ステージからみて、
①受け取ったアーティファクトを「入力アーティファクト」
②渡すアーティファクトを「出力アーティファクト」
と呼びます。


# CodeBuild
CodeBuildはソースコードを受け取り、それを仕様書（buildspec.ymlファイル）に基づいて、ビルド環境を構築しテストを行う。

# CodeDeploy
## AppSpec file
CodeDeploy があなたの EC2 インスタンス（EC2とは限らないが）に対して、Amazon S3 または GitHub にあるアプリケーションのリビジョンをどのようにインストールするか決定する、YAML フォーマットのファイルです。また同様に、デプロイの様々なライフサイクルイベントをフックして処理を実行するか決定します。


https://d1.awsstatic.com/webinars/jp/pdf/services/20201111_BlackBelt_AWS%20CodeStar_AWS_CodePipeline.pdf


---


# ELB

## リスナー
リスナーは設定したプロトコルとポートを使用して接続リクエストをチェックするプロセス。
最小1個のリスナーが必要になり、最大10個のリスナーまで設定できる。

## ターゲットとターゲットグループ
ターゲット：トラフィックを分散する対象。
ターゲットはAmazon EC2 インスタンス、コンテナ、IP アドレス、Lambda 関数、仮想アプライアンスなどがある。
ターゲットグループ：トラフィックを分散する複数のターゲットをグループ化したもの。

## ルール
定義したルールは、ロードバランサーが 1 つ以上のターゲットグループ内のターゲットにリクエストをルーティングする方法を決定する。
各ルールごと優先度·1 つ以上のアクション· 1 つ以上の条件で構成される。
各リスナーにはデフォルトのルールがあり、追加でルールを定義できる。

## ヘルスチェック
ターゲットとターゲットグループが問題なく起動できるように、定義された周期ごとにターゲットとターゲットグループの状態を確認する動作。


---


# Docker
https://d1.awsstatic.com/webinars/jp/pdf/services/202109_AWS_Black_Belt_Container142_Docker.pdf

## Docker のデータ管理
- デフォルトでは、コンテナ内で作成されたすべてのファイルは、書き込み可能な*コンテナレイヤー*に保存される。コンテナレイヤーは、コンテナの停⽌と共に無くなる。
- **Dockerボリューム**を使うことでデータの永続化が可能。

### Dockerボリューム
- **bind**マウント
  ホストの任意のディレクトリをマウント可能。
  （例: ホスト上のファイルを参照、依存させる場合）
- **volume** (推奨)
  ホスト（マシン）側のDockerの管理領域配下にディレクトリが⽣成される。( Linuxの場合 `/var/lib/docker/volumes/` )
  複数のコンテナ間のデータ共有も可能。
- tmpfs マウント
  メモリ領域を使⽤、データの*永続化は出来ない*。
  （例: 秘密情報など⼀時的な展開領域、⾼いIO処理）
- named pipes
  コンテナからDocker Engineにアクセスする時に使⽤。(Windowsのみ)

#### docker-compose.ymlでのvolume部分の書き方（抜粋）
```
volumes:
  - ./host_dir:/container_volume_dir
```

# ECS
https://d1.awsstatic.com/webinars/jp/pdf/services/202108_AWS_Black_Belt_Containers201-ECS.pdf
https://qiita.com/NewGyu/items/9597ed2eda763bd504d7
https://nishinatoshiharu.com/ecs-codedeploy/


## Fargate

### Fargate のメリット
Fargate利用により以下全てをAWS側にアウトソースできる。
- EC2 インスタンスのプロビジョニングや管理
  - 脆弱性対応のためのパッチ当てや OS アップグレード
  - EC2 インスタンス上で動くエージェント類のアップグレード
  - クラスタ内の EC2 インスタンス群それぞれの上で動くエージェント類やソフトウェアバージョンの整合性維持
  などなど…
- 状態異常が発生した EC2 インスタンスの再起動や入れ替え

https://d1.awsstatic.com/webinars/jp/pdf/services/202108_AWS_Black_Belt_Containers201-ECS.pdf
https://d1.awsstatic.com/webinars/jp/pdf/services/202108_AWS_Black_Belt_Containers202-ECSFargate.pdf
https://d1.awsstatic.com/webinars/jp/pdf/services/20190925_AWS-BlackBelt_AWSFargate.pdf



## ECSのログ

#### 「AWS ログ入門」のスライド
https://d1.awsstatic.com/webinars/jp/pdf/services/202109_AWS_Black_Belt-Container246_log.pdf

### < ログの目的 >
- 保管 : 障害時の調査に活用する。
- 分析 : 分析レポートの作成に活用する。
- 監視 : 異常を検知してアラートを投げるのに活用する。サービスの状態をダッシュボードで確認するのに活用する。

### < ECSのログドライバー >
:::message
#### ログドライバーとは 
そもそも、Dockerのログ処理は「コンテナで標準出力/標準エラー出力に吐かれたログを、設定してるログドライバが処理する」というもの。
https://zenn.dev/onigiri_w2/articles/e40c5873f7f453
:::

ECSのログドライバーには、下記が使用できる。
| ログドライバー | 説明 |
| - | - |
| **awslogs** | **CloudWatchLogs**の1つのログストリーム**に ログ（STDOUT）を保存できる**。 |
| fluentd | - |
| gelf | **Logstash**などの「Graylog Extended Log Format（GELF）」をサポートするログ管理システムにログメッセージを出力。 |
| **json-file** | JSON形式でファイルに保存（Dockerのデフォルト） |
| journald | - |
| logentries | - |
| splunk | - |
| syslog | - |
| **awsfirelens** | 下記。 |

### < AWS Firelens >
AWS ECSで使えるログルーター（特定のログを別のサービスなどに転送する機能）。

タスク定義の中に含めてサイドカー（firelensコンテナ）として配置。
他のコンテナ（例：Railsコンテナ）からはログドライバーとしてfirelensコンテナを使用する。
（つまり、Railsコンテナの`logDriver`は`awsfirelens`（firelensコンテナをログドライバーに指定）で、firelensコンテナの`logDriver`は`awslogs`とかにして、配信がコケたらCloudWatchLogsに記録。）

**FireLensそのものは**、Amazon ECSのコンテナログを同タスク定義内の**サイドカーとして配置されたFluentdまたはFluent Bitに転送することができる仕組み**。（つまり、ログ収集などの実働を行うのはFluentd or FluentBit。）
なので、**Firelensコンテナの中で動いているのはFluentd or FluentBit**。（Fluentd or FluentBitのイメージを使う。）
（ただ、もう[Fluentdは非推奨にする予定](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs.html)みたいなので、FluentBit一択の様子。）

:::message
#### Fluentd、FluentBitとは
- **Fluentd**
  データログ収集ツール。
- **Fluent Bit**
  Fluentdの軽量版。https://docs.fluentbit.io/manual/about/fluentd-and-fluent-bit
:::

AWS FireLensから下記のサービスに転送することができる。
  - Amazon CloudWatch Logs
  - Amazon Kinesis Data Streams
  - Amazon Kinesis Data Firehose
  - 別のFluentdやFluent Bit


コンテナ内にファイル出力されたログを取り扱うことは、AWSが用意しているFluent Bitイメージでは対応することができない

https://zenn.dev/knjname/articles/2dc6c5ca520006e1e0ee
https://engineering.dena.com/blog/2022/08/firelens/
https://dev.classmethod.jp/articles/ecs-firelens/
https://dev.classmethod.jp/articles/terraform-ecs-fargate-firelens-log-output/
https://dev.classmethod.jp/articles/fargate-fiirelens-fluentbit/
https://qiita.com/charon/items/727251f8ce1412a864ab
[https://twitter.com/integrated1453/status/1590341343821565953]

# Kinesis
ストリームデータを収集・処理するためのフルマネージドサービス。

種類は下記。
- Amazon Kinesis Data Streams
  ストリームデータを処理するためのアプリケーションを独自に構築。
  ストリームデータを**受ける**AWSサービス。
- Amazon Kinesis Data **Firehose**
  ストリームデータを**S3, Redshift, ESへ**簡単に配信。
  ストリームデータをS3やRedshiftなどに**送る**(流す)AWSサービス。
- Amazon Kinesis Data Analytics
  ストリームデータを標準的なSQLクエリでリアルタイムに分析。

https://d1.awsstatic.com/webinars/jp/pdf/services/20180110_AWS-BlackBelt-Kinesis.pdf


### ログ分析
AWS Athena


---


### ALB, ECS ポート設定
#### ALBについて
この記事が良かった。
https://qiita.com/yu-yama-sra/items/7ab3e6fdb2d3b73925d8

ターゲットグループに設定するポートというのは、ターゲット（ECS）に対するポート。

#### ECSについて
ホストポート：**ホスト**（**コンテナを利用する側**）のポート。
コンテナポート：（使われる側の）コンテナのポート。

```
docker run --rm -p 8080:80 ~~~
```
ローカルでコンテナを起動するとき、上記の場合は、`8080`がローカル（ホスト）のポートで、`80`がコンテナのポート。

:::message
#### ホストとは
いつも忘れる。いつもクライアント・ゲスト側と思い違いしてしまう。
https://wa3.i-3-i.info/diff389computer.html
:::

https://docs.docker.jp/engine/userguide/networking/default_network/binding.html


---


# AWS WAF

:::message
## WAF (Web Application Firewall)とは
ウェブアプリケーションの**通信内容を検査**し、**不正なアクセスを遮断するルールセット**を持つセキュリティ対策。
ウェブアプリケーションの脆弱性を悪用した攻撃などからウェブアプリケーションを保護することが目的。
（軽減するだけで、根本対策ではない。）
:::

AWS WAFでは、
1. 悪意のあるリクエストのブロック
2. カスタムルールに基づいたWebトラフィックのフィルタ
3. モニタリングとチューニング
ができる。

https://www.slideshare.net/AmazonWebServicesJapan/20171122-aws-blackbeltawswafowasptop10


以上