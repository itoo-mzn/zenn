---
title: "「達人に学ぶSQL徹底指南書」要点"
emoji: "🐕"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["SQL"]
published: false
---

# 書籍
https://www.shoeisha.co.jp/book/detail/9784798157825

## サポートページ
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
  ROWS <数値>　<PRECEDING or FOLLOWING> -- カレントレコードとその直近の?レコードを計算に使う
)
FROM テーブル名;
```
`<ウィンドウ関数>`には、`RANK`などのウィンドウ専用関数と、`SUM`や`AVG`などの集約関数が入る。

:::message alert
MySQLは8.0以降しかウィンドウ関数は使えない。
:::

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
EXISTSは、**量化**という述語論理の機能を実現するためにSQLに取り入れられた**述語**。
述語とは、**戻り値が真理値になる関数**。(=, <, >, BETWEEN, LIKE, EXISTS など)

ただし、EXISTSは他の述語と**取る引数**が違う。
- EXISTS以外 : **単一の値**(スカラ値, 1行)を引数に取る。 (例: x = y のxとyは単一の値)
- EXISTS : **行の集合**を引数に取る。

:::message
他の述語のような`こういう性質を満たすかどうか`という条件設定ではなく、
EXISTSは、`データが存在するか否か`という次数の1つ高い問題設定である。
:::

### シチュエーション: テーブルに存在しないデータを探す
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



---

　6　HAVING句の力
　Column 関係除算
　Column HAVING 句とウィンドウ関数
　7　ウィンドウ関数で行間比較を行なう
　8　外部結合の使い方
　9　SQLで集合演算
　10　SQLで数列を扱う
　11　SQLを速くするぞ
　12　SQLプログラミング作法

# 第2部　リレーショナルデータベースの世界
　13　RDB近現代史
　14　なぜ“関係”モデルという名前なの？
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