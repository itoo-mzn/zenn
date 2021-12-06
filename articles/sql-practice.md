---
title: "SQL練習問題"
emoji: "😸"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 出題元サイト
https://tech.pjin.jp/blog/2016/12/05/sql%E7%B7%B4%E7%BF%92%E5%95%8F%E9%A1%8C-%E4%B8%80%E8%A6%A7%E3%81%BE%E3%81%A8%E3%82%81/

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