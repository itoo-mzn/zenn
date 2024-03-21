---
title: "Echo"
emoji: "🙌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["echo", "Go"]
published: false
---

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

## IPアドレス

- アプリケーションの前段にHTTP(L7)プロキシ（Nginx, AWS ALBなど）を置かない場合は、`echo.ExtractIPDirect()`でネットワーク層からのIPアドレスを取得する。
  （HTTPヘッダーは信頼しないこと。クライアントが制御できるものなので。）
- プロキシを置く場合
  - X-Forwarded-Forヘッダーを使用している場合は、`echo.ExtractIPFromXFFHeader()`を使う。
    - `X-Forwarded-For: <client>, <proxy1>, <proxy2>`というように、左端がクライアントのIPアドレスで、右に行くにつれてサーバー側のプロキシを指す。
  - X-Real-IPを使う場合は、`echo.ExtractIPFromRealIPHeader()`を使う。

## リクエスト

- フォームデータは`Context.FormValue()`で取得する。
- クエリパラメータは`Context.QueryParam()`で取得する。
- パスパラメータは`Context.Param()`で取得する。

## バリデーション
- Echo.Validate()でバリデーション実施。
