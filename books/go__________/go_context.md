---
title: "Go_context"
---

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
