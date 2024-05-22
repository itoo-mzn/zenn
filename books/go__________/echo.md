---
title: "Echo"
---

https://echo.labstack.com/docs

# 特徴

- 高速かつ軽量
- ルーティング
  パラメーター、クエリ文字列、_カスタムハンドラー_（？）を使ってルーティングを定義できる。
- ミドルウェア機能をサポート
  ロギング、認証、エラー処理などのよくある課題を簡単に実装できるミドルウェアを提供。
- テンプレート
- コンテキストベースのリクエスト処理
  コンテキストにより、リクエスト固有のデータとパラメータへ簡単にアクセスできる。
- バリデーションとバインディング
  リクエストデータに対して、簡単にバリデーションして、構造体にバインディングできる。

# メモ

- 現時点の最新は v4。

# ガイド

## バインディング

- `Context.Bind`で構造体へバインドする。

## コンテキスト

- リクエストやレスポンスの情報（パス、パラメータ、データなど）が保持される。
- ゴルーチンから`echo.Context`にアクセスしてはいけない。
  (Go 組み込みの`context.Context`は複数のゴルーチンから同時に使われても安全。)

## Cookie

- `new(http.Cookie)`でクッキーを作成して`Context.SetCookie()`でセットしてブラウザに返す。
- `context.Cookie("name")`でクッキーを読む。

## エラー処理

- エラーとしては、`error`か`echo.*HTTPError`を返すようにする。

## サーバー

- `Echo.Start(address string)`や`Echo.StartSerever(s *http.Server)`などで起動する。

## IP アドレス

- アプリケーションの前段に HTTP(L7)プロキシ（Nginx, AWS ALB など）を置かない場合は、`echo.ExtractIPDirect()`でネットワーク層からの IP アドレスを取得する。
  （HTTP ヘッダーは信頼しないこと。クライアントが制御できるものなので。）
- プロキシを置く場合、アプリケーションにインフラのアーキテクチャ全体を認識させる必要がある。（信頼できるのはどこまでか。）
  - X-Forwarded-For ヘッダーを使用している場合は、`echo.ExtractIPFromXFFHeader()`を使う。
    - `X-Forwarded-For: <client>, <proxy1>, <proxy2>`というように、左端がクライアントの IP アドレスで、右に行くにつれてサーバー側のプロキシを指す。
  - X-Real-IP を使う場合は、`echo.ExtractIPFromRealIPHeader()`を使う。

## リクエスト

- フォームデータは`Context.FormValue()`で取得する。
- クエリパラメータは`Context.QueryParam()`で取得する。
- パスパラメータは`Context.Param()`で取得する。

### バリデーション

- Echo.Validate()でバリデーション実施。

## レスポンス

- JSON を返す場合は、`Context.JSON(HTTPステータス, 構造体)`を使う。構造体を渡すと、JSON にエンコードしてくれる。
  整形したければ`JSONPretty()`。
  クエリ文字列に pretty をつけても整形できる。（開発時に便利そう。）
  `curl http://localhost:1323/users/1?pretty`
- ファイルは`Context.File("ファイルパス")`で返す。
- BLOBやストリームもレスポンスできる。（*理解浅いので、実際に使ってみること！*）
- リダイレクトは`Context.Redirect(HTTPステータス, "URL")`。
- `Context.Response.Befor(関数)`や`.After()`でレスポンスの前後に処理を挟むことができる。（フック）

## ルーティング
- ルーティングの解決順序
  1. 静的なもの : `e.Get("/user/mew")`
  2. パラメータ : `e.Get("/user/:id")`
  3. いずれかに一致 `*` : `e.Get("/user/1/files/*")`
- e.Groupでグループ化することで、そのグループに（ミドルウェアで）共通した処理を挟むことができる。

## テスト
よくわからなかったので一旦飛ばす。
https://echo.labstack.com/docs/testing#testing-handler

