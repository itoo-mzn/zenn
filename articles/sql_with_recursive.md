---
title: "WITH句, WITH RECURSIVE句の使いどころ"
emoji: "🌀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: true
---

# 目的
SQLのWITH句, WITH RECURSIVE句とは何か。及びその使いどころを理解する。


# 検証DB
今回検証に用いたDBは、MySQL8.0.29。
WITH句, WITH RECURSIVE句は、MySQLでは8.0から実装された。


# WITH句
共通テーブル式 (CTE = Common Table Expression)。
**同一SQL内で仮想テーブルを作成して、それをメインクエリ内で参照できる**。

## 構文
```sql:WITH句 構文
WITH
  仮想テーブル名 (カラムの別名) AS (仮想テーブルの生成クエリ)
-- 以下、メインクエリ。メインクエリ内で仮想テーブルを呼び出すことができる
SELECT ... FROM ... WHERE ... GROUP BY ...
;
```

ちなみに、Ruby on Rails(ActiveRecord)にはWith句に相当するメソッドは無い。
(なので、書こうとするとselectメソッドで直書きになる。)

## 使用例
【例】得点の合計が一番大きい人を取得。
```sql:WITH句 例
WITH
  total_scores (name, total_score) AS ( -- SUM(score)をscoreとして別名で定義
    SELECT name, SUM(score)
    FROM scores
    GROUP BY name
  )
-- 以下、メインクエリ
SELECT t1.name, t1.total_score
FROM total_scores t1 -- 仮想テーブル呼び出し
WHERE t1.total_score  = (
  -- 合計点の最大を求めてスカラで返す
  SELECT MAX(t2.total_score)
  FROM total_scores t2 -- 仮想テーブル呼び出し
);
```


# WITH RECURSIVE句
再帰的な共通テーブル式 (再帰CTE)。
**自分自身を参照**することで、**前に行った処理の結果を利用して同じ処理を繰り返す**ことができる。(再帰処理)

```sql:WITH RECURSIVE句 構文
WITH RECURSIVE
  仮想テーブル名 AS 
  -- 仮想テーブルの生成クエリ
  (
    非再帰項（仮想テーブルの先頭行になるレコード）
    UNION ALL
    再帰項（自身を参照・条件設定して抽出されたレコード）
  )
-- 以下、メインクエリ。メインクエリ内で仮想テーブルを呼び出すことができる
SELECT ... FROM ... WHERE ... GROUP BY ...
```

## 使用例
【例1】織田家を(家系図的に)1代目から順に取得。
```sql:WITH RECURSIVE句 例1
WITH RECURSIVE
  Oda AS (
    -- 非再帰項
    SELECT id, last_name, first_name, parent_id
    FROM Family 
    WHERE last_name = "織田" AND parent_id IS NULL
    UNION ALL
    -- 再帰項
    SELECT child.id, child.last_name, child.first_name, child.parent_id
    FROM Oda -- 自身を参照
    JOIN Family as child -- 元テーブルからデータを追加 <1>
    ON Oda.id = child.parent_id
  )
SELECT * FROM Oda;
```
![](/images/sql_with_recursive/1.png)

【例2】各人の営業成績を取得。ただし、その人に部下がいる場合は部下の成績も自身の成績に含める。
```sql:WITH RECURSIVE句 例2
WITH RECURSIVE sales AS(
  -- トップ (上司がいない。社長とか)
  SELECT name, boss, sale
  FROM sales_table
  WHERE boss IS NULL
  UNION ALL
  -- 部下
  SELECT st.name, st.boss, st.sale
  FROM sales
  JOIN sales_table st -- <1>
  ON  sales.name = st.boss
)
SELECT boss, SUM(sale)
FROM sales
GROUP BY boss
;
```

:::message
上の2つの使用例は記事(末尾に記載)を参考にした。
しかし、再帰項の元テーブルのデータを追加する操作(上記SQL内の`<1>`)については、記事のようなクロス結合(直積)でなくJOIN(内部結合)のほうが一時的なデータ量と計算量が少なくて良いためそこは書き換えた。
:::

:::message
上記例のように、自分の親のレコードIDを持つデータ構造を**ナイーブツリー**と言う。(木構造がその代表例。)
このナイーブツリーはSQLアンチパターンの一つとして有名。

### ナイーブツリー
#### メリット
- *ノードの追加が楽。*
  → 親さえ分かっていれば、単にそれを親IDに設定してINSERTすれば良い。
- *階層ごとの移動が楽。*
  → 子階層をたずさえている階層でも、単に親IDを変更するだけで、それが持つ子階層ごと移動できる。
#### デメリット
- *階層はどこまでも深くできるため、すべての子階層を取得するために、どれだけ結合したらいいかわからない。*
  → WITH RECURSIVE句を使えば最下層まで取得できる。(ただし、「どれだけ結合したらいいかわからない」ままではある。)
- *ノードを削除する場合、その子階層の特定+子階層の親の差し替え+そのノードの削除というように複数の操作が必要。*
:::

# WITH RECURSIVE句を使わない場合
1. *レコードを1件ずつ取得して、アプリ側でマージする。*
→ 件数分のクエリの発行・ループ内処理が発生する。
2. *外部結合（LEFT JOIN）を利用して、id と parent_id を紐づける。*
→ 親子以下の階層(孫階層)は取得できない。
もし孫階層を取得しようと思うと下記のようなSQLになる。つまり、それより下の階層になるとJOINとそれをUNIONする回数が比例して増える。

```sql:孫階層を取得
-- 親
SELECT id, last_name, first_name, parent_id
FROM Family
WHERE last_name = '織田' AND parent_id IS NULL

UNION ALL

-- 子
SELECT f.id, f.last_name, f.first_name, f.parent_id
FROM Family f
JOIN (
  SELECT *
  FROM Family
  WHERE last_name = '織田' AND parent_id IS NULL
) f1
ON  f.parent_id = f1.id

UNION ALL

-- 孫
SELECT f.id, f.last_name, f.first_name, f.parent_id
FROM Family f
JOIN (
  SELECT f.id, f.last_name, f.first_name, f.parent_id
  FROM Family f
  JOIN (
    SELECT *
    FROM Family
    WHERE last_name = '織田' AND parent_id IS NULL
  ) f1
  ON  f.parent_id = f1.id
) f2
ON  f.parent_id = f2.id
;
```

3. *ルートノードからの経路を記録したカラム（pathカラム）を利用する。*
→ テーブル定義の変更、および経路情報のINSERTが必要となる。

いずれも欠点が大きいため、階層構造（グラフ構造）データを格納するのにはWITH RECURSIVE句を使うのが良い。


# WITH RECURSIVE句を使うと良いとき、使ってはいけないとき
## 使うと良いとき
- **ナイーブツリー構造のデータを扱う必要がある場合**。
  上記の通り、他の手段で頑張るよりもWITH RECURSIVE句を使うほうが良い。

## 使ってはいけないとき
- **大量データを扱う場合**。
  WITH句の仮想テーブルはメモリに乗るため。
- **無限ループが発生するSQLになっている場合**。
  例えば下表のように、レコード間の親子関係が循環していると無限ループが発生する。
  (ちなみに、RDMS側で再帰レベル上限値は設定できる。
  MySQLでの設定値は`cte_max_recursion_depth`。デフォルト値は1,000。)

| id | name | parent_id |
| - | - | - |
| 1 | parent | 2 |
| 2 | child | 1 |


# 参考情報
https://dev.mysql.com/doc/refman/8.0/ja/with.html
https://blog.s-style.co.jp/2017/07/884/
https://qiita.com/Shoyu_N/items/f1786f99545fa5053b75
https://qiita.com/bubu_suke/items/131b2eb7df9b16e5e3e5
https://qiita.com/fktnkit/items/57033c10b41b5747dbea
https://qiita.com/hirashunshun/items/06adf4f42f03a9f3b63d

以上
<!-- 2. WITH RECURSIVE 構文を使うと良い時, 使ってはイケナイ時の説明 -->