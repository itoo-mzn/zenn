---
title: "Go_制御構文"
---

# if 文

if 文で定義した変数は、if 外で使えない。

# switch 文

```go
switch i {
case 0:
    // 処理
default:
    // 処理
}
```

switch 句にも case 句にも、関数を使える。

```go
switch time.Now().Weekday().String() {
case "Monday", "Tuesday", "Wednesday", "Thursday", "Friday":
  fmt.Println("平日")
default:
  fmt.Println("休日")
}
```

:::message alert

### break

switch 単体で使う場合は、break は使わないこと。

ただし、for ループ内で switch を使い、break によってループを抜けたい場合は、for ループに label をつけてそれめがけて break する。

```go
loop:
  for {
    switch x {
    case "A":
       break loop // exits the loop
    }
  }
```

https://google.github.io/styleguide/go/decisions#switch-and-break
:::

#### fallthrough

switch では、1 つの case が実行されると break され他の case は評価しない。
（頻度は低いと思うが、）*他の case をまたぎたい*ときは、`fallthrough`を使い、処理を次の case に進める。
基本、使わないのが良い。

```go
switch num := 15; {
case num < 50:
    fmt.Printf("%d は50以下\n", num)
    fallthrough // 次のcase内処理を実行する (その際のcase分岐は検証されない)
case num > 100:
    fmt.Println("100以上")
    fallthrough
case num < 200:
    fmt.Println("200以下")
}
// 15 は50以下
// 100以上
// 200以下
```

# for 文

Go には、繰り返し処理に使う構文は for 文しかない。

```go:for
for i := 1; i <= 10; i++ {
    // 10回ループ
}
```

マップに使うと、要素ごとに key, value を取り出して処理する。

```go:マップ
studentAge := map[string]int{
    "john": 32,
    "bob":  31,
}

for name, age := range studentAge {
    fmt.Printf("%s\t%d\n", name, age)
}

// keyだけ使いたい場合
for name := range studentAge { ... }

// valueだけ使いたい場合
for _, age := range studentAge { ... }
```

### continue

continue 以下の処理は行わず、次のループに移る

```go
for i := 1; i <= 10; i++ {
    if i == 5 {
        continue
    }
    fmt.Println(i) // 5以外(1~4, 6~10)を出力
}
```

:::message

## 要素のコピーを避ける

下記の NG のやり方では、ループごとに値をコピーした変数が作成されるため、パフォーマンスに影響を及ぼす可能性がある。
（スライスを例にすると）スライス自体の大きさではなく、スライスに格納しているデータ 1 つ 1 つが大きい場合、特に重要。

OK のやり方のように、value 用の変数は新たに作らず、スライスに index で問い合わせる。

```go:NG
// ループごとに値がコピーされる
for _, v := range slice {
  // v を使う
}
```

```go:OK
for i := range slice {
  // slice[i] を使う
}
```

:::

:::message alert

## 要素を更新するときの注意

range で取り出した v を更新しても、items は更新されないので、items[i]を書き換えること。

```go:NG
for i, v := range items {
    v = Hoge{Num: i}
}
```

```go:OK
for i := range items {
    items[i] = Hoge{Num: i}
}
```

:::

## while 文

Go には while が無いので、for で実現する。

```go:while 条件で終了
for num != 5 {
    // numが5になったら終わる 無限ループ
}
```

```go:while breakで終了
for {
    // ...
    if num == 5 {
        break
    }
}
```

# defer 関数

遅延実行する。（スタックに積む。LIFO）

ただし、その実行タイミングは、defer を書いたスコープが終了するとき。
つまり、下記のコードの`hoge()内のdefer`は、`main()の"end"出力`より先に実行される。

また、**その時点での評価**（コード）をスタックに積むため、
defer 関数で変数を使っていたりして、その後で変数などに変更があったとしても、スタックされたものには影響を与えない。

```go
func hoge() {
	fmt.Println("hoge")
	defer fmt.Println("d: hoge")
	return
}

func main() {
	fmt.Println("start")
	defer fmt.Println("d: end")

	for i := 1; i <= 3; i++ {
		defer fmt.Println("d:", i)
		fmt.Println(i)
	}

	hoge()

	fmt.Println("end")
}
// start
// 1
// 2
// 3
// hoge
// d: hoge
// end
// d: 3
// d: 2
// d: 1
// d: end
```

:::message alert
defer()でエラー err を返す場合は、その前のエラーを上書いてしまっていないか要注意！
:::
