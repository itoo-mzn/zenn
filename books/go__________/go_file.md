---
title: "Go_ファイル"
---

# ファイル操作

## 読み込み

- ファイルを開く
  `f, err := os.Open("ファイル名")`
- 詳細なオプションを指定して、ファイルを開く
  `f, err := os.OpenFile(ファイル名, フラグ(ファイルが無ければ作成する等), パーミッション)`
- ファイルを読み込む
  `[*os.File型].Read(読み込んだデータを格納するスライス)`

```go:読み込み
func main() {
  // ファイルを開く
  f, err := os.Open("./ingo.log")
  defer f.Close()

  // ファイルの中身を格納する、空のスライスを作成
  data := make([]byte, 1024) // 最大1024byte

  // （空のスライスに）ファイルfの中身を格納
  count, err := f.Read(data)
  fmt.Println(count) // 何byte読み込んだか
  if err != nil {
    fmt.Println("読み込みエラー", err)
  }

  // ファイルの中身を出力 (stringでキャストしないと、文字列にエンコードする前のバイト列が出力されてしまう)
  fmt.Println(string(data))
}
```

## 作成+書き込み

- ファイルを作成
  `f, err := os.Create("ファイル名")`
- ファイルを読み込む
  `[*os.File型].Write(書き込む文字列を格納したスライス)`

```go
func main() {
  text := "書き込みたいテキスト"
  data := []byte(text)

  // ファイル作成
  f, err := os.Create("create_sample.txt")
  if err != nil {
    fmt.Println("ファイル作成時エラー")
  }
  defer f.Close()

  // ファイルに書き込み
  count, err := f.Write(data)
  if err != nil {
    fmt.Println("ファイル書き込み時エラー")
  }
  fmt.Println(count) // // 何byte読み込んだか
}
```

```txt:create_sample.txt
書き込みたいテキスト
```

:::message

### 文字列 → []byte へのキャスト

[]byte（[]uint8）への変換は、（int 同士の変換のように）特別に`[]byte()`でキャストできる。

```go
bytes := []byte(text)
```

:::

# ファイルパス

`path/filepath`パッケージを使う。

```go
path := filepath.Join("dir", "main.go")

fmt.Println(path) // dir/main.go
// 拡張子 のみ
fmt.Println(filepath.Ext(path)) // .go
// ファイル名 のみ
fmt.Println(filepath.Base(path)) // main.go
// ディレクトリ のみ
fmt.Println(filepath.Dir(path)) // dir
```
