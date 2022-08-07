---
title: "WITH句, WITH RECURSIVE句の使いどころ"
emoji: "🌀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 目的
SQLのWITH句, WITH RECURSIVE句とは何か、その使いどころを理解する。

# 検証DB
今回検証に用いたDBは、MySQL8.0.29。
WITH句, WITH RECURSIVE句は、MySQLでは8.0から実装された。

# WITH句
共通テーブル式(CTE)。

```sql:WITH句 構文
WITH
  仮想テーブル名 AS (仮想テーブルの生成クエリ)
-- 以下、メインクエリ。メインクエリ内で仮想テーブルを呼び出すことができる
SELECT ... FROM ... WHERE ... GROUP BY ...
;
```

```sql:WITH句 例
WITH
  cte1 AS (SELECT a, b FROM table1),
  cte2 AS (SELECT c, d FROM table2)
SELECT b, d 
FROM cte1 
INNER JOIN cte2
ON cte1.a = cte2.c;
```

# WITH RECURSIVE句
再帰的な共通テーブル式(再帰CTE)。

```sql:WITH句 構文
WITH RECURSIVE
  仮想テーブル名 AS (
    仮想テーブルの生成クエリ
    UNION ALL
  )
-- 以下、メインクエリ。メインクエリ内で仮想テーブルを呼び出すことができる
SELECT * FROM SampleTable
```

```sql:WITH句 例
WITH RECURSIVE cte (n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM cte WHERE n < 5
)
SELECT * FROM cte;
```




ちなみに、Ruby on Rails(ActiveRecord)にはWith句に相当するメソッドは無い。
(なので、書こうとするとselectメソッドで直書きになる。)



```sql
WITH total_score (name, score) AS (
  SELECT name, SUM(score) 
  FROM score_table 
  GROUP BY name
)
SELECT t1.name, t1.score 
FROM total_score t1 
WHERE t1.score = (
  SELECT MAX(t2.score) 
  FROM total_score t2
);
```

# 情報
[MySQLリファレンスマニュアル](https://dev.mysql.com/doc/refman/8.0/ja/with.html)

以上
<!-- 2. WITH RECURSIVE 構文を使うと良い時, 使ってはイケナイ時の説明 -->