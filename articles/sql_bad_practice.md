---
title: "確実に遅くなるSQL"
emoji: "☠️"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: true
---

# 目的
確実に遅くなるSQLを理解することで、それを避け、良いSQLを書けるようになること。

# 検証DB
今回検証に用いたDBは、MySQL5.6.10。

# 確実に遅くなるSQL

## <インデックスが使われていない>

### 1. インデックス列に加工をしているSQL
インデックスを貼っている列に対して加工をして絞り込むと、せっかく用意したインデックスが使われなくなってしまう。(加工 : 計算、文字列の追加など)
逆に言うと、**インデックスを使用するにはその列を裸で使う**こと。

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


### 2. インデックス列に否定形を使っているSQL
`<>`, `!=`, `NOT IN`を使う場合はインデックスが使用できない。

```sql
SELECT *
FROM messages
WHERE msg_type = 50 -- <1>
-- WHERE msg_type <> 50 -- <2>
;
```

#### EXPLAIN実行結果
<1> : 通常はインデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_4.png)
<2> : インデックスを貼っている列に、否定(`<>`)することでインデックスが使われなくなった。
![](/images/sql_bad_practice/manu_index_5.png)


### 3. インデックス列にORを使っているSQL
- (column_1, column_2)に複合インデックスが貼られている場合
- column_1, column_2にそれぞれ別々のインデックスが貼られている場合

上記の場合、条件に`OR`を使うとインデックスが使用されなくなるか、使えたとしても`AND`より非効率な検索になる。

msg_typeとuser_toで複合インデックスを成しているテーブルにて検証。
```sql
SELECT *
FROM messages
WHERE msg_type = 50
AND user_to = 1000 -- <1>
-- OR  user_to = 1000 -- <2>
;
```

#### EXPLAIN実行結果
<1> : 複合インデックスを成す列同士を`AND`条件で絞る際はインデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_6.png)
<2> : 複合インデックスを成す列同士を`OR`条件で指定すると、インデックスが使われなくなることが確認できた。
![](/images/sql_bad_practice/manu_index_7.png)


### 4. 複合インデックスが使えていないSQL
複合インデックスはcolumn_1から順に整列されてインデックスが形成されている。
そのため、「column_1, column_2, column_3」の順で複合インデックスが貼られている場合、
[column_1, column_3だけ使う], [column_2, column_3だけ使う]ような指定では複合インデックスが使えない。

```sql:<1> 全てのカラムを指定
SELECT *
FROM messages
WHERE 1 = 1
AND msg_type = 50 -- column_1
AND group_type = 2 -- column_2
AND group_number = 100 -- column_3
;
```
```sql:<2> column_1, column_2だけを指定
SELECT *
FROM messages
WHERE 1 = 1
AND msg_type = 50
AND group_type = 2
-- AND group_number = 100
;
```
```sql:<3> column_1, column_3だけを指定
SELECT *
FROM messages
WHERE 1 = 1
AND msg_type = 50
-- AND group_type = 2
AND group_number = 100
;
```
```sql:<4> column_2, column_3だけを指定
SELECT *
FROM messages
WHERE 1 = 1
-- AND msg_type = 50
AND group_type = 2
AND group_number = 100
;
```

#### EXPLAIN実行結果
<1> : 複合インデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_8.png)
<2> : 複合インデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_9.png)
<3> : 本来使いたい複合インデックスは使われなかった。(それとは別の、column_1にだけ有効なインデックスを使っている。)
![](/images/sql_bad_practice/manu_index_10.png)
<4> : 複合インデックスは使われなかった。
![](/images/sql_bad_practice/manu_index_11.png)


### 5. インデックス列に後方一致or中間一致のLIKE述語を使っているSQL
**LIKE述語は、前方一致のみインデックスが使用される**。

```sql
SELECT *
FROM users
WHERE email LIKE 'hoge%' -- <1>
-- WHERE email LIKE '%hoge%' -- <2>
;
```

#### EXPLAIN実行結果
<1> : 前方一致のLIKE検索では、インデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_12.png)
<2> : 中間一致のLIKE検索では、インデックスが使われなくなった。
![](/images/sql_bad_practice/manu_index_13.png)


### 6. インデックス列に暗黙の型変換を行っているSQL
暗黙の型変換を行うと、インデックスが使用不可になる。

文字列型で定義された列に対して、数値と比較して検証。
```sql
SELECT *
FROM userdata
WHERE school_name2 = '222' -- <1: 文字列型 = 文字列 >
-- WHERE school_name2 = 222 -- <2: 文字列型 = 数値 >
;
```

#### EXPLAIN実行結果
<1> : 前方一致のLIKE検索では、インデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_14.png)
<2> : 中間一致のLIKE検索では、インデックスが使われなくなった。
![](/images/sql_bad_practice/manu_index_15.png)

参考記事 : [記事](https://use-the-index-luke.com/ja/sql/where-clause/obfuscation/numeric-strings)


### 7. インデックス列にNULLが存在する
NULLが多い列に`IS NULL`や`IS NOT NULL`を使う場合に、インデックスが使われなかったりすることがある。(実装により異なる。)

インデックス列(msg_type)がNULLであるレコードが1件しかなかったため、検証用に全2,778,844レコード中、812,078レコードをNULLにsetしたテーブルを用意。
```sql
SELECT *
FROM messages
WHERE msg_type = 50 -- <1>
-- WHERE msg_type = 51 -- <2>
-- WHERE msg_type is null -- <3>
-- WHERE msg_type is not null -- <4>
-- WHERE msg_type = 3 -- <5>
;
```

#### EXPLAIN実行結果
<1> : 通常はインデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_19.png)
<2> : 通常はインデックスが使われていることが確認できた。
![](/images/sql_bad_practice/manu_index_20.png)
<3> : NULLが多い列に対して`IS NULL`を使うと、インデックスが使われなかった。
![](/images/sql_bad_practice/manu_index_16.png)
<4> : NULLが多い列に対して`IS NOT NULL`を使うと、インデックスが使われなかった。
![](/images/sql_bad_practice/manu_index_17.png)
<5> : インデックスが使われなかった。
![](/images/sql_bad_practice/manu_index_18.png)

| msg_type | レコード数 | 検証No. | インデックスの使用 | 考察 |
| :-: | -: | - | - | - |
| 50 | 32,125 | <1> | 使った | - |
| 51 | 1 | <2> | 使った | - |
| NULL | 812,078 | <3>, <4> | 使わなかった<br>(`IS NULL`、`IS NOT NULL`ともに) | ちなみにNULLのレコードが1件ときの実行結果は、`IS NULL`はインデックスを使い、`IS NOT NULL`は使わなかった(1件以外はnot nullなのでフルスキャン)。 |
| 3 | 1,882,560 | <5> | 使わなかった | テーブルの大多数のためフルスキャンした方が良いと判断したと思われる。 |
| (その他) | 52,080 | - | - | - |
| (合計) | 2,778,844 | - | - | - |


## <無駄にソートする>

### 8. 重複を残しても良い場面で、UNIONにALLオプションを付けていないSQL
`ALL`オプションを付けないと、暗黙的にソートが行われてパフォーマンスが悪くなる。

:::message
`UNION`は重複を排除する。
`UNION ALL`(ALLオプション有り)では重複を削除する動作が無いため、ソートは行われない。
:::

| ALLオプション | 実行時間 (n=5平均) |
| :-: | -: |
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