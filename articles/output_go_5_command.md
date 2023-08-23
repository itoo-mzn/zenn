---
title: "Go コマンドラインツール"
emoji: "🌊"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: true
---

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

:::message

### 標準入力からの受け取り

標準入力は`fmt.Scan()`で受け取る。

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
:::

# flag パッケージ

コマンドライン引数の**オプション**（フラグ）を便利に扱うパッケージ。

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

# 入出力

| 種類 | 変数 | 説明 |
| - | - | - |
| 標準入力 | os.Stdin | 入力（キーボードとかから待ち受けるやつ） |
| 標準出力 | os.Stdout | 出力。次のコマンドに（パイプとかで）渡すような値。なのでエラーは標準出力に出さないこと。 |
| 標準エラー出力 | os.Stderr | エラーを出力。 |

os.Stdin らは、**io.Reader**や**io.Writer**インターフェースを実装している。
なので、様々な関数やメソッドの引数として渡せる。

:::message

### io.Reader、io.Writer

それぞれ 1 つのメソッド（Read、Write）しか持たない、インターフェース。
ファイルへの書き込み、メモリへの書き込み...など、色々なものへの読み書きを抽象化している。
:::

# プログラムの終了
`os.Exit(0)`で、プログラムを終了する。*呼び出し元にも終了状態が伝えられる*。
- 0 : 正常
- 0以外 : 異常

# ファイル

```go:読み込み
func main() {
  // ファイルを開く
  f, err := os.Open("./ingo.log")

  // 関数の実行終了時にファイルを閉じるのを予約しておく
  defer f.Close()

  // ファイルの中身が格納される、空のスライスを作成
  data := make([]byte, 1024) // 最大1024byte

  // （空のスライスに）ファイルfの中身を格納
  count, err := f.Read(data)
  fmt.Println(count) // 何byte読み込んだか

  // 読み込みのエラーハンドリング
  if err != nil {
    fmt.Println("読み込みエラー", err)
  }

  // ファイルの中身を出力 (stringでキャストしないと、文字列にエンコードする前のバイト列が出力されてしまう)
  fmt.Println(string(data))
}
```

```go:作成+書き込み
func main() {
  text := "書き込みたいテキスト"
  data := []byte(text)

  // ファイル作成
  f, err := os.Create("create_sample.txt")
  if err != nil {
    fmt.Println("ファイル作成時エラー")
  }
  defer f.Close()

  // ファイルに書き込み
  count, err := f.Write(data)
  if err != nil {
    fmt.Println("ファイル書き込み時エラー")
  }
  fmt.Println(count) // // 何byte読み込んだか
}
```
```txt:create_sample.txt
書き込みたいテキスト
```

# ファイルパス
`path/filepath`パッケージを使う。

```go
path := filepath.Join("dir", "main.go")
fmt.Println(path) // dir/main.go
// 拡張子 のみ
fmt.Println(filepath.Ext(path)) // .go
// ファイル名 のみ
fmt.Println(filepath.Base(path)) // main.go
// ディレクトリ のみ
fmt.Println(filepath.Dir(path)) // dir
```