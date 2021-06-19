---
title: "AWS SOA セキュリティとコンプライアンス / ネットワーク"
emoji: "🔑"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["AWS","SOA"]
published: false
---

# 分野 5: セキュリティとコンプライアンス 18%

## IAM ※特に重要
### IAMロール
リソース(A)に対して、一時的にリソース(B)へのアクセスを許可。（IAMユーザの、対象が人じゃないバージョン。）
  - 権利の委譲
  - **原則：アクセスキーよりIAMロール**
### IAMポリシー
IDやリソースに関連付けてアクセス許可を定義。
- IDベースのポリシー
  **IAMユーザー、グループ、ロール**にアタッチ。
  そのアイデンティティが実行できる内容 (そのアクセス許可) を指定できる。
  「何に対して、何を実行できるか」(誰は ＝ self)
- リソースベースのポリシー
  **リソース**にアタッチ。
  特定のIAMユーザーやアカウントに対するアクセスを制御できる。たとえば、バケットポリシーをS3バケットにアタッチして、アクセスするIAMユーザーを限定することができる。
  「誰は、何を実行できるか」(何に ＝ 基本は、self)
### 信頼ポリシー, アクセス許可ポリシー
わかりやすく説明できないので、次のケース例で説明。
- ケース
  自社でAWSアカウントを「開発用」「本番用」の二つ持っている。
  開発者(IAMユーザー)は開発用アカウントに所属して作業を行っているが、必要に応じて本番用アカウントの S3 バケット にアクセスしたい。
- フロー
  1. 「本番用アカウントの管理者」が「開発用アカウントへの信頼ポリシー」を定義したロールを作成し、 ロールのアクセス許可ポリシーで「S3 バケットに対するユーザーの読み取りと書き込みのアクセス」を指定する。
  2. 「開発用アカウントの管理者」が「開発用アカウント内の開発者グループのメンバー」に対して、1のロールに切り替えるアクセス許可を付与する
  3. 「開発用アカウント内の開発者グループのユーザー」がロールの切り替えをリクエストして、一時的に認証される
  4. 3のユーザーが、ロールを使用して本番用アカウントの S3 バケット にアクセスする
  5. 3のユーザーがロールの使用を終了し、元のユーザーアクセス権限に戻る
#### 信頼ポリシー
IAMロールにアタッチされる。設定した対象に、操作を許可する。
#### アクセス許可ポリシー
IAMユーザーにアタッチされる。
一時的に、何かのリソースに特別にアクセスできる。
### サービスコントロールポリシー (SCP) 
組織を管理するために使用できるポリシーのタイプ。
リソースのアクセス権限を組織単位でコントロールすることに利用。（ユーザー単位ではない）

SCPをOU(組織単位)にアタッチする(ガードレールを敷く) + IAMポリシーを付与(実際に権限を与える)  
→  IAMユーザーの操作権限は、SCPとIAMの両方で許可されている場合に対象リソースの実行が可能。
つまり、**両方で 明示的に許可され かつ 明示的に拒否されていない** 場合に許可される。
##### 例
- SCP：EC2とRDSの全ての操作権限が許可
- IAMポリシー：EC2の削除権限のみをDeny、その他のEC2操作をAllow
→ 両方が明示されている「EC2インスタンスの削除 以外の操作」が実施できる。
### パワーユーザー
管理者権限以外のあらゆるAWSリソースに対する権限を有したユーザー。
（フルアクセスは、管理者権限も持つ。）
### AWS CLIを操作するために必要な情報
- アクセスキー
- シークレットアクセスキー
- リージョン
### 認証情報レポート (IAMコンソール)
  アカウントのすべてのユーザーと、ユーザーの各種認証情報 (パスワード、アクセスキー、MFA デバイスなど) のステータスが記載されているレポートを取得できる。

## Certificate Manager(ACM) 
- **ACMがサポートされていないリージョンでは、IAM を Certificate Manager として使用する必要がある**。
- IAM APIを使用して証明書を取得するには、get-server-certificateコマンドを使用して、証明書のARNを取得。
- 取得した証明書をELBに設定するためには、set-load-balancer-listener-ssl-certificateコマンドを使用して証明書を設定。
- ACMは**期限切れ前に自動的に証明書を更新する**。
- ACMは**ELBと統合して、ロードバランサーに証明書をデプロイできる**。

-----

## AWS Shield
マネージド型の**分散サービス妨害(DDoS)を防御**するAWSサービス。

**<注> SQLインジェクション、クロスサイトスクリプティング（XSS）、DDoS攻撃への対応としては、AWS Shield とWAFによる対応が不可欠。**
- スタンダード
  無料。通常、Cloudfrontなどを利用すると自動で適用される。
- アドバンスト
  アプリケーションを標的とした攻撃に対する高レベルな保護。**リアルタイムのモニタリング**が必要な場合に使用。

## WAF
ウェブエクスプロイトからウェブアプリケーションを保護するために役立つファイアウォール。
ルールを設定してルールがマッチしたアクセスを遮断する機能。（*監視はできない。*）
- 守れるもの
　・SQLインジェクション攻撃
　・クロスサイトスクリプティング攻撃
　・OSコマンドインジェクション攻撃
　・DDoS攻撃

AWS **WAFはOSI参照モデルの7層**で行われるDDos攻撃を緩和できますが、
AWS **Shieldは3層および4層**で行われるDDos攻撃からWebサービスを防御します。

## インポートキーペア
利用している**キーペアの複製を別リージョンに移行**することで、既存キーペアを利用できる。
（AMIを新しいリージョンにコピーしてインスタンスを作成すると、別のリージョンで作成した既存のキーペアを選択することができません。そのため、基本的には新しいリージョンでは新規キーペアを作成することになります。しかしながら、現在のリージョンで利用しているPEMキーを共有したいという場合は、**PEMキーを別リージョンにインポートすることができます**。）

-----

## 暗号化
- サーバサイド暗号化：オブジェクトを保管時に暗号化する場合。
### CSE (Client Side Encryption)
クライアント内で暗合化したオブジェクトをS3に登録して、暗号化キーの生成と管理はクライアント側で実行します。
### SSE-C (サーバサイド)
AWS側の暗号化キーではなく、ユーザが作成・管理する暗号化キーによって暗号化を実行。
### SSE-S3 (サーバサイド)
AWS S3で管理された暗号化キーによるサーバーサイド暗号化。
### AWS KMS
  AWSサービスとしてキーの作成と管理をマネージド型サービスで提供。
#### KMS キーポリシー
  KMSの発行する**カスタマーマスターキーにアクセスできるユーザーを管理・変更**できる。
### AWS CloudHSM
  **大規模システム用**。**KMSではダメな、特殊な場合**に使う。
### NGなパターン
- 暗号化キーを、暗号化されたデータと一緒に保存。（一方が侵害された場合のセキュリティリスクが高い）
- 外部ハードウェアデバイスに暗号化キーを保存。（そのハードウェアが侵害された場合）

-----

## Guard Duty (検知)
セキュリティの観点から、VPCフローログなどのトラフィックデータを機械学習などを利用して自動で解析して、不正なアクセスを**検知**。(トラフィック制御はできない)
- **機械学習を利用した不正検知**が可能です。 
- **VPCフローログを解析**できます。 
- **IPアドレスやドメインリストを解析**できます。 

## Inspector (評価)
⾃動**セキュリティ診断**サービス。
対象が**EC2インスタンスのみ**。（AWSの他のリソースを評価することができない）

-----

## Artifact
AWSとの**契約やコンプライアンス**などに関わる情報を一元管理することができるサービス。**監査**対応。(CodeArtifact は全く関係ない)
1. レポート機能
ISO認定、PCI(Payment Card Industry)、SOCレポートなどの **AWSセキュリティ・コンプライアンスドキュメント**をダウンロードできる。
2. 契約に関する機能
AWSとの契約を確認・管理。複数のアカウントに紐づく契約を管理。

-----

## [認証, 認可の前提知識]
### Single Sign-On(SSO)
１つのアカウントで複数のクライアントを利用する仕組み。
（例: 別のサービスでログインすれば、連携している他のサービスにもログインできる。）
### SSOを実現するための方法
1. ケルベロス認証方式: ケルベロス認証を利用する
2. エージェント方式: 認証を代行する「エージェント」モジュールを組み込む
3. リバースプロキシ方式: リバースプロキシサーバー + エージェント型
4. フェデレーション方式: ユーザ認証結果を他の認証基盤に渡す（ID フェデレーション = ID認証）
  
  4.1. **Open ID Connector**(ウェブIDフェデレーション)
    Webアプリケーション等を公開するときに、いちいち1ユーザ当たりにそれぞれIAMユーザを払い出したくない場合。(Google・Facebook等)
    → **AWS Cognito, AWS STS**

  4.2. **SAML2.0**
    異なるドメイン間でユーザー認証を行うための XMLをベースにした標準規格。
    オンプレミス等でID管理サーバが**SAML2.0**に対応している場合
    → **AWS Cognito, AWS SSO**

  4.3. **AD Connector**
    **Active Directoryドメイン**とAWSのIAMによるユーザー管理を連携できます。
    その上で、**シングルサインオンを有効にする**ことで、AWSマネジメントコンソールとAWSコマンドラインインターフェイス（CLI）への**SSO**を設定できます。
    オンプレミス等で**ActiveDirectory**を使用している場合。
    → **AD Connector** (すでにActiveDirectoryを使用している場合はCognitoは使わず、AD Connectorを使う。)

## AWS Cognito
ユーザ認証を提供。
下記2種のIDプロバイダーを使用したサインインをサポート。
- ソーシャルIDプロバイダー（Facebook、Google、Amazonなど）
- SAML 2.0 によるエンタープライズIDプロバイダー
## AWS STS(Security Token Service)
一時的なセキュリティ認証情報を生成するサービス。
STSによる一時認証方式 : ウェブID フェデレーション

## AWS Single Sign-On (SSO) 
**社員に対する認証向け。(SAML対応)**
複数のAWSアカウントやアプリケーションへのSSOアクセスを簡単に一元管理できるクラウドSSOサービス。
これにより、ユーザーはAWS SSOで構成する資格情報か既存の社内認証情報を使用してユーザーポータルにサインインし、割り当てられたすべてのアカウントとアプリケーションに1か所からアクセスできます。
AWS SSOでは、OrganizationsのすべてのアカウントへのSSOアクセスとユーザーアクセス権限の一元管理が簡単になります。
また、SSOアプリケーション設定ウィザードを使用することで、SAML 2.0 の統合を作成し、SSOアクセスを任意のSAML対応アプリケーションに拡張できます。
社内の既存の Microsoft Active Directory (AD)のIDを使用して、アカウントとアプリケーションへのSSOアクセスを管理できます。
AWS SSOはAWS Directory Serviceを通じてADと統合されるため、ユーザーを該当するADグループに追加するだけでアカウントとアプリケーションへのSSOアクセスをユーザーに許可できます。

-----

## Well-Architected Frameworkで提唱されている5つの設計原則
1. Reliability：回復性の高いアーキテクチャを設計する
2. Performance Efficiency：パフォーマンスに優れたアーキテクチャを定義する 
3. Security：セキュアなアプリケーションおよびアーキテクチャを規定する 
4. Cost Optimization：コスト最適なアーキテクチャを設計する。
5. Operational Excellence：オペレーショナルエクセレンスを備えたアーキテクチャを定義する。

## セキュリティに関する 設計原則とベストプラクティス
### 7つの設計原則
1. 強固な認証基盤の整備
2. 追跡可能性の実現
3. 全レイヤーへのセキュリティ適用
4. セキュリティのベストプラクティス自動化
5. 転送中および保管中のデータの保護
6. データに人を近づけない
7. セキュリティイベントに対する準備
### 5つのベストプラクティス
1. アイデンティティとアクセス管理
2. 発見的統制
3. インフラストラクチャ保護
4. DDos攻撃を緩データ保護
5. インシデント対応

-----

## 責任共有モデル
### AWS責任
- ハードウェアの物理的セキュリティ
- ネットワークインフラストラクチャ
  データセンターとリージョンを接続するAWSグローバルネットワークを流れるすべてのデータは、安全性が保証された施設から外部に通信される前に物理レイヤーで自動的に暗号化される。
- 仮想化インフラストラクチャのセキュリティ
  AWS側のインフラ環境は仮想化ソフトウェアでフィルタリングすることにより、ユーザーからはユーザーに割り当てられていない物理ホストまたはインスタンスにアクセスできない。
- インフラのパッチ対応・管理
  AWSはインフラストラクチャへのバッチ管理やマネージド型サービスへのバッチ適用を担当する。
- インフラ構成管理
  AWSはデータセンターにおけるインフラを管理する。
- データの所有権
  ユーザーが配置したAWSクラウド内のデータの所有権はユーザーが保持。（= AWSはユーザーの管理するデータにアクセスしない）
### ユーザ責任
- VPCネットワーク内の暗号化やセキュリティ対応
- 保管中のデータのセキュリティ


# 分野 6: ネットワーク 14%

**原則：セキュリティグループは、許可のみ行う。ステートフル**  
**原則：ネットワークACLは、明示的な拒否を行う。ステートレス**
特定のポートを介した特定のIPアドレスからの攻撃に対しては、*ネットワークACL*で防御。

## VPC
- **IPv6 CIDRブロックのサイズ(/56)は固定**。(独自のIPv6アドレス範囲を指定できない)
### VPCピアリング
2つのVPC間をセキュアに通信できる。
（例：異なるアカウントによって所有され、かつ別のリージョンのVPCで稼働されているインスタンス に、パブリックインターネットを通過せずにアクセスできる。）
### ネットワークACL
- 一時ポート(エフェメラルポート)使用時のアウトバウンド設定
  アウトバウンドのポート範囲**1024〜65535** を開放する。
  そうすることで、クライアントがサーバーに接続すると、一時ポート範囲（1024〜65535）からのランダムポートがクライアントのソースポートになる。
### VPCエンドポイント
VPC外のサービス(S3、DynamoDB)と接続する場合に使用。
### インターネットゲートウェイ
インターネットゲートウェイをサブネットに関連づけるとそれはパブリックに、インターネットに通信できる。（パブリックIPも必要）
### NATゲートウェイ
プライベートサブネットからセキュアにインターネットへ通信するために、パブリックサブネットに配置するもの。
設定は、**プライベートサブネットのEC2インスタンスのアウトバウンドを、NATゲートウェイに送信する**ようにする。
### Egress-only Gateway (Egress-onlyゲートウェイ)
**IPv6**を使用してインターネットに出たいときに使用するもの。(IPv6とくればコレ)
しかし、インターネットへのEgress(送信)のみでIngress(受信)はできません。
（NATゲートウェイのIPv6バージョンのようなもの。）
### AWS上のリソースに外部ネットワークへの接続を提供するもの
- インターネットゲートウェイ(IGW)
- 仮想プライベートゲートウェイ(VGW) **<オンプレに繋げる>**
  - DirectConnect
  - VPN
    - AWSのVPN接続には、デフォルトで**2つのVPNトンネル**が利用される。これは最初のVPNトンネルに障害が発生した場合やメンテナンスにより停止している場合などに自動的に2番目のVPNトンネルにフェイルオーバーするように設定されている。 
    - **VPNゲートウェイとカスタマーゲートウェイの作成が必要**。
### セカンダリーENI
  フェールオーバー時にセカンダリーENIへと移行させることで、IPアドレスの切り替えが可能。
  ENIにセカンダリープライベートIPアドレスを割り当てる。
  (Elastic Network Interface = 仮想ネットワークカード(NIC))
### ルートのブラックホール状態(現象)
ルートのターゲットが利用できない状態。
**ルートテーブルに設定したインターネットゲートウェイやNATゲートウェイを削除**すると発生。
### サブネット同士が通信できない場合
次の順番で確認する。
1. インスタンスが正常に動作しているか確認する
2. ネットワークACLで許可されているか確認する
3. VPCフローログが有効な場合はログをチェックする
### VPC間でping出来ない場合
- ping : UDP(ICMP)
セキュリティグループで許可しているか
ネットワークACLで許可しているか