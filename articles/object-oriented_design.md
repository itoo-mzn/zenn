---
title: "オブジェクト指向設計実践ガイド"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["オブジェクト指向", "設計"]
published: false
---
# 書籍
https://gihyo.jp/book/2016/978-4-7741-8361-9

# Gitレポジトリ
書いたコードはGitレポジトリに保存。
https://github.com/ito0804takuya/object-oriented_design

# 1章　オブジェクト指向設計

## 設計
後の変更を容易にする行い。
コードの構成こそが設計。設計(コードの構成)は芸術である。
変更が容易なアプリケーションは、作るのも拡張するのも楽しい。

## オブジェクト指向設計
依存関係を管理すること。
##### オブジェクト
部品。
##### メッセージ
オブジェクト間で受け渡されるもの。相互作用。

## オブジェクト指向設計の道具
設計する際に設計者を助ける道具として、**原則**と**パターン**がある。
### 設計原則
#### SOLID
1. Single Responsibility Principle：**単一責任の原則**
2. Open/closed principle：**オープン/クロースドの原則**
3. Liskov substitution principle：**リスコフの置換原則**
4. Interface segregation principle：**インターフェース分離の原則**
5. Dependency inversion principle：**依存性逆転の原則**
:::message
本書のメイン。
:::
### デザイン(設計)パターン
いわゆる**GoF**
:::message alert
本書ではデザインパターンは解説していない。
:::

# 2章　単一責任のクラスを設計する
**オブジェクト指向設計のシステムの基礎は（クラスでなく）メッセージ**である。
(メッセージこそが設計の核だが、クラスのほうが分かりやすいので、クラスから解説している。)

## 変更が容易なコードに求められる性質 (TRUE)
#### 見通しが良い(Transparent)
  変更するコードも、そのコードに依存する別の場所のコードにおいても、**変更による影響が明白**であること。（影響範囲がわかるか）
#### 合理的(Reasonable)
  どんな変更であっても、**かかるコストは変更がもたらす利益にふさわしい**。（低コストか）
#### 利用性が高い(Usable)
  新しい環境、**予期していなかった環境**でも再利用できる。（どこでも動くか）
#### 模範的(Examplary)
  後からコードに変更を加える人が、上記の**品質を自然と保つようなコード**である。（他人を導くことができるか）

## なぜ単一責任が重要なのか
1. 責任が互いに結合しすぎて、必要な振る舞いだけを取り出すこと（再利用）ができないため。
2. 変更を加えるたびに、そのクラスに依存するクラスすべてを破壊する危険性があるため。

## クラスが単一責任かどうかを見極める
1. **クラスメソッドを質問に言い換える。**
  - 「Gearさん、この自転車のギアの比率を教えてくれますか？」→OK
  - 「Gearさん、この自転車のタイヤのサイズを教えてくれますか？」→NG
2. **クラスの責任を1文で言い表す**
  - 「自転車へのギアの影響を計算する」→OK
  - 「自転車へのギアの影響と、タイヤの円周を計算する」→NG

## 変更を歓迎するコードを書く
実際に変更が起こるかorどんな変更がおこるかは分からないが、容易に変更を受け入れられるコードを書くことは、将来的に大きな見返りとなる。
以下は、そのテクニック。

### データでなく、振る舞いに依存する
データへのアクセスは2つのどちらかの方法で行われるが、2.を使うようにする。
1. インスタンス変数を直接参照する
2. **インスタンス変数をアクセサメソッドで包み隠す**（ゲッタを経由させる）

#### インスタンス変数の隠蔽 (2.)
```ruby
class Gear
  # ゲッタを用意 → インスタンス変数の隠蔽
  attr_reader :chainring, :cog

  def initialize(chainring, cog)
    @chainring = chainring # チェーンリングの歯数
    @cog = cog # コグの歯数
  end

  # (以下略)
end
```
`attr_reader`や`attr_accessor`を使わない（ゲッタを用意しない）場合、例えば@cogを修正する必要が生じたとき、@cogの出現箇所すべてを修正する必要がある。
それに対し、`attr_reader`は裏で下記の実装をしてくれているため、1箇所だけの修正で変化に対応できる。
:::message
ゲッタを設けることで、(どこからでも参照される)**データ** → (1箇所で定義される)**振る舞い**に変わる。
:::
```ruby
def cog
  @cog # ここを修正すればいい
end
```
つまり、**@cogというデータでなく、cogという振る舞い(アクセサメソッド)に依存する**ようにする。

## あらゆる箇所を単一責任にする

### メソッドから余計な責任を抽出する
（クラスと同様の理由で）メソッドも単一責任であるべき。
メソッドに対しても、その役割を1文で説明できるようにすること。

2つの責任を持っている。（直径の計算 + 繰り返し処理）
```ruby
# 複数のタイヤの直径をそれぞれ計算
def diameters
  wheels.collect { |wheel|
    wheel.rim + (wheel.tire * 2) # 直径 = リム+タイヤの厚み
  }
end
```

メソッドには単一の責任を持たせる。（直径の計算 , 繰り返し処理）
```ruby
# 複数のタイヤの直径を取得
def diameters
  wheels.collect { |wheel| diameter(wheel) }
end

# タイヤの直径を計算
def diameter(wheel)
  wheel.rim + (wheel.tire * 2) # 直径 = リム+タイヤの厚み
end
```

# 3章 依存関係を管理する
適切に設計されたオブジェクトは単一の責任を持つ。そのため、目的のためにはオブジェクト同士の共同作業が必要であり、共同作業をするにオブジェクトは他のオブジェクトを知っていないといけない。**「知っている」というのは依存**であり、しっかり管理する必要がある。

## 依存関係とは
クラス間に一定の依存関係が生まれるのは避けられないが、依存は最低限にするべき。（コードの合理性が失われるため）

以下のコードには、依存関係がある。（Wheelの変更によって、Gearの変更が強制される状況。）
```ruby
# 自転車のギア
class Gear
  attr_reader :chainring, :cog, :rim, :tire

  def initialize(chainring, cog, rim, tire)
    @chainring = chainring # チェーンリングの歯数
    @cog = cog # コグの歯数
    @rim = rim # リム(タイヤの内側の金属部分)の直径
    @tire = tire # タイヤの厚み
  end

  # ギアの比率(= ペダル1回転に対する車輪の回転数)
  def ratio
    chainring / cog.to_f # 浮動小数点へ変換
  end

  # ギアインチ(ギアと車輪の大きさが異なっても比較できる基準)
  def gear_inches
    # ギア比率 * タイヤの直径
    ratio * Wheel.new(rim, tire).diameter
  end
end

# 自転車の車輪
class Wheel
  attr_reader :rim, :tire

  def initialize(rim, tire)
    @rim = rim # リム(タイヤの内側の金属部分)の直径
    @tire = tire # タイヤの厚み
  end

  # タイヤの直径
  def diameter
    rim + (tire * 2) # 直径 = リム+タイヤの厚み
  end
end

puts Gear.new(52, 11, 26, 1.5).gear_inches
```

### オブジェクトが次のことを知っているとき、オブジェクトには依存関係がある。
- **他のクラスの名前**
  Gearは、Wheelという名前のクラスが存在することを知っている。
- **self以外のどこかに送ろうとするメッセージの名前**
  Gearは、Wheelのインスタンスがdiameterに応答することを知っている。
- **メッセージが要求する引数**
  Gearは、Wheel.newにrimとtireが必要なことを知っている。
- **引数の順番**
  Gearは、Wheel.newの第1引数がrimで、第2引数がtireである必要があることを知っている。

## オブジェクト間の結合
2つ以上のオブジェクトの結合が強固なとき、それらは1つのユニットであるように振る舞う。
つまり、1つだけを再利用する ということができない。

## 疎結合なコードを書く
### 依存オブジェクトの注入
```diff ruby
# 自転車のギア
class Gear
- attr_reader :chainring, :cog, :rim, :tire
+ attr_reader :chainring, :cog, :wheel

  def initialize(chainring, cog, rim, tire)
    @chainring = chainring # チェーンリングの歯数
    @cog = cog # コグの歯数
-   @rim = rim # リム(タイヤの内側の金属部分)の直径
-   @tire = tire # タイヤの厚み
+   @wheel = wheel # wheelオブジェクト
  end

  # ギアの比率(= ペダル1回転に対する車輪の回転数)
  def ratio
    chainring / cog.to_f # 浮動小数点へ変換
  end

  # ギアインチ(ギアと車輪の大きさが異なっても比較できる基準)
  def gear_inches
    # ギア比率 * タイヤの直径
-   ratio * Wheel.new(rim, tire).diameter
+   ratio * wheel.diameter
  end
end

- puts Gear.new(52, 11, 26, 1.5).gear_inches
+ puts Gear.new(52, 11, Wheel.new(26, 1.5)).gear_inches # Gearが依存しているWheelオブジェクトを注入
```
依存が削減され、今は**wheelがdiameterメソッドに応答することだけ知っている(1つだけ依存を残している)状況**に改善。

### 外部メッセージを隔離する
gear_inchesの`wheel.diameter`は、Gearにおいては**外部メッセージ**。
```ruby
def gear_inches
  # ギア比率 * タイヤの直径
  ratio * wheel.diameter # selfへのメッセージ+外部メッセージ (外部メッセージが含まれている)
end
```
今は簡素なコードだから良いが、gear_inchesが複雑になるほどこの外部メッセージによって変更が必要になる可能性(壊れる危険性)が高くなる。
そこで、gear_inches内の**外部的な依存を取り除くため、専用のメソッド内にカプセル化する**。
```ruby
def gear_inches
  ratio * diameter # selfへのメッセージのみ
end

def diameter
  wheel.diameter # 外部メッセージ
end
```

### 引数の順番への依存を除去する
引数が必要なメッセージを送るとき、引数を「正しい順番」で渡す必要がある場合、それは**引数の順番に依存している**。
```ruby:引数の順番に依存している
# 第1引数はchainringで, 第2引数はcog, 第3引数はwheel であることを知っている必要がある
Gear.new(52, 11, Wheel.new(26, 1.5))
```

:::message alert
本書では「引数をハッシュで渡すテクニック」が紹介されていたが、今は**キーワード引数**があるので、キーワード引数を使うほうがいい。
（調べたところ、本書が2016年出版で、キーワード引数は2017年に導入されたので、タイミングが悪かったのだと思われる。）
:::

```ruby:キーワード引数
Gear.new(chainring: 52, cog: 11, wheel: Wheel.new(26, 1.5))
```

## 依存方向の管理
依存関係には常に方向がある。依存方向の決め方を知る。

### 依存方向の選択
:::message
結論 : **「自身よりも変更されないもの」に依存すること**
:::
#### 見定め方・考え方
- そのクラスは他のクラスより**要件が変わりやすいか**。
  （変わりにくいものの例：Rubyの基本的なクラス、フレームワークのコード）
- **具象クラスは**、抽象クラスより**変わる可能性が高い**。
  （抽象化されたものへの依存は、具象的なものへの依存よりも常に安全。）
- 多くから依存されているクラスを変更すると、広範囲に影響がでる。

# 4章 柔軟なインターフェースをつくる
オブジェクト指向のアプリケーションは**クラスから成り立つが、メッセージによって定義される**。
設計では、オブジェクト間で受け渡されるメッセージについても考慮しなければならない。
→オブジェクトが何を知っているか（責任）や、誰を知っているか（依存関係）だけでなく、**オブジェクトが互いにどうやって会話するかの設計が必要**。
→オブジェクト間の会話はオブジェクトのインターフェースを介して行われる。

## インターフェースを定義する
レストランを例にして表現。
- *レストランの厨房* = プライベートなメソッド
  プライベートなメッセージが数多く受け渡されている
- *メニュー表* = インターフェース
  パブリックなメッセージ
- *お客さん* = オブジェクト
  どのように料理が作れられているか（処理が行われているか）は知らなくていい。

クラス内の**パブリックなメソッドは安定した部分**であり、**プライベートなメソッドは変化し得る部分**。

### より良いインターフェース
本書では、自転車旅行を提供する旅行会社のシステムを例にしている。

- 参加者(Customer)
- 旅行(Trip)
- 工程(Route)
- 自転車(Bike)
- 整備士(Mechanic)

#### 参加者(Customer)と旅行(Trip)のメッセージ
参加者は、旅行を選ぶために、適切な難易度の、特定の日付の、自転車を借りられる旅行の一覧を見たい。

これを下記のように表す。（本書ではシーケンス図で表している）
`Customerクラス → suitable_trips(on_date, of_difficuly, need_bike)メッセージ → Tripクラス (1)`
(Tripにsuitable_tripsメソッドがある)
Tripに「自転車が利用可能か」も聞いている。これは、Tripが担う責任ではない。
→**このメッセージを送る必要があるが、だれが応答すべきなのか？を考える**。

自転車については、Bicycleに聞くように変更。
`Customerクラス → suitable_trips(on_date, of_difficuly)メッセージ → Tripクラス (2-1)`
`Customerクラス → suitable_bicycle(trip_date, route_type)メッセージ → Bicycleクラス (2-2)`
Tripから余計な責任は取り除けたが、**Customerが「何を望むか」だけでなく、「どのようにして望むものを準備するか」まで知っている**（知りすぎている）。
（メニューで何を望むか注文するのでなく、Customerが厨房に入りこんで調理している ような状況。）

#### 旅行(Trip)と整備士(Mechanic)のメッセージ
旅行の出発前に、自転車が整備されているか確認したい。
`Tripクラス ↔ bicyclesメッセージ (3-1)`
`Tripクラス → clean_bicycle(bike)メッセージ → Mechanicクラス (3-2)`
`Tripクラス → pump_tires(bike)メッセージ → Mechanicクラス (3-3)`
`Tripクラス → lude_chain(bike)メッセージ → Mechanicクラス (3-4)`
`Tripクラス → check_brakes(bike)メッセージ → Mechanicクラス (3-5)`

Tripが自転車の整備工程を全て知っている。(手続き的である)
→Mechanicでの整備工程が追加・変更されると、Tripも修正しないといけない。

上記を改善。
`Tripクラス ↔ bicyclesメッセージ (4-1)`
`Tripクラス → prepare_bicycle(bike)メッセージ → Mechanicクラス (4-2)`
**「どのようにしてほしいか」伝えるのでなく「何をしてほしいか」を頼む**ようにすることで正しい振る舞いを得ることができた。

Mechanicが何をするかを知ることなく、TripがMechanicの正しい振る舞いを実行できるようにする。
`Tripクラス → prepare_trip(self)メッセージ → Mechanicクラス → bicyclesを返却 (5-1)`
`Tripクラス → prepare_bicycle(bike)メッセージ → Mechanicクラス (5-2)`
どの自転車を用意するのか を、Trip自身でなくMechanicに聞くようにしている。
この状態では、TripはMechanicについて何も知らない。Mechanicに**何をしてほしいか**をselfを引数にして伝えている。
整備士がどのように旅行を準備するのかは、すべてMechanic内に隔離することができた。

#### 全体
参加者(Customer)と旅行(Trip)のメッセージの話に戻る。
(1)：Tripに「自転車が利用可能か」も聞いていて、これはTripが担う責任ではない。
(2)：Customerが(どうやって用意するかまで)知りすぎている。
こんな状況で止まっていた。

これを解決するには、
**「適切な旅行の一覧」と「自転車が準備できているか」を聞くことができ**、(*厨房で何をするか知っていて*)
**Customerには望みだけを聞くことができる**(*メニューを提供できる*)
オブジェクトを用意する必要がある。

そこで、TripFinderクラスを用意することが適切と考える。
`Customerクラス → suitable_trips(on_date, of_difficuly, need_bike)メッセージ → TripFinderクラス (6-1)`
`TripFinderクラス → suitable_trips(on_date, of_difficuly)メッセージ → Tripクラス (6-2)`
`TripFinderクラス → suitable_bicycle(trip_date, route_type)メッセージ → Bicycleクラス (6-3)`

### 一番良い面(インターフェース)を表に出すコードを書く
**インターフェースの明快さは、設計スキルを表す**。

インターフェースは、下記のようにあるべき。
- **パブリックかプライベートかが明らか**。
- **「どのように」でなく「何を」になっている**。
- **名前は変わり得ない**。（考えられる限り）
- **オプション引数としてハッシュをとる**。

### メソッドのアクセス制御
Rubyには下記3種のアクセス制御がある。
- `public` : 制限なし。クラスの外からでも呼び出すことができる。
- `private` : クラス内でのみ呼び出せる。クラスの外から呼び出せない。
- `protected` : クラス内+*同じクラスのインスタンス*なら呼び出せる。(特殊)

（下記サイトがわかりやすく解説していた）
https://26gram.com/private-protected-in-ruby
https://qiita.com/tbpgr/items/6f1c0c7b77218f74c63e

これらの制御を使う用途は下記2つであり、全く異なるものである。
1. **どのメソッドが安定していて、どのメソッドが不安定か** を示すため。
  `private`が最も不安定。（publicが安定。）
2. アプリケーションの**ほかのところに、どれだけメソッドが見えるか** を制御するため。

:::message
これらは、アクセスを**拒否する訳ではなく、ただ大変にする**のみ。そこを勘違いしないこと。
（絶対的な制限でないため、だれでもその障壁を超えることはできる。）
:::
それでも使うのは、上記1.の通り**そのメソッドの安定性を示すため**である。

### デメテルの法則
**3つ目のオブジェクトにメッセージを送る際に、異なる型の2つ目のオブジェクトを介することを禁止する**。
（直接の隣人にのみ話しかけよう、ドットは1つまでにしよう と表現される。）

```ruby:悪い例
customer.bicycle.wheel.tire
```
メッセージチェーン内のどこかで起きる関係のない変更によって、変更を与儀なくされるリスクが高まっている。

# 5章 ダックタイピングでコストを削減する
動的型付けオブジェクト指向プログラミング言語で使われる型付けのやり方のこと。
（由来：そのオブジェクトがアヒルのように鳴き、アヒルのように歩くならば、そのクラスが何であれ、それはアヒルである。）

## ダックタイピングを理解する
### ダックを見逃す
以下は、ダックタイピングする前のコード。
```ruby
class Trip
  attr_reader :bicycles, :customers, :vehicle

  # 引数のmechanicは、どんなクラスのものでも良いことになっている
  def prepare(mechanic)
    # しかし、mechanicがprepare_bicyclesに応答するはずだと信じている
    # → prepare_bicyclesに応答できるオブジェクトが渡される ことに依存している
    mechanic.prepare_bicycles(bicycles)
  end
end

class Mechanic
  def prepare_bicycles(bicycles)
    bicycles.each {|bicycle| prepare_bicycle(bicycle)}
  end

  def prepare_bicycle(bicycle)
    # 何かの処理
  end
end
```

### 問題を悪化させる
あえて問題を悪化させて考えるために、下記のように要件が変わったとする。
「旅行の準備には、整備士に加え、旅行のコーディネーターと運転手も必要になった」
```ruby
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each {|preparer|
      # prepare_bicyclesに応答できないオブジェクトにも対応するためcase文で場合分け
      case preparer
      when Mechanic
        preparer.prepare_bicycles(bicycles)
      when TripCoordinator
        preparer.buy_food(customers)
      when Driver
        preparer.gas_up(vehicle)
      end
    }
  end
end

# (その他のクラスは略)
```
ここでの問題点は、**Tripが具象クラスとそのメソッドを知りすぎている**こと。

### ダックを見つける
ダックを見つける思考を下記に示す。
1. 依存を取り除く(ダックを見つける)鍵となるのは、「Tripクラスのprepareメソッドは単一の目的を達成するためにあるので、その**引数も単一の目的を達成するために渡されてくる**」と認識すること。
2. prepareの目的は、旅行を準備すること。
3. その引数も、旅行の準備に協力しようとやってくる(渡されてくる)。つまり、**引数はすべて準備するもの(Preparer)だ**と考える
4. **TripはPreparer(整備士、コーディネーター、運転手)に何をしてほしいか**。それは**旅行に行くための準備(prepare_trip)**。
5. よって、**Preparerは皆、prepare_tripに応答できればいい**。
:::message alert
**実際にPreparerクラスを作るのではない**。ダックタイプは概念。
:::

```ruby
class Trip
  attr_reader :bicycles, :customers, :vehicle

  def prepare(preparers)
    preparers.each { |preparer| preparer.prepare_trip(self) }
  end
end

class Mechanic
  def prepare_trip(trip)
    trip.bicycles.each { |bicycle| prepare_bicycle(bicycle) }
  end

  def prepare_bicycle(bicycle)
    # 何かの処理
  end
end

class TripCoordinator
  def prepare_trip(trip)
    buy_food(trip.customers)
  end
  
  # ...
end

class Driver
  def prepare_trip(trip)
    gas_up(trip.vehicle)
  end
  
  # ...
end
```

:::message
### ポリモーフィズム
多岐にわたるオブジェクトが、同じメッセージに応答できる能力。
:::

## 隠れたダックを見つける
既存のコード内にダックタイプが潜んでいることがある。
よく使われるコーディングパターンの中には、その存在を示唆するものがある。
- クラスで分岐するcase文
- `kind_of?`と`is_a?`
- `responds_to?`

### クラスで分岐するcase文
前述のコードで示した内容。(オブジェクトのクラスによって分岐させていた。)

### `kind_of?`と`is_a?`
`kind_of?`と`is_a?`も、そのオブジェクトのクラスを確認するものなので、上記と同じ。

### `responds_to?`
`responds_to?`はオブジェクトにメソッドがあるか調べる。
そのオブジェクトのクラスを確認することと、そのオブジェクトがメッセージに応答するかどうか確認することは、この文脈上同じ。(そのオブジェクトが何を実行できるか知っている)

# 6章 継承によって振る舞いを獲得する
継承したクラスが応答できないメッセージ(メソッドが無い場合)は、親クラス(スーパークラス)に自動的に問い合わせる。
(自分で応答できる場合は当然、自分で応答する。)
##### 例：Rubyのnil?メソッド
すべてのクラスの親クラスである*Objectクラス*には`nil? -> false`と定義してある。
*Nillクラス*には`nil? -> true`と定義されてある。
そうすることで、Nillインスタンス.nil?はtrueに、その他のインスタンスはfalseを返すようになっている。

## 継承を使うべき箇所を識別する
以下、2種類の自転車（ロードバイク、マウンテンバイク）を例にする。

### 複数の型を埋め込む定義したクラス
```ruby:1つのクラスに2つの型を埋め込んだ
class Bicycle
  attr_reader :style, :size, :tape_color, :front_shock, :rear_shock

  def initialize(args)
    @style = args[:style] # 自転車の種類
    @size = args[:size] # 自転車のサイズ
    @tape_color = args[:tape_color] # ハンドルテープの色
    @front_shock = args[:front_shock] # 前のサスペンション(マウンテンバイク特有)
    @rear_shock = args[:rear_shock] # 後ろのサスペンション(マウンテンバイク特有)
  end

  # スペアとして用意するもの
  def spares
    if style == :road
      # ロードバイクの場合
      {
        chain: '10-speed',
        tire_size: '23',
        tape_color: tape_color
      }
    else
      # ロードバイク以外(マウンテンバイク)の場合
      {
        chain: '10-speed',
        tire_size: '2.1',
        rear_shock: rear_shock
      }
    end
  end
end

bike = Bicycle.new(
  style: :mountain,
  size: 'S',
  front_shock: 'Manitou',
  rear_shock: 'Fox'
)
p bike.spares
```

### 継承を不適切に使う
```ruby
class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock] # 前のサスペンション(マウンテンバイク特有)
    @rear_shock = args[:rear_shock] # 後ろのサスペンション(マウンテンバイク特有)
    super(args) # 親クラスの同メソッド呼び出し
  end

  def spares
    super.merge(rear_shock: rear_shock)
  end
end
```
このようにクラスを定義してはいけない。
なぜなら、Bicycleが具象クラスのままで、Bicycleにはロードバイクがまだ含まれている。
つまり、MountainBike(具象クラス)がロードバイクの振る舞いを継承してしまっている。
→ Bicycle(親クラス)を抽象クラスにして、RoadBikeをBicycleから分離すべき。

:::message
**サブクラスはそのスーパークラスを特化したもの**。
:::

:::message
#### 継承のルール
1. **汎化-特化の関係**であること。
2. 正しいコーディングテクニックを使っていること。
:::

### 抽象的な親クラスをつくる
Bicycleから分離し、RoadBikeクラスを新規で作成。
```ruby
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args = {})
    @size = args[:size] # 自転車のサイズ
    @chain = args[:chain]
    @tire_size = args[:tire_size]
  end

  def spares
    {
      chain: chain,
      tire_size: tire_size,
    }
  end
end

class RoasBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color] # ハンドルテープの色
    super(args) # 親クラスの同メソッド呼び出し
  end

  def spares
    # {
    #   chain: '10-speed',
    #   tire_size: '23',
    #   tape_color: tape_color
    # }
    super.merge(tape_color: tape_color)
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock] # 前のサスペンション(マウンテンバイク特有)
    @rear_shock = args[:rear_shock] # 後ろのサスペンション(マウンテンバイク特有)
    super(args) # 親クラスの同メソッド呼び出し
  end

  def spares
    # {
    #   chain: '10-speed',
    #   tire_size: '2.1',
    #   rear_shock: rear_shock
    # }
    super.merge(rear_shock: rear_shock)
  end
end
```

### テンプレートメソッドパターンを使う
#### テンプレートメソッドパターン
親クラスで抽象的に決めて、子クラスで詳細を埋める。
```diff ruby
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args = {})
    @size = args[:size]
    # 初期値として渡されない限りは、自転車共通の値を採用する
-   @chain = args[:chain]
+   @chain = args[:chain] || default_chain
    # 初期値として渡されない限りは、各自転車で指定している特有の値を採用する
-   @tire_size = args[:tire_size]
+   @tire_size = args[:tire_size] || default_tire_size
  end

+ def default_chain
+   '10-speed' # どんな自転車でも共通の初期値
+ end

  def spares
    {
      chain: chain,
      tire_size: tire_size
    }
  end
end

class RoasBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)
  end

+ def default_tire_size
+   '23' # ロードバイク特有の初期値
+ end

  def spares
    super.merge(tape_color: tape_color)
  end
end

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock = args[:rear_shock]
    super(args)
  end

+ def default_tire_size
+   '2.1' # マウンテンバイク特有の初期値
+ end

  def spares
    super.merge(rear_shock: rear_shock)
  end
end
```

### すべてのテンプレートメソッドパターンを実装する
上の実装で各パラメータが存在すべき場所に存在できるようになったが、新たな具象クラスを作るときに問題を引き起こす可能性がある。
具象クラスには`default_tire_size`の実装が必須だが、そのことを知らずに新たな`***Bike`クラスを作り、特に`tire_size`を指定せず初期化するとエラーが起こる。
→ **一見しただけでは把握できない要件(`default_tire_size`が必須)を、親クラスが子クラスに課している**。

```diff ruby
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args = {})
    @size = args[:size]
    # 初期値として渡されない限りは、自転車共通の値を採用する
    @chain = args[:chain] || default_chain
    # 初期値として渡されない限りは、各自転車で指定している特有の値を採用する
    @tire_size = args[:tire_size] || default_tire_size
  end

+ def default_tire_size
+   # なぜエラーが起きたのか明確にする
+   raise NotImplementedError, "#{self.class}クラスはこのメソッドに応答できない:"
+ end

  # 略
end
# 略
```

### フックメッセージを使って子クラスを疎結合にする
上のコードにおいても改善点があり、それは子クラスの`initialize`。
親クラスがhashを返すこと(アルゴリズム)を知っていることがまずい。
(例えば、新しい子クラス`RecumbentBike`を作り、`initialize`で`super`を書き忘れると、指定した値が初期値として設定されずnilとなる。)

*子クラスから親クラスにsuperを送るように(親クラスが)求める*のでなく、**親クラスが子クラスにメッセージを送るようにする**ことで、それを解消する。
```diff ruby
class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args = {})
    @size = args[:size]
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size

+   post_initialize(args)
    # -> 子クラスにpost_initializeメッセージを送る(無ければこのクラスのpost_initializeに)
  end

+ def post_initialize(args)
+   nil
+ end
  
  # 略
end

class RoasBike < Bicycle
  attr_reader :tape_color

- def initialize(args)
+ def post_initialize(args)
    @tape_color = args[:tape_color]
-   super(args) # -> 親クラスにメッセージを送らなくて良くなった
  end

  # 略
end
```

# 7章 モジュールでロールの振る舞いを共有する
#### モジュール
プログラム上での役割や振る舞いをまとめることができる。
クラスと同じように定数やメソッドをまとめたり、クラスに組み込んで多重継承を実現したり、クラスなどをまとめることで名前空間を提供するなど。

## ロールを理解する
例題として、旅行のスケジュールを知ることができるように、機能を追加する。
- 予定が空いているか確認が必要なのは、自転車・整備士・自動車。
- 前の旅行からのメンテ(休息)期間は、自転車1日・整備士4日・自動車3日。

モジュールを使って表現する。
```ruby
class Schedule
  def scheduled?(schedulable, start_date, end_date)
    false # ひとまず、予定が空いていないことにしておく
  end
end

module Schedulable
  attr_writer :schedule

  def schedule
    @schedule ||= ::Schedule.new
  end

  def schedulable?(start_date, end_date)
    !scheduled?(start_date - lead_days, end_date)
  end

  def scheduled?(start_date, end_date)
    schedule.scheduled?(self, start_date, end_date)
  end

  def lead_days
    0 # 必要に応じてincludeする側で書き換える
  end
end

class Bicycle
  include Schedulable

  def lead_days
    1 # 自転車のメンテ期間は1日
  end

  # 略
end

class Mechanic
  include Schedulable

  def lead_days
    4 # 整備士の休息期間は4日
  end

  # 略
end
```

:::message
**クラスの継承は「である（is-a）」、モジュールでの共有は「のように振る舞う（behave-like-a）」**
:::

### メソッド探索の仕組み
`bike.spares`を実行したとき、sparesメソッドがあるかどうかは、下記のように探索される。
1. MountainBikeクラスにsparesメソッドがあるか確認。
2. Bicycleクラス(親)にsparesメソッドがあるか確認。
3. Objectクラス(親の親)にsparesメソッドがあるか確認。

#### モジュールをinclueしている場合
1. MountainBikeクラスにsparesメソッドがあるか確認。
2. Bicycleクラス(親)にsparesメソッドがあるか確認。
3. *Schedulableモジュールにsparesメソッドがあるか確認。*
4. Objectクラス(親の親)にsparesメソッドがあるか確認。

そのため、Schedulableモジュールに定義したメソッドを、意図せずBicycleクラスがオーバーライドする可能性がある。
(複数includeしている場合は、最後にincludeしたものが先に探索される。)

##### TODO: include, prepend, extend。ActiveSupport::Concern を調べて学ぶこと!

## 継承可能なコードを書く
### アンチパターン
1. オブジェクトがtypeやcategoryという変数名を使い、**どんなメッセージをselfに送るか決めている**パターン。
→ 共通のコードを抽象親クラスにおき、子クラスで異なる型をつくる。
2. メッセージを受け取る**オブジェクトのクラスを確認してから、どのメッセージを送るかをオブジェクトが決めている**パターン。
→ ダックタイプを見落としている。ダックタイプやモジュールを使い、ロールを担わせる。

### 抽象に固執する
**抽象親クラス内のコードを使わない子クラスがあってはいけない**。
すべての子クラスで使わないけど一部の子クラスで使うようなコードは、親クラスに置くべきでない。

### リスコフの置換原則(LSP)
(SOLIDのL)
**派生型は、上位型と置換可能でなければならない。**

### テンプレートメソッドパターンを使う
継承可能なコードを書くための最も基本的なコーディング手法は、テンプレートメソッドパターンを使うこと。
テンプレートメソッドパターンを使うと、**抽象を具象から分けることができる**。

### 前もって疎結合にする
**継承する側で`super`を呼び出すのは避ける。変わりにフックメッセージを使う**。

### 階層構造は浅くする
クラスの階層構造は**浅く**する。（広さ、狭さ でなく。）
複雑になり理解が困難になるため、**深くしてはいけない**。

# 8章 コンポジションでオブジェクトを組み合わせる
コンポジションとは、組み合わされた全体が*単なる部品の集合*以上となるように、「部品」を「全体」へと組み合わせる行為。
以下、コンポジションのテクニック。

## 自転車をパーツからcomposeする
6章で作ったBicycleクラスは、継承を使った抽象親クラス。これをコンポジションを使うように変更する。

Bicycleクラスは`spares`に応答する必要があるが、パーツから構成される自転車は、Partsクラスを持ち、それが`spares`に応答できればいい。
部品群を表すPartsクラスを作成し、自転車の種類(ロードバイクなど)もPartsの一部として考える。

```ruby
class Bicycle
  attr_reader :size, :parts

  def initialize(args = {})
    @size = args[:size] # 自転車のサイズ
    @parts = args[:parts] # 自転車の部品
  end

  def spares
    parts.spares # 応答をpartsに委譲
  end
end

class Parts
  attr_reader :chain, :tire_size

  def initialize(_atgs = {})
    @chain = args[:chain] || default_chain
    @tire_size = args[:tire_size] || default_tire_size
    post_initialize(args)
  end

  def spares
    {
      chain: chain,
      tire_size: tire_size
    }.merge(local_spares) # 自転車ごとに特有のスペアを足す
  end

  # 子クラスでオーバーライドするメソッド群 -----
  def default_tire_size
    raise NotImplementedError
  end

  def post_initialize(_args)
    nil
  end

  def local_spares
    {}
  end
  # -----------------------------------

  def default_chain
    '10-speed' # どんな自転車でも共通の初期値
  end
end

class RoasBikeParts < Parts
  attr_reader :tape_color

  def post_initialize(args)
    @tape_color = args[:tape_color] # ハンドルテープの色
  end

  def local_spares
    { tape_color: tape_color }
  end

  def default_tire_size
    '23' # ロードバイク特有の初期値
  end
end

class MountainBikeParts < Parts
  attr_reader :front_shock, :rear_shock

  def post_initialize(args)
    @front_shock = args[:front_shock] # 前のサスペンション(マウンテンバイク特有)
    @rear_shock = args[:rear_shock] # 後ろのサスペンション(マウンテンバイク特有)
  end

  def local_spares
    { rear_shock: rear_shock } # マウンテンバイク独自で必要なスペアはrear_shockのみ
  end

  def default_tire_size
    '2.1' # マウンテンバイク特有の初期値
  end
end
```

## Partsオブジェクトをcomposeする
`Parts`クラスはPartの集まり(集合)であるため、`Part`クラスを作る。
→ PartでPartsをcomposeする。
```ruby
class Bicycle
  attr_reader :size, :parts

  def initialize(args = {})
    @size = args[:size] # 自転車のサイズ
    @parts = args[:parts] # 自転車の部品
  end

  def spares
    parts.spares
  end
end

# Partの集合
class Parts
  attr_reader :parts

  def initialize(parts)
    @parts = parts
  end

  def spares
    parts.select { |part| part.need_spare }
  end
end

class Part
  attr_reader :name, :description, :need_spare

  def initialize(args)
    @name = args[:name]
    @description = args[:description] # 部品の詳細情報
    @need_spare = args.fetch(:need_spare, true) # スペアを用意する必要があるか
  end
end
```

## コンポジションと継承の選択
一般的なルールとして、コンポジションで解決できるものであれば、コンポジションを使うべき。
コンポジションが持つ依存は、継承よりも少ないため。

### 継承
#### メリット
1. 継承階層の頂点に近いところで定義されたメソッドの影響は広範囲に及ぶ。そのため、**振る舞いの大きな変更を、コードの小さな変更で達成できる**。
2. 継承を使ったコードは「Open-Closed」となる。**拡張には開いていて、修正には閉じている**。
3. 継承が正しく適用できれば、*TRUE* の**R,U,Eにおいて優れる**。
##### 変更が容易なコードに求められる性質 (TRUE)
見通しが良い(Transparent)
合理的(Reasonable)
利用性が高い(Usable)
模範的(Examplary)
#### デメリット
1. 継承が適さない問題に使用すると、**簡単に振る舞いを追加できなくなる**。
2. 自分の書いたコードが、他のプログラマによって**予期していなかった目的のために使われるかもしれなくなる**。
3. 継承が正しく適用**できなければ**、*TRUE* の**R,U,Eにおいて副作用が起こり得る**。
  - 合理的(Reasonable)
    間違ってモデル化された階層構造の頂点付近の変更にかかる、莫大なコストがかかる。(変更が困難)
  - 利用性が高い(Usable)
    サブクラスが複数の型を混合したものの表現だったとき、振る舞いの追加が困難になる。
  - 模範的(Examplary)
    間違ってモデル化された階層構造を使って、(リファクタリングでなく)既存のコードを複製したり、クラス名への依存が追加されたりすることで、問題が悪化する。

### コンポジション
#### メリット
1. **責任が単純明快**であり、明確に**定義されたインターフェース**を介してアクセスできる**小さなオブジェクト**が、自然と作られる傾向がある。
2. 小さなオブジェクトなため見通しが良い。コードを簡単に理解でき、変更が起きた場合に何が起こるかが明確。上の階層構造の変更による副作用に悩まされることが基本的にない。
3. composeされたオブジェクトは、自身のパーツとインターフェースを介して関わるため、新しい種類の部品の追加は、その部品に定義したインターフェースを持たせればいい。(あとは差し込むだけ)
#### デメリット
1. 個々の部品は見通しが良くとも、組み合わされた全体の動作は理解しにくくなる。
2. composeされたオブジェクトは、明示的にどのメッセージをだれに委譲するか、必ず知っておかなければならない。
3. ほぼ同一のパーツを構成する問題に対してはそこまで助けにならない。

### 関係の選択
:::message
#### `is-a関係`に 継承 を使う
#### `behave-like-a(~のように振る舞う)関係`に ダックタイプ を使う
#### `has-a関係`に コンポジション を使う
:::

# 9章 費用対効果の高いテストを設計する
変更可能なコードを書くために必要なのは次の3つのスキル。
1. *オブジェクト指向設計の理解*
2. *リファクタリングに長けていること*
3. **価値の高いテストを書く能力**
:::message
リファクタリングとは、**ソフトウェアの外部の振る舞いを保ったままで、内部の構造を改善**していく作業。
:::

## 意図を持ったテスト
*テストにコストがかかる*という問題への解決方法は、テストをやめることではなく、**上手くなること**。
→ テストから優れた価値を得るには、(テストの)**意図の明確さ**が求められる。
何を、いつ、どのようにテストするかを知らなければならない。

### テストの意図
#### バグを見つける
- 欠陥やバグを開発プロセスの初期段階で見つけることは、大きな利益である。(早ければ早いほど)
#### 仕様書となる
- 信頼できる設計の仕様書となる。
#### 設計の決定を遅らせる
- 設計の決定を安全に遅らせることができる。テストがインターフェースに依存している場合、その根底にあるコードは、奔放にリファクタリングできる。
#### 設計の欠陥を明らかにする
- **テストのセットアップに苦痛が伴うのであれば、コードはコンテキストを要求しすぎている**。
- 設計がまずければ、テストも難しい。(しかし、その逆は必ずしも真ではない。テストにコストがかかるからといって、必ずしも設計がまずい訳ではない。)

### 何をテストするかを知る
テストからより良い価値を得るための1つの単純な方法は、**より少ないテストを書く**こと。
貪欲すぎるテストは、対象のクラスをリファクタリングするたびに毎回壊れるせいで、コストを高めてしまう。

**パブリックインターフェースに定義されるメッセージを対象としたテスト**を書くべき。
テストは、オブジェクトの境界に入ってくる(受信)か、出ていく(送信)メッセージに集中すべき。
- **受信メッセージ : その戻り値の状態がテストされるべき**。
- **送信コマンドメッセージ : 送られたことがテストされるべき**。
- **送信クエリメッセージ : テストするべきでない**。

### いつテストするかを知る
初級の設計者はテストファーストでコードを書くことが最も有益。

## 受信メッセージをテストする
### 使われていないインターフェースを削除する
依存されていないメッセージをテストしてはいけない。
→ そのメッセージは使われていないということなので、削除する。
### パブリックインターフェイスを証明する
受信メッセージは、その実行によって戻される値や状態を表明することでテストされる。
考えられうるすべての状況において正しい値を返すことを証明する。

## プライベートメソッドをテストする
プライベートメソッドは、原則テストしないこと。
プライベートメソッドはパブリックメソッドによって実行されており、かつ、それは既にテストされているはずなため。

ブライベートメソッドを作らないようにする。
プライベートメソッドを大量に持つオブジェクトは、責任を大量に持ちすぎているかもしれない。

