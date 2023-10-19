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

## <トランザクションを使うときは、defer 文で Rollback メソッドを予約しておく>

下記のように、**トランザクションを開始してすぐに、defer で Rollback メソッドを予約しておく**こと。
（1 回 1 回の更新処理のたびに Rollback を書くのは、それを書き忘れる恐れがあるため。）

tx.Commit()したあとに tx.Rollback()が実行される訳だが、下記の特性があるため問題ない。

:::message
Rollback()について、下記条件下では**ロールバック処理は実行されない**。

- **Commit()した後**のロールバック。
- **キャンセル済みの context**上でのトランザクションに対するロールバック。
  :::

```go
// トランザクション開始
tx, err := r.db.BeginTx(ctx, nil)
if err != nil {
  return err
}
defer tx.Rollback() // ロールバックを予約

// 更新処理1
// 更新処理2
// など...

// コミット前のこの時点で何かエラーがあるとロールバックする

return tx.Commit() // コミット → 以降、ロールバックは実行されない
```

# 04. 可視性と Go

Go には`private`や`public`といった概念がない。
存在するのは「**パッケージ外から参照できるか（`exported`）/できないか（`unexported`）**」のみ。

外部パッケージから参照できる（`exported`）のは、**大文字**から始まるもの。
できない（`unexported`）のは**小文字**。

つまり、**同じパッケージ内であれば`unexported`な値を直接参照できる**。

:::message

### internal パッケージ

`internal` パッケージというのは特別なパッケージ名（予約されている）で、`internal`という名称のディレクトリを作成した場合、外部パッケージから参照できなくなる。

**`internal`パッケージの 1 つ上の改装のパッケージ と その階層以下のパッケージ のみが、`internal`パッケージ内にアクセスできる**ようになる。

:::

# 05. Go Modules（Go の依存関係管理ツール）

## <パッケージとモジュール>

モジュール：バージョニングしてリリースする単位。
パッケージ：特定のディレクトリに含まれているソースコードの総称。

例えば、GitHub にある**レポジトリは 1 モジュール**で、その中の**各ディレクトリがパッケージ**。

## <Go Modules>

### Go Modules とは

Go の**パッケージ管理ツール**として、`Go Modules`は Go 1.13 から正式にサポートされ、今は Go Modules を使うようになっている。
（それ以前は標準の管理ツールは無かった。そのため、検索すると **Go Modules 以前の情報**が出てくるが、それらは**無視すること**。）

Go Modules 自体は、**`go.mod`ファイルと`go.sum`ファイルを使ってパッケージのバージョン管理を行う**仕組み。

セマンティックバージョニングを使って、破壊的変更を含むのかなどを表す。

**極力古いバージョンのパッケージを使うように設計されている**のが、Go Modules の**大きな特徴**。

### Go Modules の使い方

Go Modules は`go.mod`ファイルを作成することで開始できる。
`go.mod`ファイルを作るには、アプリケーションの**ルートディレクトリで`go mod init`コマンドを実行**する。
（`go.mod`ファイルは**リポジトリに 1 ファイル**で十分。**サブパッケージを作るたびに`go mod init`を実行する必要はない**。）

`go.mod`ファイルの作成後は、`go get`コマンドで利用したいパッケージを取得する。
（`go get -u`（u オプション）で、パッケージを更新。）

パッケージの依存関係が更新された場合は、自動で`go.mod`ファイルと`go.sum`ファイルが更新される。
ルートディレクトリ（`go.mod`ファイルがあるディレクトリ）でなく、サブディレクトリで`go get`を実行しても、自動で`go.mod`ファイルと`go.sum`ファイルが更新される。

`go mod tidy`を実行すると`go.sum`ファイルができる。
モジュール管理していて使わなくなったり必要なくなったパッケージを削除するためのコマンド。（tidy : 几帳面）
**`go.mod`ファイルを修正したあとは、commit する前に`go mod tidy`を実行する**のがオススメ。

# 06. Go とオブジェクト指向プログラミング

Go はオブジェクト指向なのか という問いに対して、公式サイトで Yes でも No でもある と回答している。
オブジェクト指向言語であるということを 下記の 3 要素を満たすこと とした場合、Go は継承に対応していないため。

- カプセル化
- 多態性（ポリモーフィズム）
- 継承
  → Go は**サブクラス**（クラスの階層構造による**継承**）に**対応していない**。

**埋め込み**を使うアプローチがあるが、これは**継承を完全には表現できない**。
**埋め込みは継承でなくコンポジションである**。

:::message

### オブジェクト指向の「関係」について

- 継承
  `サブクラス is a スーパークラス. （トラックは車。）`
- 集約
  部品として他のオブジェクトを持つが、弱い結びつき。
  関連先が消滅しても、自身は消滅しない。
  `A part of B. （駐車場Bと、そこに駐車された車A。）`
- コンポジション（合成）
  部品として他のオブジェクトを持つ、強い結びつき。
  関連先が消滅すると、自身も消滅する。
  集約と似ている概念。
  `A part of B. （エンジンAは車Bの一部。）`

#### 参考記事

https://zenn.dev/itoo/articles/object-oriented_design#%E3%82%B3%E3%83%B3%E3%83%9D%E3%82%B8%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%A8%E7%B6%99%E6%89%BF%E3%81%AE%E9%81%B8%E6%8A%9E
:::

```go:埋め込みは継承でなくコンポジション
type Dog struct {}

func (d *Dog) Bark() string { return "Bow" }

type BullDog struct { Dog }

type ShibaInu struct { Dog }

func (s *ShibaInu) Bark() string { return "ワン"}

func DogVoice(d *Dog) string { return d.Bark()}

func main() {
  bd := &BullDog{}
  fmt.Println(bd.Bark()) // Bow

  si := &ShibaInu{}
  fmt.Println(si.Bark()) // ワン

  // 下のコードはエラーが出る
  fmt.Println(DogVoice(bd))
  // → cannot use bd (variable of type *BullDog) as *Dog value in argument to DogVoice
}
```

上のコードで以下のことが分かる。

- `BullDog`は、`Dog`が持つ Bark()を実行できる。
  `ShibaInu`は更に、Bark()をオーバーライドして独自の処理を定義できている。
- しかし、`Dog`を引数にするメソッドに、`BullDogはDog`や`ShibaInu`は引数として使うことができない。
  これは、シンプルに`BullDogはDog`や`ShibaInu`は Dog 型でないから。
  つまり、`Dog`型を**継承した訳でなく**、`Dog`型の値を**保有しているだけ（= コンポジション）だから**。

よって、SOLID 原則のリスコフの原則（サブクラスは、スーパークラスを代替可能としなければならない。）は、そのまま Go に適用できない。

https://dave.cheney.net/2016/08/20/solid-go-design
https://qiita.com/shunp/items/646c86bb3cc149f7cff9

# 07. インターフェース
## <利用者側で最小のインターフェースを定義する>
（他の多くのオブジェクト指向言語と異なり）Goのインターフェースは、**実装側（構造体）だけを見ても、それがどのインターフェースを満たしているのかが分からない**。

だが、**利用するメソッドだけを持つインターフェース**を**利用者側で定義できる**ため、
SOLIDの**インターフェース分離の原則**に則った、実装側と利用側の結合度が低い（**疎結合**な）関係性にできる。

:::message
### インターフェースの命名 -er 
`Xxx`メソッドを1つだけ持つインターフェースの場合、そのインターフェースは（`er`をつけて）`Xxxer`という命名にする。
例えば`Do`メソッドだけを持つインターフェースは、（そんな単語は無いけども）`Doer`とする。
:::

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
