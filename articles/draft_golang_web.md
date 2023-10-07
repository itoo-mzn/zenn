---
title: "「詳解Go言語Webアプリケーション開発」"
emoji: "😽"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: false
---

# 01. Go のコーディングで意識しておきたいこと

Go は大規模なチーム開発で浮かび上がった問題を解決するために開発された言語であり、学術的な目的ではないので、言語機能がシンプル。（そのため、表現力が不足している点もある。）

Go を使った設計やコーディングをする上では「シンプルかどうか」を判断基準にし、**迷ったらシンプルを選ぶ**ことが良い。

# 02. 「context」パッケージ

context パッケージの役割は下記 2 点。

1. **キャンセル**や**デッドライン**（時間制限）を伝搬させる。
2. （リクエストやトランザクションスコープ内の）**メタデータ**を、関数やゴルーチン間で伝播させる。

Go を使った HTTP サーバーにおいて、context パッケージの利用は必須。
**クライアントとの通信状態は、`context.Context`型の値からしか知ることができない**ため。

:::message
Go の仕様上、xxx 型のオブジェクト（やインスタンス）という表現は無く、**xxx 型の値**という表現になる。
:::

多くのパッケージが`context.Context`型の値を受け取る前提で設計されている。
**関数やメソッドを設計するときは、常に`context.Context`型の値を受け取るよう実装しておくべき**。

## <キャンセルを通知する>

### 任意のタイミングでキャンセル

ある処理に失敗した場合に、`context.Context`型の値を共有するすべての操作をキャンセルしたいときがある。
そういった場合は、**`context.WithCancel`メソッドを使って、キャンセル関数を用意・実行**する。

```go:context.WithCancelメソッド
func child(ctx context.Context) {
  if err := ctx.Err(); err != nil {
    fmt.Println("キャンセルされた")
    return
  }
  fmt.Println("キャンセルされていない")
}

func main() {
  ctx, cancel := context.WithCancel(context.Background()) // context.Background()はrootコンテキスト
  child(ctx) // "キャンセルされていない"
  cancel()
  child(ctx) // "キャンセルされた"
}
```

### デッドライン（時間制限）でキャンセル

指定**時刻**を経過したらキャンセルする場合：`WithDeadline`を使う。
指定**時間**を経過したらキャンセルする場合：`WithTimeout`を使う。

## <キャンセル通知を受け取る>

### キャンセル済みかどうかを知る

**`context.Context.Err`メソッドでキャンセルの有無を確認**する。
（↑ の context.WithCancel メソッドのサンプルコード内で使っている。）

### キャンセルされるまで処理を続ける

キャンセル通知（完了通知）があるまで処理を待機する場合は、**`<-ctx.Done()`で通知を待つ**。

```go
func main() {
  ctx, cancel := context.WithCancel(context.Background())
  go func() {
    // キャンセルを受け取るまで無限ループする
    for {
      select {
      case <-ctx.Done():
        fmt.Println("キャンセルされた")
        return
      default:
        fmt.Println("キャンセルされていない")
      }
      time.Sleep(300 * time.Millisecond)
    }
  }()
  time.Sleep(time.Second)
  cancel()
  fmt.Println("終了")
}

// キャンセルされていない
// キャンセルされていない
// キャンセルされていない
// 終了
```

## <Context にデータを含める>

**`context.WithValue(context, キー, 値)`でデータをセット**。
**`ctx.Value(キー)`でデータを取得**する。

**キーには空の構造体`struct{}`を使う**のが一般的。
（プリミティブな値はキーが衝突する恐れがあるので避けること。）

```go
// 独自型を用意
type TraceID string

const ZeroTraceID = ""

// 単にstringだと、キーが衝突する恐れがある。
// struct{}(空の構造体)だと、traceIDKey{}とすればキーになるのが良い。
// （逆に、stringなど他の型だと、traceIDKey("キー1")とか、具体的な値にしないといけない。）
type traceIDKey struct{}

func GetTraceID(ctx context.Context) TraceID {
  // ctx.Value(traceIDKey{}) で取得した値を、`.(TraceID)`でTraceID型に型アサーション
  if v, ok := ctx.Value(traceIDKey{}).(TraceID); ok {
    return v
  }
  return ZeroTraceID
}

func SetTraceID(ctx context.Context, tid TraceID) context.Context {
  // contextにデータをセット
  return context.WithValue(ctx, traceIDKey{}, tid)
}

func main() {
  ctx := context.Background()
  fmt.Printf("trace id = %q\n", GetTraceID(ctx)) // trace id = ""
  ctx = SetTraceID(ctx, "test-id")
  fmt.Printf("trace id = %q\n", GetTraceID(ctx)) // trace id = "test-id"
}
```

:::message

### 型アサーション

`インターフェース.(型)`と書くことで、**特定の型への変換や型の確認**ができる。

```go
var i interface{} = 42
result, ok := i.(int)
fmt.Println(result, ok) // 42 true
```

:::

## <context を扱うときの注意点>

- 呼び出された側で context.Context 型の値を操作しても、**呼び出した側には伝搬されない**。

- 構造体の中（フィールド）に context.Context 型の値を保持すると、それが対象とするスコープが曖昧になるため、アンチパターン。

- context.Context 型の値は、**複数のゴルーチンから同時に使われても安全**。

- context.Context 型の値に、含める or 含めないべきデータは下記。
  - 関数への引数となる値は含めない。（= **関数のロジックに関わる値を含めてはいけない**。）
  - リクエストに関するデータを含める。
  - 認証・認可に関するデータは、（厳密にはロジックに関わることになるが）含めてもよい。

:::message

### 既存のコードが context.Context 型の値を引数に受け取っていない場合

`context.TODO`を使うことで、膨大なコードの中でも徐々に context.Context 型の値を引数に受け取るように改修を進めることができる。
`context.TODO`は、空の context.Context 型の値。
:::

# 03. 「database/sql」パッケージ

:::message
MYSQL を使うときのチュートリアル
https://go.dev/doc/tutorial/database-access
:::

## <sql.Open を使うのは一度だけ>

\*sql.DB 型の値がコネクションプールを持っているので、HTTP リクエストを受け取るたびに`sql.Open`関数を呼ぶとコネクションが再利用されず効率が悪い。
なので、**`sql.Open`は main 関数や初期化処理の中で、一度だけ呼ぶ**ようにする。



CHAPTER 04 　可視性と Go
CHAPTER 05 　 Go Modules（Go の依存関係管理ツール）
CHAPTER 06 　 Go とオブジェクト指向プログラミング
CHAPTER 07 　インターフェース
CHAPTER 08 　エラーハンドリングについて
CHAPTER 09 　無名関数・クロージャ
CHAPTER 10 　環境変数の扱い方
CHAPTER 11 　 Go と DI（依存性の注入）
CHAPTER 12 　ミドルウェアパターン
CHAPTER 13 　ハンズオンの内容について
CHAPTER 14 　 HTTP サーバーを作る
CHAPTER 15 　開発環境を整える
CHAPTER 16 　 HTTP サーバーを疎結合な構成に変更する
CHAPTER 17 　エンドポイントを追加する
CHAPTER 18 　 RDBMS を使ったデータの永続化処理の実装
CHAPTER 19 　責務別に HTTP ハンドラーの実装を分割する
CHAPTER 20 　 Redis と JWT を用いた認証・認可機能の実装
