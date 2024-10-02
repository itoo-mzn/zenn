---
title: "Go_ログ"
---

# ログ

## ログを取る目的

- 開発者目線
  - 不具合があった場合の問題追跡
  - パフォーマンス改善ポイントの発見
- 運用目線
  - サーバー停止などのアクションの確認
  - ユーザーの行動分析
  - 監査
- セキュリティ監査目線
  - ユーザーや管理者の操作を追跡できるようにする
  - 怪しげなリクエストの発見

:::message

#### 標準出力

最近は Firelens などによってログ収集してくれるのでログは標準出力に出力するだけでいい。

#### 標準エラー出力

標準エラー出力に出力されるエラーは、基本的には標準出力と同じ場所に出力される。
わざわざ標準出力と違うものとして用意されているのは、「標準エラー出力だけを表示させたい」というようにニーズに応じて制御できるようにするため。
:::

## 使用ツール

目的別に、以下のように使い分ける。

- デバッグの補助
  `log`パッケージ
- 構造化ログ（→JSON で出力してデータ分析できるように）
  `github.com/rs/zerolog`, `github.com/uber-go/zap`
- 分散トレーシング
  `go.opencensus.io`, `go.opentelemetry.io`

## ログに出力する項目

- HTTP リクエスト
  日時、URL、メソッド、ヘッダー、リクエストボディ
- エラー発生時
  発生箇所がわかるメッセージや ID、エラーの原因
- ユーザーの行動
  セッション ID、ユーザー行動に影響があるデータ、そのときのユーザーのデータの状態

## log パッケージ

構造化ログは外部パッケージを利用するようにして、log パッケージは開発時のデバッグ用に留めるのがいい。

並行処理の挙動を調べるようなときは log を仕込んで確認するのがシンプルかつ確実。

```go:log.Fatal, log.SetPrefix
log.Print("Printログ1")

log.SetPrefix("main(): ") // ログにprefixを設定
log.Print("Printログ2")

log.Fatal("最終ログ")
log.Print("これは実行されない")
/*
  2023/08/24 06:48:09 Printログ1
  main(): 2023/08/24 06:48:09 Printログ2
  main(): 2023/08/24 06:48:09 最終ログ
  exit status 1
*/
```

```go:log.Panic
log.Panic("panicろぐ")
fmt.Print("これは実行されない")
// → panic: panicろぐ
//   goroutine 1 [running]:
//   log.Panic(0xc0000c3f58, 0x1, 0x1)
//       /usr/local/go/src/log/log.go:354 +0xae
//   main.main()
//       /Users/itotakuya/projects/go/src/helloworld/main.go:814 +0xa5
// Panic()以降は実行されない
```

### ファイルにログを記録

デフォルトでは標準出力に出力するが、`log.SetOutput()`で出力先を設定できる。

```go:出力先をファイルへ
file, err := os.OpenFile("ingo.log", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
if err != nil {
  log.Fatal("エラー発生")
}
defer file.Close()

// fileにログを記録する
log.SetOutput(file)

log.Print("ログ2") // ファイルに書き込まれる
```

## 構造化ログ

`zerolog`や`zap`が有名。

### zap

`zapcore`という主体があって、`zap`はその薄いラッパーのよう。

```go:zap
logger, _ := zap.NewProduction()
// 終了する前に、溜め込んでいる（かもしれない）ログエントリ（ログデータ）を全てフラッシュする（出力先に書き込む）。
// パフォーマンス向上のため、zap.loggerは内部でログエントリを溜めている場合がある。
// 例えば下のlogger.Info()はlogger.Sync()を忘れていたとしても出力されるが、
// 出力先への書き込みが遅延していて、その間にプログラムが終了した 等の理由で溜め込んでいる場合は、
// logger.Sync()でフラッシュしないとログが消失する。
defer logger.Sync()

logger.Info("fail to xxx",
  zap.String("str", "ABCD"),
  zap.Int("int", 3),
  zap.Duration("duration", time.Second),
)
```

log.Fatal や log.Panic は大域脱出する。呼び出し元にエラーを渡してそちらでハンドリングする Go の基本と離れてしまうため、よっぽどじゃなければ使わないこと。
