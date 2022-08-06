---
title: "WITH句, WITH RECURSIVE句の使いどころ"
emoji: "🌀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 目的
WITH句, WITH RECURSIVE句とは何か、その使いどころを理解する。

# 検証DB
今回検証に用いたDBは、MySQL8.0.29。

# WITH句
共通テーブル式(CTE)。


# WITH RECURSIVE句
再帰的な共通テーブル式(再帰CTE)


RECURSIVE句は省略できる。(PostgreSQL以外)

MySQLでは8.0から実装された。

ちなみに、Ruby on Rails(ActiveRecord)にはWith句に相当するメソッドは無い。
(なので、書こうとするとselectメソッドで直書きになる。)



```sql
WITH product_name AS (
  SELECT name
  FROM sample_table
)
SELECT *
FROM product_name
;

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


以上
<!-- 2. WITH RECURSIVE 構文を使うと良い時, 使ってはイケナイ時の説明 -->