---
title: "Go_DB、SQL"
---

# 「database/sql」パッケージ

:::message
MYSQL を使うときのチュートリアル
https://go.dev/doc/tutorial/database-access
:::

## sql.Open を使うのは一度だけ

\*sql.DB 型の値がコネクションプールを持っているので、HTTP リクエストを受け取るたびに`sql.Open`関数を呼ぶとコネクションが再利用されず効率が悪い。
なので、**`sql.Open`は main 関数や初期化処理の中で、一度だけ呼ぶ**ようにする。

## トランザクションを使うときは、defer 文で Rollback メソッドを予約しておく

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
