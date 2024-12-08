---
title: "Go_定数、変数"
---

# 定数

コンパイル時に作成されるので、基本型（プリミティブな値）のみが使える。
（スライスやマップも使えない。複合型なので。）
（変数では、関数実行の結果など、自由に定義できる。）

:::message
Go の定数では複合型（スライスやマップ、構造体など）を定義できないのは、コンパイル以降、_その定数にいつアクセスしても同じ値_ であることを保証するため。
JavaScript などでは、オブジェクトや配列を定数にできるが、それらの価が書き換えできてしまう。
Go ではそれができないように厳格になっている。
:::

## 宣言

`:=`を使うと変数になるので、定数には使えない。

```go
const limit = 100
const (
  StatusOk = 0
  StatusError = 1
)
```

### iota

`iota` を使うと、0 起点で 1 ずつ大きくなる定数を簡単に定義できる。

ゼロ値の 0 と区別がつくように、`iota + 1` を初期値とするのが一般的。

iota でインクリメントが発生するのは、_改行されるたび_。（参照されるたび ではない。）

```go:iota
type CarType int

const (
  a CarType = iota + 1 // 1
  b                    // 2
  c                    // 3
)
```

準標準パッケージの stringer を使うと、iota で定義した定数を、数値でなく文字列と紐づけできる。
（`//go:generate stringer -type=XXX`というように型ごとに 1 行ずつ書いて、go generate を実行。`XXX_stringer.go`というファイルが生成される。）

:::message alert
↑ の例でいうと、a と b の間に定数を追加してしまった場合、b 以降の値が全て変更されてしまうので注意。
DB に値を保存していたり、batch サーバーなど別のプロセスから参照される事がある場合、値がズレてしまいアウト。
:::

:::message
ラベルを出力する用の String()メソッドを定義しておくと良い。

https://qiita.com/ksato9700/items/6228d4eb6d5b282f82f6#%E6%95%B4%E6%95%B0%E5%AE%9A%E6%95%B0%E5%80%A4%E3%81%AB%E3%81%AFstring%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%82%92%E5%AE%9A%E7%BE%A9%E3%81%97%E3%81%A6%E3%81%8A%E3%81%93%E3%81%86-add-string-method-for-integers-const-values
:::

# 変数

## 宣言

1: 宣言と代入を分ける方法

```go
var age int
age = 20

var firstName, lastName string
firstName = "ichiro"
lastName = "tanaka"
```

2: 宣言をまとめる方法（代入は別々）

```go
var (
  age int
  firstName, lastName string
)
age = 20
firstName = "ichiro"
lastName = "tanaka"
```

3: 宣言と代入を一度に行う方法（`var`）

```go
var age = 20
var (
  firstName = "ichiro" // 型が推定される
  lastName = "tanaka"
)
```

4: 宣言と代入を一度に行う方法（`:=`）

```go
age := 20
firstName, lastName := "ichiro", "tanaka"
```

基本的には 4.の省略記法を使えばいい。

ただし、`:=`は関数内でしか使えない。

## シャドーイング

**異なるスコープで同じ名前の変数を再宣言すると、その変数はスコープ外の値には影響を与えない**。

```go
x := 1
if ... {
  x := 2
}
// ここ（if文の外）では x は 1
```

なのでこの例でいうと、x を 2 に更新したいなら、下記のように書く。

```go
x := 1
if ... {
  x = 2 // := でなく、=
}
```

## 命名

- MixedCaps（意味区切りで大文字）を使う。`_`は使わない。

- 略語は全て大文字にする。ただし、パッケージ内に閉じる場合は全て小文字。
  Id, Url ではなく、ID, URL（id, url）にする。

- できるだけ短い名前が好まれる。が、スコープが大きいものについては、説明的な名前にすること。

- 名前に型情報は含めない。（IDE でカーソルをあわせたら型情報はわかるので。）
