---
title: "Go 基礎"
emoji: "⛳"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: true
---

# ステートメント

## 基本構文

```go:main.go
// main: すべての 実行可能プログラムは main パッケージに含まれる必要がある。
package main

// import: 別のパッケージ内のコードからプログラムにアクセス。
// fmt: 標準ライブラリパッケージ
import "fmt"

// main(): package main 全体で main()関数は1つだけ。
func main() {
    fmt.Println("helo")
}
```

## Exported name

Go では、最初の文字が**大文字**で始まる名前は、**外部のパッケージから参照できる**（export された）ものです。

# プログラム実行

Go は、main パッケージ内の main 関数からプログラムがスタートします。
（プログラムがスタートする地点のことを、エントリーポイントといいます。）

## 実行

Go ファイルがあるフォルダーに移動し、`go run`を実行。

```bash
go run main.go

# 移動しない場合
go run ./src/helloworld/main.go
```

run コマンドは、**ビルド(go build) + 実行** を行っています。
が、**実行ファイル**（= バイナリファイル（機械語で書かれたファイル））**が残らない**ので、見た目はインタプリタ言語のように実行できます。

## ビルド

```bash
go build main.go

.\main
# もしくは ./main
```

ビルドすると、実行したファイルの拡張子がない ver.のファイルが生成されます。
(main.go → main が生成される)
生成された実行ファイルは、`.\main`や`./main`（こっちは環境による）で実行できます。

:::message
`go build` コマンドにて`GOOS`と`GOARCH`を指定すると、違う OS やアーキテクチャ向けのビルドができます。
:::

## Module の場合

これまで記載したのはファイル単体を実行するときの話でしたが、Module として実行するときの話をします。

### Package とは

同じ 1 つの空間に存在するソースコードファイル群のこと。同じ空間とは、同じ package 名が付いている ということ。
**このソースコードファイル群は一緒にコンパイルされる**。
**同じ Package 内のソールファイル間では、関数や変数などが共有される**。

### Module とは

複数の Package の集合体。

### go mod

`go mod init モジュール名`で Module を使用するのに必要な**go.mod ファイル**を生成。

```:go.modファイル
module sample

go 1.20
```

### 実行

#### go run の場合

```bash
# go.modファイルが存在しているディレクトリで
go run .
```

#### go build の場合

```bash
# go.modファイルが存在しているディレクトリで
go build
.\sample
```

https://qiita.com/t-yama-3/items/1b6e7e816aa07884378e

https://blog.framinal.life/entry/2021/04/11/013819

:::message
Go でプログラムを作成する場合、必ず**main パッケージ**が存在する必要があり、main パッケージ中に**main 関数**が定義される必要があります。
:::

# Go Tool

### go doc

ドキュメント自動生成ツール。

https://zenn.dev/mkosakana/articles/bb411e9d6b5ad9
