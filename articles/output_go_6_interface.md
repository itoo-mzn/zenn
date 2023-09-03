---
title: "Go インターフェース"
emoji: "🕌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: true
---

# インターフェース
`type インターフェース名 interface { ... }`
- Go では**インターフェースでしか抽象化できない**。
- インターフェースを実装した具象を定義する際、Javaとかみたいに`implements`などのキーワードはいらない。
  逆に言うと、**この型がそのインターフェースを実装しているのかどうか**が分からなくなるが、下記のようにしてチェックできる。
  ```go:インターフェースを満たすかチェック
  // Funcという型を定義。
  // それは、stringを返す関数（func）。
  type Func func() string

  // Func型にStringメソッドを定義。
  // Stringメソッドはstringを返す。
  // 自分自身（fという関数（func））をそのまま返す。
  func (f Func) String() string { return f()}

  // というFunc型, Stringメソッドを、fmt.Stringerというインターフェースを満たすものとして作ったとして、
  // それが実際にfmt.Stringerというインターフェースを満たすのかをチェックするのが下記コード。
  // （fmt.Stringer というのは、Stringメソッドを持つインターフェース。fmt.Printfで使用される。）

  // 右辺が左辺と等しいかどうかを確認。
  // もし等しくなければコンパイルエラーが起きるので、インターフェースを満たしていないということが分かる。
  // Funcには本来関数を渡して初期化するが、チェックのためだけに使うのでnilを渡し、返り値も使わないので、_で受け取っている。
  var _ fmt.Stringer = Func(nil)
  ```

### empty interface

empty interface（`interface{}`）を使うと、どの型の値も実装していることになる。
つまり、**何でも入れれる箱**が作れる。（Java の Object 型に近いらしい。）

```go
var v interface{}
v = 100
v = "hoge" // 普通なら代入できないが、できる
```

（空のインターフェースというのはつまり、（インターフェースを満たす条件となる）メソッドを定義していないということ。
int や string など色々な型は、**空のインターフェースを既に実装している**ということになるので、何でもボックスになる。）

ただし、それをすると型の恩恵が受けれなくなるため、**基本使うべきではない**。どうしてもそうしたい場合のみ使う。

## インターフェースの設計
- **メソッドリストは小さく**するのが良い。
  - **共通点を抜き出して抽象化しない**。
  - **1つの振る舞い（塊）を1つのインターフェース**にする。
  - **型を使うクライアント（ユーザ）が触れる部分がインターフェースでなくてもよい**。

## インターフェースの合成
https://zenn.dev/itoo/articles/output_go_4_type_func
こちらで構造体の埋め込みについて記載したが、インターフェースも埋め込み（合成）できる。

```go:インターフェースの合成
type Reader interface { Read(p []byte) (n int, err error) }
type Writer interface { Write(p []byte) (n int, err error) }
type ReadWriter interface { 
	Reader
	Writer
}
```