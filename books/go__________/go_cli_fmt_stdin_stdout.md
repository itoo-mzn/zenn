---
title: "Go_コマンドラインツール、fmt、標準入力・出力"
---

# 入出力

| 種類           | 変数      | 説明                                                                                     |
| -------------- | --------- | ---------------------------------------------------------------------------------------- |
| 標準入力       | os.Stdin  | 入力（キーボードとかから待ち受けるやつ）                                                 |
| 標準出力       | os.Stdout | 出力。次のコマンドに（パイプとかで）渡すような値。なのでエラーは標準出力に出さないこと。 |
| 標準エラー出力 | os.Stderr | エラーを出力。                                                                           |

os.Stdin らは、**io.Reader**や**io.Writer**インターフェースを実装している。
なので、様々な関数やメソッドの引数として渡せる。

:::message

#### io.Reader、io.Writer

それぞれ 1 つのメソッド（Read、Write）しか持たない、インターフェース。
ファイルへの書き込み、メモリへの書き込み...など、色々なものへの読み書きを抽象化している。
:::

## 標準入力からの受け取り

複雑な処理（低レベルな処理）をするときは`os.Stdin`を使うが、
文字列など簡単な受け取りでいいときは`fmt.Scan()`で受け取る。（競技プログラミングの問題など）

```go:個数が固定で決まっている場合
var a, b int
var s string
fmt.Scan(&a, &b, &s)
```

```go:n個の入力を受け取る場合
nums := make([]int, n)
for _, num := range nums {
  fmt.Scan(&num)
}
```

https://zenn.dev/pikarich/articles/8f1c7fe4d04e93

# コマンドライン引数

コマンドライン引数は、`os.Args`で受け取る。

`os.Args`は string 型のスライスで、

- 0 番目の要素には、実行したコマンド名が格納されている。
- 1 番目以降の要素に、コマンドに渡された引数が格納されている。

```go:[ go run test.go 123 456 ]と実行した
func main() {
  fmt.Printf("args count: %d\n", len(os.Args))
  // → 3
  fmt.Printf("args : %#v\n", os.Args)
  // → []string{"/var/folders/rj/l6kf96gj15331qbmbr7lggp40000gn/T/go-build4014886209/b001/exe/test", "123", "456"}
  fmt.Printf("実際に欲しい引数 : %#v\n", os.Args[1:])
  // → []string{"123", "456"}
}
```

## flag パッケージ

コマンドライン引数の**オプション**（フラグ）を便利に扱うパッケージ。

:::message alert
簡単な場合は flag パッケージで良い。
複雑な場合は kingpin や cobra といった外部パッケージを使うのも良い。
:::

### 定義

オプションを定義するには、下記 2 つの方法がある。

- `var 変数 = flag.型名("フラグ名", デフォルト値, "説明文")` : `型名()`ではポインタが返される。
- `flag.型名Var(&変数, "フラグ名", デフォルト値, "説明文")` : 変数が既に宣言されている場合。`型名Var()`では変数にバインド（=実体を更新）する。

### パース（解析）

こうして**オプションを定義した後**、実際にそれにアクセスする前に`flag.Parse()`で、コマンドをパースしないといけない。

### 例

`go run test.go -msg=こんにちは -n=2`というように実行するコマンドの msg オプション / n オプションを実装するには、下記のように書く。

```go
var msg = flag.String("msg", "デフォルト値です", "メッセージ文")
var n int

func init() {
  flag.IntVar(&n, "n", 1, "メッセージを繰り返す回数")
}
func main() {
  // オプションをパース → 実際にフラグ変数を使えるようになる
  flag.Parse()
  fmt.Println(strings.Repeat(*msg, n)) // こんにちはこんにちは
}
```

:::message

### init()

init()は main()より先に実行される特殊な関数。
:::

# fmt.Print()

```go:main.go
import "fmt"

func main() {
  fmt.Print("Hello", "world!")
  fmt.Print("Hello", "world!")
  // -> Helloworld!Helloworld!

  // Printlnの場合は、スペースと改行が挿入される
  fmt.Println("Hello", "world!")
  fmt.Println("Hello", "world!")
  // -> Hello world!
  //    Hello world!

  hello := "Hello world!"
  // Printf : フォーマットを指定して出力する
  fmt.Printf("%s\n", hello) // %s : 文字のみを出力 (""なし)
  fmt.Printf("%#v\n", hello) // %#v : Goの文法での表現を出力
  // -> Hello world!
  //    "Hello world!"
}
```

## フォーマット指定子

`%v`には何でも渡して ok。

構造体の出力には、フォーマット指定子は`%+v`か`%#v`がいい。

```go
t := &T{ 7, -2.35, "abc\tdef" }

fmt.Printf("%+v\n", t)
// &{a:7 b:-2.35 c:abc     def}

fmt.Printf("%#v\n", t)
&main.T{a:7, b:-2.35, c:"abc\tdef"}
```

:::message
Printf のフォーマット指定方法については、下の記事が詳細に書いてある。
:::
https://qiita.com/rock619/items/14eb2b32f189514b5c3c

## 機密情報をログに漏らしたくない場合

fmt.Print でログなどに機密情報（個人情報など）をそのまま出力せず、マスキングしたい場合は、
fmt の 2 つのインターフェースを満たすメソッドをその構造体に実装したら実現できる。

- Stringer
- GoStringer
  （インターフェースの詳細は省略。）

`return "XXX-XXXX-XXXX"`とする感じ。

# プログラムの終了

`os.Exit(0)`で、プログラムを終了する。_呼び出し元にも終了状態が伝えられる_。

- 0 : 正常
- 0 以外 : 異常
