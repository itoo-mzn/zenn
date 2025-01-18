---
title: "Go_ジェネリクス"
---

# ジェネリクス

ジェネリクスとは、1 つの関数で複数の型の処理ができるようにする仕組み。

```go
func 関数名[型パラメータ 型制約](普通の引数) 普通の返り値 {}
```

型引数：実際に型パラメータに渡される具体的な型のこと。(string, int, comparable など)


:::message alert
型パラメータは、**メソッドの引数**では使えない。
**関数の引数**か**メソッドのレシーバ**のみ使える。
:::

:::message
不必要な抽象化は複雑さを生む。
ジェネリクスを使う必要性があるのかどうか、慎重に判断すること。
:::

### 型制約

型パラメータに対して許可される操作やメソッドを制限するためのインターフェース。

```go
func getKeys[K comparable, V any](m map[K]V) []K {
	var keys []K
	for k := range m {
		keys = append(keys, k)
	}
	return keys
}
```

上の関数の引数`map[K]V`の V は any も可だが、K（キー）は any が不可。
マップのキーには、比較ができる（==や!=ができる）`comparable`でないといけない。

また、型制約は自分で定義できる。

```go
type customConstraint interface {
	// ~int or ~string
	~int | ~string
}

func getKeys[K customConstraint, V any](m map[K]V) []K {
	var keys []K
	for k := range m {
`		keys = append(keys, k)
	}
	return keys
}
```

:::message

### `~int`と`int`の違い

`~int`は、`int`を基底型とする型を指す。
:::

以下のように、指定のメソッドを実装していることを制約とすることもできる。

```go
type customConstraint interface {
	// ~int かつ String()メソッドを実装している
	~int
	String() string
}
```
