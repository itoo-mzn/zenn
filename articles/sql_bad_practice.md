---
title: "確実に遅くなるSQL"
emoji: "☠️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

<!-- 1. 確実に遅くなる悪い例を３つ -->
  <!-- 実行計画をちゃんとレポートに入れて説明 -->

# 目的
確実に遅くなるSQLを理解することで、それを避け、良いSQLを書けるようにする。

# 確実に遅くなるSQL

## <インデックスが使われていない>
### 1. 索引列(インデックスが張られている列)に加工を行っている
そもそも、explain使うときはレコード数がけっこう多いテーブルに対してやらないといけないっぽい。
（索引を使用せず表をフルスキャンした方が効率的であるとオプティマイザが判断）　https://teratail.com/questions/81089

msg_typeを3に設定したら<3>でもインデックス効かなかった。おそらく該当行数が多すぎたため。50にしたらkeyを使うようになった。
<2>はすべて読み込むのでrowsが桁違いに大きい。実行はしていないけど、相当時間かかるクエリになっているはず。

```sql
explain
select *
from messages
-- <1>
-- where msg_type = 50
-- <2>
where msg_type / 2 > 50
-- <3>
-- where msg_type > 50 / 2
;
```

<!-- インデックス列にNULLが存在する -->
NULLが多い列や、`IS NULL`や`IS NOT NULL`を使う場合に、インデックスが使われなかったりすることがある。(実装により異なる。)

再現できなかった。
cmapで良い例のテーブルがないので、自分で作るorローカルのcmapのuserdataテーブルのcorporation_name1をほとんどnullにするか。で試す。
```sql
SELECT 
id,
corporation_name1
FROM userdata
where corporation_name1 is null
;
```


### 否定形を使っている
`<>`, `!=`, `NOT IN`を使う場合はインデックスが使用できない。

```sql
explain
SELECT *
FROM messages
-- where msg_type = 50
where msg_type <> 50
;
```


### ORを使っている
- col_1, col_2にそれぞれ別々のインデックスが張られている場合
- (col_1, col_2)に複合インデックスが張られている場合

上記の場合、条件に`OR`を使うとインデックスが使用されなくなるか、使えたとしても`AND`より非効率な検索になる。

```sql
explain
select *
from messages
where msg_type = 50
-- and user_to = 1000
or user_to = 1000
;
```


### 複合インデックスに対して、列の順番を間違えている
(col_1, col_2, col_3)と、この順で複合インデックスが張られている場合、列の順番が重要。
- 必ず最初の列(col_1)を先頭に書かないといけない。
- 間を飛ばす 等、順番を崩してはいけない。(例: col_1, col_3だけ使う)

と聞いていたが、最初の列(col_1)を最後尾につけても問題なかった。（オプティマイザがよしなにやってくれた？のかと思う）
当然だが、3つで1つの複合キーの最初のカラム(msg_type)を条件に含めないとインデックス効かなかった。

```sql
explain
select *
from messages
where 1=1
and msg_type = 50
and group_type = 2
and group_number = 100
;

explain
select *
from messages
where 1=1
-- and msg_type = 50
and group_type = 2
and group_number = 100
;
```


### 後方一致or中間一致のLIKE述語を使っている
**LIKE述語は、前方一致のみINDEXが使用される**。

```sql
explain
select *
from users
-- where email like 'cmap%'
where email like '%cmap%'
;
```


### 暗黙の型変換を行っている
オーバーヘッドを発生させるだけでなく、インデックスまで使用不可になる。

```sql
explain
select *
from userdata
-- where school_name2 = '222'
where school_name2 = 222 -- 文字列型で定義された列
;
```


## <無駄にソートする>
### 1. 重複を残しても良い場面で、UNIONにALLオプションを付けない
ALLオプションを付けないと、暗黙的にソートが行われてパフォーマンスが悪くなる。

:::message
`UNION`は重複を排除する。
`UNION ALL`(ALLオプション有り)では重複を削除する動作が無いため、ソートは行われない。
:::

| ALLオプション | 実行時間 (n=5平均) |
| - | - |
| 無し | 150.6 ms |
| 有り | 73.1 ms |

```sql:ALL無し
SELECT v.id
FROM voices v -- テーブルの選定に特に意味は無い
UNION
SELECT u.id
FROM users u
;
```
```sql:ALL有り
SELECT v.id
FROM voices v
UNION ALL
SELECT u.id
FROM users u
;
```


以上