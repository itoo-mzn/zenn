---
title: "Go_構造体, 関数, インターフェース"
---

# 構造体

**型の異なる**データを集めたデータ型。

## 宣言・初期化・アクセス

```go
// 宣言
type User struct {
  Name string
  Age  int
}

// 初期化
u := User{Name: "太郎", Age: 20}

// 代入・参照
u.Age = 30
fmt.Println(u.Name, u.Age) // 太郎 30
```

:::message
初期化については、以下 3 通りの方法があり、どれも正しいしよく使われるもの。
1 つ目の方法のみ、ポインタ型のインスタンスができる。

```go
s1 := new(Sample) // *Sample
var s2 Sample     // Sample
s3 := Sample{}    // Sample
```

:::

### コンストラクタ

基本的には、インスタンスを初期化するコンストラクタを作ること。
命名は`New型名`とするのが一般的。

## 構造体の埋め込み

```go
type triangle struct {
  size int
}

type coloredTriangle struct {
  triangle // 構造体を埋め込む
  color string
}

func (t triangle) perimeter() int {
  return t.size * 3
}

t := coloredTriangle{triangle{3}, "blue"}

fmt.Println("size:", t.size) // triangleのメソッドも使える

fmt.Println("perimeter:", t.triangle.perimeter())
fmt.Println("perimeter:", t.perimeter()) // ↑の書き方のシンタックスシュガー
```

また、**埋め込んだ構造体のメソッドをオーバーロード**することもできる。
（※ オーバーロード(多重定義) : 同じ名前の関数等を定義すること。）
その場合、下記のように、**埋め込んだ側・埋め込まれた側どちらのメソッドも使用することができる**。

```go
func (t triangle) perimeter() int {
  return t.size * 3
}

func (t coloredTriangle) perimeter() int {
  return t.size * 5
}

// coloredTriangleのメソッドを使う
fmt.Println("perimeter:", t.perimeter()) // perimeter: 15

// triangleのメソッドも使える
fmt.Println("perimeter:", t.triangle.perimeter()) // perimeter: 9
```

:::message
Go には**継承は無い**。
**構造体の埋め込み**で行っているのは**継承ではなく、委譲**。

https://qiita.com/Maki-Daisuke/items/511b8989e528f7c70f80#%E7%BD%A0%EF%BC%93-embedded%E3%81%AE%E5%89%8D%E3%81%AB%E3%82%AA%E3%83%BC%E3%83%90%E3%83%BC%E3%83%A9%E3%82%A4%E3%83%89%E3%81%AA%E3%81%A9%E7%84%A1%E5%8A%9B

---

具体的に言うと、

- 構造体 A（B に埋め込まれる側）
  - メソッド 1 : return "A"
  - メソッド 2 : return メソッド 1 + "です"
- 構造体 B（A を埋め込んでいる側）
  - メソッド 1 : return "B"

というものがあるとしたとき、**オーバーロード**によって、`B.メソッド1`も、`B.A.メソッド1`も実行可能。（これは OK）

ただし、`B.メソッド2`を実行すると、（**B のメソッド 1 でなく**）**A のメソッド 1 を利用したメソッド 2 が実行される**。
**B はメソッド 2 を A から継承したわけではなく**、B がメソッド 2 を実行したときは構造体 A のメソッド 2 を実行しているだけなので。
（シンタックスシュガーで`B.メソッド2`と記述できているので勘違いしやすいが、実際には`B.A.メソッド2`を実行している。）
つまり、**B はメソッド 2 の実行を A に移譲している**。

`B.メソッド2`を実行したときに、内部で _B のメソッド 1_ を利用してもらうようにするには、B にもメソッド 2 を用意するしかない。
:::

## タグ

構造体のフィールドに対してタグを付けることができる。

- 同じ名前で扱うなら、複数のタグをまとめて記述できる。（例：`json xml: "name"`）

- 自分でパッケージを作ってタグ対応する場合は reflect パッケージを使うことになる。

:::message
大きい構造体や大量の構造体を使う場合は、`sync.Pool`を使って、インスタンスを使いますとメモリ使用量を抑えることができる。
（*ランタイム内部におけるメモリ確保*や、*OS に依頼するメモリの確保*は、Go でも遅い処理。）
:::

## ポインター型 or 値型、どちらで扱うか

構造体のフィールドに、（マップやポインターなどの）**単純にコピーをした場合に危険な値がある場合**は、その構造体は（値型ではなく）ポインター型として扱うべき。

また、ポインター型の場合は Copy()メソッドを提供するべき。

## ゼロ値での動作を保証するかどうか

ゼロ値での動作（特に、ポインターのゼロ値(nil)での動作）に対して、以下の手段の選択肢がある。

- 保証するために実行時にチェック（nil チェックなど）する。
- ファクトリ関数を用意して、そこで作られたもの以外の動作は保証しない。

# 関数

## Named return value

返り値の定義で変数を指定すると、それをそのまま関数内で使え、return 時にはそれが返される。

```go
func greetingPrefix(language string) (prefix string) {
	switch language {
	case japanese:
		prefix = japaneseHelloPrefix
	default:
		prefix = englishHelloPrefix
	}
	return
}
```

https://zenn.dev/yuyu_hf/articles/c7ab8e435509d2

ただ、基本的には関数名が明確で、返り値の型が分かれば十分に伝わるので、以下の状況で使うのがいい。

- 同じ型の複数の値 を返却するとき。
- 返却したものを使って、呼び出し側に何かアクションを求めるとき。（cancel 関数を返す場合など）

さらに、それに加えて 関数が小さいとき のみ。中規模以上になると明示的に return しないと読みづらい。

## オプション引数

関数にオプション引数を渡して、オプションを足したり引いたりできるようにするには、以下のような方法がある。

### 1. 可変長引数

`fmt.Println(a ...any)`のように、同じ型のものを何個でも渡せるようにした引数。
型指定では、`...型`という描き方をする。

:::message alert
`fmt.Println()`の例のように、**すべての引数が同じ使われ方をするもの**でないといけない。
例えば、1 つ目は名前、2 つ目は住所、3 つ目は電話番号...などと、それぞれ別の意味を持つものを、同じ型だからといって可変長引数にしてはいけない。
:::

### 2. コンストラクタ関数に切り出す

例えばうどん屋の場合、かけうどん、きつねうどん、天ぷらうどん...などがある。
それらを `NewUdon()`の引数で具体的に何の具材を x 個指定するのでなく、
`NewKakeUdon()`、`NewKitsuneUdon()`というように、よく使われると分かっている種類（_オプションの組み合わせ_）をコンストラクタ関数に切り出す方法。
（各コンストラクタ関数の中で、具体的に具材を指定する。）

組み合わせが多い場合はコンストラクタが増えすぎるのがデメリット。

### 3. オプションを構造体にする

複数のオプションを、1 つの構造体の各フィールドに設定し、コンストラクタに渡す方法。
`NewUdon(ud *UdonOption)`という感じ。

:::message
この方法がシンプルでおすすめ。
:::

### 4. ビルダーパターン

各オプションを追加・設定する関数をそれぞれ作成し、それらを必要に応じて組み合わせて使うパターン。
`NewUdon().AddOage().AddTempula().Create()`

コード量が多くなるのがデメリット。

### 5. Functional Option パターン

オプションを設定する関数をそれぞれ実装し、コンストラクトには ConfFunc 型を可変長引数で渡すだけにするパターン。
ビルダーパターンよりかは冗長なコードを書かなくて済むが、
別パッケージ使う場合、パッケージ名をいちいち書かないといけないのでコードが長くなる。

:::details 実装例

```go
type options struct {
	port    *int
	timeout *time.Duration
}

type Option func(options *options) error

func WithPort(port int) Option {
	return func(options *options) error {
		if port < 0 {
			return errors.New("port should be positive")
		}
		options.port = &port
		return nil
	}
}

// WithTimeout()は省略

func NewServer(addr string, opts ...Option) (*http.Server, error) {
	var options options
	for _, opt := range opts {
		err = opt(&options)
		// 省略
	}

	var port int
	if options.port == nil {
		port = 3000 // 指定ない場合はデフォルト値をセット
	} else {
		port = *options.port
	}

	var timeout time.Duration
	if options.timeout == nil {
		timeout = 10 * time.Second // 指定ない場合はデフォルト値をセット
	} else {
		timeout = *options.timeout
	}

	// port, timeoutを使って、サーバー起動
	// 省略
}
```

```go:main.go
s, err := NewServer("localhost", WithPort(8080), WithTimeout(30 * time.Second))
```

:::

## 高級関数

関数を引数にとる関数や、返り値に関数を返すというテクニック。

```go:関数を引数にとる関数
func compute(a, b int, ope operation) int {
  return ope(a, b)
}

// この型に合致すればcompute()に渡せる
type operation func(a, b int) int

func add(a, b int) int {
	return a + b
}

func sub(a, b int) int {
	return a - b
}

func main() {
	a, b := 5, 3
	sum := compute(a, b, add)
	diff := compute(a, b, sub)
	fmt.Println(sum, diff) // 8 2
}
```

↑ は、ようは http.HandleFunc()でやっていることと同じ。

```go
func sampleHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello")
}

http.HandleFunc("/", sampleHandler)
```

```go:関数を返す関数
func tenTimes() func(i int) int {
	return func(i int) int { return i * 10 }
}

func main() {
	fmt.Println(tenTimes()(5))
}
```

# メソッド

`func (変数 レシーバ) メソッド名() 返却型 { ... }`
（レシーバ名は 1 or 2 文字にする。）

メソッドは、**レシーバ**（= 構造体 や その他何かのデータ）**に紐付けられた関数**。
メソッドによって、作成した構造体やデータに動作を追加できる。

**レシーバには、プリミティブな値、配列、マップ、iota なども定義できる**。
ドメインロジックを閉じ込めるのに、こういった値の型にメソッドを生やすのが有効。

**レシーバは、第 0 引数みたいなイメージ**。（なので変数の値のコピーが発生する。）

:::message

### 関数でなく、メソッドへ

構造体のフィールドを使っているロジックは、Struct 側に寄せていく（その構造体のメソッドにする）のがいい。[参考](https://future-architect.github.io/articles/20200709/#10-Struct%E3%81%AE%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AB%E3%83%89%E3%82%92%E5%88%A9%E7%94%A8%E3%81%97%E3%81%9F%E5%88%A4%E5%AE%9A%E3%83%AD%E3%82%B8%E3%83%83%E3%82%AF%E3%82%92%E5%91%BC%E3%81%B3%E5%87%BA%E3%81%97%E5%85%83%E3%81%A7%E3%81%AF%E3%81%AA%E3%81%8FStruct%E5%81%B4%E3%81%AB%E5%AF%84%E3%81%9B%E3%81%A6%E3%81%84%E3%81%8F)
:::

## レシーバにポインターを使う

メソッドに、変数でなくポインターを渡すほうが良い場合がある。（変数のアドレスを参照する。）

- メソッドで変数を更新する場合。
- 引数が（データ容量として）大きすぎる場合。→ そのコピーを回避したい。

```go
type triangle struct {
  size int
}

// ポインタを使わないメソッド
func (t triangle) perimeter() int {
  return t.size * 3
}

// ポインタを使うメソッド
func (t *triangle) doubleSize() {
  t.size *= 2 // return しない
}

t := triangle{3}
t.doubleSize() // ポインタを参照して tが更新される

fmt.Println("size:", t.size) // size: 6
fmt.Println("perimeter:", t.perimeter()) // perimeter: 18
```

:::message
メソッドにポインターを使うこの用法はよく使われるので、シンタックスシュガーがある。

`(&t).doubleSize()` 本来はこう書かないといけないが、
`t.doubleSize()` こう書いても同じ意味になる。
:::

ポインタを使わない場合のレシーバ のことを**値レシーバ**、使う場合は**ポインタレシーバ**という。

```go
// 値レシーバ
func (t triangle) perimeter() int { }

// ポインタレシーバ
func (t *triangle) doubleSize() { }
```

:::message
**基本的にはポインタレシーバを使うこと**。

- 大きなデータのコピーが発生しないため。
- メソッドがインスタンスの状態を変更する場合。値の変更が簡単。

逆に言うと、値レシーバを使うのは下記の場面。

- メソッド呼び出しが**オリジナルのインスタンスに影響を与えてはいけない場合**。
- レシーバがプリミティブ型など単純な型の場合。

また、**どっちを使うのか、1 つの型の中で混在させない（統一する）こと**。
:::

:::message alert
下記については詳細を省略。

- メソッド値 : メソッドを値として扱える。なので、変数にメソッドを格納して、それを別の場所で実行できたりする。
- メソッド式 : おおよそメソッド値と同じようなこと。違いは、レシーバでなく型を渡しているだけなので、メソッド式にはレシーバを第一引数に渡す必要がある。

:::

### カプセル化

パッケージ外からは public（頭文字が大文字）なメソッド・フィールドしか参照できないため、それによってカプセル化を行う。

# インターフェース

## 命名

1 つのメソッドしか持たないインターフェースには、`そのメソッド名 + er`というインターフェース名にすることがある。（例えば`Do`メソッドだけを持つインターフェースは、（そんな単語は無いけども）`Doer`とする。）
が、そうじゃない場合もある。
2 つ以上のメソッドを持つインターフェースも含め、目的を適切に表現する名前にすること。

## 宣言

`type インターフェース名 interface { ... }`

- Go では**インターフェースでしか抽象化できない**。
- インターフェースを実装した具象を定義する際、Java とかみたいに`implements`などのキーワードはいらない。
  逆に言うと、**この型がそのインターフェースを実装しているのかどうか**が分からなくなるが、下記のようにしてチェックできる。

  ```go:インターフェースを満たすかチェック
  // 独自型を定義
  type Func func() string

  func (f Func) String() string { return f()}

  // これがfmt.Stringerインターフェースを満たすか確認する
  // （fmt.Stringer はStringメソッドを持つインターフェース）

  // もし等しくなければコンパイルエラーが起きるので、インターフェースを満たしていないということが分かる。
  // チェックのためだけに使うのでFunc()にはnilを渡し、返り値も使わないので _ で受け取っている。
  var _ fmt.Stringer = Func(nil)
  ```

  また、変数が any 型の場合（静的に確定しない場合）は、`v, ok := 変数.(インターフェース名)`でインターフェースを満たしているかどうか確認できる。

### empty interface (any)

empty interface（`interface{}`）を使うと、どの型の値も実装していることになる。（1.18 から`any`型が用意された。）
つまり、**何でも入れれる箱**が作れる。

```go
var v interface{}
v = 100
v = "hoge" // 普通なら代入できないが、できる
```

（空のインターフェースというのはつまり、インターフェースを満たす条件となるメソッドを定義していないということ。int や string など色々な型は、**空のインターフェースを既に実装している**ということになるので、何でもボックスになる。）

ただし、それをすると型の恩恵が受けれなくなるため、**基本使うべきではない**。どうしてもそうしたい場合のみ使う。

`変数.(type)`と書くと、その変数に格納されている値の型が取得できる。

## インターフェースの合成

構造体だけでなく、インターフェースも埋め込み（合成）できる。

```go
type Reader interface { Read(p []byte) (n int, err error) }
type Writer interface { Write(p []byte) (n int, err error) }
type ReadWriter interface {
	Reader
	Writer
}
```

## インターフェースの設計

主に以下の 3 つの用途でインターフェースを作ることになる。

- 共通の振る舞い
- 具体的な実装との分離
- 振る舞いの制限

:::message

- **メソッドリストは小さく**するのが良い。
  - **共通点を抜き出して抽象化しない**。
  - **1 つの振る舞い（塊）を 1 つのインターフェース**にする。
  - **型を使うクライアント（ユーザ）が触れる部分がインターフェースでなくてもよい**。

:::

### インターフェースで行動を制限する

"振る舞いの制限"についての具体例は以下。

```go
// なんらかの設定
type Config struct{}

func (c *Config) Get() int { ... }

func (c *Config) Set(v int) { ... }

// ---------------------------------------

// 設定を参照してなにかを実行するオブジェクト
type Foo struct {
	threshold configGetter
}

// Fooで設定を更新(Set)させないために参照のみ可能なインターフェースを作り、Fooはそれに依存させる
type configGetter interface {
	Get()
}

func NewFoo(threshold configGetter) Foo {
	return Foo{threshold: threshold}
}

func (f Foo) Bar() {
	t := f.threshold.Get()
	// tを使って何かをする
}
```

## インターフェースを作りすぎない

構造体から、どれがどのインターフェースを満たしているのかを確認できないため、**不要な抽象化を行うインターフェースの定義は可読性を低下させる**。（コードの流れを複雑にしてしまう。）

ムダな間接参照は価値がない。まずは、実装を直接呼び出す。

インターフェースは以下の場合に定義するようにする。

1. 統一的に扱わなければいけない、2 つ以上の具象型が存在する場合。
2. インターフェースは単一の具象型で満足しているが、依存性のためにその具象型が別々のパッケージにそれぞれ存在しないといけない場合。

:::message
「インターフェースは**作成するものではなく、発見するもの**。」

必要に駆られない限りは作らずに、具体的な必要性が発生するのを待つべきだということ。
:::

## 利用者側で最小のインターフェースを定義する

（他の多くのオブジェクト指向言語と異なり）Go のインターフェースは、**実装側（構造体）だけを見ても、それがどのインターフェースを満たしているのかが分からない**。

だが、**利用するメソッドだけを持つインターフェース**を**利用者側で定義できる**ため、
SOLID の**インターフェース分離の原則**に則った、実装側と利用側の結合度が低い（**疎結合**な）関係性にできる。

実装側に多くのメソッドがあったとして、それを利用者がすべて求めている訳ではない。そのため、利用者側が、どんな抽象化が必要なのかを判断する。

## ライブラリとしてインターフェースを返す

基本的には、インターフェースを返すのは良くない。具体的な実装を返すべき。
利用者側で柔軟にインターフェースを設計をする余地がなくなり、制限されてしまうため。

ただし、インターフェースを提供することが利用者の役に立つことが確定しているなら OK。

パッケージをライブラリとして他のパッケージに提供する場合は、実装の詳細を隠蔽するために、インターフェースを返す関数を作成する場合がある。
その場合、契約による設計を意識して、コードコメントで事前条件・事後条件・不変条件などを記載すること。
