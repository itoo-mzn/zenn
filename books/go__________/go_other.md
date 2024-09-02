---
title: "Go_その他"
---

# Go のインストール、バージョン管理

## インストール

インストールは、ここから普通に GUI で MacOS(ARM64)用の.pkg ファイルを落とした。
https://go.dev/doc/install

```sh
$ go version
go version go1.22.4 darwin/arm64

$ which go
/usr/local/go/bin/go

# /usr/local/go は GOROOT

$ cat .zshrc
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
eval "$(anyenv init -)"

$ echo $PATH
/Users/itoutakuya/.anyenv/envs/nodenv/shims:/Users/itoutakuya/.anyenv/envs/nodenv/bin:/opt/homebrew/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/go/bin
# 長くて分かりづらいが、出力の最後が ...:/usr/local/go/bin となっている → パスが通っている
```

## 複数バージョン管理

今後、別のバージョンを追加したい場合は下記。

```sh:go1.17.7の例
$ go install golang.org/dl/go1.17.7@latest
$ go1.17.7 download
```

### 導入時のエラー

ここに書いているとおり。なのだがエラー起きたりしたのでそれはメモに残す。
https://go.dev/doc/manage-install#installing-multiple

- go install 時、バージョンが古すぎると M1Mac では動かなかったので、ある程度は新しめのバージョン以降じゃないとダメ。

  ```sh
  $ go install golang.org/dl/go1.10.7@latest # NG

  $ go install golang.org/dl/go1.17.7@latest # OK
  ```

- go install 後、`go1.17.7 download`が実行できなかったが、パスを通して解決。
  go の 1.17.7 自体は、~/go/bin にあるのだが、PATH になかったことが原因。

  ```sh
  $ go env GOPATH
  /Users/itoutakuya/go

  $ ls ~/go/bin
  go1.17.7	gopls		staticcheck

  $ vi .zshrc
  $ cat .zshrc
  export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
  eval "$(anyenv init -)"
  # 追加
  export PATH=$PATH:$(go env GOPATH)/bin
  ```

# time パッケージ

- 時刻：time.Time
- 時間：time.Duration（1 が 1 ナノ秒を表す。）

- AddDate()で 1 ヶ月後と指定したとき、6/31 は存在しないので 5/31 の 1 ヶ月後が 7/1 になる。
  日付計算には要注意。

# 01. Go のコーディングで意識しておきたいこと

Go は大規模なチーム開発で浮かび上がった問題を解決するために開発された言語であり、学術的な目的ではないので、言語機能がシンプル。（そのため、表現力が不足している点もある。）

Go を使った設計やコーディングをする上では「シンプルかどうか」を判断基準にし、**迷ったらシンプルを選ぶ**ことが良い。

# 10. 環境変数の扱い方

環境変数を読み込む操作は（リクエストを受け付けるたびでなく）アプリケーション起動時のみにすること。

- `os.Getenv`は環境変数が設定されていない場合に空文字を返すため、空文字が設定されていること との区別ができない。設定されているかどうかは、`os.LookupEnv`関数（bool）で判定する。

- テスト時に t.Setenv を使うことで、そのテストケースの間だけ環境変数を設定した状態にできる。

外部パッケージの envconfig を使えば、環境変数を簡単に構造体にマッピングできる。

# プログラム実行

Go は、main パッケージ内の main 関数からプログラムがスタートします。
（プログラムがスタートする地点のことを、エントリーポイントといいます。）

## <実行>

Go ファイルがあるフォルダーに移動し、`go run`を実行。

```bash
go run main.go

# 移動しない場合
go run ./src/helloworld/main.go
```

run コマンドは、**ビルド(go build) + 実行** を行っています。
が、**実行ファイル**（= バイナリファイル（機械語で書かれたファイル））**が残らない**ので、見た目はインタプリタ言語のように実行できます。

## <ビルド>

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

## <Module の場合>

これまで記載したのはファイル単体を実行するときの話でしたが、Module として実行するときの話をします。

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

### ビット演算

https://www.flyenginer.com/low/go/go%E3%81%AE%E3%83%93%E3%83%83%E3%83%88%E6%BC%94%E7%AE%97%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6.html

Web 開発ではあまり登場しないと思うので説明は上記リンク先にお任せするが、
ビット演算とは何をすることなのか、少しだけ下記コードで説明。

```go:否定(^)だけピックアップ
one := 3 // 2進数表現では「0000 0011」
fmt.Println(one) // 3
fmt.Println(^one) // -4
// -3 を2進数に変換するときは「3の2進数表現をすべて反転して、1を足す」ので、
// 3の否定 である「1111 1100」は、-4 となる
```
