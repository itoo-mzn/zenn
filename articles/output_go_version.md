---
title: "Goのバージョン管理"
emoji: "🌟"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: true
---

# 概要

Go バージョンの管理についての備忘録です。
（過去には goenv を使っていましたが、Go で推奨されている方法へ移行しました。）

https://go.dev/doc/manage-install

# バージョン up 方法

今回は、1.22.5 → 1.23.0 へバージョン up します。

#### 1. 現状確認

```sh
$ go version
# go version go1.22.5 darwin/arm64
```

#### 2. インストール

以降は、[こちらの記事](https://zenn.dev/wasuwa/articles/3d2e65516b760e)に記載されているようにインストール。

```sh
$ go install golang.org/dl/go1.23.0@latest

$ go1.23.0 download
```

ちゃんとインストールできたかかどうか確認します。

```sh
$ go1.23.0 version
# go version go1.23.0 darwin/arm64
```

#### 3. デフォルトのバージョンに設定する

`.zshrc`に下記を追記します。

```sh:.zshrc
export GOROOT=$(go1.23.0 env GOROOT)
export PATH=$GOROOT/bin:$PATH
```

追記後、`source ~/.zshrc`を実行し反映させます。

#### 4. プロジェクトに反映

```sh
$ go mod tidy -go=1.23.0
```

#### 5. goqls も更新

私は VSCode を使っているんですが、goqls も更新しないと構文エラーが表示されます。
以下で最新バージョンへ更新します。

```sh
$ go install -v golang.org/x/tools/gopls@latest
```

その後、VSCode のリロードもお忘れなく。

:::message
やったことは無いんですが、（恒久的に）バージョン down したい場合も、同様の手順で可能だと思います。
:::

# 指定のバージョンを一時的に使いたい場合

上に記載しているインストール方法でインストールすると、`goX.XX.X`でそのバージョンが使えるようになります。

今、どのバージョンが使えるようになっているのかを確認するには、`ls -l ~/sdk`を実行します。

```sh
$ ls -l ~/sdk
# total 0
# drwxr-xr-x@ 21 username  staff  672  6 23 22:46 go1.17.7
# drwxr-xr-x  20 username  staff  640  8 30 06:51 go1.23.0
```

この状態であれば、`go1.17.7 run main.go`とかで、1.17.7 バージョンの Go で実行できます。
