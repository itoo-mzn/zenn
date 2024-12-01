---
title: "Go_パッケージ、モジュール"
---

## パッケージ、モジュールとは

### Package とは

同じ 1 つの空間に存在するソースコードファイル群のこと。同じ空間とは、同じ package 名が付いている ということ。
**このソースコードファイル群は一緒にコンパイルされる**。
**同じ Package 内のソールファイル間では、関数や変数などが共有される**。

### Module とは

複数の Package の集合体。
バージョニングしてリリースする単位。

## パッケージ

### 命名

パッケージ名は、小文字の英単語 1 文字にする。
ただし、テスト用パッケージについては、`xxx_test`とする。

パッケージを使うとき、パッケージ名を毎度使うことになるため、メソッド名はパッケージ名と重複しないようにする。（例: `http.HttpServer` でなく、`http.Server`。）

### スコープ

Go には`private`や`public`といった概念がない。
存在するのは「**パッケージ外から参照できるか（`exported`）/できないか（`unexported`）**」のみ。（つまり、同じパッケージ内であれば`unexported`な値を直接参照できる。）

`exported`は、変数や関数の先頭文字が**大文字**から始まるもの。
`unexported`は**小文字**。

ディレクトリとして親/子の関係であっても、それぞれパッケージとしては独立していて、親/子のどちら方向から依存しても OK。

:::message

### internal パッケージ

`internal` パッケージというのは特別なパッケージ名（予約されている）で、`internal`という名称のディレクトリを作成した場合、外部パッケージから参照できなくなる。

**`internal`パッケージの 1 つ上の階層のパッケージ と その階層以下のパッケージ のみが、`internal`パッケージ内にアクセスできる**ようになる。

:::

:::message

### 無視される名前のもの

`.`や`_`から始まるファイルと、`testdata`というディレクトリは、コンパイル時に無視される。
:::

## モジュール

GoModules によってパッケージを管理し、モジュールを作る。
モジュールは単なるパッケージの集合ではなく、自身のバージョン情報 や 依存するモジュール情報 を持つ。

モジュールには必ず go.mod ファイルが含まれる。

### Go Modules とは

Go の**パッケージ管理ツール**として、`Go Modules`は Go 1.13 から正式にサポートされ、今は Go Modules を使うようになっている。（それ以前は標準の管理ツールは無かった。そのため、検索すると Go Modules 以前の情報が出てくるが、それらは無視すること。）

Go Modules 自体は、**go.mod ファイルと go.sum ファイルを使ってパッケージのバージョン管理を行う**仕組み。
操作には`go mod`コマンドを使う。

**極力古いバージョンのパッケージを使うように設計されている**のが、Go Modules の大きな特徴。

セマンティックバージョニングを使って、破壊的変更を含むのかなどを表す。

:::message

#### セマンティックバージョニング

- 互換が崩れる場合 : メジャーバージョンが上がる（例: v1.2.3 → v**2**.0.0）
- 機能追加の場合 : マイナーバージョンが上がる（例: v1.2.3 → v1.**3**.0）
- バグ修正の場合 : パッチバージョンが上がる（例: v1.2.3 → v1.2.**4**）

:::

### Go Modules の使い方

Go Modules は go.mod ファイルを作成することで開始できる。
go.mod ファイルを作るには、アプリケーションの**ルートディレクトリで`go mod init`コマンドを実行**する。
（go.mod ファイルは**リポジトリに 1 ファイル**で十分。**サブパッケージを作るたびに`go mod init`を実行する必要はない**。）

go.mod ファイルの作成後は、`go get`コマンドで利用したいパッケージを取得する。
（`go get -u`（u オプション）で、最新パッケージを取得。）

:::message
- `go get`: アプリケーションのビルドに必要なものをダウンロード。依存関係を更新する。
- `go install`: アプリケーションのビルドには不要だが、開発時に使うものをダウンロード+インストール。go modファイルは書き換わらない。
:::

パッケージの依存関係が更新された場合は、自動で go.mod ファイルと go.sum ファイルが更新される。
ルートディレクトリ（go.mod ファイルがあるディレクトリ）でなく、サブディレクトリで`go get`を実行しても、自動で go.mod ファイルと go.sum ファイルが更新される。

`go mod tidy`を実行すると go.sum ファイルができる。
モジュール管理していて使わなくなったり必要なくなったパッケージを削除するためのコマンド。（tidy : 几帳面）
**go.mod ファイルを修正したあとは、commit する前に`go mod tidy`を実行する**のがオススメ。

# 参考

https://blog.serverworks.co.jp/go-module

## モジュールの作成方法

モジュールを作成するには、そのコード(ファイル)があるカレントディレクトリで `go mod init` を実行する。

```
go mod init github.com/myuser/calculator
```

→ github.com/myuser/calculator がモジュール名になる。
→ go.mod が生成される。

```go:go.mod
module github.com/myuser/calculator

go 1.16
```

## 作成したモジュールを使う

```go
// 自作（calculator）パッケージを使う
import "github.com/myuser/calculator"

func main() {
  total := calculator.Sum(3, 5)
  println(total)
  println("version: ", calculator.Version)
}
```

:::message alert
上記のようにコードを書くだけでは使えない。
:::

1. 呼び出す側のファイルがあるディレクトリで `go mod init` を実行する。

```
go mod init github.com/myuser/calculator
```

2. 生成された go.mod ファイルを編集。(追加)

```diff go:go.mod
module helloworld

go 1.14

+ require github.com/myuser/calculator v0.0.0

+ replace github.com/myuser/calculator => ../calculator
```
