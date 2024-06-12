---
title: "Go_基本型（プリミティブ型）"
---

# 真偽値 : bool

:::message alert
他の言語のように**暗黙的に 0, 1 に変換しない**。**明示的に行う必要あり**。
:::

# 整数

- int
- int8
- int16
- rune : int32 のエイリアス。
  （UTF-8 では 1 文字を 1~4byte で表現し、最大で 4byte 必要なので 32bit 要する。）
- int64
- uint : 0 以上（負数以外）
- byte : uint8 のエイリアス。（1byte = 8bit なので。）
- uint16
- uint32
- uint64
- uintptr

:::message

### int32 と int64 の違い

int32 と int64 は、プラットフォームの bit 数によってどっちが使えるのかが異なる。
int は、32bit の数値か 64bit か、Go がプラットフォームに合わせて自動的に使い分けてくれている。
:::

:::message

### 文字列の長さの測り方

文字列の長さを知りたいときは、`rune`に変換してからでないと、1 文字が 2byte 以上の文字（日本語や絵文字など）が合った場合に、期待する値が取得できない。

```go
// 6文字
s := "abcあいう"

fmt.Println(len(s)) // 12
// 6文字じゃない?!
// "あいう"は各3byte使うため
// つまり、len()はbyte数

fmt.Println(len([]rune(s))) // 6
// 期待していた値（文字数）
```

https://zenn.dev/masafumi330/articles/3286ccbad98892
:::

# 浮動小数点数 : float

- float32
- float64

:::message
数値は `_` で区切れる。（例：`1_000_000`）
:::

# 複素数型 : complex

虚数（`i^2 = -1`の i）を扱うためのもので、complex64, complex128 がある。
（たぶん使わないので忘れることにする。）

# 文字列 : string

:::message
**ダブルクォーテーション `"` で囲む**。
シングルクォーテーション `'`で囲むのは、rune。

リテラル（改行可能な文字列）はバッククォート \`。
エスケープはバックスラッシュ `\`。
:::

# ゼロ値

変数を初期化したときのデフォルト値。

| 型       | ゼロ値                 |
| -------- | ---------------------- |
| bool     | false                  |
| int      | 0                      |
| string   | ""                     |
| error    | nil                    |
| ポインタ | nil                    |
| 配列     | 要素の型のゼロ値       |
| スライス | nil                    |
| マップ   | nil                    |
| 構造体   | フィールドの型のゼロ値 |

# 型変換(キャスト)

基本は、**strconv**パッケージを使う。

ただし、**数値**同士のキャストは`T(v)`でできる。

```go:T(v)
var f float64 = 10
var n int = int(f)
```

## strconv

- `Atoi` : 文字列 → int（32 か 64 なのかは環境依存）
- `Itoa` : int → 文字列
  :::message
  A は ASCII コード を表す。
  :::

```go:Atoi, Itoa
i, _ := strconv.Atoi("-42") // Atoi は返り値が2つあり、2つ目は使わないため、 _ で、これから使わないことを明示。
s := strconv.Itoa(-42)
```

# 型の確認方法

型の確認は、`reflect.TypeOf()` でできる。

```go
fmt.Println( reflect.TypeOf(v) )
```

# ユーザ定義型

`type 型名 基底型` で定義する。（基底型 : 基にする型。）

なので、ユーザ定義型というのは struct だけでなく、`type MyInt int`とかも定義できる。
