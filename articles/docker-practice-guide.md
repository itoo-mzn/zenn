---
title: "「Docker実践ガイド」要点"
emoji: "🐳"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Docker"]
published: false
---

# 書籍
https://www.amazon.co.jp/dp/4295005525/ref=sspa_dk_detail_0?psc=1p13NParams&spLa=ZW5jcnlwdGVkUXVhbGlmaWVyPUE5SjNMNEpDMFMyTjkmZW5jcnlwdGVkSWQ9QTA1NzYzNTYzSFlBQVBGVzQ1UzBVJmVuY3J5cHRlZEFkSWQ9QTNKWFRISDFFSTJHMEkmd2lkZ2V0TmFtZT1zcF9kZXRhaWwmYWN0aW9uPWNsaWNrUmVkaXJlY3QmZG9Ob3RMb2dDbGljaz10cnVl

# 1章 Dockerとは?
## コンテナとは
ホストOA上で独立したプロセスとして実行されるアプリケーション環境。
アプリケーション本体や必要なライブラリ、設定ファイルなどの実行環境をパッケージ（ひとまとめに）したもの。それをOSの分離された空間で実行する技術。

（1つの）ホストOS上で、複数のOS環境（コンテナ）を動かせる。
ホストOSがLinuxの場合、そのディストリビューションのOS(CentOS, Ubuntu, Debianなど)なら使うことができる。

## Dockerイメージとは
Dockerコンテナの生成に必要なファイルシステム。
**複数のイメージレイヤー（image layer）によって構成されている**。
イメージの中身（イメージ・レイヤー）は、実行ファイル、ライブラリ、コンテナ起動時に実行するコマンドなど。
Dockerイメージをレジストリから入手して使うことで、1から開発環境を作るのでなく、すぐアプリケーションを利用できる。

##### 参考記事
https://qiita.com/zembutsu/items/24558f9d0d254e33088f

## 　Dockerの有用性
OS環境とアプリケーション の 入手・構築・利用・破棄 が素早く行える環境を提供している。
これは、イミュータブルインフラストラクチャに有用。

##### イミュータブルインフラストラクチャ
本番系と全く同じ構成・能力のインフラ（開発系）を用意しておき、本番を変更する場合はネットワークの接続先を開発系（→新本番系）に切り替える構成。
イミュータブル = 不変。すなわち「本番環境に手を加えない」ということ。

## 名前空間
名前空間（Linuxの機能の1つ）により、ホストOS上で、複数のコンテナによるマルチOS環境を作れる。

### pid名前空間の分離
各コンテナは別々の名前空間で動作しており、アクセスはその名前空間内に限定されている。
ホストOS目線では、各コンテナのプロセスが見えるが、個々の名前空間内（=コンテナ内）ではその中のアプリケーションのプロセスしか見えない。

＜例＞ 下表のように、コンテナ内では名前空間で閉じた形でPIDが割り当てられる。
| 稼働しているコンテナ | ホストOS上でのPID | コンテナ内でのPID |
| ---- | ---- | ---- |
| Webサーバーのhttpdサービスが稼働するコンテナ | 1000番 | 1番 |
| FTPサーバーのvsftpdサービスが稼働するコンテナ | 2000番 | 1番 |

### ファイルシステムの分離
