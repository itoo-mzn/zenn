---
title: "Go_色々なフォーマットのデータ"
---

## JSON

- json.Marshal() : 構造体を json に変換
- json.Unmarshal() : json を構造体に変換

```go
type Person struct {
  ID        int
  // jsonタグを使う
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
