---
title: "Go 学習メモ"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: false
---

# プログラム実行
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