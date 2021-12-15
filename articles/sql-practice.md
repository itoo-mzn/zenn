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

#### 14. グループCの各対戦毎にゴール数を表示してください。（外部結合で）
```sql
select 
  pa.kickoff, 
  my_c.name as my_country, 
  en_c.name as enemy_country,
  my_c.ranking as my_ranking, 
  en_c.ranking as enemy_ranking,
  count(g.id)
from pairings pa
left join countries my_c
  on pa.my_country_id = my_c.id
left join countries en_c
  on pa.enemy_country_id = en_c.id
left join goals g
  on pa.id = g.pairing_id
where 1=1
  and my_c.group_name = 'C'
  and en_c.group_name = 'C' -- 自分も敵もCグループ（こうしないと、決勝戦の結果も含まれてしまう）
group by 
--   g.id, # 間違えた。
  pa.kickoff, 
  my_c.name, 
  en_c.name,
  my_c.ranking, 
  en_c.ranking
order by
  pa.kickoff,
  my_c.ranking
;
```

#### 15. グループCの各対戦毎にゴール数を表示してください。（サブクエリで）
コメント部は、14.のもの。
```sql:解答
select 
  pa.kickoff, 
  my_c.name as my_country, 
  en_c.name as enemy_country,
  my_c.ranking as my_ranking, 
  en_c.ranking as enemy_ranking,
--   count(g.id)
  (
    select count(g.id)
    from goals g
    where pa.id = g.pairing_id
   ) as my_goals
from pairings pa
left join countries my_c
  on pa.my_country_id = my_c.id
left join countries en_c
  on pa.enemy_country_id = en_c.id
/* left join goals g
  on pa.id = g.pairing_id */
where 1=1
  and my_c.group_name = 'C'
  and en_c.group_name = 'C'
/* group by 
  pa.kickoff, 
  my_c.name, 
  en_c.name,
  my_c.ranking, 
  en_c.ranking */
order by
  pa.kickoff,
  my_c.ranking
;
```
サブクエリを使うと、GROUP BYを使わないでいいので、すっきりする。
COUNTをサブクエリを使ってSELECT句で行った形。

#### 16. グループCの各対戦毎にゴール数を表示してください。（問15のSQLにカラムを付けくわえる形で）
```sql:解答
select 
  pa.kickoff, 
  my_c.name as my_country, 
  en_c.name as enemy_country,
  my_c.ranking as my_ranking, 
  en_c.ranking as enemy_ranking,
  (
    select count(g.id)
    from goals g
    where pa.id = g.pairing_id
  ) as my_goals,
  (
    select count(g2.id)
    -- 敵のゴール数を取得するためには、my_goalsと別のgoalsのビューでCOUNTしないといけないため、新たにg2が必要になる
    from goals g2 
    left join pairings pa2
      on pa2.id = g2.pairing_id
    -- 自分と敵を入れ替えて絞り込む
    where 1=1
      and pa2.my_country_id = pa.enemy_country_id -- paが使える
      and pa2.enemy_country_id = pa.my_country_id
  ) as enemy_goals -- 敵のゴール数
from pairings pa
left join countries my_c
  on pa.my_country_id = my_c.id
left join countries en_c
  on pa.enemy_country_id = en_c.id
where 1=1
  and my_c.group_name = 'C'
  and en_c.group_name = 'C'
order by
  pa.kickoff,
  my_c.ranking
;
```

#### 17. 問題16の結果に得失点差を追加してください。
```sql
select 
  pa.kickoff, 
  my_c.name as my_country, 
  en_c.name as enemy_country,
  my_c.ranking as my_ranking, 
  en_c.ranking as enemy_ranking,
  (
    select count(g.id)
    from goals g
    where pa.id = g.pairing_id
  ) as my_goals,
  (
    select count(g2.id)
    from goals g2
    left join pairings pa2
      on pa2.id = g2.pairing_id
    where 1=1
      and pa2.my_country_id = pa.enemy_country_id
      and pa2.enemy_country_id = pa.my_country_id
  ) as enemy_goals,
--    my_goals - enemy_goals as goal_diff -- こうしたいが、できない。(UnknownColumn)
  (
    select count(g.id)
    from goals g
    where pa.id = g.pairing_id
  ) - (
    select count(g2.id)
    from goals g2
    left join pairings pa2
      on pa2.id = g2.pairing_id
    where 1=1
      and pa2.my_country_id = pa.enemy_country_id
      and pa2.enemy_country_id = pa.my_country_id
  ) as goal_diff -- 冗長だがこうするしかない。
from pairings pa
left join countries my_c
  on pa.my_country_id = my_c.id
left join countries en_c
  on pa.enemy_country_id = en_c.id
where 1=1
  and my_c.group_name = 'C'
  and en_c.group_name = 'C'
order by
  pa.kickoff,
  my_c.ranking
;
```

#### 18. ブラジル（my_country_id = 1）対クロアチア（enemy_country_id = 4）戦のキックオフ時間（現地時間）を表示してください。
```sql
select 
  kickoff, 
  date_add(kickoff, interval -12 hour) as kickoff_jp
from pairings
where 1=1
and my_country_id = 1
and enemy_country_id = 4
;
```
日付計算用の関数は色々ある。
`ADDTIME(), SUBTIME(), 
DATE_ADD(), DATE_SUB(), 
ADDDATE(), SUBDATE()`

また、DBの種類によって関数（書き方）が違うことがわかった。

#### 19. 年齢ごとの選手数を表示してください。（年齢はワールドカップ開催当時である2014-06-13を使って算出してください。）
```sql:回答
select age, count(age)
from (
  select TIMESTAMPDIFF(YEAR, birth, '2014-06-13') as age
  from players
) as ages -- わざわざサブクエリを使わなくてもいい。
group by age
;
```
```sql:解答
SELECT TIMESTAMPDIFF(YEAR, birth, '2014-06-13') AS age, COUNT(id) AS player_count
FROM players 
GROUP BY age;
```
:::message
SELECT句で求めた計算結果を、GROUP BY句で集約できる。
:::

#### 20. 年齢ごとの選手数を表示してください。ただし、10歳毎に合算して表示してください。
```sql:回答
select
  case 
    when age between 10 and 19 then '10代'
    when age between 20 and 29 then '20代'
    when age between 30 and 39 then '30代'
    when age between 40 and 49 then '40代'
  end as age_group,
  count(*)
from (
  select TIMESTAMPDIFF(YEAR, birth, '2014-06-13') as age
  from players
) as ages
group by age_group
;
```
```sql:解答
select
  truncate(TIMESTAMPDIFF(YEAR, birth, '2014-06-13'), -1) as age,
  count(id) as player_count
from players
group by age
;
```
TRANCATE関数で年齢の1桁目を切り捨てることで、10年ごとの年代が求められ、それをグループ化すればいい。
（MySQLでは「FLOOR関数」を使ってもできる。）

#### 21. 年齢ごとの選手数を表示してください。ただし、5歳毎に合算して表示してください。
```sql:解答
select 
  floor(timestampdiff(year, birth, '2014-06-13') / 5) * 5 as age,
  count(id)
from players
group by age
;
```
5で割って小数点を切り捨てて5倍すれば、5歳ごとに分けられる。

#### 22. 以下の条件でSQLを作成し、抽出された結果をもとにどのような傾向があるか考えてみてください。
・5歳単位、ポジションでグループ化
・選手数、平均身長、平均体重を表示
・順序は年齢、ポジション
```sql
select 
  floor(timestampdiff(year, birth, '2014-06-13') / 5) * 5 as age,
  position,
  count(id),
  avg(height),
  avg(weight)
from players
group by age, position
order by age, position
;
```

#### 23. 身長の高い選手ベスト5を抽出し、以下の項目を表示してください。
・名前
・身長
・体重
```sql
select name, height, weight
from players
order by height desc
limit 5
;
```

#### 24. 身長の高い選手6位～20位を抽出し、以下の項目を表示してください。
・名前
・身長
・体重
```sql
select name, height, weight
from players
order by height desc
limit 15
offset 5
;
```
`LIMIT x OFFSET y` の代わりに、`LIMIT y, x`でも書ける。

#### 25. 全選手の以下のデータを抽出してください。
```sql
select uniform_num, name, club
from players
;
```

#### 26. グループCに所属する国をすべて抽出してください。
```sql
select *
from countries
where 1=1
and group_name = 'C'
;
```

#### 27. グループC以外に所属する国をすべて抽出してください。
```sql
select *
from countries
where 1=1
and group_name <> 'C'
;
```
SQLで**否定**は`<>`。

#### 28. 2016年1月13日現在で40歳以上の選手を抽出してください。（誕生日の人を含めてください。）
```sql:回答
select *
from players
where timestampdiff(year, birth, '2016-01-13') >= 40
;
```
```sql:解答
SELECT * 
FROM players
WHERE birth <= '1976-1-13'
```

#### 29. 身長が170cm未満の選手を抽出してください。
```sql
select *
from players
where 1=1
and height < 170
;
```

#### 30. FIFAランクが日本（46位）の前後10位に該当する国（36位～56位）を抽出してください。ただし、BETWEEN句を用いてください。
```sql
select *
from countries
where 1=1
and ranking between 36 and 56
;
```
- BETWEEN句の文法
  `カラム名 BETWEEN 小 AND 大`

#### 31. 選手のポジションがGK、DF、MFに該当する選手をすべて抽出してください。ただし、IN句を用いてください。
```sql
select *
from players
where 1=1
and position in ('GK', 'DF', 'MF')
;
```

#### 32. オウンゴールとなったゴールを抽出してください。goalsテーブルのplayer_idカラムにNULLが格納されているデータがオウンゴールを表しています。
```sql
select *
from goals
where 1=1
and player_id is null
;
```

#### 33. オウンゴール以外のゴールを抽出してください。goalsテーブルのplayer_idカラムにNULLが格納されているデータがオウンゴールを表しています。
```sql
select *
from goals
where 1=1
and player_id is not null
;
```

#### 34. 名前の末尾が「ニョ」で終わるプレイヤーを抽出してください。
```sql
select *
from players
where 1=1
and name like '%ニョ'
;
```
- LIKE句の文法
 `LIKE '文字列'`
  - `%` : 0文字以上の任意の文字
  - `_` : 任意の1文字

#### 35. 名前の中に「ニョ」が含まれるプレイヤーを抽出してください。
```sql
select *
from players
where 1=1
and name like '%ニョ%'
;
```

#### 36. グループA以外に所属する国をすべて抽出してください。ただし、「!=」や「<>」を使わずに、「NOT」を使用してください。
```sql
select *
from countries
where 1=1
and not group_name = 'A'
;
```
否定には、`<>`や`!=`以外に、`NOT述語`が使える。
- NOT述語の文法
  `WHERE NOT カラム名 = XXX`

#### 37. 全選手の中でBMI値が20台の選手を抽出してください。BMIは以下の式で求めることができます。
weight / POW(height / 100, 2)
- POW関数 : べき乗を求める。(例: `POW(3, 2)` => 9)
```sql
select *
from players
where 1=1
and weight / POW(height / 100, 2) >= 20
and weight / POW(height / 100, 2) < 21
;
```
##### 範囲検索
BETWEEN句は、両端の値も含める。
含めたくない場合は、下記のように`<`と`>`を使う必要がある。
`WHERE カラム名 < XXX AND カラム名 > YYY`

#### 38. 全選手の中から小柄な選手（身長が165cm未満か、体重が60kg未満）を抽出してください。
```sql
select *
from players
where 1=1
and height < 165
or weight < 60
;
```

#### 39. FWかMFの中で(身長が)170未満の選手を抽出してください。ただし、ORとANDを使用してください。
```sql
select *
from players
where 1=1
and (
  position = 'FW'
  or position = 'MF'
)
and height < 170
;
```

#### 40. ポジションの一覧を重複なしで表示してください。グループ化は使用しないでください。
```sql
select distinct position
from players
;
```

#### 41. 全選手の身長と体重を足した値を表示してください。合わせて選手の名前、選手の所属クラブも表示してください。
```sql
select name, club, height + weight
from players
;
```

#### 42. 選手名とポジションを以下の形式で出力してください。シングルクォートに注意してください。
「ジュリオセザール選手のポジションは’GK’です」
```sql
select concat(name, '選手のポジションは\'', position, '\'です')
from players
;
```
- 文字列結合は`CONCAT`。
- シングルクオート（やその他の特殊文字）を出力するには、`\`でエスケープ。

#### 43. 全選手の身長と体重を足した値をカラム名「体力指数」として表示してください。合わせて選手の名前、選手の所属クラブも表示してください。
```sql
select name, club, height + weight as '体力指数'
from players
;
```

#### 44. FIFAランクの高い国から順にすべての国名を表示してください。
```sql
select *
from countries
order by ranking
;
```

#### 45. 全ての選手を年齢の低い順に表示してください。なお、年齢を計算する必要はありません。
```sql
select *
from players
order by birth desc
;
```

#### 46. 全ての選手を身長の大きい順に表示してください。同じ身長の選手は体重の重い順に表示してください。
```sql
select *
from players
order by height desc, weight desc
;
```

#### 47. 全ての選手のポジションの1文字目（GKであればG、FWであればF）を出力してください。
```sql
select id, name, LEFT(position, 1)
from players
;
```
`LEFT`や`SUBSTRING`を始め、文字を加工する方法が色々ある。下記記事がよくまとまっている。

##### 参考記事
https://qiita.com/yatto5/items/0efc8c22e1fbc4f6f091

