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
`LEFT`や`SUBSTRING`関数を始め、文字を加工する方法が色々ある。下記記事がよくまとまっている。

##### 参考記事
https://qiita.com/yatto5/items/0efc8c22e1fbc4f6f091

#### 48. 出場国の国名が長いものから順に出力してください。
```sql
select name, char_length(name)
from countries
order by char_length(name) desc
;
```
文字列の長さは、`CHAR_LENGTH`で求められる。(MySQLの場合。他は関数の名称が違う。)

#### 49. 全選手の誕生日を「2017年04月30日」のフォーマットで出力してください。
```sql
select name, date_format(birth, '%Y年%m月%d日')
from players
;
```
date型なので、`DATE_FORMAT関数`で書式設定できる。

#### 50. 全てのゴール情報を出力してください。ただし、オウンゴール（player_idがNULLのデータ）はIFNULL関数を使用してplayer_idを「9999」と表示してください。
```sql
select ifnull(player_id, 9999)
from goals
;
```
NULLのデータが存在しうる場合は、`IFNULL関数`で指定の値に変換できる。

#### 51. 全てのゴール情報を出力してください。ただし、オウンゴール（player_idがNULLのデータ）はCASE関数を使用してplayer_idを「9999」と表示してください。
```sql
select
  case when player_id is null then 9999
       else player_id
  end as player_id
from goals
order by id desc
;
```
（プログラム言語のように）`CASE関数`が使える。

#### 52. 全ての選手の平均身長、平均体重を表示してください。
```sql
select avg(height), avg(weight)
from players
;
```
`AVG`は、平均を求める**グループ関数**。
単に`AVG`とすると、テーブルの**全レコードを1つのグループ**として実行される。
（複数のグループに分ける場合は、追加で`GROUP BY句`が必要。

#### 53. 日本の選手（player_idが714から736）が上げたゴール数を表示してください。
```sql
select count(id)
from goals
where 1=1
and player_id between 714 and 736
;
```

#### 54. オウンゴール（player_idがNULL）以外の総ゴール数を表示してください。ただし、WHERE句は使用しないでください。
```sql
-- select count(id)
select count(player_id)
from goals
-- where 1=1
-- and player_id is not null
;
```
`COUNT`(グループ関数)は、**NULLのレコードはカウントしない**性質がある。
（なので、IS NOT NULLで絞ってIDでまとめるより、player_idでまとめたほうが良い。）

#### 55. 全ての選手の中で最も高い身長と、最も重い体重を表示してください。
```sql
select max(height), max(weight)
from players
;
```

#### 56. AグループのFIFAランク最上位を表示してください。
```sql
select min(ranking)
from countries
where 1=1
and group_name = 'A'
;
```

#### 57. CグループのFIFAランクの合計値を表示してください。
```sql
select sum(ranking)
from countries
where 1=1
and group_name = 'C'
;
```

#### 58. 全ての選手の所属国と名前、背番号を表示してください。
```sql
select c.name, p.name, p.uniform_num
from players p
join countries c
  on p.country_id = c.id
;
```

#### 59. 全ての試合の国名と選手名、得点時間を表示してください。オウンゴール（player_idがNULL）は表示しないでください。
```sql
select c.name, p.name, g.goal_time
from goals g
join players p
  on g.player_id = p.id
join countries c
  on p.country_id = c.id
-- where 1=1
-- and g.player_id is not null
;
```
`JOIN(INNER JOIN = 内部結合)`のため、`IS NOT NULL`は不要だった。

#### 60. 全ての試合のゴール時間と選手名を表示してください。左側外部結合を使用してオウンゴール（player_idがNULL）も表示してください
```sql
select g.goal_time, p.uniform_num, p.name
from goals g
left join players p
  on g.player_id = p.id
;
```
`LEFT JOIN(LEFT OUTER JOIN = 外部結合)`のため、player_id=NULLも表示される。


#### 61. 全ての試合のゴール時間と選手名を表示してください。右側外部結合を使用してオウンゴール（player_idがNULL）も表示してください。
```sql
select g.goal_time, p.uniform_num, p.position, p.name
from goals g
left join players p
  on g.player_id = p.id
;
```

#### 62. 全ての試合のゴール時間と選手名、国名を表示してください。また、オウンゴール（player_idがNULL）も表示してください。
```sql
select c.name, g.goal_time, p.uniform_num, p.position, p.name
from goals g
left join players p
  on g.player_id = p.id
left join countries c
  on p.country_id = c.id
;
```

#### 63. 全ての試合のキックオフ時間と対戦国の国名を表示してください。
```sql
select pa.kickoff, my_c.name, enemy_c.name
from goals g
join pairings pa
  on g.pairing_id = pa.id
join countries my_c
  on pa.my_country_id = my_c.id
join countries enemy_c
  on pa.enemy_country_id = enemy_c.id
;
```

#### 64. 全てのゴール時間と得点を上げたプレイヤー名を表示してください。オウンゴールは表示しないでください。ただし、結合は使わずに副問合せを用いてください。
```sql
select
g.id,
g.goal_time,
(
  select p.name
  from players p
  where 1=1
  and g.player_id = p.id
) as '選手名'
from goals g
-- where 1=1
-- and g.player_id is not null
;
```

#### 65. 全てのゴール時間と得点を上げたプレイヤー名を表示してください。オウンゴールは表示しないでください。ただし、副問合せは使わずに、結合を用いてください。
```sql
select g.id, g.goal_time, p.name
from goals g
join players p
  on g.player_id = p.id
;
```

#### 66. 各ポジションごと（GK、FWなど）に最も身長と、その選手名、所属クラブを表示してください。ただし、FROM句に副問合せを使用してください。
```sql:解答
select p1.position, p1.最大身長, p2.name, p2.club
from (
  select position, max(height) as 最大身長
  from players
  group by position
) p1
join players p2
  on p1.position = p2.position
  and p1.最大身長 = p2.height -- p1.heightは実行できない
;
```
:::message
**イメージ**
サブクエリが特殊条件（加工しているデータ）で、本体が主テーブル（何も加工していないデータ）。
:::

1. サブクエリでポジション（グループ）ごとの最大身長を求める。
2. その最大身長を持つ選手のレコードの情報が更にほしいため、playersテーブルを更にJOINする。
:::message alert
JOINする条件（ON句）は、レコードが一意に特定できないといけない。
（今回でいうと、`position`と`height`は一意じゃない可能性もあると思うので微妙では...？）
:::

#### 67. 各ポジションごと（GK、FWなど）に最も身長と、その選手名を表示してください。ただし、SELECT句に副問合せを使用してください。
```sql
select 
  p1.position, 
  max(p1.height) as 最大身長,
  (
  select p2.name
  from players p2
  where 1=1
    and p1.position = p2.position
--     and p1.最大身長 = p2.height
    and max(p1.height) = p2.height
  ) as 名前
from players p1
group by position
;
```
:::message
**イメージ**
サブクエリが主テーブル（何も加工していないデータ）を1カラムだけ取り出していて、本体が特殊条件（加工しているデータ）。
:::

#### 68. 全選手の平均身長より低い選手をすべて抽出してください。表示する列は、背番号、ポジション、名前、身長としてください。
```sql
select uniform_num, position, name, height
from players
where 1=1
and height < (
  select avg(height) -- ここは1行だけ返す結果にしないといけない
  from players
)
;
```
WHERE句にサブクエリを使うパターン。
:::message
比較演算子(<, >, =)を使うときはサブクエリの返す結果は1行でないといけないが、
**IN句を使う場合は複数行を返すサブクエリで良い**。
:::

#### 69. 各グループの最上位と最下位を表示し、その差が50より大きいグループを抽出してください。
```sql
select max(ranking), min(ranking)
from countries
group by group_name
having max(ranking) - min(ranking) > 50
;
```
:::message
**グループ関数(`MAX`や`MIN`や`COUNT`)の結果を使って抽出条件を作りたい場合は、**(WHERE句でなく)**HAVING句**に記述する。
:::

#### 70. 1980年生まれと、1981年生まれの選手が何人いるか調べてください。ただし、日付関数は使用せず、UNION句を使用してください。
```sql
select 1980 as 誕生年, count(p1.id) as 人数
from players p1
where 1=1
and birth between '1980-01-01' and '1980-12-31'
union
select 1981 as 誕生年, count(p2.id) as 人数
from players p2
where 1=1
and birth between '1981-01-01' and '1981-12-31'
;
```
**UNION句** : 2つの結果を**縦に**つなげる。

#### 71. 身長が195㎝より大きいか、体重が95kgより大きい選手を抽出してください。ただし、以下の画像のように、どちらの条件にも合致する場合には2件分のデータとして抽出してください。また、結果はidの昇順としてください。
```sql
select id, position, name, height, weight
from players
where 1=1
and height > 195
union all
select id, position, name, height, weight
from players
where 1=1
and weight > 95
order by id
;
```
**UNION ALL句** : 重複を削除しない（=同じ行をまとめない）。
（UNIONは重複を削除する）

---

## Viewとは
SQLで利用されるViewは実テーブルから作成される「仮想的なテーブル」。
**必要なデータだけを抜粋**したり、各テーブルから**データを参照しやすいように加工**したViewを作成することができます。
Viewはあくまでも仮想テーブルなので、その中にデータは存在しませんが、テーブル操作をするのと同じような感覚で参照することができます。
Viewの実態はSELECT文。Viewにアクセスする際、定義したSELECT文が実行され、抽出したデータを参照することで仮想テーブルのように扱うことができる。

### Viewを使うメリット
- 複雑なSQL文をViewとして定義することで、毎回入力する必要がなくなり開発効率が向上する
- Viewを利用すれば一般ユーザーに見せたくないデータへのアクセスを制限することができる

### Viewの作成
`CREATE VIEW [ビュー名] AS [定義]`を実行。
```sql
CREATE VIEW players_view AS
select id, name
from players
;
```
### Viewの参照
`SELECT [カラム] AS [ビュー名]`を実行。（=普段どおりのSQL）
```sql
select *
from players_view
;
```

---

## 制約の種類
1. NOT NULL制約
2. DEFAULT制約
3. PRIMARY KEY（主キー）制約
4. AUTO_INCREMENT（※主キー必須）
5. UNIQUE KEY制約
6. FOREIGN KEY（外部キー）制約

---

## サブクエリ
一言でいうと、使い捨てのビュー。
(特定の条件式の中にSELECT文を含むことで、そのSELECTの結果を条件として利用する記述方法。)
WHERE句で使うことが多い。

1. **単一行サブクエリ (スカラ・サブクエリ)**
  戻り値が1行(1件のデータ)。
  使われる演算子は、比較演算子（=、<、<=、>、>=、!=）やIN/NOT IN演算子、EXISTS/NOT EXISTS演算子など。
2. **複数行サブクエリ**
  戻り値が複数行。
  WHERE句だけでなくFROM句でも記述できる。
  使われる演算子は、IN, ANY, ALL。
```sql:単一行サブクエリ ・ 複数行サブクエリ
SELECT 列名1, 列名２, …
FROM テーブル名
WHERE 列名 演算子 ( 
  SELECT 列名 FROM テーブル名 [WHERE 条件式] -- サブクエリ
)
```
3. **表サブクエリ**
  戻り値がn行n列の表となる場合に利用する。(n,nは１以上)
  SELECT文のFROM句やINSERT文などに記述できる。
4. **相関サブクエリ**
  サブクエリのSELECT文で、主クエリのテーブルの列を参照するもの。
  通常のサブクエリは内側のSELECT文の結果に基づき外側のクエリを実行するのに対し、
  相関サブクエリは外側の実行結果1件に対して内側のSELECT文が実行される。
  (外側のテーブルAの1行ごとに、内側のSELECT文が実行される。)

```sql:相関サブクエリ
SELECT 列名1, 列名２, …
FROM テーブルA
WHERE 列名 演算子 ( 
  SELECT カラム名 
  FROM テーブルB 
  WHERE テーブルA.カラム名 = テーブルB.カラム名 -- 相関
)
```

## インデックス