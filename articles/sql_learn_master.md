---
title: "「達人に学ぶSQL徹底指南書」要点"
emoji: "📑"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 目的
SQLを書く力、および基礎知識の理解度の向上のため、SQLを書きながら下記書籍にて学習。
その要点をまとめた。(つまり、所々割愛している。)

### 書籍
https://www.shoeisha.co.jp/book/detail/9784798157825

### サポートページ
http://mickindex.sakura.ne.jp/database/db_support_sinan.html

# 第1部　魔法のSQL
## 1.　CASE式のススメ
CASE式で**条件分岐**を記述できる。
- CASE式では、**真になる条件(WHEN句)が見つかった時点で打ち切られて、残りのWHEN句は評価されない**ので要注意。
- 各分岐が返す結果のデータ型(THEN句)は統一しないといけない。
- **ELSE句は書く**クセをつける。(書かないと暗黙的にNULLになり、バグの温床になるため)

### シチュエーション: 新しい体系に変換して集計
| 県名 | 県の人口 |
| - | - |

↓
| 地方名 | 地方ごとの合計人口 |
| - | - |

```sql:全てのDBMSで使える
SELECT
  --
  CASE pref_name
    WHEN '徳島' THEN '四国'
    WHEN '愛媛' THEN '四国'
    WHEN '香川' THEN '四国'
    WHEN '高知' THEN '四国'
    WHEN '佐賀' THEN '九州'
    WHEN '福岡' THEN '九州'
    WHEN '長崎' THEN '九州'
    ELSE 'その他'
  END AS '地方名', -- 地方名を出力するためのCASE式
  --
  SUM(population) AS '地方ごとの人口' -- 地方ごとの人口 (ほしいデータ)
FROM
  PopTbl
GROUP BY
  --
  CASE pref_name -- SELECT句と同じCASEを使う
    WHEN '徳島' THEN '四国'
    WHEN '愛媛' THEN '四国'
    WHEN '香川' THEN '四国'
    WHEN '高知' THEN '四国'
    WHEN '佐賀' THEN '九州'
    WHEN '福岡' THEN '九州'
    WHEN '長崎' THEN '九州'
    ELSE 'その他'
  END -- 県→地方という新しい体系に変換するためのGROUP BYに使うCASE式
  --
;
```
MySQL, PostgreSQLは列を先に計算するため、同じことを下記SQLでスッキリ書くことができる。
```sql:MySQL, PostgreSQLで使える
SELECT
  CASE pref_name
    WHEN '徳島' THEN '四国'
    WHEN '愛媛' THEN '四国'
    WHEN '香川' THEN '四国'
    WHEN '高知' THEN '四国'
    WHEN '佐賀' THEN '九州'
    WHEN '福岡' THEN '九州'
    WHEN '長崎' THEN '九州'
    ELSE 'その他'
  END AS '地方名',
  SUM(population) AS '地方ごとの人口'
FROM
  PopTbl
GROUP BY
  地方名 -- 'シングルクォーテーション'をつけるとエラー発生した
;
```

### シチュエーション: 異なる条件の集計を1つのSQLで行う
以下のようにCASE式を利用すれば、**クロス表を作ることができ**、集計をするときに便利。
([クロス表とは](https://trim-site.co.jp/vocabulary/totalling/cross-tabulation/))

| 県名 | 性別 | 県の人口 |
| - | - | - |

↓
| 県名 | 男性の人口 | 女性の人口 |
| - | - | - |
```sql
SELECT
  pref_name,
  -- 男性の場合・女性の場合の2つの情報のうち、男性の情報以外を0にして、男性の場合の数(人口)を求める
  SUM(CASE sex WHEN 1 THEN population ELSE 0 END) AS '男性', 
  SUM(CASE sex WHEN 2 THEN population ELSE 0 END) AS '女性'
FROM
  `PopTbl2`
GROUP BY
  pref_name -- これによって1つの県レコードに、男性・女性の2つの情報がぶら下がる
;
```
1つのSQLであるため、2回SQLを発行してアプリケーションで展開する or UNIONする よりもパフォーマンスが良い。

:::message
プロはWHERE句でなく、SELECT句で条件分岐させる。
プロはHAVING句でなく、SELECT句で条件分岐させる。
:::

### シチュエーション: 複数の列を使った条件を定義
CASE式を入れ子にすることで、ネストした条件分岐を表現できる。
```sql
SELECT
  *,
  -- 男性の人口が100人以上の県は1, それ以外は0
  CASE sex
    WHEN 1 THEN CASE
      WHEN population >= 100 THEN 1
      ELSE 0
    END
    ELSE 0
  END
FROM
  PopTbl2
;
```

### シチュエーション: 条件を分岐してUPDATEする
30万以上の社員は10%減給して、20万以上30万未満の社員は20%昇給する といった要件の場合、
UPDATE文を2回実行すると不整合が起きてしまう。
CASE式を使って1回のUPDATEにできる。
```sql
UPDATE
  TestSal
SET
  salary = (
    CASE
      WHEN salary >= 300000 THEN salary * (1 - 0.1) -- 30万以上の社員は10%減給
      WHEN salary >= 200000 AND salary < 300000 THEN salary * (1 + 0.2) -- 20万以上30万未満の社員は20%昇給
      ELSE salary
    END
  )
;
```

### シチュエーション: 2つのテーブル間でのマッチング
CourseMasterテーブル
| course_id | course_name(講座名) |
| - | - |

OpenCoursesテーブル
| month(講座の実施月) | course_id |
| - | - |

↓

| course_name(講座名) | x月(x月に講義が実施されるかどうか) | y月 | z月 | ... |
| - | - | - | - | - |

```sql
SELECT
  course_name,
  CASE
    WHEN EXISTS(
      SELECT
        course_id
      FROM
        `OpenCourses` oc
      WHERE
        oc.course_id = cm.course_id
      AND MONTH = 200706
    ) THEN "◯"
    ELSE "✕"
  END AS "6月",
  CASE
    WHEN EXISTS(
      SELECT
        course_id
      FROM
        `OpenCourses` oc
      WHERE
        oc.course_id = cm.course_id
      AND MONTH = 200707
    ) THEN "◯"
    ELSE "✕"
  END AS "7月",
  CASE
    WHEN EXISTS(
      SELECT
        course_id
      FROM
        `OpenCourses` oc
      WHERE
        oc.course_id = cm.course_id
      AND MONTH = 200708
    ) THEN "◯"
    ELSE "✕"
  END AS "8月"
FROM
  `CourseMaster` cm
;
```

:::message
#### exists句
existsの内のSQLがデータを取得できたとき（データが存在(exist)するとき）のみ、
existsの外のSQLが実行される。
```sql:構文
SELECT *
FROM テーブル1
WHERE exists (
  select *
  from テーブル2
  where 条件
);
```
https://itsakura.com/sql-exists
:::

CASE式は、文ではなく式であり、**1つの値に定まる**もの。
だから、SELECT句やWHERE句など、どこにでも書くことができる。

---

## 2. 必ずわかるウィンドウ関数
### ウィンドウ関数とは
#### どういうときに使うか
各グループ内でのランキングをつけるときや、
移動平均(今計算している地点を基準に、ある条件で求める平均)を求めるとき 等に使う。
#### 何をするか
1. `PARTITION BY句`でテーブルを縦方向に分割して**ウィンドウ**を作成し、
  (`PARTITION BY`が行う縦方向の分割は、`GROUP BY`と同じようなイメージ。
  オプションなので指定しなくても良いが、その場合はテーブル全体を1つのウィンドウとなる。)
2. `ORDER BY句`でウィンドウ内でのソートを行い、
3. `フレーム句`で**カレントレコード**を中心としたサブセット(**フレーム**)を定義し、
4. `ウィンドウ関数`で欲しい結果を取得する。

#### 構文
```sql
SELECT 
<ウィンドウ関数> OVER (
  PARTITION BY <列> -- どういうグループ郡にするか
  ORDER BY <列>
  ROWS(やRANGEなど) <数値>　<PRECEDING or FOLLOWING> -- フレーム句。カレントレコードとその直近の?レコードを計算に使う
)
FROM テーブル名;
```
`<ウィンドウ関数>`には、`RANK`などのウィンドウ専用関数と、`SUM`や`AVG`などの集約関数が入る。

https://resanaplaza.com/2021/10/17/%E3%80%90%E3%81%B2%E3%81%9F%E3%81%99%E3%82%89%E5%9B%B3%E3%81%A7%E8%AA%AC%E6%98%8E%E3%80%91%E4%B8%80%E7%95%AA%E3%82%84%E3%81%95%E3%81%97%E3%81%84-sql-window-%E9%96%A2%E6%95%B0%EF%BC%88%E5%88%86/

https://qiita.com/tlokweng/items/fc13dc30cc1aa28231c5

https://zenn.dev/nanbunan/articles/ad96d04fb2e616

### シチュエーション: フレーム句を使って、違う行を自分の行に持ってくる
| sample_date | ... |
| - | - |

↓

| cur_date(現在の日付) | latest_date(直近の過去の日付) |
| - | - |

```sql
SELECT
  sample_date AS cur_date,
  MIN(sample_date) -- MINである必要は無く、集約関数であれば良い
  over(
    ORDER BY
      sample_date ASC -- sample_dateの昇順で並べて
    rows BETWEEN 1 preceding AND 1 preceding -- カレントレコードの1つ前の日付のみを選ぶ (範囲に指定する)
  ) AS latest_date
FROM
  `LoadSample`
;
```

---

## 3. 自己結合の使い方
### シチュエーション: 非順序対を作成する
非順序対は、(りんご, みかん), (みかん, りんご)というな組み合わせを同じものと捉える。

| name(果物の名前) | price(果物の価格) |
| - | - |

```sql
SELECT
  p1.name AS p1_name,
  p2.name AS p2_name
FROM
  Products p1
  INNER JOIN Products p2 -- 自己結合
  ON  p1.name > p2.name -- 非順序対にする : (りんご, みかん), (みかん, りんご)のような重複を削除できる
;
```

### シチュエーション: 部分的に不一致なキーの検索
```sql:価格が同じ果物だけを取得する
SELECT DISTINCT
  p1.name,
  p1.price
FROM
  Products p1
  INNER JOIN Products p2
  ON  p1.price = p2.price
;
```

---

## 4. 3値論理とNULL
### 3値論理とは
SQLの真理値型で使われる `true`, `false`, `unknown` のこと。
(プログラミング言語では `true`, `false` のみ。)

`unknown`になるのは、NULLに比較述語を使った場合(`= NULL`, `<> NULL`) など。

### NULLの種類
NULLについての議論では、一般的に2種類に分けて考える。
- 未知 (`UNKNOWN`)
  今は分からないが、条件によっては分かる という状態。
- 適用不能 (`Not Applicable`, `N/A`)
  無意味、論理的に不可能 という状態。

:::message alert
3値論理の`unknown`と、NULLの`UNKNOWN` は異なる存在。
:::

### 3値論理の真理表
下記記事の解説がよくまとまっていたためこれを参照。
https://qiita.com/devopsCoordinator/items/9c10410b50f8fcc2ba79

### 比較述語とNULL
```sql:全件取得できない
SELECT *
FROM students
WHERE age = 20 
OR  age <> 20
;
```
上のSQLで、全レコードが取得できそうに見える。
しかし、`age`がNULLのレコードがあった場合、そのレコードは(trueでなく)`unknown`と評価されるため取得できない。
そのため、下のように書かないといけない。
```sql:全件取得できる
SELECT *
FROM students
WHERE age = 20
OR  age <> 20
OR  age IN NULL -- NULLも取得
;
```

### NOT IN と NOT EXISTS は同値でない
IN と EXISTS は同値だが、NOT IN と NOT EXISTS は同値でない。
これも、NULLが含まれる場合にunknownと評価されるため。

### 限定述語 / 極値関数 / 集約関数 と NULL
限定述語 : ALL と ANY の2つあるが、ANYはINと同値なのであまり使われない。

下記はBクラスの東京在住の誰よりも若いAクラスの人を取得するSQL。
しかし、class_bに`age`がNULLの東京在住の人がいた場合、このSQLの結果は問答無用で空になってしまう。
```sql:限定述語(ALL)
SELECT *
FROM class_a
WHERE age < ALL (
  -- ここのサブクエリが返す値が例えば(22, 29, NULL)の場合、主のWHERE句がunknownになる
  SELECT age
  FROM class_b
  WHERE city = '東京'
);
```

限定述語の代わりに極値関数(MIN, MAX)を使えば、上の問題は解決する(ことが多い)。
しかし、class_bテーブルにデータが無い場合(空集合の場合)はデータが取得できない。
(→ それで良い場合はいいが、そうでない場合は問題となるため、場合により判断が必要。)
これはCOUNT以外の集約関数(AVGなど)でも同じ。
```sql:極値関数
SELECT *
FROM class_a
WHERE age < (
  -- ここがNULLになる場合、主のWHERE句がunknownになる
  SELECT MIN(age)
  FROM class_b
  WHERE city = '東京'
);
```

#### (NULLを値に変換する方法)
IFNULL と COALESCE という関数がある。
どちらを使うか迷った場合、COALESCEを使う。
- より型に厳しいため。
- IFNULL以上に引数をとることができるため。
https://note.mokuzine.net/sqlserver-isnull-coalesce/

---

## 5. EXISTS述語の使い方
EXISTSは、*量化*という述語論理の機能を実現するためにSQLに取り入れられた**述語**。
:::message
SQLには**全称量化**(「**全てのxが条件Pを満たす**」こと)に対応する演算子が無いので、NOT EXISTSで代用する。
:::

述語とは、**戻り値が真理値になる関数**。(=, <, >, BETWEEN, LIKE, EXISTS など)

ただし、EXISTSは他の述語と**取る引数**が違う。
- EXISTS以外 : **単一の値**(スカラ値, 1行)を引数に取る。 (例: x = y のxとyは単一の値)
- EXISTS : **行の集合**を引数に取る。

:::message
他の述語のような`こういう性質を満たすかどうか`という条件設定ではなく、
EXISTSは、`データが存在するか否か`という次数の1つ高い問題設定である。
:::

### シチュエーション: テーブルに存在しないデータを探す
| meeting(会議の開催回) | person(参加者) |
| - | - |

```sql:not exists
SELECT DISTINCT -- 開催回と参加者の重複を排除
  m1.meeting,
  m2.person
FROM
  Meetings m1
  CROSS JOIN Meetings m2 -- m1とm2の直積(全組み合わせ)
-- 上の全組み合わせから、下（元のテーブル）の中に無いものをnot existsで取得
WHERE
  NOT EXISTS(
    SELECT *
    FROM
      Meetings m3 -- 元のテーブル
    WHERE
      m1.meeting = m3.meeting
    AND m2.person = m3.person
  )
;
```

同じことを、exceptを使って下記のように書くこともできる。(ただし、MySQLはexpectが無いため不可。)
```sql:exept ver.
SELECT m1.meeting, m2.person
FROM
  Meetings m1, Meetings m2 -- cross join
  except(
    SELECT
      meeting, person
    FROM
      Meetings
  )
;
```

### シチュエーション: 肯定 ⇔ 二重否定 の変換
`全ての行において〜`という条件(全称量化)を `〜でない行が1つも無い`という二重否定に変換する技術が、EXISTS述語では重要になる。

:::message alert
二重否定するには、`NOT EXISTS( ~でないこと )`という文法になる。
これを単純に肯定形`EXISTS( ~であること )`としてしまうと、どれか1つだけでも`~である`集合を取得してしまい、全く意味が違うため注意。
:::

（例題）
`全ての教科が50点以上である`生徒の成績を全て取得する。
→ これは、`50点未満の教科が1つもない`と(二重否定に)変換できる。

| student_id(生徒ID) | subject(教科) | score(点数) |
| - | - | - |

```sql
SELECT *
FROM TestScores ts1
WHERE NOT EXISTS(
    SELECT *
    FROM TestScores ts2
    WHERE ts1.student_id = ts2.student_id
    AND ts2.score < 50
  )
;
```

（例題）
`算数が80点以上かつ国語技術50点以上`の生徒を全て取得する。ただし、どちらかしかデータが無いものも含める。
→ これは、`全ての成績データにおいて、算数ならば80点以上であり、国語ならば50点以上`となり、
  `全ての成績データにおいて、算数ならば80点未満であり、国語ならば50点未満である成績が存在しない生徒`(二重否定)に変換できる。
```sql
SELECT student_id
FROM TestScores ts1
WHERE ts1.subject IN('算数', '国語') -- 他の教科は関係ないので2教科に絞る
AND NOT EXISTS(
  SELECT *
  FROM TestScores ts2
  WHERE ts1.student_id = ts2.student_id
  AND 1 = CASE
    WHEN ts2.subject = '算数' AND score < 80 THEN 1
    WHEN ts2.subject = '国語' AND score < 50 THEN 1
    ELSE 0
  END
)
GROUP BY student_id
HAVING COUNT(*) = 2
;
```

（例題）
`工程No.2以降は待機状態であり、No.1までが完了しているプロジェクト`を取得する。
→ これは、`工程が1以下なら完了で、1より大きければ待機であるプロジェクト`となり、
  `工程が1以下なのに待機で、1より大きいのに完了であるレコード が存在しないプロジェクト`と(二重否定に)変換できる。

| project_id(プロジェクトID) | step_nbr(工程No.) | status(待機or完了) |
| - | - | - |

```sql
-- 注: 下記1, 2の通りに変えて、二重否定でなく肯定に変えても成立しない。
--     工程No.0~2の内どれか1つでも条件に当てはまると取得する ようになってしまうため。
SELECT *
FROM Projects p1
WHERE NOT EXISTS ( -- 1. ここをexistsに変更
  SELECT *
  FROM Projects p2
  WHERE p1.project_id = p2.project_id
  AND status <> CASE -- 2. ここを = に変更
      WHEN step_nbr <= 1 THEN '完了'
      ELSE '待機'
    END
);
```

（例題）
valが全て1であるkey_colを取得する。
| key_col (A~C) | i (1~10) | val (NULL or 数値) |
| - | - | - |

```sql:NOT EXISTSを使用
SELECT DISTINCT key_col
FROM ArrayTbl2 at2_1
WHERE NOT EXISTS(
  SELECT *
  FROM ArrayTbl2 at2_2
  WHERE at2_1.key_col = at2_2.key_col
  AND coalesce(at2_2.val, 0) <> 1 -- NULL対策
);
```
```sql:ALLを使用
SELECT DISTINCT key_col
FROM ArrayTbl2 at2_1
WHERE 1 = ALL (
  SELECT coalesce(at2_2.val, 0)
  FROM ArrayTbl2 at2_2
  WHERE at2_1.key_col = at2_2.key_col
);
```
```sql:HAVINGを使用
SELECT key_col
FROM ArrayTbl2
GROUP BY key_col
HAVING SUM(
  CASE
    WHEN val = 1 THEN 1
    ELSE 0
  END
) = 10 -- iの数(同じkey_colのi違いのレコード数)
;
```

（例題）
1~100の中の素数を求める。(seq = 1~100)
```sql
SELECT seq AS prime -- 素数
FROM Sequence Dividend -- 被除数
WHERE seq > 1 -- 素数は定義上、2以上である
AND NOT EXISTS( -- 剰余が0のものが含まれない数値のみを取得
  SELECT *
  FROM Sequence Divisor -- 除数
  WHERE Divisor.seq <= Dividend.seq / 2 -- 自分の1/2以上は約数になり得ない
  AND Divisor.seq <> 1
  AND Dividend.seq % Divisor.seq = 0
)
ORDER BY prime
;
```

---

## 6. HAVING句の力

### シチュエーション: データの歯抜けを探す
このデータの中に歯抜けがあるかどうかを探す。
(seqには1以上の値が入ることとする。1が歯抜けの場合もある。)
| seq |
| - |
| 2 |
| 3 |
| 5 |
| 7 |


データに歯抜けがあるかどうか(のみ)を取得する。
```sql:歯抜けがあるかどうか
SELECT '歯抜けあり' AS gap
FROM SeqTbl
-- レコード数と数値の最大値が等しいかどうかで、歯抜けかどうかを判定 (上の表でいうと、レコード数=4、数値の最大値=7)
HAVING COUNT(*) <> MAX(seq)
;
```

:::message
今のSQLではHAVING句を(GROUP BY句無しで)単独で使える。つまり**テーブル全体を1つの集合と捉える**ということ。
しかしその場合は、SELECT句で元のテーブルの列を参照できない。
:::

歯抜けの最小値を取得する。
```sql:歯抜けの最小値
SELECT
  CASE WHEN COUNT(*) = 0 OR  MIN(seq) > 1 THEN 1 -- データが存在しないor下限が1でない場合(1が抜けている場合)、答えとして1を返す
  ELSE(
    SELECT MIN(seq + 1) -- 歯抜けの最小値
    FROM SeqTbl s1
    WHERE NOT EXISTS(
      SELECT *
      FROM SeqTbl s2
      WHERE s2.seq = s1.seq + 1-- 探索する数値の次の数値 が存在するか
    )
  )
  END
FROM SeqTbl
;
```

### シチュエーション: 最頻値を求める
| name(人名) | income(収入額) |
| - | - |

```sql
SELECT income, COUNT(*)
FROM Graduates
GROUP BY income
HAVING COUNT(*) >= ALL (
  SELECT COUNT(*)
  FROM Graduates
  GROUP BY income
)
;
```

### シチュエーション: NULLを含まない集合を探す
`COUNT(*)`は、**NULLを数える**が、
`COUNT(列名)`は、他の集約関数と同じく、**NULLを数えない**(除外して集計する)。

上の性質を利用して、NULLを含むかどうかが上手く判定できる。
（例題）
レポートを全て提出した学部を取得。

| student_id(学生ID) | dpt(学部) | sbmt_date(レポート提出日 or NULL) |
| - | - | - |

```sql
SELECT dpt
FROM Students
GROUP BY dpt
-- NULLを含む数 と 含まない数が不一致であれば、提出されていないレポートがあるということ。
HAVING COUNT(*) = COUNT(sbmt_date)
;
```

:::message
HAVING句で集合を切り分けて問題を考えるときは、ベン図が有効。
:::

#### 特性関数の応用
**CASE式**は、**各要素(行)が 特定の条件を満たす集合 に含まれるかどうか**を決める。
(こういう関数を特性関数という。)

（例題）
| student_id | class | sex | score |
| - | - | - | - |

1. クラスの75%以上の生徒が80点以上の成績をとっているクラス。
```sql
SELECT　class
FROM　TestResults tr1
GROUP BY　class
-- 80点以上をとった生徒が、クラスの人数の75%以上
HAVING COUNT(student) * 0.75 <= SUM(
  CASE
    WHEN score >= 80 THEN 1
    ELSE 0
  END
);
```

2. 50点以上をとった生徒のうち、男子の数が女子の数より多いクラス。
```sql
SELECT class
FROM TestResults
GROUP BY class
HAVING SUM(
  CASE WHEN score >= 50 AND sex = '男' THEN 1 ELSE 0 END -- 50点以上を取った男子生徒の数
) > SUM(
  CASE WHEN score >= 50 AND sex = '女' THEN 1 ELSE 0 END -- 50点以上を取った女子生徒の数
);
```

```sql:私の別解
SELECT class
FROM TestResults
GROUP BY class
HAVING SUM(
  -- 50点以上を取った男子は1、女子は-1として合計を求めることで、正の値であれば男子のほうが多い。
  CASE
    WHEN score >= 50 AND sex = '男' THEN 1
    WHEN score >= 50 AND sex = '女' THEN - 1
    ELSE 0
  END
) > 0
;
```

3. 女子の平均点が男子より高いクラス。
```sql
SELECT class
FROM TestResults
GROUP BY class
HAVING AVG(
  CASE WHEN sex = '女' THEN score ELSE NULL END -- ELSE句で0でなくNULLを指定しているのは、空集合のケア。
) > AVG(
  CASE WHEN sex = '男' THEN score ELSE NULL END
);
```

### シチュエーション: HAVING句で全称量化
NOT EXISTSで全称量化(「全てのxが条件Pを満たす」こと)を表現するのは5.で行ったが、ここではHAVING句で行う。

（例題）
すぐ出動できる(=全員が待機状態)のチームを取得。

| member | team_id | status (待機 or 休暇 or 出動中) |
| - | - | - |

```sql:NOT EXISTS
SELECT * -- 元のカラムをすべて取得できる
FROM Teams t1
WHERE NOT EXISTS(
  SELECT *
  FROM Teams t2
  WHERE t1.team_id = t2.team_id
  AND status <> '待機'
);
```

```sql:HAVING CASE
SELECT team_id -- GROUP BYしているため、1つの値しか取得できない
FROM Teams
GROUP BY team_id
-- チームの総数 と 待機状態の隊員の数 が等しいかどうか
HAVING COUNT(*) = SUM( 
  CASE WHEN status = '待機' THEN 1
  ELSE 0
  END
);
```

```sql:HAVING ALL
SELECT team_id
FROM Teams t1
GROUP BY team_id
-- チームの隊員全員が待機状態 であるかどうか
HAVING '待機' = ALL(
  SELECT status
  FROM Teams t2
  WHERE t1.team_id = t2.team_id
);
```

MAXとMINを使って、最も離れている存在(MAX, MIN)同士が等しいかどうか で判定することもできる。
```sql:HAVING MAX,MIN
SELECT team_id
FROM Teams
GROUP BY team_id
HAVING MAX(status) = '待機' AND MIN(status) = '待機'
;
```

:::message alert
上のSQLにコメントで記載したが、
- **NOT EXISTS**を使う場合は、**元のカラムをすべて取得できる**。また、比較的パフォーマンスが良い。
- **HAVING**を使う場合は、**GROUP BYでまとめたカラムしか取得できない**。
:::

### シチュエーション: 関係除算でバスケット解析
- 関係除算 : 
- バスケット解析 : マーケティング分野における解析手法。頻繁に一緒に買われる商品の規則性を見つける。

（例題）
(Itemsに)登録している全ての商品を販売している店舗を取得。

Itemsテーブル
| item (商品) |
| - |

ShopItemsテーブル
| shop (店舗) | item |
| - | - |

```sql
SELECT shop
FROM ShopItems s
JOIN Items i -- inner joinで、Itemsに存在する商品 だけを含む集合を作る
  ON s.item = i.item
GROUP BY shop
HAVING COUNT(*) = ( SELECT COUNT(*) FROM Items ) -- 後方のカッコ内の返り値はスカラ値なので、COUNT()と比較演算できる
;
```

:::message
- SQLを使う上で重要なのは、**レコード**単位でなく**集合**単位という観点で考えること。

- HAVING句を使う上で重要なのは、**何をもって集合と見なすか**を考えること。
  つまり、どういうグループで括って、それによりできた集合にどんな特性を求めるか。（集合群からどういう集合を選出するか。）

  上の例でいうと、「店舗」で括った集合群（各店舗）の中から、登録している全ての商品を販売している集合を取得する ということ。
:::

### 集合の特性を調べるための条件
| 式 | 用途 |
| - | - |
| COUNT(DISTINCT column) = COUNT(column) | columnの値が一意(ユニーク)である |
| COUNT(*) = COUNT(column) | columnの値にNULLが存在しない |
| COUNT(*) = MAX(column) | columnは歯抜けの無い連番である (開始値が`1`の場合) |
| COUNT(*) = MAX(column) - MIN(column) - 1 | columnは歯抜けの無い連番である (開始値は任意の整数) |
| MIN(column) = MAX(column) | columnの値が1つだけ or NULLである |
| MIN(column) = MAX(column) | columnの値が1つだけ or NULLである |

:::message
### WHERE句とHAVING句の使い分け
#### 用途
- **WHERE句**は、**集合の要素**の特性を調べる道具。
- **HAVING句**は、**集合自身**の特性を調べる道具。

#### 使い分け
検索対象となる**実体1つにつき**、
- **1行**(要素)が対応している → WHERE句を使う。
- **複数行**(集合)が対応している → HAVING句を使う。
:::

---

## 7. ウィンドウ関数で行間比較を行なう
同じ行内の列同士の比較(例:`WHERE col1 = col2`)は簡単だが、異なる行同士での比較はそうではない。
ウィンドウ関数を使うことで、簡潔なSQLで記述できる。
(ウィンドウ関数が使えるようになるまでは、相関サブクエリを使っていた。)

- 相関サブクエリ : WHERE句に外側のクエリの値をサブクエリ内で使用する。

### シチュエーション: 成長・後退・現状維持
（例題）
前年と同じ売上の年を取得。

| year (年度) | sale (売上) |
| - | - |

```sql:相関サブクエリ
SELECT *
FROM Sales s1
WHERE sale = (
  SELECT sale
  FROM Sales s2
  WHERE s1.YEAR = s2.YEAR + 1 -- バインド条件 (s1集合とs2集合の結びつけ)
);
```

```sql:ウィンドウ関数
SELECT year, current_sale
FROM (
  SELECT
    year, -- 基準年
    sale AS current_sale, -- 基準年の売上
    SUM(sale) over(
      ORDER BY year -- 年で並べて 見る
      RANGE BETWEEN 1 preceding AND 1 preceding -- 基準年の1つ前(前年)しか見ない
    ) AS pre_sale -- 前年の売上
  FROM
    Sales
) tmp
WHERE current_sale = pre_sale
ORDER BY year
;
```

（例題）
前年と比べて成長・後退・現状維持したのかを判定。

```sql
SELECT
  YEAR,
  current_sale,
  pre_sale,
  CASE
    WHEN current_sale = pre_sale THEN '→'
    WHEN current_sale > pre_sale THEN '↑'
    WHEN current_sale < pre_sale THEN '↓'
    ELSE '-'
  END AS var
FROM
  (
    SELECT
      YEAR,
      sale AS current_sale,
      SUM(sale) over(
        ORDER BY
          YEAR RANGE BETWEEN 1 preceding AND 1 preceding
      ) AS pre_sale
    FROM
      Sales
  ) tmp
;
```

（例題）
前年と同じ売上の年を取得。ただし、データに歯抜けがあり、年が連続していない場合。

相関サブクエリだと、ネストが深くなってしまう。
```sql:相関サブクエリ
SELECT *
FROM Sales2 s_a
WHERE sale = (
  SELECT sale
  FROM Sales2 s_b
  -- 基準年より過去の年の中で最大の年が、基準年と同じ売上かどうか
  WHERE s_b.YEAR = (
    SELECT MAX(YEAR)
    FROM Sales2 s_c
    WHERE s_a.YEAR > s_c.YEAR
  )
);
```

上で書いたウィンドウ関数のSQLの、`RANGE` を `ROWS` に変えるだけで良い。
(`RANGE`は、今の位置から、指定された範囲内の**値**を見る。
 `ROWS`は、今の位置から、指定された範囲内の**行**を見る。)
```sql:ウィンドウ関数
SELECT year, current_sale
FROM (
  SELECT
    year, -- 基準年
    sale AS current_sale, -- 基準年の売上
    SUM(sale) over(
      ORDER BY year -- 年で並べて 見る
      ROWS BETWEEN 1 preceding AND 1 preceding -- 基準年の1つ前(前年)しか見ない
    ) AS pre_sale -- 前年の売上
  FROM
    Sales
) tmp
WHERE current_sale = pre_sale
ORDER BY year
;
```

### ウィンドウ関数 vs 相関サブクエリ
結論、ウィンドウ関数のほうが性能が良い。
- ウィンドウ関数はサブクエリを使うが、**相関**サブクエリではない。(外側の値を内側で使わない。)
  そのため、**サブクエリ単体で実行できる**。なので、可読性が高く、デバッグも容易。
- テーブルへのスキャンが1度だけなので、パフォーマンスが良い。
- **欲しい情報は**列に**追加**する形となり、レコードを集約しないため**元のテーブルの全ての列を取り出せる**(=情報保全性が働く)。

### シチュエーション: オーバーラップする期間を調べる

（例題）
ダブルブッキングになっている客をリストアップ。

| reserver (宿泊客) | start_date (宿泊開始日) | end_date (宿泊終了日) |
| - | - | - |

```sql:相関サブクエリ
SELECT *
FROM Reservations r1
WHERE EXISTS(
  SELECT *
  FROM Reservations r2
  -- 自分以外の宿泊客と比較 (自分を含めると、絶対に下記のダブルブッキング条件に含まれてしまう)
  WHERE r1.reserver <> r2.reserver
  -- ダブルブッキング = 開始日が他の期間内にある or 終了日が他の期間内にある
  AND (
    r1.start_date BETWEEN r2.start_date AND r2.end_date
    OR  r1.end_date BETWEEN r2.start_date AND r2.end_date
  )
);
```

```sql:ウィンドウ関数
SELECT *
FROM (
  SELECT
    reserver,
    start_date,
    end_date,
    -- 次の宿泊客の宿泊開始日
    MAX(start_date) over(
      ORDER BY
        start_date rows BETWEEN 1 following AND 1 following
    ) AS next_start_date,
    -- 次の宿泊客の名前
    MAX(reserver) over(
      ORDER BY
        start_date rows BETWEEN 1 following AND 1 following
    ) AS next_reserver
  FROM Reservations
) AS tmp
-- 次の宿泊客の宿泊開始日が、自分の宿泊期間内にあるかどうか
WHERE next_start_date BETWEEN start_date AND end_date
;
```

---

## 8. 外部結合の使い方
SQLはデータ検索を目的に作られた言語だが、帳票やレポートを作成するためにも利用され、その力を発揮している。

### JOINのおさらい
- 内部結合 : **INNER JOIN** (= **JOIN**)
    結合相手がいない場合、その行は削除される。
    **積集合**。
- 外部結合 : OUTER JOIN
  - 左外部結合 : **LEFT OUTER JOIN** (= **LEFT JOIN**)
    結合される側(`左`)の表は、結合する側(`右`)にデータが無くても全て残り、
    結合する側(`右`)は、結合相手(`左`)がいない場合、削除される。
  - 右外部結合 : **RIGHT OUTER JOIN** (= **RIGHT JOIN**)
    LEFT OUTER JOINの逆。
  - 完全外部結合 : **FULL OUTER JOIN** (= **FULL JOIN**)
    結合相手がいなくても、結合される側(`左`)・結合する側(`右`)ともに全て残る。
    **和集合**。
    (MySQLでは使えないため、UNIONで代替する。)
- クロス結合 : **CROSS JOIN**
  全ての組み合わせが作られる。(直積)
  そのため、結果の行数は、2つの表の行数の積。(例: 10レコード✗20レコード=200レコード)

### シチュエーション: 外部結合で差集合を求める

| id | name (学生の名前) |
| - | - |

#### A - B
クラスAにしか存在しない(= クラスBには存在せず、クラスAに存在する)学生を探す。

```sql:LEFT JOIN
SELECT *
FROM Class_A a
  LEFT JOIN Class_B b
  ON a.id = b.id
WHERE b.id IS NULL
;
```

これは実は`LEFT JOIN`の本来の使い方ではない。(本来は`NOT EXISTS`や`NOT IN`。)
だが、場面によっては`LEFT JOIN`が最速の動作をする可能性が高い。

```sql:NOT EXISTS
SELECT *
FROM Class_A a
WHERE NOT EXISTS(
  SELECT *
  FROM Class_B b
  WHERE a.id = b.id
);
```

#### B - A
```sql:RIGHT JOIN
SELECT *
FROM Class_A a
  RIGHT JOIN Class_B b
  ON a.id = b.id
WHERE a.id IS NULL
;
```

### シチュエーション: 外部結合で排他的集合(排他的論理和)を求める
```sql:UNION (MySQLの場合)
SELECT a.id id, a.name, b.name
FROM Class_A a
  LEFT JOIN Class_B b
  ON a.id = b.id
UNION
SELECT b.id id, a.name, b.name
FROM Class_B b
  RIGHT JOIN Class_A a
  ON a.id = b.id
WHERE a.id IS NULL
  OR b.id IS NULL
;
```

---

## 9. SQLで集合演算
### 集合演算子
**集合**を入力にとる演算を行う。
- UNION : 和 (昔からある)
- INTERSECT : 交差
- EXCEPT : 差

### 集合演算の注意点
#### 1. ALLオプションがある
通常、集合といえば重複する要素を認めない。(例: [1, 1, 2, 2, 2]は[1, 2]と見なす。)
だが、SQLは重複を認める。そのため、重複行を残すかどうかを考える必要がある。

UNIONなどは**デフォルトで重複行を削除する**ため、**重複行を残したい場合にはALLオプションを付ける**。(例: UNION ALL)

また、**ALLオプション無しでは暗黙でソートを行う**が、**有りだとソートが行われない**。(→パフォーマンスが向上する)
そのため、重複を気にしなくて良い場合はALLオプションを付けるほうが良い。

#### 2. 演算の順番に優先順位がある
UNIONとEXCEPTより、INTERSECTのほうが先に実行される。

#### 3. DBMSごとに実装状況にバラツキがある
SQL Server, Oracleはサポートしたが、MySQLはまだEXCEPT・INTERSECTをサポートしていない。

### シチュエーション: 集合の相当性チェック
バックアップや新環境などと比較したい場合など、テーブル同士が等しいかどうかを調べる場合。

このクエリの結果が、tbl_aとtbl_bの行数と等しければ、テーブル同士は等しい。
集合と集合を足して、それでも行数が増えない ということは、2つのテーブルの内容が同じだった という原理。
```sql
SELECT COUNT(*)
FROM (
  SELECT *
  FROM tbl_a
  UNION -- 和集合
  SELECT *
  FROM tbl_b 
);
```

---

## 10. SQLで数列を扱う
### シチュエーション: 3人なんですけど、座れますか？
席が3人が並んで座れるような席があるかを調べる。

| seat (席番号) | status (空 or 占) |
| - | - |

その範囲内の全てが空席である、始まり(1人目)の席位置〜終わり(3人目)の席位置の組み合わせ を取得する
と考えて、下記のように書ける。
```sql:NOT EXISTS
SELECT s1.seat AS start_seat, '~', s2.seat AS end_seat
FROM Seats s1, Seats s2
-- 上で席の全て組み合わせを作っているため、そこから3人が並んで座る場合の1人目の席と3人目の席の組み合わせのみ絞る
WHERE s2.seat = s1.seat + (3 - 1) -- 3人分
-- 始まり(1人目)の位置〜終わり(3人目)の位置に対して、全て空席であること(→ 空席じゃない行が無いこと)
AND NOT EXISTS(
  SELECT *
  FROM Seats s3
  WHERE s3.seat BETWEEN s1.seat AND s2.seat
  AND s3.status <> '空'
)
ORDER BY s1.seat, s2.seat
;
```

また、3席連続で空いているということは、
空席だけで絞りこんだ後の「ある席(seat)の2行後ろの席番号は seat+2」である
というように考えることができる。
それをウィンドウ関数で実現できる。
```sql:ウィンドウ関数
SELECT seat AS start_seat, '~', end_seat
FROM
  (
    SELECT
      seat,
      MAX(seat) over(
        ORDER BY seat
        rows BETWEEN 2 following AND 2 following -- (3 - 1)とするとsyntaxエラー出た
      ) AS end_seat
    FROM Seats
    WHERE status = '空'
  ) tmp
WHERE end_seat = seat + (3 - 1)
;
```

```sql:HAVING
SELECT s1.seat AS start_seat, '~', s2.seat AS end_seat
-- s1とs2でシートの全組み合わせ(3席分)を作るため、
-- s3はその3席分のステータスを保持するために直積を使っている
FROM Seats s1, Seats s2, Seats s3
WHERE s2.seat = s1.seat + (3 - 1) -- 3席分
AND s3.seat BETWEEN s1.seat AND s2.seat -- 3席のステータス
GROUP BY s1.seat, s2.seat
-- その組み合わせの3席全てが空席であること
HAVING COUNT(*) = SUM(
  CASE
    WHEN s3.status = '空' THEN 1
    ELSE 0
  END
);
```

---

## 11. SQLを速くするぞ
レスポンスが悪いのは、SQLだけでなく、システムの物理的な設計が原因であることもしばしば。
- システムの物理的な設計
  - メモリの配分が悪い
  - ストレージ構成が不適切 など
- SQL : 実行計画を見て判断することが必要

そのため、本格的なパフォーマンスチューニングを行うためには、使用しているハードウェアやDBMSの機能や特徴についての知識が不可欠。

ここでは、実装非依存でSQLを見直すだけで手軽にできるチューニング方法を記載。

### 効率の良い検索を利用する
#### 方法: サブクエリを引数に取る場合、INよりもEXISTSを使う
```sql:IN 遅い
SELECT *
FROM Class_A
WHERE id IN (
  SELECT id
  FROM Class_B
);
```
```sql:EXISTS 速い
SELECT *
FROM Class_A A
WHERE EXISTS (
  SELECT id
  FROM Class_B B
  WHERE A.id = B.id
);
```
1. **もし結合キー(この場合はid)にインデックスが張られている場合、Class_Bの実表は見に行かず、インデックスを参照するのみで済む。**
  INの引数にサブクエリを与える場合、DBはまずサブクエリから実行し、その結果を一時的なワークテーブルに格納して、その後ビューを全件走査する。
  多くの場合これは非常にコストがかかるし、一般にワークテーブルにはインデックスが張られない。
  それに比べ、EXISTSはワークテーブルを作らない。そのためINよりもEXISTSのほうが速いと期待できる。
2. **EXISTSは1行でも条件に合致する行を見つけたらそこで検索を打ち切るので、INのように全件検索する必要がない。**

#### 方法: サブクエリを引数に取る場合、INよりも結合を使う
```sql:JOIN 速い
SELECT A.*
FROM Class_A A
JOIN Class_B B -- INNER JOIN
  ON A.id = B.id
;
```
1. 少なくともどちらかのテーブルのid列のインデックスが利用できる。
2. サブクエリが無くなったのでワーキングテーブルも作られない。

### ソートを回避する
#### 方法: 集合演算子のALLオプションを上手く使う
[9. SQLで集合演算 / 集合演算の注意点]で記載したように、UNIONなどの集合演算子にALLオプションを付けるとソートが行われないため、重複を気にしなくて良い場合はALLオプションを付けるほうが良い。

#### 方法: DISTINCTをEXISTSで代用する
DISTINCTも内部的にソートを行っているため、EXISTSで代用するほうが良い。
```sql:DISTINCT ソート発生
SELECT DISTINCT i.item
FROM Items i
  INNER JOIN SalesHistory sh
  ON  i.item_no = sh.item_no
;
```

```sql:EXISTS ソート発生しない
SELECT DISTINCT i.item
FROM Items i
  INNER JOIN SalesHistory sh
  ON  i.item_no = sh.item_no
;
```

### WHERE句で書ける条件はHAVING句には書かない
GROUP BYで集約する前に絞り込むほうが、それ以降に計算する行数が減らせる。

```sql:HAVING句に条件を書く
-- 集約した後にHAVING句でフィルタリング
SELECT sale_date, SUM(quantity)
FROM SalesHistory
GROUP BY sale_date
HAVING sale_date = "2007-10-01"
;
```

```sql:HAVING句に条件を書く
-- 集約する前にWHERE句でフィルタリング
SELECT sale_date, SUM(quantity)
FROM SalesHistory
WHERE sale_date = "2007-10-01"
GROUP BY sale_date
;
```

### そのインデックス、本当に使われていますか？
インデックスが使われない場合があるシチュエーションについてまとめる。

#### シチュエーション: 索引列(インデックスが張られている列)に加工を行っている
↓のSQLはcolumn_1に張られたインデックスを使用できていない。
```sql:インデックスを使えていない
SELECT *
FROM SomeTable
WHERE column_1 * 1.1 > 100
;
```
代わりに、↓のようにすればインデックスが使用される。
インデックスが張られている列に計算が行われないため。
```sql:インデックスを使えている
SELECT *
FROM SomeTable
WHERE column_1 > 100 / 1.1
;
```

:::message
**インデックスを使用するときは、列は裸にする**。
:::

#### シチュエーション: インデックス列にNULLが存在する
NULLが多い列や、`IS NULL`や`IS NOT NULL`を使う場合に、インデックスが使われなかったりすることがある。(実装により異なる。)

#### シチュエーション: 否定形を使っている
`<>`, `!=`, `NOT IN`を使う場合はインデックスが使用できない。

```sql
SELECT *
FROM SomeTable
WHERE column_1 <> 200
;
```

#### シチュエーション: ORを使っている
- col_1, col_2にそれぞれ別々のインデックスが張られている場合
- (col_1, col_2)に複合インデックスが張られている場合

上記の場合、条件に`OR`を使うとインデックスが使用されなくなるか、使えたとしても`AND`より非効率な検索になる。

```sql
SELECT *
FROM SomeTable
WHERE column_1 > 300 OR column_2 = 'abc'
;
```

#### シチュエーション: 複合インデックスに対して、列の順番を間違えている
(col_1, col_2, col_3)と、この順で複合インデックスが張られている場合、列の順番が重要。
- 必ず最初の列(col_1)を先頭に書かないといけない。
- 間を飛ばす 等、順番を崩してはいけない。(例: col_1, col_3だけ使う)

```sql:OK
SELECT *
FROM SomeTable
WHERE column_1 = 100 AND column_2 = 200 AND column_3 = 300 -- 1, 2, 3を使用
;

SELECT *
FROM SomeTable
WHERE column_1 = 100 AND column_2 = 200 -- 1, 2だけ
;
```
```sql:NG
SELECT *
FROM SomeTable
WHERE column_2 = 200 AND column_3 = 300 -- 2, 3だけ
;

SELECT *
FROM SomeTable
WHERE column_1 = 100 AND column_3 = 300 -- 1, 3だけ
;
```

#### シチュエーション: 後方一致or中間一致のLIKE述語を使っている
**LIKE述語は、前方一致のみINDEXが使用される**。

#### シチュエーション: 暗黙の型変換を行っている
例えば、文字列型で定義された列に対しては下記のようになる。
```sql:OK
SELECT *
FROM SomeTable
WHERE column_1 = '100' -- 文字列
;
```
```sql:NG
SELECT *
FROM SomeTable
WHERE column_1 = 100 -- 数値 (暗黙的にキャストを指示)
;
```

:::message alert
暗黙の型変換は、オーバーヘッドを発生させるだけでなく、インデックスまで使用不可になる。
:::

### 中間テーブルを減らせ
中間テーブルの問題点は、データを展開するためにメモリを消費すること。
また、元テーブルに存在したインデックスを使うのが難しくなること。

#### HAVING句を活用する
集約した結果に対する条件は、HAVING句で設定するのが原則。
(慣れていないエンジニアはWHERE句に頼ろうとする。)

```sql:NG
SELECT *
FROM (
  SELECT sale_date, MAX(quantity) as max_qty
  FROM SomeTable
  GROUP BY sale_date
) tmp -- 無駄な中間テーブル
WHERE max_qty > 100
;
```
```sql:OK
SELECT sale_date, MAX(quantity)
FROM SomeTable
GROUP BY sale_date
HAVING max_qty > 100
;
```
#### 集約よりも結合を先に行う
集約よりも結合を先に行うことで、中間テーブルが省略(小さく)できる。

:::message
パフォーマンスチューニングにおいて大事なのは、**ボトルネックを見つけ、そこを重点的に解消すること**。
DBとSQLにおいては最大のボトルネックは、ストレージへのアクセス。
なのでDBのパフォーマンスチューニングの本質は、**低速ストレージへのアクセスを減らす**こと。
:::

---

## 12. SQLプログラミング作法

### ワイルドカード`*`は使わない
- 取得不要な列まで含まれる。
- SELECT句での結果が、テーブル列の並び順に左右されるため、テーブルの列の順番の入れ替えや追加・削除が発生すると結果が狂う可能性がある。

### 標準語を話そう
#### 実装依存の関数・演算子を使わない
- 使わないようにする : 実装に依存してしまう。
  - DECODE (Oracle)
  - NVL (Oracle)
  - IF (MySQL) : CASE式を使う
  など
- 極力使わないようにする : 実装状況にバラツキがあり、DBMSの互換性が低下するため。
  - EXTRACT
  - ||
  - POSITION
  など
- 使ってもいい : 標準SQLではないが、ほぼ全ての実装で使えるため実害がない。
  - SIGN : 符号を返す
  - ABS : 絶対値
  - REPLACE : 文字列を置換
  など

#### 結合には標準の構文を使う
外部結合のときは、内部結合でなく外部結合であることを示すため、`OUTER`を省略せず書くのが良い。

### 相関サブクエリを追放せよ
ウィンドウ関数により、相関サブクエリを消去する。これにより、可読性もパフォーマンスも上がる。
また、単体で実行できない相関サブクエリに対し、ウィンドウ関数は単体で実行できるためデバッグしやすい。

### FROM句から書く
(SELECT句などでなく)FROM句から書いたほうが、自然にロジックを追える。

:::message
#### SQLの実行順序
1. FROM句
2. JOIN句
3. WHERE句
4. GROUP BY句
5. HAVING句
6. SELECT句
7. ORDER BY句
8. LIMIT句
:::

---

# 第2部　リレーショナルデータベースの世界

## 13. RDB近現代史

#### RDBが表現するのが苦手なデータ
- グラフ
  非循環グラフ（木構造）、循環グラフ（ネットワーク構造）のような再帰的構造を表現するのが難しい。
- 非構造化データ
  XMLやJSON。事前に列と数を決める必要があるテーブルと相性が悪い。

#### NoSQL
RDBとは異なるアーキテクチャやデータモデルに基づくデータベース。（定義はゆるい。）
- KVS
  キーで一意に決まる値を持つという、非常にシンプルな構造。高速検索を実現。(結合などの)高度な処理はできない。Redis、memcachedなど。
- ドキュメント指向型DB
  XMLやJSONのような自由度が高いドキュメントを、RDBのテーブルに変換することなくネイティブに扱う。MongoDB、CouchDBなど。

---

　15　関係に始まり関係に終わる
　16　アドレス、この巨大な怪物
　17　順序をめぐる冒険
　18　GROUP BYとPARTITION BY
　19　手続き型から宣言型・集合指向へ頭を切り替える7箇条
　20　神のいない論理
　21　SQLと再帰集合
　22　NULL撲滅委員会
　23　SQLにおける存在の階層

<!-- 課題 -->
<!-- 1. 確実に遅くなる悪い例を３つ -->
  <!-- 実行計画をちゃんとレポートに入れて説明 -->
<!-- 2. WITH RECURSIVE 構文を使うと良い時, 使ってはイケナイ時の説明 -->