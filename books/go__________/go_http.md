---
title: "Go_HTTP"
---

# HTTP サーバー

HTTP 関連の型や関数を提供してくれる`net/http`パッケージを使うと、Go で HTTP サーバーを作成できる。
（HTTP クライアントも。ただそれは割愛。）

`net/http`はゴルーチンやチャネルといった並行処理の恩恵を受けている。内部ではリクエストごとにクライアントとのコネクションを生成し、それらのコネクションごとに並行して処理できる仕組みになっている。

## サーバー起動の流れ

1. **HTTP ハンドラー**を作成。
2. ハンドラーとエントリポイント（"/index"など）を結びつける。（**ルーティング**）
3. HTTP サーバーを起動。（ホスト名(IP)、ポート番号、ハンドラを指定。）

1 リクエストは 1 ゴールーチン（軽量スレッド）で動く。（並行に動く。）

```go
// ハンドラー
func sampleHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello")
}

func main() {
  // ルーティング
	http.HandleFunc("/", sampleHandler)
  // サーバ起動
	http.ListenAndServe(":8080", nil)
}
```

:::message
HTTP ハンドラーとは、リクエストに応じてレスポンスを返す関数。
:::

## 重要なオブジェクト

### Handler インターフェース

HTTP ハンドラーはインターフェース（`http.Handler`）として定義されている。
→`SereveHTTP(w ResponseWriter, r *Request)`メソッドを実装していると、HTTP ハンドラーとして振る舞える。

### HandleFunc 型

`http.HandleFunc()`は、引数に渡された関数に`http.Handler`インターフェース（`ServeHTTP(`）を実装させている。
（つまり、Handler 製造機。）

なので、

```go
func Health(w http.ResponseWriter, r *http.Request) {
	// 略
}

http.Handle("/health", http.HandlerFunc(Health))
```

は、

- `http.HandlerFunc(Health)`にて、HandlerFunc 型によって Health()をハンドラーへキャスト。
- それを第二引数にとって`Handle(pattern string, handler http.Handler)`を実行し、ハンドラーを`http.DefaultServeMux`に登録している。

:::message

```go:Handle() + HandlerFunc
http.Handle("/health", http.HandlerFunc(Health))
```

は、HandleFunc()を使うと下記で書ける。

```go:HandleFunc()
http.HandleFunc("/health", Health)
```

`HandlerFunc型`と`HandleFunc()`が似ているのでややこしいが、英語の意味で捉えるといい。

- handler : 登録されるもの。（名詞）
- handle : 登録する。（動詞）
  :::

### DefaultServeMux

`http.ServeMux`というのは、複数のハンドラをまとめるもので、パスによって使うハンドラーを切り替える。
Handle() と HandleFunc() は、デフォルトの ServeMux である`http.DefaultServeMux`に登録するようになっている。

### ListenAndServe()

第一引数はホスト名とポート番号。（ホスト名省略時は localhost）
第二引数は HTTP ハンドラー。nil の場合は、`DefaultServeMux`が使用される。

## バリデーション

**必須属性のフィールドは、型をポインタで定義する**ことで、「初期値と同じ値（int なら`0`, string なら`""`）を正しい値としてセットしてリクエストしたのに必須バリデーションで落ちてしまう」ことを回避できる。

## リクエストの値の受け取り方

- クエリパラメータ：
  - http.Request の`FormValue()`を使う。（ただし、そのフィールドに複数の値をセットされていたとしても単一の値しか取得できない。）
  - ParseForm()を実行した上で`Formフィールド`にアクセスする。
- ファイル：http.Request の`FormFile()`を使う。
- それ以外：おおよそ JSON で送られるので、json パッケージで Decode して受け取る。
