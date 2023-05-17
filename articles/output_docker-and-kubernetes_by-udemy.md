---
title: "Docker + Kubernetes"
emoji: "🐳"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Docker", "Kubernetes"]
published: false
---

# 教材
Udemy　「Docker + Kubernetes で構築する Webアプリケーション 実践講座」
https://www.udemy.com/course/web-application-with-docker-kubernetes/

**参考文献**
https://qiita.com/Kta-M/items/ce475c0063d3d3f36d5d#pod
https://thinkit.co.jp/series/7342

# 目的
- Dockerの習熟度UP
- Kubernetes技術の新規習得

# 内容・要点

## Docker
:::message
個人的に、Dockerについては学習経験あるため、改めて理解したこと及び初めて知ったことのみを記載。
:::
### 用語
- デーモン：コントローラ（ユーザとのインターフェース）
- イメージ：実行環境の定義（設計図）
- コンテナ：実行環境（実態）
### コンテナと仮想マシンの違い
結論：カーネルを共有しているかどうか。
- 仮想マシン : 仮想マシンごとにカーネルを持つ。（ホストOSのカーネルを使わない。）
- コンテナ : ホストOSのカーネルを使う。
### コマンド
- コンテナ実行 : イメージが手元に無ければダウンロードし、有ればそのイメージを使って、コンテナ実行する。
```
docker run -d nginx:1.17.2-alpine  # 例
```
- DockerHubへログイン
```
docker login -u ユーザ名 -p パスワード
```
### Dockerfile
- COPY : ホスト側からファイルを転送する。
- ENTRYPOINT : デフォルト実行、初期化処理。
- CMD : メインとなるコマンド。
### イメージにつけるタグ名の命名規則
`ユーザ名 / イメージ名 : タグ`

---
## Kubernetes
### 概要
コンテナオーケストレーション = 大量のコンテナをデプロイ、管理していく仕組み。

kubectlコマンドを実行すると、それを受けたmaster nodeからworker nodeに対して司令を与える。(node = 実サーバー)
- worker node：処理を実行する。
- master node：worker nodeを管理する。


### リソース
![](https://storage.googleapis.com/zenn-user-upload/gufly7ucf2my7d4yhq5laaklj2xd)

#### Pod
Kubernetesの最小デプロイ単位で、コンテナ（+ストレージボリューム）の集合。
#### ReplicaSet
同じ仕様のPodが指定した数だけ存在するようスケール（生成・管理）する。
#### Deployment
新しいバージョンを反映させるときのデプロイ方法を指定する。
- Recreate : 一度ReplicaSet（Pod郡）を削除してから、ReplicaSetを新規作成。（ダウンタイムが発生する）
- RollingUpdate : Pod数を減らしていい数、増やしていい数を定義し、それに準じて1つずつ新しいバージョンのPodと置き換える。

#### Service
内部のネットワーク（名前解決）を定義。L4ロードバランサーの役割を果たす。
#### Ingress
外部のネットワークを定義。L7ロードバランサーの役割を果たす。

#### ConfigMap
環境変数などの設定情報を定義。
#### Secret
秘密情報を定義。

#### PersistentVolume(PV)
ストレージの実体（物理的）。
ボリュームを提供する外部システムと連携して、ボリュームの新規作成や既存のボリュームの削除などを行うことが可能。（AWSならNodeのEC2が持つEBS）
#### PersistentVolumeClaim(PVC)
PersistentVolumeを要求する側。必要な容量を動的に確保。
ストレージを論理的に抽象化したリソース。

### ネットワーク
リソース(Pod等)は、各worker nodeに分散配置される。

Kubernetes内には2つのネットワークが存在する。
- 外部ネットワーク
- クラスタネットワーク
クラスタネットワークには、外部からアクセスできない。
Podへアクセスする方法は下記3種類。
  1. 直接Podへアクセスする。
  2. 他のPod経由でアクセスする。
  3. サービスからアクセスする。

![](https://storage.googleapis.com/zenn-user-upload/li3wvv0q7kyl6xguva77c8x57cf7)

### リソース構築
#### リソース作成
リソースを作成するには、リソースをマニフェストファイルで定義し、それを適用するコマンドを実行する。
1. マニフェストファイル作成
```
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  containers:
    - name: debug
      image: centos:7
      command: ["sh", "-c"]
      args: ["while true; do sleep ${DELAY}; done;"]
      env:
        - name: "DELAY"
          value: "5"
```
2. リソース作成
```
kubectl apply -f FILE
```

#### リソース確認
```
kubectl get TYPE   # TYPE: podなど
```

#### リソース削除
```
kubectl delete TYPE/NAME
```

#### Podに入ってコマンド実行
```
kubectl exec -it NAME sh
```


#### Pod⇔ホスト間のファイル転送
```
kubectl cp SRC DEST
```

#### ログ確認
```
kubectl describe TYPE/NAME
kubectl logs TYPE/NAME
```


# 結果
- 教材としては、Kubernetesの基本を知る + 実際に手を動かして試す という内容であり、内容の基本は押さえることができた。
- Kubernetesはdocker-composeと似ていると感じたが、その違いがわからなかく、教材の中で解説がなかったため調べた。docker-composeは命令的（例：普通の蕎麦）にリソースを作成するのに対し、Kubernetesは宣言的（例：わんこそば）にリソースを作成・監視するものだと理解した。
- Kubernetesの全体的な仕組み・各要素を理解するので精一杯であり、使いこなすためには更に深い理解・経験が必要と感じた。（まだ入り口感がすごい。奥が深いと感じる。）その分、使いこなせるようになると幅広く、柔軟に実行環境を構成できると思うので、この機会をきっかけに少しずつ勉強していこうと思う。
- ネットワーク、ボリュームに対しての理解がまだ低いと感じた。
- 学習の前工程でVirtualBoxを使ったことで、Docker(コンテナ)とのレイヤー違いを理解できた。