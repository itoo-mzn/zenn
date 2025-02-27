---
title: "Go_DB、SQL"
---

# Go で DB を使うときの全体像

上から下に向かって利用する流れになる。

1. アプリケーションコードや ORM
2. 汎用 API（`database/sql`パッケージ）
   コネクションプーリングや並行処理の制御などの複雑な処理を、`database/sql`パッケージで吸収してくれている。
3. DB ドライバー
   `go-sql-driver/mysql`など。
4. DB

:::message

### ブランク import

DB ドライバーをブランク import することがある。
これで何をしているのかというと、そのドライバーパッケージの init 関数を実行させている。
その上で、DB ドライバーに直接依存させないように、`database/sql`パッケージを使うようにする といった戦略を取ることができる。
:::

# 「database/sql」パッケージ

:::message
MYSQL を使うときのチュートリアル
https://go.dev/doc/tutorial/database-access
:::

## sql.DB 構造体

sql.DB 構造体は、コネクションをプールする。
コネクション数を設定できるが、DB 側の設定もするのを忘れず。
プールされていると、新規にコネクションを確立するコストがかからずに済むが、コネクションを維持するにはアプリケーションと DB の両リソースを消費するので、脳死で多くすればいい訳ではない。

また、ゴルーチンセーフなので、多数の Web アプリケーションハンドラーから同時に、かつ安全に使用できる。
（ハンドラーは「リクエストを受け取ったときに、どのようなレスポンスを返すかを決めるもの」。）

#### sql.Open を使うのは一度だけ

sql.DB 型の値がコネクションプールを持っているので、HTTP リクエストを受け取るたびに`sql.Open`関数を呼ぶとコネクションが再利用されず効率が悪い。
なので、**`sql.Open`は main 関数や初期化処理の中で、一度だけ呼ぶ**ようにする。

→ sql.DB 構造体を使い回すようにして使うこと。

#### sql.Open ではコネクションが確立されない（場合がある）

`sql.Open()`を実行しただけでは、SQL ドライバーによってはコネクションが確立されない場合がある。
初回リクエストを行ってから確立されるため、DB へ到達可能かどうかをリクエスト前に事前に確認したい場合は、`db.Ping()`を実行する。

## コネクションプール

コネクションは２つの状態を持つ。

- 使用中
- アイドル（作成されているが今は使われてない）

プール（sql.DB）に対して、以下のメソッドで４つのパラメータが設定できる。

- `SetMaxOpenConns` : 最大オープンコネクション数（デフォルト：無制限）
  - 本番では、DB が処理できる範囲に収まるように設定すること。
- `SetMaxIdleConns` : アイドル状態の最大コネクション数（デフォルト：2）
  - リクエストが多い場合は、この値を大きくして、頻繁な再接続が起きないようにする。
- `SetConnMaxIdleTime` : コネクションが終了するまでのアイドル状態の最大時間（デフォルト：無制限）
  - 急激なリクエストが来たあと、平常時に戻ったときに余計なコネクションを開放させる。
- `SetConnMaxLifetime` : コネクションをクローズする前にオープンにしたままにできる最大時間（デフォルト：無制限）
  - 特に DB サーバーをスケールアウトさせたときに効く。アプリケーションが同じコネクションを長時間使わず、スケールさせた DB にも接続してほしいため。

## Nullable な値

`NullString` 型などがある。Valid が false なら null。

## トランザクション

#### トランザクションを使うときは、defer 文で Rollback メソッドを予約しておく

下記のように、**トランザクションを開始してすぐに、defer で Rollback メソッドを予約しておく**こと。（1 回 1 回の更新処理のたびに Rollback を書くのは、それを書き忘れる恐れがあるため。）

tx.Commit()したあとに tx.Rollback()が実行される訳だが、下記の特性があるため問題ない。

:::message
Rollback()について、下記条件下では**ロールバック処理は実行されない**。

- **Commit()した後**のロールバック。
- **キャンセル済みの context**上でのトランザクションに対するロールバック。

:::

```go
// トランザクション開始
tx, err := r.db.BeginTx(ctx, nil)
if err != nil {
  return err
}
defer tx.Rollback() // ロールバックを予約

// 更新処理1
// 更新処理2
// など...

// コミット前のこの時点で何かエラーがあるとロールバックする

return tx.Commit() // コミット → 以降、ロールバックは実行されない
```

上記のコードをまとめた関数を作っておいて、それを利用することで Rollback 忘れを防止するプラクティスもある。

## クエリをキャンセルする

一定時間以上かかるクエリはキャンセルしたい など、クエリをキャンセルするためには context を使うのが一般的。（`db.ExecContext()`）

## ロギング

ロギングするには以下のような方法がある。

- DB にてロギングする
  DB を設定する。
- アプリケーションにてロギングする
  1. ドライバー側でロギングする
     例えばドライバーに Postgres 用の`pgx`を使う場合には、`pgx`がロギングを提供しているのでそれを使う。
  2. ドライバーにラッパーする
     `go-sql-driver/mysql`ではロギングを提供していないので、ドライバーをラップしてロギングできる`gchaincl/sqlhooks`などを使う。
  3. ORM のロギングを使う
     `GORM`は提供されている。

## プリペアードステートメント

Gorm で MySQL を操作するときはプリペアードステートメントが使われるが、プレースホルダー上限が 65,535 個なので要注意。
https://tech.talentx.co.jp/entry/2023/12/28/083009

# テスト

DB アクセスを伴うテストには、2 種類の方法がある。

1. 実際に DB を使う方法
   できる限りこちらの方法が良い。
   しかし、テスト実行時間が長くなる、次のテストに影響しないようデータを都度クリアする などの考慮事項がある。
2. モックを使う方法
   どのレイヤーをモックにするか（レポジトリをモックに差し替えるのか、発行される SQL の一致を見るのか）、モックの粒度にも大小がある。
