---
title: "Go_構造体"
---

# 構造体

**型の異なる**データを集めたデータ型。

## 宣言・初期化・アクセス

```go
// 宣言
type User struct {
  Name string
  Age  int
}

// 初期化
u := User{Name: "太郎", Age: 20}

// 代入・参照
u.Age = 30
fmt.Println(u.Name, u.Age) // 太郎 30
```

## 構造体の埋め込み

```go
type Person struct {
  ID        int
  FirstName string
  LastName  string
}

type Employee struct {
  Person // Personを埋め込む
  ManagerID int
}

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
```

## 構造体 ↔JSON

- json.Marshal() : 構造体を json に変換
- json.Unmarshal() : json を構造体に変換

```go
type Person struct {
  ID        int
  FirstName string `json:"name"`
  LastName  string `json:"lastname,omitempty"`
}

type Employee struct {
  Person
  ManagerID int
}

employees := []Employee{
  {
    Person: Person{
      LastName: "hoge", FirstName: "john",
    },
  },
  {
    Person: Person{
      LastName: "fuga", FirstName: "bob",
    },
  },
}

data, _ := json.Marshal(employees) // 構造体をjsonに変換
fmt.Printf("%s\n", data)
// [
//   {"ID":0,"name":"john","lastname":"hoge","ManagerID":0},
//   {"ID":0,"name":"bob","lastname":"fuga","ManagerID":0}
// ]


var decorded []Employee
json.Unmarshal(data, &decorded) // jsonを構造体に変換(戻す)
fmt.Printf("%v", decorded)
// [
//   {{0 john hoge} 0}
//   {{0 bob fuga} 0}
// ]
```

# 関数

## Named return value

返り値の定義で変数を指定すると、それをそのまま関数内で使え、return 時にはそれが返される。

```go
func greetingPrefix(language string) (prefix string) {
	switch language {
	case japanese:
		prefix = japaneseHelloPrefix
	default:
		prefix = englishHelloPrefix
	}
	return
}
```

https://zenn.dev/yuyu_hf/articles/c7ab8e435509d2

# メソッド

`func (変数 レシーバ) メソッド名() 返却型 { ... }`

メソッドは、**レシーバ**（= 構造体 や その他何かのデータ）**に紐付けられた関数**。
メソッドによって、作成した構造体やデータに動作を追加できる。

**レシーバは、第 0 引数みたいなイメージ**。（なので変数の値のコピーが発生する。）

## レシーバにポインターを使う

メソッドに、変数でなくポインターを渡すほうが良い場合がある。（変数のアドレスを参照する。）

- メソッドで変数を更新する場合。
- 引数が（データ容量として）大きすぎる場合。→ そのコピーを回避したい。

```go
type triangle struct {
  size int
}

// ポインタを使わないメソッド
func (t triangle) perimeter() int {
  return t.size * 3
}

// ポインタを使うメソッド
func (t *triangle) doubleSize() {
  t.size *= 2 // return しない
}

t := triangle{3}
t.doubleSize() // ポインタを参照して tが更新される

fmt.Println("size:", t.size) // size: 6
fmt.Println("perimeter:", t.perimeter()) // perimeter: 18
```

:::message
メソッドにポインターを使うこの用法はよく使われるので、シンタックスシュガーがある。

`(&t).doubleSize()` 本来はこう書かないといけないが、
`t.doubleSize()` こう書いても同じ意味になる。
:::

:::message alert
下記については詳細を省略。

- メソッド値 : メソッドを値として扱える。なので、変数にメソッドを格納して、それを別の場所で実行できたりする。
- メソッド式 : おおよそメソッド値と同じようなこと。違いは、レシーバでなく型を渡しているだけなので、メソッド式にはレシーバを第一引数に渡す必要がある。

:::

## 構造体の埋め込み

```go
type triangle struct {
  size int
}

type coloredTriangle struct {
  triangle // 構造体を埋め込む
  color string
}

func (t triangle) perimeter() int {
  return t.size * 3
}

t := coloredTriangle{triangle{3}, "blue"}

fmt.Println("size:", t.size) // triangleのメソッドも使える

fmt.Println("perimeter:", t.triangle.perimeter())
fmt.Println("perimeter:", t.perimeter()) // ↑の書き方のシンタックスシュガー
```

また、**埋め込んだ構造体のメソッドをオーバーロード**することもできる。
※ オーバーロード(多重定義) : 同じ名前の関数等を定義すること。

その場合、下記のように、**埋め込んだ側・埋め込まれた側どちらのメソッドも使用することができる**。

```go
type triangle struct {
  size int
}

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

t := coloredTriangle{triangle{3}, "blue"}

// coloredTriangleのメソッドを使う
fmt.Println("perimeter:", t.perimeter()) // perimeter: 15

// triangleのメソッドも使える
fmt.Println("perimeter:", t.triangle.perimeter()) // perimeter: 9
```

:::message
Go には**継承は無い**。
↑ の**構造体の埋め込み**で行っているのは**継承ではなく、委譲**。
:::

### カプセル化

パッケージ外からは public（頭文字が大文字）なメソッド・フィールドしか参照できないため、それによってカプセル化を行う。

