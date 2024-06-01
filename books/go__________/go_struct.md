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
