---
title: "WITH句, WITH RECURSIVE句の使いどころ"
emoji: "🌀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 目的
SQLのWITH句, WITH RECURSIVE句とは何か。及びその使いどころを理解する。


# 検証DB
今回検証に用いたDBは、MySQL8.0.29。
WITH句, WITH RECURSIVE句は、MySQLでは8.0から実装された。


# WITH句
共通テーブル式(CTE = Common Table Expression)。
同一SQL内で仮想テーブルを作成して、それをメインクエリ内で参照できる。

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
再帰的な共通テーブル式(再帰CTE)。
自分自身を参照することで、前に行った処理の結果を利用して同じ処理を繰り返すことができる。(再帰処理)

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
SELECT * FROM SampleTable
```

## 使用例
【例】

```sql:WITH RECURSIVE句 例
WITH RECURSIVE 
  cte (n) AS (
    SELECT 1
    UNION ALL
    SELECT n + 1 FROM cte WHERE n < 5
  )
SELECT * FROM cte;
```

【例】織田家を1代目から順に取得。(家系図的に)
```sql:WITH RECURSIVE句 例
WITH RECURSIVE
  Oda AS (
    SELECT id, last_name, first_name, parent_id
    FROM Family 
    WHERE last_name = "織田" AND parent_id IS NULL
    UNION ALL
    SELECT child.id, child.last_name, child.first_name, child.parent_id
    FROM Oda -- 自身を参照
    join Family as child
    on Oda.id = child.parent_id
  )
SELECT * FROM Oda;
```
![](/images/sql_with_recursive/1.png)

【例】各人の営業成績を取得。ただし、その人に部下がいる場合は部下の成績も自身の成績に含める。
```sql:WITH RECURSIVE句 例
WITH RECURSIVE sales AS(
  SELECT name, boss, sale
  FROM sales_table
  WHERE boss IS NULL
  UNION ALL
  SELECT st.name, st.boss, st.sale
  FROM sales
  JOIN sales_table st
  ON  sales.name = st.boss
)
SELECT boss, SUM(sale)
FROM sales
GROUP BY boss
;
```

# WITH RECURSIVEを使わない場合
1. レコードを1件ずつ取得して、アプリ側でマージする。
件数分のクエリの発行・ループ内処理が発生する。
2. 外部結合（LEFT JOIN）を利用して、id と parent_id を紐づける。
親子以下の階層(孫階層)は取得できない。
3. ルートノードからの経路を記録したカラム（pathカラム）を利用する。
テーブル定義の変更、および経路情報のINSERTが必要となる。

いずれも欠点が大きいため、階層構造（グラフ構造）データを格納するのにはWITH RECURSIVEを使うのが良いと考える。

# 情報
[MySQLリファレンスマニュアル](https://dev.mysql.com/doc/refman/8.0/ja/with.html)
[記事1](https://style.potepan.com/articles/26192.html)
[記事2](https://blog.s-style.co.jp/2017/07/884/)
[記事3](https://qiita.com/Shoyu_N/items/f1786f99545fa5053b75)

以上
<!-- 2. WITH RECURSIVE 構文を使うと良い時, 使ってはイケナイ時の説明 -->