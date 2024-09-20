---
title: "Go_HTTP"
---

# HTTP サーバー

Go で HTTP サーバーを作成するには、HTTP 関連の型や関数を提供してくれる`net/http`パッケージを使う。

## <作成の流れ>

1. **HTTP ハンドラ**を作成。
2. ハンドラとエントリポイント（"/index"など）を結びつける。（**ルーティング**）
3. HTTP サーバを起動。（ホスト名(IP)、ポート番号、ハンドラを指定。）

1 リクエストは 1 ゴールーチン（軽量スレッド）で動く。（並行に動く。）

```go
// ハンドラ
// 引数: (レスポンスを書き込む先, リクエスト)
func handler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprint(w, "Hello") // 書き込み
}

func main() {
  // ルーティング
	http.HandleFunc("/", handler)
  // サーバ起動
	http.ListenAndServe(":8080", nil)
}
```

### http.Handler インターフェース

HTTP ハンドラはインターフェース（`http.Handler`）として定義されている。
→`SereveHTTP(w ResponseWriter, r *Request)`というメソッドを持っていると、HTTP ハンドラ型となる。

### http.HandleFunc 型

`HandleFunc`は、引数に渡された関数に`http.Handler`インターフェース（`ServeHTTP(`）を実装させている。（つまり、http.Handler を製造している。）
ハンドラは、`http.DefaultServeMux`に登録される。

なので、

```go
http.Handle("/health", http.HandlerFunc(Health))
```

は、Health 関数（`func Health(w http.ResponseWriter, r *http.Request) { ... }`）を HandlerFunc 型によって Handler インターフェースを満たすものへと進化させていて、
それを第二引数にとって`http.Handle(pattern string, handler http.Handler)`を実行している。

### http.DefaultServeMux

`http.ServeMux`というのは、複数のハンドラをまとめるもので、パスによって使うハンドラを切り替える。
http.Handle と http.HandleFunc は、デフォルトの ServeMux である`http.DefaultServeMux`を使っている。

:::message
handler : 登録されるもの。（名詞）
handle : 登録する。（動詞）
:::

### http.ListenAndServe

第一引数はホスト名とポート番号。（ホスト名省略時は localhost）
第二引数は HTTP ハンドラ。nil の場合は、http.HandleFunc などで登録されたハンドラが使用される。

### http.ResponseWriter

### http.Error

### JSON を返す

encoding/json パッケージを使う。
構造体やスライスを JSON（のオブジェクトや配列）にできる。
