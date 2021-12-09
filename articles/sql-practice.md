---
title: "SQL練習問題"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 出題元サイト
https://tech.pjin.jp/blog/2016/12/05/sql%E7%B7%B4%E7%BF%92%E5%95%8F%E9%A1%8C-%E4%B8%80%E8%A6%A7%E3%81%BE%E3%81%A8%E3%82%81/

# 実行環境
MySQL 5.6

# 問題・回答・解答・メモ
#### 1. 各グループの中でFIFAランクが最も高い国と低い国のランキング番号を表示してください。
```sql
select group_name, min(ranking) as 'ランキング最上位', max(ranking) as 'ランキング最下位'
from countries
group by group_name
;
```

#### 2. 全ゴールキーパーの平均身長、平均体重を表示してください
```sql
select avg(height) as '平均身長', avg(weight) as '平均体重'
from players
where 1=1
and position = 'GK'
-- group by position
;
```
GROUP BYはいらない。WHEREで絞ってから、AVG(SELECT)が実行されるため。

#### 3. 各国の平均身長を高い方から順に表示してください。ただし、FROM句はcountriesテーブルとしてください。
```sql
select countries.name as '国名', avg(height) as '平均身長'
from countries
join players
  on countries.id = players.country_id
-- group by countries.name
group by countries.id, countries.name
order by avg(height) desc
;
```
countries.nameだけでのGROUP BYが駄目なのは、countries.nameが重複しない保証が無いため。
なので、idでもGROUP BYしないといけない。

#### 4. 各国の平均身長を高い方から順に表示してください。ただし、FROM句はplayersテーブルとして、テーブル結合を使わず副問合せを用いてください。
```sql
select 
  (select c.name
   from countries c
   where p.country_id = c.id) as '国名',
  avg(height) as '平均身長'
from players p
group by p.country_id
order by avg(p.height) desc
;
```
サブクエリは、SELECT句でも使える。

#### 5. キックオフ日時と対戦国の国名をキックオフ日時の早いものから順に表示してください。
```sql
select
kickoff,
my_country.name,
enemy_country.name
from pairings
join countries as my_country
  on pairings.my_country_id = my_country.id
join countries enemy_country
  on pairings.enemy_country_id = enemy_country.id
order by kickoff
;
```

#### 6. すべての選手を対象として選手ごとの得点ランキングを表示してください。（SELECT句で副問合せを使うこと）
```sql
select 
  name as 名称,
  position as ポジション,
  club as 所属クラブ,
  ( select count(g.id)
    from goals g
    where g.player_id = p.id
    group by p.id
   ) as ゴール数
from players p
order by ゴール数 desc
;
```

#### 7. すべての選手を対象として選手ごとの得点ランキングを表示してください。（テーブル結合を使うこと）
```sql
select 
  name as 名称,
  position as ポジション,
  club as 所属クラブ,
  count(g.id) as ゴール数
from players p
-- join goals g
left join goals g
  on g.player_id = p.id
-- group by p.id
group by p.id, p.name, p.position, p.club
order by ゴール数 desc
;
```
- LEFT JOINじゃないと、ゴールしていない（goalsにデータがない）playerが含まれない。
  （実行結果のレコード合計数が違う。）
- **グループ関数を使っている場合は、SELECT句に使っているカラムをすべてGROUP BY句に記述しないといけない。**
  （**MySQLはエラーにならずに実行できてしまうが、他で通用しないので正しく覚えること。**）
:::message alert
**GROUP BY句を使うときは、SELECT句に集約キー以外の列名を書けない。**
:::

#### 8. 各ポジションごとの総得点を表示してください。
```sql
select players.position as ポジション, count(goals.id) as ゴール数
from goals
left join players
  on goals.player_id = players.id
group by players.position
;
```

#### 9. ワールドカップ開催当時（2014-06-13）の年齢をプレイヤー毎に表示する。
```sql
select birth, TIMESTAMPDIFF(YEAR, birth, '2014-06-13') as age, name, position
from players
order by age desc
;
```
MySQLでは、日付計算用の関数`TIMESTAMPDIFF()`で年齢を簡単に求められる。

#### 10. オウンゴールの回数を表示する
```sql
select count(goals.id)
from goals
where 1=1
and player_id is null
;
```

#### 11. 各グループごとの総得点数を表示して下さい。
```sql
select c.group_name, count(g.id)
from goals g
join pairings p
  on g.pairing_id = p.id
  and p.kickoff between '2014-6-13 00:00:00' and '2014-6-27 23:59:59'
join countries c
  on p.my_country_id = c.id
group by c.group_name
;
```
:::message
BETWEEN句で日付を絞り込むときは、
- 期間の末尾は、時間を23:59:59で指定しないとその日のデータが含まれない。
- 期間の先頭は、時間を00:00:00で指定しなくても取得できた。（MySQLだけなのか不明。）明示したほうが良いと思っている。

`between '2014-6-13 00:00:00' and '2014-6-27 23:59:59'`
:::

#### 12. 日本VSコロンビア戦（pairings.id = 103）でのコロンビアの得点のゴール時間を表示してください
```sql
select goals.goal_time
from goals
where 1=1
and pairing_id = 103
;
```

#### 13. 日本VSコロンビア戦（pairings.id = 103）でのコロンビアの得点のゴール時間を表示してください
```sql:回答
select c.name, count(g.pairing_id)
from goals g
-- join pairings p
inner join pairings p
  on g.pairing_id = p.id
  and p.id in (103, 39)
-- join countries c
inner join countries c
  on p.my_country_id = c.id
group by g.pairing_id, c.name
;
```

解答として下記が示されていた。
```sql:解答
SELECT c.name, COUNT(g.goal_time)
FROM goals g
LEFT JOIN pairings p 
  ON p.id = g.pairing_id
LEFT JOIN countries c 
  ON p.my_country_id = c.id 
WHERE p.id = 103 OR p.id = 39
GROUP BY c.name
;
```

両者の違いは下記。
- 回答: ON句で絞り込んでからINNER JOIN(= JOIN)。
- 解答: LEFT JOIN(= LEFT OUTER JOIN)してからWHEREで絞り込む。

回答のほうが、実行過程でのデータ量が少なくなるから良いと思っている。
調べると、下記の記事で言及されていた。**今回はINNER JOINなので**、回答のほうが良い。

##### 参考記事
https://zukucode.com/2017/08/sql-join-where.html