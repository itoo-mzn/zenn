---
title: "Go HTTPサーバ"
emoji: "🐷"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go"]
published: false
---

# HTTPサーバー
GoでHTTPサーバーを作成するには、HTTP関連の型や関数を提供してくれる`net/http`パッケージを使う。

## <作成の流れ>
1. **HTTPハンドラ**を作成。
2. ハンドラとエントリポイント（"/index"など）を結びつける。（**ルーティング**）
3. HTTPサーバを起動。（ホスト名(IP)、ポート番号、ハンドラを指定。）

1リクエストは1ゴールーチンで動く。（並行に動く。）

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

### http.handler
HTTPハンドラはインターフェース（`http.handler`）として定義されている。
→`SereveHTTP`というメソッドを持っていると、HTTPハンドラ型となる。

### http.HandleFunc
`HandleFunc`は、ハンドラを登録する関数。
引数に渡された関数に`http.handler`（`ServeHTTP`）を実装させている。
ハンドラは、`http.DefaultServeMux`に登録される。

### http.DefaultServeMux
`http.ServeMux`というのは、複数のハンドラをまとめるもので、パスによって使うハンドラを切り替える。
http.Handleとhttp.HandleFuncは、デフォルトのServeMuxである`http.DefaultServeMux`を使っている。

:::message
handler : 登録されるもの。（名詞）
handle : 登録する。（動詞）
:::

### http.ListenAndServe
第一引数はホスト名とポート番号。（ホスト名省略時はlocalhost）
第二引数はHTTPハンドラ。nilの場合は、http.HandleFuncなどで登録されたハンドラが使用される。

### http.ResponseWriter

### http.Error

### JSONを返す
encoding/jsonパッケージを使う。
構造体やスライスをJSON（のオブジェクトや配列）にできる。