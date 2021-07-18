---
title: "Go 学習メモ"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: false
---

# プログラム実行
Goは、mainパッケージ内のmain関数からプログラムがスタートする。
（プログラムがスタートする地点のことを、エントリーポイントという。）

## 実行
Goファイルがあるフォルダーに移動。
```zsh
go run main.go

# 移動しない場合
go run ./src/helloworld/main.go
```

runコマンドは、ビルド(下記buildコマンド) + 実行 を行っている。

## ビルド
```zsh
go build main.go
```
ビルドすると、実行したファイル(main.go)の拡張子がないverのファイル(main)が生成される。

# ステートメント
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

# 変数
```go
// 1
var firstName, lastName string
var age int

// 2
var (
	firstName, lastName string
	age int
)

// 3
var (
	firstName = "ichiro" // 型が推定される
	lastName = "tanaka"
	age = 20
)

// 4
firstName, lastName := "ichiro", "tanaka" // 定義+代入を同時に
age := 20 // int
age = age /3 // = 6 になる（int = 整数 のため小数が切り捨てられた）
```

# 定数
```go
const (
	StatusOk = 0 // 変数のように := は使わない
	StatusError = 1
)
```

# 型
## 浮動小数点数(float32, float64)
```go
var shousuu1 float32 = 2.11
shousuu2 := 2.11
```
## 真偽値(bool)
他の言語のように暗黙的に0, 1に変換しない。明示的に行う必要あり。

## 文字列(string)
ダブルクォーテーション (") で囲む。シングルクォーテーション (')で囲むのは、rune。

## 型変換・キャスト
```go:main.go
import "strconv"

func main() {
    i, _ := strconv.Atoi("-42") // Atoi: 文字列 → 数値へパース。Atoi は返り値が2つあり、2つ目は使わないため、 _ で、これから使わないことを明示。
    s := strconv.Itoa(-42)
    println(i, s)
}
```

型の確認は、reflect.TypeOf() でできる。
```go
fmt.Println(reflect.TypeOf(num1))
// println(reflect.TypeOf(num1)) （つまりビルトインのprintln）では変な出力になる。
```

# 標準入力
```go:main.go
import (
	"os"
	"strconv"
)

func main() {
	number1, _ := strconv.Atoi(os.Args[1]) // os.Argsで標準入力を受け取り
	number2, _ := strconv.Atoi(os.Args[2])
	println("合計:", number1+number2)
}
```
```zsh
# 実行
go run src/helloworld/main.go 3 5

# 結果
合計: 8
```

# Print関数について
TODO: 使いこなせていないので、後で詳しく調べること
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
	fmt.Printf("%s\n", hello) // TODO
	fmt.Printf("%#v\n", hello) // TODO
	// -> Hello world!
	//    "Hello world!"
}
```

# 関数
```go:main.go
import (
	"os"
	"strconv"
)

func main() {
	sum := sum(os.Args[1], os.Args[2])
	println("合計:", sum)
}

// func 関数名(引数名 型) 返り値の型 { ... }
func sum(number1 string, number2 string) int {
	int1, _ := strconv.Atoi(number1)
	int2, _ := strconv.Atoi(number2)
	return int1 + int2
}
```
```go
// func 関数名(引数名 型) (返り値名 返り値の型) { ... }
func sum(number1 string, number2 string) (result int) {
	int1, _ := strconv.Atoi(number1)
	int2, _ := strconv.Atoi(number2)
	result = int1 + int2
	return result
}
```

## ポインター
  値を関数に渡すとき、**その関数内での変更は、呼び出し元に影響を与えない**。

  :::message
  Go は"値渡し"の言語。
  つまり、関数に値を渡すたびに、Goがその値を受け取って**ローカルコピー(メモリ内の新しい変数)を作成**する。
  :::

```go:main.go
func main() {
	first := "ジョン"
	updateName(first)
	println(first) // ジョン と出力される
}

func updateName(name string) {
	name = "田中" // update
}
```

  updateName関数で行う変更を main関数のfirst変数にも反映させるには、ポインターを使用する。
  **ポインターで、値ではなくアドレスメモリを渡すことで、呼び出し元にも反映される**。

  #### ポインター
  **変数のメモリアドレス**を格納する変数。
  #### &演算子
  その後にあるオブジェクトのアドレスを取得。
  #### *演算子
  ポインターを逆参照する。つまり、ポインターに格納されたアドレスにあるオブジェクトへアクセスする。

```go:main.go
func main() {
	first := "ジョン"
	updateName(&first) // ポインター(メモリアドレス)を渡す
	println(first) // 田中 と出力される
}

func updateName(name *string) { // 注: 変数名でなく、型のとなりに*を書く
	*name = "田中" // ポインター先の文字列をupdate
}
```

# パッケージ
## スコープ
Goには、public や private キーワードが存在しない。
変数や関数の先頭文字が 小文字 or 大文字 で判断される。
#### プライベート
名前の先頭が小文字。
#### パブリック
名前の先頭が大文字。

```go:sum.go
// 自作したpackage
package calculator

// パッケージの中からしか呼び出せない
var logMessage = "[LOG]"

// どこからでもアクセスできる
var Version = "1.0"

// パッケージの中からしか呼び出せない
func internalSum(number int) int {
	return number - 1
}

// どこからでもアクセスできる
func Sum(number1, number2 int) int {
	return number1 + number2
}
```

## モジュールを作成
上のコードでモジュールを作成するには、そのコード(ファイル)があるカレントディレクトリで `go mod init` を実行する。
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
```go:main.go
// 自作（calculator）パッケージを使う
import "github.com/myuser/calculator"

func main() {
	total := calculator.Sum(3, 5)
	println(total)
	println("version: ", calculator.Version)
}
```

:::message
上記のようにコードを書くだけでは使えない。
:::

1. 呼び出す側のファイルがあるディレクトリで `go mod init` を実行する。
```
go mod init github.com/myuser/calculator
```
2. 生成された go.mod ファイルを編集。
```diff go:go.mod
module helloworld

go 1.14

+ require github.com/myuser/calculator v0.0.0

+ replace github.com/myuser/calculator => ../calculator
```

# if文
```go:main.go
import "fmt"

func givemeanumber() int {
	return -1
}

func main() {
	// 変数numを定義して、それをif内で使う
	if num := givemeanumber(); num < 0 {
		fmt.Println(num, "is negative")
	} else if num < 10 {
		fmt.Println(num, "has only one digit")
	} else {
		fmt.Println(num, "has multiple digits")
	}

	// if文で定義した変数numは、if外で使えない
	fmt.Println(num) // エラー undifed: num
}
```

# swich文
```go:main.go
import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	sec := time.Now().Unix() // UNIXタイム	
	rand.Seed(sec) // seed値としてUNIXタイムを使い、実行の度(1秒毎?)にランダムな値を生成
	i := rand.Int31n(10) // 0~10 の乱数
	fmt.Println(i)
	
	switch i {
	case 0:
		fmt.Println("zero")
	case 1:
		fmt.Println("one")
	case 2:
		fmt.Println("two")
	default: // デフォルト
		fmt.Println("default output")
	}

	fmt.Println("ok")
}
```

## switch文に関数を使用できる
  switch句にも、case句にも関数を使える。
```go:main.go
import (
	"fmt"
	"time"
)

func main() {
	switch time.Now().Weekday().String() {
	case "Monday", "Tuesday", "Wednesday", "Thursday", "Friday":
		fmt.Println("平日")
	default:
		fmt.Println("休日")
	}

	fmt.Println(time.Now().Weekday().String())
}
```

## fallthrough
```go:main.go
import "fmt"

func main() {
	switch num := 15; {
	case num < 50:
		fmt.Printf("%d は50以下\n", num)
		fallthrough
	case num > 100:
		fmt.Println("100以上")
		fallthrough // caseを検証しない
	case num < 200:
		fmt.Println("200以下")
	}
	// -> 15 は50以下
	//    100以上  (fallthroughによって、case文(num > 100)が無視される)
	//    200以下
}
```

# for文
- forの後ろに`()カッコ`不要。
- 3つの引数は、`; セミコロン`で区切る。
```go:main.go
import "fmt"

func main() {
	sum := 0
	
	for i := 1; i < 100; i++ {
		sum += i
	}
	fmt.Println("sumは", sum)
}
```
## while
#### Goに while は無いので、forで実現する。
- for文には、条件式のみ でOK。
```go:main.go
import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	var num int64 // 空の変数
	rand.Seed(time.Now().Unix()) // 乱数 生成器
	
	// numがたまたま 5 にならない限りループする (= while)
	for num != 5 {
		num = rand.Int63n(15) // 0~15の乱数
		fmt.Println(num)
	}
}
```

## 無限ループとbreak
```go:main.go
import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	var num int32
	sec := time.Now().Unix()
	rand.Seed(sec)

	for {
		fmt.Print("ループ中")

		if num = rand.Int31n(10); num == 5 { // 変数を定義して、それをif内で使う
			fmt.Println("終了")
			break // ループから抜ける
		}

		// break実行時には、この行は実行されない
		fmt.Println(num)
	}
}
```

## continue
```go:main.go
func main() {
	sum := 0
	for num := 1; num <= 10; num++ {
		// numが3の倍数なら、sumに足さない
		if num%3 == 0 {
			continue // continue以下の処理は行わず、次のループに移る
		}
		fmt.Println(num)
		sum += num
	}
	fmt.Println(sum)
}
```

# defer関数
遅延実行する。
```go:main.go
import "fmt"

func main() {
	for i := 1; i <= 3; i++ {
		defer fmt.Println("defer", -i) // [1, 2, 3]とスタック的に保管され、3, 2, 1の順で遅延実行される（取り出される）
		fmt.Println("regular", i) // ここで"regular 3"が終わると、deferが遅延実行される

		/* 出力
		regular 1
		regular 2
		regular 3
		defer -3
		defer -2
		defer -1
		*/
	}
}
```

```go:main.go
import (
	"fmt"
	"io"
	"io/ioutil"
	"os"
)

func main() {
	f, err := os.Create("notes.txt") // ファイル新規作成
	if err != nil {
		return
	}
	defer f.Close() // 閉じる。忘れないようにdeferで遅延実行を予約しておく（以下に大量のコードがある場合など）

	// if文で変数を定義するパターン
	if _, err = io.WriteString(f, "これが書き込まれる"); err != nil {
		return
	}

	out, _ := ioutil.ReadFile("notes.txt") // ファイル読み込み
	fmt.Println(string(out)) // 出力

	f.Sync() // メモリ上のファイル内容をディスクに書き出す（内容を同期）
}
```

# 例外処理
panic と recover の組み合わせは、Go での特徴的な例外処理方法。
（他のプログラミング言語では、try/catch。）

## panic関数
プログラムを強制的にパニックにする。ログメッセージを出力してクラッシュする。
```go:main.go
import "fmt"

func main() {
	g(0) // 関数g()を実行
	fmt.Println("finish") // panicにより、この行は実行されない
}

func g(i int) {
	if i > 3 {
		fmt.Println("パニック前") // 2. panic前の処理は、ふつうに2番目に実行される
		panic("パニック") // 4. deferの後に実行される
	}

	defer fmt.Println("defer:", i) // 3. panic("パニック")より先に実行される

	fmt.Println("print:", i) // 1. まずはこの行が実行される
	g(i + 1) // 再帰(panicが無ければ、無限に繰り返す)
}

/* 出力
  print: 0
  print: 1
  print: 2
  print: 3
  パニック前
  defer: 3
  defer: 2
  defer: 1
  defer: 0
  panic: パニック

  goroutine 1 [running]:
  main.g(0x4)
          /Users/itotakuya/projects/go/src/helloworld/main.go:329 +0x22e
  main.g(0x3)
          /Users/itotakuya/projects/go/src/helloworld/main.go:335 +0x17a
  main.g(0x2)
          /Users/itotakuya/projects/go/src/helloworld/main.go:335 +0x17a
  main.g(0x1)
          /Users/itotakuya/projects/go/src/helloworld/main.go:335 +0x17a
  main.g(0x0)
          /Users/itotakuya/projects/go/src/helloworld/main.go:335 +0x17a
  main.main()
          /Users/itotakuya/projects/go/src/helloworld/main.go:322 +0x2e
  exit status 2
*/
```

## recover関数
`panic()`後に、制御できる。
`defer()`の中で実行できる。
`panic()`と違い、ログメッセージを出力しない。
```go:main.go
import "fmt"

func main() {
	defer func() { // 5. panicが発生したので、deferの後で実行される
		if r := recover(); r != nil { // panicが起きたときに、catchするよう予約
			fmt.Println("リカバーした", r) // r = "パニック"
		}
	}()

	g(0)
	fmt.Println("finish!!") // panicにより、この行は実行されない
}

func g(i int) {
	if i > 3 {
		fmt.Println("パニック前") // 2. panic前の処理は、ふつうに2番目に実行される
		panic("パニック") // 4. panic発生
	}

	defer fmt.Println("defer:", i) // 3. recover() より先に実行される

	fmt.Println("print:", i) // 1. まずはこの行が実行される
	g(i + 1) // 再帰(panicが無ければ、無限に繰り返す)
}

/* 出力
	print: 0
	print: 1
	print: 2
	print: 3
	パニック前
	defer: 3
	defer: 2
	defer: 1
	defer: 0
	リカバーした パニック
/*
```

# 練習問題（復習）
## FizzBuzz
```go:main.go
func main() {
	fizzBuzz(15)
	fizzBuzz(10)
	fizzBuzz(9)
	fizzBuzz(2)
}

func fizzBuzz(i int) {
	switch {
	case i%15 == 0:
		fmt.Println("FizzBuzz")
	case i%5 == 0:
		fmt.Println("Buzz")
	case i%3 == 0:
		fmt.Println("Fizz")
	default:
		fmt.Println(i)
	}
}
```

## 平方根を推測する
```go:main.go
func main() {
	guessSquare(25)
}

func guessSquare(i float64) {
	// 計算途中値（初期値は1）
	sqroot := 1.00
	// 計算結果
	guess := 0.00

	// 計算するのは10回まで
	for count := 1; count <= 10; count++ {
		// 計算する（下記ニュートン法）
		// sqroot n+1 = sqroot n − (sqroot n * sqroot n − x) / (2 * sqroot n)
		guess = sqroot - (sqroot*sqroot-i)/(2*sqroot)

		if sqroot == guess {
			// 計算前後で結果が同じであれば、それが平方根
			fmt.Println("平方根は:", guess)
			break // ループ10回以下でも終了
		} else {
			// ループ
			fmt.Println("計算途中:", guess)
			sqroot = guess
		}
	}
}
```

## 入力した数値を出力する
```go:main.go
func main() {
	val := 0

	// 繰り返し整数の入力を求めます。 ループの終了条件は、ユーザーが負の数を入力した場合です。
	for val >= 0 {
		fmt.Print("数字を入力 : ")
		fmt.Scanf("%d", &val)
		if val == 0 {
			// 数が 0 の場合は、0 is neither negative nor positive と出力します。 数の要求を続けます。
			fmt.Println(val, "is neither negative nor positive")
		} else if val < 0 {
			// ユーザーが負の数を入力したら、プログラムをクラッシュさせます。 その後、スタック トレース エラーを出力します
			panic("負の数なので終了")
		} else {
			// 数が正の値の場合は、You entered: X と出力します (X は入力された数)。 数の要求を続けます。
			fmt.Println("入力したのは :", val)
		}
	}
}
```