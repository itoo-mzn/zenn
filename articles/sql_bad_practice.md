---
title: "確実に遅くなるSQL"
emoji: "☠️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 目的
確実に遅くなるSQLを理解することで、それを避け、良いSQLを書けるようになること。

# 検証DB
今回検証に用いたDBは、MySQL5.6.10。

# 確実に遅くなるSQL

## <インデックスが使われていない>
### 1. インデックスが貼られている列に加工を行っているSQL
インデックスを貼っている列に対して加工をして絞り込むと、せっかく用意したインデックスが使われなくなってしまう。

下記SQLのように、WHERE句を3パターン用意して検証。
- <1> : 通常はインデックスが使われていることを確認するために用意。(msg_typeにはインデックスが貼られている。)
- <2> : インデックスを貼っている列を加工することでインデックスが使われなくなることを確認するために用意。
- <3> : インデックスを貼っている列と比較する側の値に加工することでインデックスが使われるようになり、<2>の状態から改善されることを確認するために用意。

```sql
SELECT *
FROM messages
where msg_type = 50 -- <1>
-- WHERE msg_type / 2 > 50 -- <2>
-- where msg_type > 50 / 2 -- <3>
;
```

#### EXPLAIN実行結果
<1> : 通常はインデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_1.png)
<2> : インデックスを貼っている列を加工することでインデックスが使われなくなった。
![](/images/sql_bad_practice/manu_index_2.png)
<3> : インデックスが使われるように改善された。
![](/images/sql_bad_practice/manu_index_3.png)

:::message
## EXPLAINについて
### 使い方
- 実行したいSQLの先頭に`EXPLAIN`を付けて実行。
- テーブルのレコード数が比較的少なかったり、実行結果がそのテーブルの大多数を占めるSQLに対してEXPLAINすると、インデックス(key)を使用しない場合がある。インデックスを使用せずテーブルをフルスキャンした方が効率的だとオプティマイザが判断して最適化するため。(実際に今回の検証で起きた。)
  - 参考記事 : [MySQLチューニング基礎](https://downloads.mysql.com/presentations/20151208_02_MySQL_Tuning_for_Beginners.pdf)の71ページ目, [Qiita](https://qiita.com/kouki_o9/items/b1d9181e3f9d072a3cdb), [teratail回答](https://teratail.com/questions/81089)
<!-- msg_typeを3に設定したら<3>でもインデックス効かなかった。おそらく該当行数が多すぎたため。50にしたらkeyを使うようになった。 -->
### 結果の見方
| 項目 | 説明 |
| - | - |
| select_type | クエリの種類。*JOIN、UNION、サブクエリ*の3つのどれを使うかによって異なる。<br><br>`SIMPLE` : 単純なSELECT文。(UNION、サブクエリを使わない。)<br>`PRIMARY` : 最も外側のSELECT文。(サブクエリを使う側 or UNIONの1つ目)<br><br>`SUBQUERY` : FROM句ではないサブクエリのSELECT文。<br>`DERIVED` : FROM句で使われているサブクエリのSELECT文。<br><br>`UNION` : UNIONの2つ目以降のSELECT文。<br>`UNION_RESULT` : UNIONの実行結果を取得するためのSELECT文。<br> |
| **type** | どのようにレコードにアクセスするか。<br><br>`const` : 一致するレコード数が0 or 1。PRIMARY KEY or UNIQUEインデックス が貼られている列を定数値と比較する場合。最速。<br>`eq_ref` : JOINするときにPRIMARY KEYやUNIQUE KEYが使われることを表す。constに似ているが、JOINの内部表へのアクセスで用いられる点が異なる。const以外の最適。<br>`ref` : PRIMARY KEY or UNIQUEでないインデックスを使って等価検索(WHERE key = value)を行うことを表す。<br>`range` : インデックスを用いた範囲検索。<br><br>`ALL` : フルテーブルスキャン。**重い処理**。<br>`index` : フルインデックススキャン。該当のインデックスをスキャンする**重い処理**。<br> |
| possible_keys | 利用可能なインデックス。ただし、*使うとは限らない*。<br>`NULL`の場合、インデックスが使われない。 |
| **key** | MySQLが実際に使用すると決定したインデックス。<br>`NULL`の場合、インデックスが使われない。 |
| rows | 調査が必要と考える行の見積もり。(正確な数値ではない。)<br>Extraに`Using where`が表示されている場合は、rowsに対してさらにWHERE句で絞り込んだものが結果として返される。 |
| Extra | クエリーを解決する方法に関する追加情報。オプティマイザがどのような戦略を立てたかを知ることが出来る。 |

参考記事 : [MySQLリファレンス](https://dev.mysql.com/doc/refman/8.0/ja/explain-output.html), [記事(Extraの説明が特に良い)](http://nippondanji.blogspot.com/2009/03/mysqlexplain.html), [記事](https://free-engineer.life/mysql-explain/)
:::


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
<!-- 1. 確実に遅くなる悪い例を３つ -->
  <!-- 実行計画をちゃんとレポートに入れて説明 -->