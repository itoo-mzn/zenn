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
1. `PARTITION BY句`でテーブルを縦方向に分割してウィンドウを作成し、
2. `ORDER BY句`でウィンドウ内でのソートを行い、
3. `フレーム句`で**カレントレコード**を中心としたサブセット(**フレーム**)を定義し、
4. `ウィンドウ関数`で欲しい結果を取得する。
(`PARTITION BY`が行う縦方向の分割は、`GROUP BY`と同じようなイメージ。)
#### 構文
```sql
SELECT 
<ウィンドウ関数> OVER (
  PARTITION BY <列>
  ORDER BY <列>
  ROWS <数値>　<PRECEDING or FOLLOWING> -- カレントレコードとその直近の?レコードを計算に使う
)
FROM テーブル名;
```
`<ウィンドウ関数>`には、`RANK`などのウィンドウ専用関数と、`SUM`や`AVG`などの集約関数が入る。

:::message alert
MySQLは8.0以降しかウィンドウ関数は使えない。
:::

---

　Column なぜONではなくOVERなのか？
　3　自己結合の使い方
　Column SQL とフォン・ノイマン
　4　3値論理とNULL
　Column 文字列とNULL
　5　EXISTS述語の使い方
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