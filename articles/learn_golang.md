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

# 配列
特定の型の固定長のデータ構造。
0個以上の要素を保持することができ、それらを宣言または初期化するときにサイズの定義が必要。
また、作成後にサイズを変更することができない。
これらの理由により、配列はGoプログラムでは一般に使用されないが、スライスとマップの基盤となっている。
```go:配列
変数 := [要素数] 型 {値, 値, ..}
```

```go:main.go
func main() {
	var a [3]int
	a[1] = 10

	fmt.Println(a[0]) // 0 : intの場合、初期値が0なので 0 と出力される
	fmt.Println(a[1]) // 10
	
	fmt.Println(len(a)) // 3 : len()は要素数を取得する

	fmt.Println(a[len(a)-1]) // 0
}
```

### 要素数がわからない場合は省略できる。
```go:配列
変数 := [...] 型 {値, 値, ..}
```

```go:main.go
func main() {
	// 5個の要素を全て埋める必要はない。4, 5個目には、初期値の空文字""がセットされている。
	cities := [5]string{"東京", "大阪", "神戸"}

	fmt.Println(cities) // [東京 大阪 神戸  ]
}

func main() {
	cities := [...]string{"東京", "大阪", "神戸"} // 要素数を省略

	fmt.Println(cities) // [東京 大阪 神戸]  上記と違って、空文字が含まれていない
	
	fmt.Println(len(cities)) // 3
}
```

### 2次元配列
```go:main.go
func main() {
	var twoD [3][5]int

	for i := 0; i < 3; i++ {
		for j := 0; j < 5; j++ {
			twoD[i][j] = (i + 1) * (j + 1)
		}
		fmt.Println("Row", i, ":", twoD[i])
	}
	fmt.Println(twoD)
}
/* 出力
	Row 0 : [1 2 3 4 5]
	Row 1 : [2 4 6 8 10]
	Row 2 : [3 6 9 12 15]
	[[1 2 3 4 5] [2 4 6 8 10] [3 6 9 12 15]]
/*
```

# スライス
スライスは、同じ型の要素が連続していることを表すデータ型。
ただし、配列との大きな違いは、スライスのサイズは固定ではなく動的であるということ。
```go:スライス
変数 := [] 型 {値, 値, ..} // 配列と違い、[]内に要素数の指定不要
```

スライスのコンポーネントは次の3つのみ。
- **基になる配列**の**最初の要素へのポインター** : この要素は、必ずしも配列の最初の要素 array[0] であるとは限りません。
- スライスの**長さ** : スライス内の要素数。
- スライスの**容量** : スライスの始めから、基になる配列の終わりまでの要素数。

つまり、基になる配列に対して、ある位置からある位置まで取得した配列 ということ。

```go:main.go
func main() {
	// スライスを宣言（サイズを指定しない）
	months := []string{"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}

	fmt.Println(months)
	fmt.Println("length:", len(months)) // 要素数
	fmt.Println("capacity:", cap(months)) // 容量
}
```

## スライスの拡張
### スライス演算子 s[i:p] 
- s
  配列。
- i 
  **新しいスライスに追加する、基になる配列(または別のスライス)の最初の要素へのポインター**。
  配列内のインデックス位置iにある要素( **array[i]** )に対応。
- p
  **新しいスライスに追加する、基になる配列の最後の要素へのポインター**。
  配列内のインデックス位置p-1にある要素( **array[p-1]** )に対応。
```go:main.go
func main() {
	months := []string{"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
	fmt.Println("length:", len(months))
	fmt.Println("capacity:", cap(months))

	quarter1 := months[0:3]
	quarter2 := months[3:6]
	quarter3 := months[6:9]
	quarter4 := months[9:12]

	fmt.Println(quarter1, len(quarter1), cap(quarter1)) // [January February March] 3 12
	fmt.Println(quarter2, len(quarter2), cap(quarter2)) // [April May June] 3 9
	fmt.Println(quarter3, len(quarter3), cap(quarter3)) // [July August September] 3 6
	fmt.Println(quarter4, len(quarter4), cap(quarter4)) // [October November December] 3 3
	// lenは、そのスライスが持つ要素数。
	// capは、基になる配列を基準に、どこからスライスしたかによって変わる。

	quarter2Extend := quarter2[:4] // スライスを拡張（要素数を3→4に）
	fmt.Println(quarter2, len(quarter2), cap(quarter2)) // [April May June] 3 9
	fmt.Println(quarter2Extend, len(quarter2Extend), cap(quarter2Extend)) // [April May June July] 4 9
}
```

## 要素の追加
要素の追加に対して、スライスの容量(cap)は自動的に2のn乗で増える。（メモリが自動的に確保される）
```go:main.go
func main() {
	var numbers []int
	for i := 0; i < 10; i++ {
		numbers = append(numbers, i) // 要素を追加
		fmt.Printf("%d\tcap=%d\t%v\n", i, cap(numbers), numbers)
	}
}
/* 出力
	0       cap=1   [0]
	1       cap=2   [0 1]
	2       cap=4   [0 1 2]
	3       cap=4   [0 1 2 3]
	4       cap=8   [0 1 2 3 4]
	5       cap=8   [0 1 2 3 4 5]
	6       cap=8   [0 1 2 3 4 5 6]
	7       cap=8   [0 1 2 3 4 5 6 7]
	8       cap=16  [0 1 2 3 4 5 6 7 8]
	9       cap=16  [0 1 2 3 4 5 6 7 8 9]
/*
```

## 要素の削除
1. append()
```go:main.go
func main() {
	letters := []string{"A", "B", "C", "D", "E"} // スライス
	remove := 2 // 削除する要素の位置

	if remove < len(letters) {

		fmt.Println("Before", letters, "Remove", letters[remove]) // Before [A B C D E] Remove C

		fmt.Println(letters[remove]) // C
		fmt.Println(letters[:remove]) // [A B] = Cの手前まで
		fmt.Println(letters[remove+1:]) // [D E] = C以降
		letters = append(letters[:remove], letters[remove+1:]...) // (切り出した)[A B]に、(切り出した)[D E]を追加している

		fmt.Println("After", letters) // After [A B D E]

	}
}
```

2. copy()
#### コピーしないとどうなるか？（なぜコピーするのか）
スライスの要素を変更すると、基になる配列の要素も変更される。
なので、同じ配列を基にしている 他のスライスにも影響が及んでしまう。
```go:main.go
func main() {
	letters := []string{"A", "B", "C", "D", "E"} // スライス
	fmt.Println("Before", letters)

	slice1 := letters[0:2] // A, B
	slice2 := letters[1:4] // B, C, D

	slice1[1] = "X"
  
	fmt.Println("slice1", slice1) // slice1 [A X]
	fmt.Println("slice2", slice2) // slice2 [X C D] : 同じ配列を基にしているため、要素が変更されている
	
	fmt.Println("After", letters) // After [A X C D E] : 基にしている配列自体も、変更される
}
```

#### 配列をコピーして使う
```go:main.go
func main() {
	letters := []string{"A", "B", "C", "D", "E"}
	fmt.Println("Before", letters)

	slice1 := letters[0:2] // A, B

	slice2 := make([]string, 3) // cap=3と指定した 空のスライスが生成される
	copy(slice2, letters[1:4]) // slice2にletters[1:4]をコピーする -> B, C, D

	slice1[1] = "X"
  
	fmt.Println("slice1", slice1) // slice1 [A X]
	fmt.Println("slice2", slice2) // slice2 [B C D] : 要素が変更されていない!
	
	fmt.Println("After", letters) // After [A X C D E] : slice1が基にしている配列は当然変更される
}
```

# マップ
ハッシュのこと。
```go:マップ
変数 := [キーの型] バリューの型 {値, 値, ..}
// []内
// ・配列 : 要素数
// ・スライス : なし
// ・マップ : キーの型
```

```go:main.go
func main() {
	studentAge := map[string]int{
		"john": 32,
		"bob": 31,
	}
	fmt.Println(studentAge) // map[bob:31 john:32]
	fmt.Println(studentAge["john"]) // 32
}
```

空のマップを作るには、make()を使う。（スライスも同様）
```go
studentAge := make(map[string]int)
```

## 項目の追加、削除
```go:main.go
func main() {
	// 空のマップを作成
	studentAge := make(map[string]int)
	fmt.Println(studentAge) // map[]
	
	// マップに追加
	studentAge["john"] = 32
	studentAge["bob"] = 31
  fmt.Println(studentAge) // map[bob:31 john:32]

	// マップ内の項目にアクセス
	fmt.Println("john's age is", studentAge["john"]) // john's age is 32
	
	// マップ内にないキーでアクセスすると、初期値が返る（今回はintなので 0）
	fmt.Println("hogehoge's age is", studentAge["hogehoge"]) // john's age is 0

	// マップ内に存在するかを確認したい場合
	age, exist := studentAge["hogehoge"] // 2つ目の戻り値でboolが返る
	if exist {
    fmt.Println("hogehoge's age is", age)
	} else {
		fmt.Println("not exist")
	}


	// 項目の削除
	delete(studentAge, "john") // delete(マップ, 削除する項目のキー)
	fmt.Println(studentAge) // map[bob:31]

	// 存在しない項目を削除
	delete(studentAge, "hogehoge") // エラー（パニック）にならない
}
```

# マップ内でループさせる
range を使って、すべての項目にアクセスできる。
```go
range マップ
```

```go:main.go
func main() {
	studentAge := map[string]int{
		"john": 32,
		"bob": 31,
	}

  // 処理イメージ
	// 1. rangeによって、マップの1つ目("john": 32)がname, ageに代入される。
	// 2. {}内が実行される
	for name, age := range studentAge {
		fmt.Printf("%s\t%d\n", name, age)
		// john    32
    // bob     31
	}

	for name := range studentAge {
		fmt.Printf("%s\t", name) // john    bob
	}

	for _, age := range studentAge {
		fmt.Printf("%d\t", age) // 32      31
	}
}
```

# 構造体
```go:main.go
type Employee struct {
	ID        int
	FirstName string
	LastName  string
}

func main() {
	employee1 := Employee{1001, "Bob", "Hoge"}
	fmt.Println(employee1) // {1001 Bob Hoge}

	employee2 := Employee{FirstName: "John", LastName: "Fuga"}
	fmt.Println(employee2) // {0 John Fuga}
	fmt.Println(employee2.ID) // 0

	employee2.ID = 1002
	fmt.Println(employee2) // {1002 John Fuga}
}
```

#### ポインタを使って、コピーと元の構造体を変更
```go:main.go
func main() {
	employee := Employee{FirstName: "John", LastName: "Fuga"}
	fmt.Println(employee) // {0 John Fuga}

	// ポインタ作成
	employeeCopy := &employee
	employeeCopy.FirstName = "bob"
	fmt.Println(employeeCopy) // &{0 bob Fuga}
  
	// 元の構造体も変更されている
	fmt.Println(employee) // {0 bob Fuga}
}
```

#### 構造体の埋め込み
```go:main.go
type Person struct {
	ID        int
	FirstName string
	LastName  string
}

type Employee struct {
	Person // Personを埋め込む
	ManagerID int
}

type Contractor struct {
	Person // Personを埋め込む
	CompanyID int
}

func main() {
	employee := Employee{
		// 初期化の際は、Personフィールド（構造体）を明示しないといけない
		Person: Person{
			FirstName: "john",
		},
	}
	fmt.Println(employee) // {{0 john } 0}

	// 初期化でないので、Person経由でなくてOK
	employee.LastName = "doe"
	fmt.Println(employee) // {{0 john doe} 0}
}
```

#### 構造体↔JSON
```go:main.go
type Person struct {
	ID        int
	FirstName string `json:"name"`
	LastName  string `json:"lastname,omitempty"`
}

type Employee struct {
	Person
	ManagerID int
}

type Contractor struct {
	Person
	CompanyID int
}

func main() {
  employees := []Employee{
		Employee{
			Person: Person{
				LastName: "hoge", FirstName: "john",
			},
		},
		Employee{
			Person: Person{
				LastName: "fuga", FirstName: "bob",
			},
		},
	}

	data, _ := json.Marshal(employees) // 構造体をjsonに変換
	fmt.Printf("%s\n", data)
	// [
	// 	{"ID":0,"name":"john","lastname":"hoge","ManagerID":0},
	// 	{"ID":0,"name":"bob","lastname":"fuga","ManagerID":0}
	// ]
	
	
	var decorded []Employee
	json.Unmarshal(data, &decorded) // jsonを構造体に変換(戻す)
	fmt.Printf("%v", decorded)
	// [
	// 	{{0 john hoge} 0}
	// 	{{0 bob fuga} 0}
	// ]
}
```

# フィボナッチ数列
```go:main.go
package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	// 入力を受け取る
	input_int, _ := strconv.Atoi(os.Args[1])

	// フィボナッチ数列を作成
	slice := generateFibonacciSequence(input_int)
	fmt.Println(slice)
}

func generateFibonacciSequence(input int) []int {
	if input < 2 {
		// 入力が2未満の場合計算できないため、panicを起こしnilスライスを返す
		panic([]int{})
	} else {
		// 入力が2以上の場合、フィボナッチ数列を生成する
		
		// スライスの初期値の意味
		// 0 : ロジック上あったほうが便利なので設けたダミーの数値。(不要なので後で削除する)
		// 1 : 存在することが確定している、最初の値
		slice := []int{0, 1}

		// [入力された数値]個のフィボナッチ数列を生成
		for i := 0; i < input; i++ {
			// 追加する数値
			add_num := slice[len(slice)-2] + slice[len(slice)-1]

			// スライスに要素追加
			slice = append(slice, add_num)
		}

		// 初期値として用意していた 0 を削除
		slice = append(slice[:0], slice[1:]...)

		return slice
	}
}
```

# エラー処理
## エラー処理に関する推奨事項
Goでエラーを処理する場合は、次のような推奨事項を考慮してください。

1. エラーが予想されていなくても、エラーがないかどうかを常に確認します。
  そのうえで、不要な情報がエンドユーザーに公開されないようにします。
	(エラー処理の最も簡単な方法は、if 条件を使用すること)
2. エラーメッセージにプレフィックスを含めて、エラーの発生元がわかるようにします。 たとえば、パッケージや関数の名前を含めることができます。
3. 可能な限り、再利用可能なエラー変数を作成します。
4. エラーを返すことと、パニックの違いを理解します。 
  他に対処方法がない場合は、パニックが発生します。
	たとえば、依存関係の準備ができていない場合、プログラムは動作しません (既定の動作を実行する場合を除きます)。
5. 可能な限り多くの詳細情報でエラーをログに記録し(次のセクションで説明)、エンドユーザーが理解可能なエラーを出力します。

```go:main.go
type Employee struct {
	ID        int
	FirstName string
	LastName  string
	Address   string
}

func main() {
	employee, err := getInformation(1001)
	if err != nil {
		// なにかする
	} else {
		fmt.Println(employee)
	}
}

func getInformation(id int) (*Employee, error) {
	employee, err := apiCallEmployee(1000)

	// 修正前
	// return employee, err

	// 修正後
	// 1. エラーが予想されていなくても、エラーがないかどうかを常に確認します。
	//   そのうえで、不要な情報がエンドユーザーに公開されないようにします。
	if err != nil {
		return nil, err // apiCallEmployee()からエラーが返って来ている場合は、errのみ返す
	}
	return employee, nil
}

// 3. 可能な限り、再利用可能なエラー変数を作成します。
var ErrNotFound = errors.New("Employee not found")

func apiCallEmployee(id int) (*Employee, error) {
	if id != 1001 {
		return nil, ErrNotFound
	}

	employee := Employee{LastName: "hoge", FirstName: "john"}
	return &employee, nil
}
```

# ログ
```go:main.go
import (
	"fmt"
	"log"
)

func main() {
	log.Print("printろぐ")
	// → 2021/08/09 07:23:53 printろぐ

	log.Fatal("fatalろぐ")
	fmt.Print("これは見えない")
  // → 2021/08/09 07:23:53 fatalろぐ
	// Fatal()により、プログラムが停止するため、Fatal()以降は実行されない
}
```

```go:main.go
import (
	"fmt"
	"log"
)

func main() {
	log.Print("printろぐ")
	// → 2021/08/09 07:23:53 printろぐ

	log.Panic("panicろぐ")
	fmt.Print("これは見えない")
	// → panic: panicろぐ
	//   goroutine 1 [running]:
	//   log.Panic(0xc0000c3f58, 0x1, 0x1)
	// 	  			/usr/local/go/src/log/log.go:354 +0xae
	//   main.main()
	// 	  			/Users/itotakuya/projects/go/src/helloworld/main.go:814 +0xa5
	// Panic()以降は実行されない
}
```

```go:main.go
import (
	"log"
)

func main() {
	log.Print("printろぐ")
	// → 2021/08/09 07:23:53 printろぐ

	log.SetPrefix("main():") // ログにprefixが設定できる
  log.Print("printログ")
	log.Fatal("Fatalログ")
	// → main():2021/08/09 07:29:49 printログ
	//   main():2021/08/09 07:29:49 Fatalログ
	//   exit status 1
}
```

### ファイルにログを記録する
```go:main.go
import (
	"log"
	"os"
)

func main() {
	// ファイル作成
	// os.OpenFile(ファイル名, フラグ(ファイルが無ければ作成する等), パーミッション)
	file, err := os.OpenFile("ingo.log", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)

	if err != nil {
		log.Fatal("エラー発生")
	}

	// 後でファイルにログを記録するが、file.Close()を忘れないようにdefer予約
	defer file.Close()

	// fileにログを記録することを宣言
	log.SetOutput(file)
	// 通常どおり、log.Print()を実行することで、ファイルに記録される
	log.Print("ログ")
}
```

# メソッド
メソッドを追加することで、作成した構造体に動作を追加できる。

```go:main.go
type triangle struct {
	size int
}

// func (変数 構造体) メソッド名() 返却型 {
func (t triangle) perimeter() int {
	return t.size * 3
}

func main() {
	t := triangle{3}
	fmt.Println("この三角形の外周:", t.perimeter())
}
```

### ポインターを参照する
メソッドに、変数自体でなくポインターを渡すほうが良い場合がある。（変数のアドレスを参照する。）
- メソッドで変数を更新する場合
- 引数が大きすぎる場合（そのコピーを回避したい）

```go:main.go
type triangle struct {
	size int
}

// func (変数 構造体) メソッド名() 返却型 {
func (t triangle) perimeter() int {
	return t.size * 3
}

// *triangle で、構造体自体でなく 構造体のポインターを渡すように定義
func (t *triangle) doubleSize() {
	t.size *= 2
}

func main() {
	t := triangle{3}
	t.doubleSize() // ポインタを参照して tが更新される

	fmt.Println("size:", t.size) // size: 6
	fmt.Println("perimeter:", t.perimeter()) // perimeter: 18
}
```

#### 埋め込まれた構造体のメソッドを呼び出すことができる
```go:main.go
type triangle struct {
	size int
}

type coloredTriangle struct {
	triangle // 構造体を埋め込む
	color string
}

// func (変数 構造体) メソッド名() 返却型 {
func (t triangle) perimeter() int {
	return t.size * 3
}

func main() {
	t := coloredTriangle{triangle{3}, "blue"}
	fmt.Println("size:", t.size)
	// coloredTriangleが、triangle構造体向けのメソッドも使える
	fmt.Println("perimeter:", t.perimeter())
}
```

#### メソッドのオーバーロード
※ オーバーロード(多重定義) : 同じ名前の関数等を定義すること
```go:main.go
type triangle struct {
	size int
}

// func (変数 構造体) メソッド名() 返却型 {
func (t triangle) perimeter() int {
	return t.size * 3
}

type coloredTriangle struct {
	triangle
	color string
}

func (t coloredTriangle) perimeter() int {
	return t.size * 5
}

func main() {
	t := coloredTriangle{triangle{3}, "blue"}
	fmt.Println("size:", t.size)

	// coloredTriangleで、coloredTriangle構造体向けのメソッドを使う
	fmt.Println("perimeter:", t.perimeter()) // perimeter: 15
	// coloredTriangleで、triangle構造体向けのメソッドも使える
	fmt.Println("perimeter:", t.triangle.perimeter()) // perimeter: 9
}
```

### カプセル化

通常、他のプログラミング言語では、private または public のキーワードをメソッド名の前に配置します。 Goでは、メソッドを公開にするには大文字の識別子だけを、メソッドを非公開にするには子文字の識別子を使用する必要があります。

private : 小文字から始まる名前
public  : 大文字から始まる名前

```go:size.go
package geometry

type Triangle struct {
	size int
}

func (t *Triangle) doubleSize() {
	t.size *= 2
}

func (t *Triangle) SetSize(size int) {
	t.size = size
}

func (t *Triangle) Perimeter() int {
	t.doubleSize()
	return t.size * 3
}
```
```go:main.go
func main() {
	t := geometry.Triangle{}
	t.SetSize(3)
	
	// publicなので実行できる
	fmt.Println(t.Perimeter()) // 18

  // privateなメソッドなのでアクセスできない
	fmt.Println(t.doubleSize()) // t.doubleSize undefined
}

```

# インターフェイス
```go:main.go
// インターフェイス ------------------
type Shape interface {
	Perimeter() float64
	Area() float64
}

// 2つの構造体 ------------------
// 構造体にはインターフェイスとの関連は定義されていない

// Square構造体 
type Square struct {
	size float64
}

func (s Square) Area() float64 {
	return s.size * s.size
}

func (s Square) Perimeter() float64 {
	return s.size * 4
}

// Circle構造体
type Circle struct {
	radius float64
}

func (c Circle) Area() float64 {
	return math.Pi * c.radius * c.radius
}

func (c Circle) Perimeter() float64 {
	return 2 * math.Pi * c.radius
}

// 関数 ------------------
// パラメータとしてShapeインターフェイスを求める
func printInformation(s Shape) {
	fmt.Printf("%T\n", s)
	fmt.Println("Area:", s.Area())
	fmt.Println("Perimeter:", s.Perimeter())
	fmt.Println()
}

// main ------------------
func main() {
	var s Shape = Square{3}
	printInformation(s)

	c := Circle{6}
	printInformation(c)
}
```