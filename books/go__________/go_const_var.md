---
title: "Go_定数、変数"
---

# 定数

コンパイル時に作成されるので、プリミティブな値のみが使える。
（変数は、関数実行の結果など、自由に定義できる。）

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

```go:iota
const (
  a = iota // 0
  b        // 1
  c        // 2
)
```

# 変数

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
