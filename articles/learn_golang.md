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

