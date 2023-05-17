---
title: "「リファクタリング (Rubyエディション)」要点"
emoji: "💎"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Ruby"]
published: false
---

# 書籍
https://www.fukkan.com/fk/CartSearchDetail?i_no=68327896

# この記事について
個人のメモとして、下記の事項のみを抜粋して記載している。
1. 自分が今後使いそうな内容
2. 忘れそうな内容
3. 初めて知って、感動した内容

## 注意
自分なりに解釈し、咀嚼した内容を記載しているため、実際にリファクタリングを適用する際は、本書の`手順`項にちゃんと從って行わないといけない。

# リファクタリングとは
**コードの外から見た振る舞いは変えずに、内部構造を改良すること**。

- バグを埋め込む危険を*最小限に抑えて*コードをクリーンにする方法。
（感想: 「最小限に抑えて」と書籍に書いていた。やはり、**バグを作りだしてしまう危険は0ではない**んだと感じた。）
- コードが書かれた後で設計を改良すること。
  コードは設計してから書いているはずではあるが、**時間が経つとともにコードは書き換えられ、設計に基づく構造は次第に変わっていく**。
  （感想: 完璧な設計なんてものは無い。その理由は、ビジネスは変化するものだからだと思う。）

# 1章 リファクタリング -最初のサンプル
（この章は例題を取り上げて、リファクタリングの重要ポイントが解説されていた。詳細は割愛し、重要だと感じた部分のみ列挙する。）

## 重要ポイント
- 機能を追加しにくいプログラムに機能を追加するとき、まずリファクタリングして作業をしやすくしてから進めること。
- リファクタリングするときの第一歩は、テストを作ること。
- **プログラムを少しずつ変更すること**。そうすると、間違えても簡単にバグを見つけられる。
- コンピュータが理解できるコードは誰でも書ける。**優れたプログラマは、人間が理解できるコードを書く。**
（感想: この点が最重要。）
- case文を使うときは、他のオブジェクトでなく、自身のデータ（状態）によって分岐すべき。

# 2章 リファクタリングの原則
## リファクタリングはいつすべきか
**特別な時間を割いて、決意してすることでなく**、何か他のことをするときに、役立つからリファクタリングするという性質のもの。
（感想: 現状、自分が書くコードだけで完結している部分はリファクタしているが、既存のコードも絡んでくるコードについては全然できていない。息を吸って吐くようにリファクタできるようにレベルまで高めないといけない。）

:::message
#### 3度目の原則
1度目: ただ、それをする。
2度目: 同じようなことを2度目にするときは、重複が気になっても、同じことをする。
3度目: リファクタリングする。
:::

# 3章 コードの臭い
リファクタリングしたほうがいいな と思うのはどういうときか、そのタイミングを説明。

## 3.1 コードの重複
複数の箇所で同じ構造のコードは、統一する方法を探す。

## 3.2 長いメソッド
手続きは長いほどわかりにくくなるため、メソッドは短くする。
(コメントを書きたいと思うたびにメソッドを書くぐらいに、分解をする。)
**メソッドの名前の付け方が大事で、メソッド名が良ければその中身を見る必要がなくなる。**

## 3.3 大きなクラス
1つのクラスの責務が多い場合は、大体インスタンス変数が多すぎる。

## 3.4 長い引数リスト
引数リストが長いとわかりにくく、一貫性が崩れて使いにくくなりやすく、必要なデータが増えるたびにメンテしなければいけない。

## 3.5 変更系統の分岐
バリエーションを処理するための変更は、1つのクラス/モジュールであるべき。
バリエーションの表現には、クラス/モジュールの新しい型を使うべき。

## 3.7 メソッドの浮気
メソッドが、自分のクラス以外のクラスに関心を持っている状態。
例えば、計算をするために、他のオブジェクトのゲッターを何回も呼び出しているメソッド 等。

## 3.10 case文
case文が少ないのはオブジェクト指向らしいコードの特徴。
case文には、コードの重複を生むという問題点がある。
**case文を見かけたら、ほとんどの場合ポリモーフィズムを検討すべき。**
（感想：ポリモーフィズムを検討すべきと言っているのは、おそらくオブジェクトのタイプによって分岐する場面を想定していると思う。）

## 3.12 仕事をしないクラス
1つ1つのクラスには、メンテナンスと理解のための時間というコストがかかる。
コストに見合う仕事をしないクラスは削除すべき。

## 3.13 空論的一般化
人が「いずれこういったこともできるようにする必要があると思うよ」と言ってあらゆるフックを欲しがったり、必要でないものを処理するための特殊条件を設けたりしている場合。
わかりにくく、メンテしづらいコードになることが多い。
使われていないなら、削除すべき。

## 3.15 メッセージの連鎖
クライアントがオブジェクトに別のオブジェクトを要求し、それが更に別のオブジェクトを要求...というような状態。

## 3.17 親密すぎるクラス
互いにプライベートな(非公開な)部分まで知っている状態。

## 3.22 コメント
**コメントを消臭剤として使っていることが多い。その臭いの原因を取り除くべき。**
(コメントを書いていけないということではない。)

:::message
**コメントを書かなければならないときには、まずコメントが不要になるまでコードをリファクタリングすること。**
:::

# 4章 テストの構築
- リファクタリングにテストは必要。
  - 赤→緑→リファクタリング
  （感想: 「テスト駆動開発」を勉強済なのですんなり理解できた。）
  - `例外`もテストする必要がある。
- バグレポートを受け取ったら、それを再現するテストを書くこと。

# 5章 リファクタリングのカタログに先立って
（この章は 6~12章の構成の説明 であったため省略。）

# 6章 メソッドの構成方法
## 6.1 メソッドの抽出
**コードの一部をメソッドにして、その目的を説明する名前をつける**。
- 理由: メソッドの粒度が細ければ、流用性が高くなる。
- 注意: 意味のある良い名前が思いつかないなら、それは抽出すべきでない。

（感想: とても重要。<6.2 メソッドのインライン化>にもあるように。メソッドの粒度は粗すぎず細かすぎないように気をつける。）

### 6.1.1 パターン: ローカル変数なし
```ruby:リファクタ前
def sample_method
  puts "sample"
  # その他諸々の処理...
end
```
```ruby:リファクタ後
def sample_method
  print_sample_method
end

def print_sample
  puts "sample"
  # その他諸々の処理...
end
```

### 6.1.2 パターン: ローカル変数あり
```ruby:リファクタ前
def sample_method
  local_variable = 0
  puts "instance_variable: #{@instance_variable}"
  puts "local_variable: #{local_variable}"
  # その他諸々の処理で、local_variableは使われる...
end
```
```ruby:リファクタ後
def sample_method
  local_variable = 0
  print_sample_method(local_variable)
  # その他諸々の処理で、local_variableは使われる...
end

# ローカル変数は別メソッド間でアクセスできないため、引数で渡す必要がある。
def print_sample_method(local_variable)
  puts "instance_variable: #{@instance_variable}"
  puts "local_variable: #{local_variable}"
end
```

### 6.1.3 パターン: ローカル変数への再代入
```ruby:リファクタ前
def sample_method
  local_variable = 0
  @sample.each do |sample|
    local_variable += sample.num
  end
  # その他諸々の処理で、local_variableは使われる...
end
```
```ruby:リファクタ後
def sample_method
  # ローカル変数に再代入することで、以降の処理に影響を与えない
  local_variable = calculate_sum
  # その他諸々の処理で、local_variableは使われる...
end

def calculate_sum
  # local_variable = 0
  # @sample.each do |sample|
  #   local_variable += sample.num
  # end
  # local_variable
  
  # 上記はinjectでスマートに書ける
  @sample.inject(0) { |local_variable, sample| local_variable + sample.num }
end
```

## 6.2 メソッドのインライン化
メソッドを呼び出し元に組み込み、そのメソッドを削除。
- 条件: メソッドの本体が、そのメソッドの名前と同じぐらいわかりやすい場合。
- 理由: 過剰な間接化はイライラの原因。

```ruby:リファクタ前
def sample_method
  is_more_than_five ? 2 : 1
end

def is_more_than_five
  @sample > 5
end
```

```ruby:リファクタ後
def sample_method
  @sample > 5 ? 2 : 1
end
```

## 6.3 一時変数のインライン化
一時変数を削除。
- 条件: 単純 かつ 1度しか代入されていない場合。
- 理由: リファクタリングを妨げる。

## 6.4 一時変数から問合せメソッドへ
一時変数(式)をメソッドにする。
メソッドは最初は非公開にしておき、後で他の用途が見つかったら緩めればいい。
- 条件: なし。
- 理由: **一時変数の問題点は、一時的でローカルであること**。一時変数にアクセスするためにはメソッドを長くする以外になく、メソッドの長大化を助長するため。

:::message
この変更で不安なのは下記2点。
- 同じメソッドを2回以上呼び出しても、パフォーマンスは大丈夫か。
  - **リファクタリングは、わかりやすくすることに集中すべき。**（パフォーマンスを上げるのは別の仕事）
  - **メソッド呼び出し回数が増えても、ほとんどの場合問題ない。**
- 複数回呼び出しているメソッドが、**冪等かどうか**。
:::

:::message
**一時変数は無いほうがいい**。なぜそこに一時変数があるのか分からなくなってしまうため。
**コードが何をしようとしているか**が、はっきりと分かるようになる。
:::

（感想: とても重要。特に「メソッドを複数回呼び出しまって良いのか」という点。この点は、個人的にはこれまで抵抗があったが、この本を読んで考え方が理解できた。）


```ruby:リファクタ前
def price
  # base_priceを求めるロジック
  base_price = @quantity * @item_price

  # discount_factorを求めるロジック
  if base_price > 1000
    discount_factor = 0.95
  else
    discount_factor = 0.98
  end
  
  # 本質
  base_price * discount_factor
end
```

```ruby:リファクタ後
def price
  base_price * discount_factor
end

def base_price
  @quantity * @item_price
end

def discount_factor
  base_price > 1000 ? 0.95 : 0.98
end
```

```ruby:base_priceを一時変数から問合せメソッドにしなかった場合
def price
  # base_priceが一時変数のままの場合
  base_price = @quantity * @item_price

  discount_factor(base_price)
  
  base_price * discount_factor
end

# base_priceはローカル変数なのでメソッドからアクセスできず、外部から渡さないといけない（引数など）
def discount_factor(base_price)
  base_price > 1000 ? 0.95 : 0.98
end
```

## 6.5 一時変数からチェインへ
チェイニングして、一時変数を削除。
- 条件: 一時変数に対して複数行に渡ってメソッドを複数回実行している状況。

## 6.6 説明用変数の導入
処理の目的を説明する名前の一時変数に、式orその一部 の結果を保管する。
- 条件: 式が複雑な場合。
- 理由: 可読性向上のため。
:::message alert
6.6 ~ 6.8項で一時変数を導入するが、**軽々しく一時変数を導入してはいけない**。(理由: 6.4項に記載)
**<6.6 説明用変数の導入>の前に、<6.1 メソッドの抽出>ができないか考える**こと。
:::

## 6.7 一時変数の分割
代入ごとに別の一時変数を用意する。
- 条件: ループ変数でも計算結果蓄積用の変数でもないのに、複数回代入される一時変数がある場合。
- 理由: 2つの異なる目的のために1つの一時変数を使い回すと混乱するため。

## 6.8 引数への代入の除去
引数への代入の代わりに一時変数を使う。
- 条件: 引数に代入を行っている場合。
- 理由: Rubyは(参照渡しでなく)値渡しなため、呼び出し元ルーチンには影響はないが、紛らわしく、読みにくいため。
また、引数の用途は渡されたものを表すことなので、それに代入して別の役割を持たせないようにするため。

## 6.9 メソッドからメソッドオブジェクトへ
メソッドを独自のオブジェクト(クラス)に変える。ローカル変数をそのオブジェクトのインスタンス変数にする。
- 条件: <メソッドの抽出>を適用できないようなローカル変数の使い方をしている場合。
- 理由: 独自のオブジェクト内で、メソッドの分解(<メソッドの抽出>)ができる。

（感想: 手間のかかるリファクタなので、巨大なメソッドに適用するのが費用対効果的に良いと思う。）

## 6.10 アルゴリズム変更
より簡単なアルゴリズムに変更。
（感想: 6.11項のコレクションクロージャメソッドを使うことで、アルゴリズムを簡単にすることがかなり実現できると思う。）

## 6.11 ループからコレクションクロージャメソッドへ
ループでなく、コレクションクロージャメソッドを使う。
**each系の処理をmap系の処理にする**こと。
繰り返し処理した結果を返却したい場合に、ループの外から変数として渡す必要がなくなる。
（感想: とても重要。eachを使いたいと思ったとき、必ずmap系で実現できないか確認する。）

### select
**条件に合致するものだけを抽出**する。
```ruby
managers = []
employees.each do |e|
  managers << e if e.manager?
end
# ↓
managers = employees.select { |e| e.manager? } # {}内は真偽値
```

### map
**ブロックを実行した戻り値を格納**する。
```ruby
offices = []
employees.each { |e| offices << e.office }
# ↓
offices = employees.map { |e| e.office } # {}内は実行するブロック
```

----

```ruby:リファクタ前
managerOffices = []
employees.each do |e|
  managerOffices << e.office if e.manager?
end
```
```ruby:リファクタ後
# チェインで繋げられる
managerOffices = employees.select { |e| e.manager? }
                           .map { |e| e.office }
```

### inject
**合計を出すとき** など、ループ内で値を生み出すような場合に使う。
返り値の初期値が設定できる。（例: 0からスタートする、10からスタートする）

`inject(返り値の初期値)　{ | 返り値, 配列内のオブジェクト| ブロック }`


```ruby
total = 0
employees.each { |e| total += e.salary }
# ↓
total = employees.inject(0) { |sum, e| sum + e.salary }
# (デフォルト引数は0 なので(0)は省略可)
```

## 6.12 サンドイッチメソッドの抽出
- 条件: ほぼ同じロジックだが、その中間ぐらいのロジックに差異がある複数のメソッドがあるとき。

重複部分を抽出してメソッドにする。
その複数のメソッドは、抽出したメソッドにブロックを渡すようにする。
（感想: よくあるシチュエーションだと感じる。よく使いそう。）

```ruby:リファクタ前
  def sample_method_equal_one
    if @count.present? && @count == 1
      @count += 1
    end
  end

  def sample_method_equal_arg(arg)
    if @count.present? && @count == arg # 少しだけ違う
      @count += 1
    end
  end
```
```ruby:リファクタ後
  def sample_method_equal_one
    sample_method_logic { |count| count == 1 } # {}内がブロック
  end

  def sample_method_equal_arg(arg)
    sample_method_logic { |count| count == arg }
  end

  def sample_method_logic
    if @count.present? && yield(@count) # ブロックを実行。
      @count += 1
    end
  end
```

### ブロックについて
よく知らなかったため、下記の記事を参考に下記の通り理解した。
#### ブロック
メソッドに渡すコードの塊。
#### `yeild`
ブロックを起動する。
#### `&block`
&blockという引数を宣言すると、ブロックがblock変数に代入される。
block.callメソッドを呼ぶと、ブロックの処理が実行される。

https://qiita.com/genya0407/items/1a34244cba6c3089a317

## 6.13 クラスアノテーションの導入
initializeの導入。

## 6.14 名前付き引数の導入
キーワード引数の導入。

## 6.15 名前付き引数の除去
キーワード引数の除去。引数が1つであるとき。
- 理由: 引数が1つだと、わざわざキーワードにする必要がない。メソッドを呼び出すたびにキーワード引数を書かないといけなく、費用対効果が小さいため。

## 6.16 使われていないデフォルト引数の除去
使われていないデフォルト引数を除去。
引数による条件分岐などが削除できる可能性がある。
（感想: 使われていないことをちゃんと確認しないといけない。）

## 6.17 動的メソッド定義
メソッドを動的に定義する。

:::message
本書にあったのは`def_each`等を使う方法であったが、調べたところ古いなので、下記記事を参考にした。
https://tech.ga-tech.co.jp/entry/2019/10/ruby-metaprogramming
`define_method`や`send`を使うことで実現できる。
:::

## 6.18 動的レセプタから動的メソッド定義へ
動的メソッド定義を行うことで、`method_missing`を使わずに同じような振る舞いを実現。
:::message
`method_missing`
メソッドが未定義の際にNoMethodErrorを発行するメソッド。ここにバグがあると発見しにくいため、自前でmethod_missingを実装するのは避けたほうがいい。
:::

# 7章 オブジェクト間でのメンバの移動

## 7.1 メソッドの移動
**メソッドを最もよく使っている他のクラスに、同じ内容の新メソッドを作る**。
古いメソッドは、そのメソッドに処理を委ねる or 削除する。
- 条件: メソッドが、自身のクラスよりも他クラスをよく利用している or 利用されている場合。（今はそうでなくても、そうなりつつあるとき。）

## 7.2 フィールドの移動
**移すクラスに新しいフィールドのreader（必要ならwriterも)を作り、フィールドを使っているコードを書き換える**。
- 条件: フィールドが、自身のクラスよりも他クラスをよく利用している or 利用されている場合。（今はそうでなくても、そうなりつつあるとき。）

## 7.3 クラスの抽出
新しいクラスを作成。関連フィールド・メソッドを移す。
- 条件: 2つのクラスで行うべき仕事をしているクラスがある場合。

```ruby:リファクタ前
class Person
  attr_accessor :office_area_code
  attr_accessor :office_number
  
  def telephone_number
    '(' + @office_area_code + ')' + @office_number
  end
end

person = Person.new
person.office_area_code = 123
```

```ruby:リファクタ後
class Person
  # 新しいクラスへのリンクを作る
  def initialize
    @office_telephone = TelephoneNumber.new
  end

  # 少し違う手段として、下記のコメント部のようにゲッター・セッターを用意すれば、フィールドへのアクセス方法は変えないで済む。
  # -----------------------------------------------
  # 既存のフィールドは、新しいクラスのフィールドに向ける
  # ゲッター
  # def office_area_code
  #   @office_telephone.area_code
  # end
  # # セッター
  # def office_area_code(arg)
  #   @office_telephone.area_code = arg
  # end
  # -----------------------------------------------

  # 移動したフィールドへのアクセスは、office_telephone経由となる。
  def office_telephone
    @office_telephone
  end

  # メソッドは新しいクラスに移動
  def telephone_number
    @office_telephone.telephone_number
  end
end

class TelephoneNumber
  attr_accessor :area_code, :number

  def telephone_number
    '(' + area_code + ')' + number
  end
end

person = Person.new
# 移動したフィールドへのアクセスは、office_telephone経由となる。
person.office_telephone.area_code = 123
```

## 7.4 クラスのインライン化
すべての機能を他のクラスに移して、クラスを削除する。（<7.3 クラスの抽出>の逆）
- 条件: 大した仕事をしていないクラスがある場合。

<7.3 クラスの抽出>の逆のことをすればいい。

## 7.5 委譲の隠蔽
サーバに、委譲を隠すためのメソッドを作る。
- 条件: クライアント（呼び出し元）が、サーバ（呼ばれる側）クラスの委譲クラスを呼び出している。
  - サーバ（呼ばれる側） : 下記例では、`Person`。
  - 委譲クラス : 下記例では、`Department`。
- 理由: カプセル化できるため。

### カプセル化
**オブジェクトがシステムの他の部分についてあまり知識を持たなくていい**。
→　システムに変更を加えても、**その変更を知らせないといけないオブジェクトが減るため、変更しやすい**。

```ruby:リファクタ前
# 社員
class Person
  attr_accessor :department
end

# 部門
class Department
  attr_reader :manager

  def initialize(manager)
    @manager = manager
  end
end

manager = person.department.manager
```
```ruby:リファクタ後
class Person
  attr_writer :department # ゲッターは不要になった

  def manager
    @department.manager
  end
end

class Department
  attr_reader :manager

  def initialize(manager)
    @manager = manager
  end

  # ...
end

# managerを取得するためにはdepartmentを経由しないといけない という知識が必要なくなる
manager = person.manager
```

## 7.6 横流しブローカーの除去
クライアントに、委譲オブジェクトを直接呼び出させる。（<7.5 委譲の隠蔽>の逆）
- 条件: クラスが単純な委譲をやりすぎている。
- 理由: 委譲オブジェクトに新しいメンバが追加されるたびに、サーバクラスに委譲メソッドを作らないといけないため。（<7.5 委譲の隠蔽>の代償）

<7.5 委譲の隠蔽>の逆のことをすればいい。

# 8章 データの構成
## 8.1 自己カプセル化フィールド
フィールド（インスタンス変数）に直接アクセスするのでなく、ゲッター・セッターを作りそれを経由する。
```ruby:リファクタ前
class Item
  def initialize(base_price, tax_rate)
    @base_price = base_price
    @tax_rate = tax_rate
  end

  def raise_base_price_by(percent)
    @base_price = @base_price * (1 + percent/100)
  end

  def total
    @base_price * (1 + @tax_rate)
  end
end
```
```ruby:リファクタ後
class Item
  attr_accessor :base_price, :tax_rate

  def initialize(base_price, tax_rate)
    @base_price = base_price
    @tax_rate = tax_rate
  end

  def raise_base_price_by(percent)
    base_price = base_price * (1 + percent/100)
  end

  def total
    base_price * (1 + tax_rate)
  end
end

class ImportedItem < Item
  attr_reader :import_duty

  def initialize(base_price, tax_rate, import_duty)
    super(base_price, tax_rate)
    # 関税
    @import_duty = import_duty
  end

  def tax_rate
    # Item側の振る舞いを変えず、簡単にtax_rateをオーバーライドできた
    super + import_duty
  end
end
```

## 8.2 データ値からオブジェクトへ
データ項目をオブジェクトに変換する。
- 理由: 1つの単純なデータ（項目）として表現していたものが、それほど単純でないと分かることがある。そういったときに、振る舞いを追加できるようにするため。

```ruby:リファクタ前
class Order
  attr_accessor :customer

  def initialize(customer)
    @customer = customer # 顧客名(文字列)
  end
end

# ----------------------
# 別のクラスのどこかのコード

# 顧客が注文したorderの数を取得
def self.number_of_orders_for(orders, customer)
  orders.select { |order| order.customer == customer }.size
end
```
```ruby:リファクタ後
class Order
  def initialize(customer)
    @customer = Customer.new(customer)
  end

  def customer
    @customer.name
  end

  def customer=(value)
    @customer = Customer.new(value)
  end
end

class Customer
  attr_reader :name

  def initialize(name)
    @name = name
  end
end
```

## 8.3 値から参照へ
- 条件: 同じインスタンス(値オブジェクト)をいくつも生成しており、それらを1つに圧縮したい場合。
その値オブジェクトを参照オブジェクトに変える。

毎回インスタンスを生成するのでなく、オブジェクト群をハッシュに格納（ロード）しておき、そのハッシュから探して返却する。
```ruby
class Sample
  instances = {}

  def store
    instances[name] = self
  end

  def self.with_name(name)
    instances[name]
  end
end
```

## 8.6 ハッシュからオブジェクトへ
- 条件: 異なる種類のオブジェクトを格納しているhashがある。
各キーに対応するフィールドを持つオブジェクトを定義し、hashを削除する。
（感想: フィールドをメソッドに変換できるのがメリット。）

```ruby:リファクタ前
new_network = { nodes: [], old_networks: [] }

new_network[:old_networks] << node.network
new_network[:nodes] << node

new_network[:name] = new_network[:old_networks].map { |network| network.name }.join(" - ")
```

```ruby:リファクタ後
# このように使いたい↓
new_network = NewworkResult.new

new_network.old_networks << node.network
new_network.nodes << node

new_network.name = new_network.old_networks.map { |network| network.name }.join(" - ")

# なので、クラスを定義する↓
class NewworkResult
  attr_reader :old_networks, :nodes
  # attr_accessor :name ← メソッドに移した

  def initialize
    @old_networks, @nodes = [], []
  end

  # nameフィールド→nameメソッドに移し、処理を定義できる
  def name
    @old_networks.old_networks.map { |network| network.name }.join(" - ")
  end
end
```

## 8.9 マジックナンバーからシンボル定数へ
マジックナンバーを**意味がわかる名前の定数**に置き換える。
（感想: とても重要。これは今後必ず行う。）
```ruby:リファクタ前
def sample_method(number)
  number * 3.14
end
```
```ruby:リファクタ後
PI = 3.14

def sample_method(number)
  number * PI
end
```

## 8.15 サブクラスからフィールドへ
- 条件: 定数を返すメソッド以外には違いがない複数のサブクラス（子クラス）がある場合。
メソッドをスーパークラス（親クラス）のフィールドに変えて、サブクラスを削除する。

```ruby:リファクタ前
class Person
  # ..
end

class Female < Person
  def female?
    true
  end

  def code
    'F'
  end
end

class Male < Person
  def female?
    false
  end

  def code
    'M'
  end
end
```
```ruby:リファクタ後
class Person
  def initialize(female, code)
    @female = female
    @code = code
  end

  def female?
    @female
  end

  def code
    @code
  end

  def self.create_female
    Person.new(true, 'F')  # フィールドに詰めて初期化する
  end

  def self.create_male
    Person.new(false, 'M')
  end
end
```

## 8.16 属性初期化の遅延実行 , 8.17 属性初期化の先行実行
属性を初期化するタイミングをどうするか(どちらがいいか)という話。
（著者の周りでも2つの意見で5分に分かれたと記載ある。）
メリット・デメリットがあるため、どちらの手法を取るかはチームで決めればいい。

```ruby:属性初期化の先行実行
class Sample
  def initialize
    @samples = []
  end
end
```
```ruby:属性初期化の遅延実行
class Sample
  def samples
    # メリット: initializeでいちいち初期化しなくていい,コードが減る
    # デメリット: アクセスの度に値が変わるためデバッグしにくい
    @samples ||= [] 
  end
end
```

# 寄り道
上で出てきた `||=` はRuby独自の記法。他にも便利なイディオムがあるはずだと思い調べた。
https://docs.ruby-lang.org/ja/latest/doc/symref.html
上記サイトを参考に、メモする。

## def xxx!
この場合の「!」はメソッド名の一部です。
慣用的に、同名の(! の無い)メソッドに比べてより**破壊的な作用をもつメソッド**で使われます。
(例: map と map!)

## def xx?
この場合の「?」はメソッド名の一部分です。
慣用的に、**真偽値を返すメソッド**を示すために使われます。

## def xxx(&yyy)
&がついた引数はブロック引数。

## xxx&.yyy
ぼっち演算子。
**xxxがnilでないときに**メソッドyyyを呼び出す。

## a ||= xxx
**「||」演算子の自己代入演算子**。
**aが偽か未定義 なら aにxxxを代入する**。

```ruby
a ||= :some
p a #=> some
a ||= :sec 
p a #=> some # aは定義済みだったので、:secはaに代入されなかった
```

## \`ls\`
コマンド出力。
バッククォート(`)で囲まれた文字列は、コマンドとして実行され、その標準出力が文字列として与えられます。

```ruby
p `ls`
#=> "README.md\ndata.txt\nrefactoring_1.rb\nrefactoring_2.rb\n"
```


# 9章 条件式の単純化
## 9.1 条件文の分解
**条件部からメソッドを抽出**する。
- 条件: 条件が複雑な場合。
（感想: とても重要。よく使用される条件はメソッドに抽出することで再利用しやすくなる。今後複雑な条件を書く必要が出た場合は、必ず検討をする。）

```ruby:リファクタ前
if number >= 10 || number <= -10
  p "絶対値が10以上"
else
  p "絶対値が10未満"
```
```ruby:リファクタ後
if is_over_ten(number)
  p "絶対値が10以上"
else
  p "絶対値が10未満"
end

def is_over_ten(number)
  number >= 10 || number <= -10
end
```

## 9.2 条件分岐の組み替え
Rubyらしく書くことで読みやすくする。
（感想: とても重要。Rubyらしさ、PHPらしさ...というのは言語特有なので、言語を深く知ることはこういうときに力を発揮する。）

### 三項演算子 → OR代入 へ
```ruby
samples = params.present? ? params : []
# ↓
samples = params : []
```

### 条件分岐 → 明示的なreturn へ
```ruby
def sample_method(number)
  if sample > 10
    1
  else
    2
  end
end
# ↓
def sample_method(number)
  return 1 if sample > 10
  2
end
```

## 9.3 条件式の統合
- 条件: 同じ結果になる条件が複数ある場合。

それらを1つにまとめ、メソッドとして抽出する。

```ruby:リファクタ前
def sample_method
  return 0 if @data.size > 5
  return 0 if @amount > 10 # 結果は上と同じ
  1
end
```
```ruby:リファクタ後
def sample_method
  return 0 if sample_condition
  1
end

def sample_condition
  @data.size > 5 || @amount > 10
end
```

## 9.5 制御フラグの除去
**`break`や`return`を使って、制御フラグを除去**する。
- 条件: 制御フラグがある場合。

### break使用
```ruby:リファクタ前
def check_security(people)
  found = false # 制御フラグ
  people.each do |person|
    unless found
      if person == "Taro"
        send_alert
        found = true # ある条件に合致したら制御フラグを切り替え
      end
      if person == "Hanako"
        send_alert
        found = true
      end
    end
  end
end
```
```ruby:リファクタ後
def check_security(people)
  people.each do |person|
    if person == "Taro"
      send_alert
      break # ループを抜ける
    end
    if person == "Hanako"
      send_alert
      break
    end
  end
end
# まだリファクタの余地があるが、別の話になるので割愛
```

### return使用
```ruby:リファクタ前
def check_security(people)
  # 制御フラグ かつ 別で使用する値
  found = "" # 初期値
  people.each do |person|
    if found == ""
      if person == "Taro"
        send_alert
        found = "Taro"
      end
      if person == "Hanako"
        send_alert
        found = "Hanako"
      end
    end
  end
  some_later_code(found)
end
```
```ruby:リファクタ後
def check_security(people)
  found = found_miscreant(people) # 2つのことをしていたので、メソッドに切り出し
  some_later_code(found)
end

# foundの値を返すメソッド
def found_miscreant(people)
  people.each do |person|
    if person == "Taro"
      send_alert
      return "Taro" # 早期return
    end
    if person == "Hanako"
      send_alert
      return "Hanako"
    end
    end
  end
  "" # 条件に合致しなかった → 初期値のまま
end
```

## 9.6 条件分岐のネストからガード節へ
- 条件: 
  - 条件分岐によって、正常な実行経路がわかりづらい場合。
  - 異常な状態を表す条件(特殊条件)がある場合。

**特殊条件をガード節で処理（早期リターン）する**。
（感想: とても重要。使い分けの指針を下記した。）

:::message
条件分岐には2種類ある。
1. 分岐先のいずれも(if/else)、正常な振る舞いで、同じぐらい実行され、同じくらい重要な場合。 → **if/else**
2. 分岐先の片方が、異常状態を表したり、まれなケースな場合。 → **ガード節**
:::

```ruby:リファクタ前
# 支払う給与
def pay_amount
  if @dead
    result = dead_amount # 死亡
  else
    if @separated
      result = separated_amount # 別居中
    else
      if @retired
        result = retired_amount # 退職
      else
        result = normal_pay_amount # 通常
      end
    end
  end
  result
end
```
```ruby:リファクタ後
def pay_amount
  # 特殊な条件は早期return
  return dead_amount if @dead # 死亡 
  return separated_amount if @separated # 別居中
  return retired_amount if @retired # 退職

  normal_pay_amount # 通常
end
```

### 条件式を逆にしながら<条件分岐のネストからガード節へ>
（感想: 条件を逆にしたほうがすっきりするときがある ということだと思う。）

```ruby:リファクタ前
def adjussted_capital
  result = 0
  if @capital > 0
    if @interest_rate > 0 && @duration > 0
      result = ( @income / @duration) * ADJ_FACTOR
    end
  end
  result
end
```
```ruby:リファクタ後
def adjussted_capital
  return 0 if @capital <= 0 # 条件を逆にした
  return 0 if @interest_rate <= 0 || @duration <= 0 # 条件を逆にした
  (@income / @duration) * ADJ_FACTOR
end
```

## 9.7 条件分岐からポリモーフィズムへ
（ポリモーフィック関連の）オブジェクトの種類によって分岐する条件分岐を削除し、その分岐先の処理をオブジェクトに移す。

:::message
### ポリモーフィズム（多相性）
多岐にわたるオブジェクトが、同じメッセージに応答できる能力。
:::

# 10章 メソッドの呼び出しの単純化
## 10.1 メソッド名の変更
メソッド名を修正。
- 条件: メソッド名から**メソッドの目的**がわからない場合。


```ruby
# def sample_method (悪い)
def full_name
  "#{name_last} #{name_first}"
end
```

## 10.2 引数の追加
- 条件: メソッドの振る舞いの変更により。引数を追加しないといけない。

引数を追加する。
ただし、**代わりになる方法を考えてから**行うこと。
- オブジェクトに問い合わせればいい場合
  - オブジェクトを渡したほうがいいのでは？
  - 逆に、そのオブジェクトに情報を提供するメソッドを追加するほうがいいのでは？

## 10.4 問い合わせと更新の分離
問い合わせ用と更新用の2つのメソッドを作る。
- 条件: 値を返すとともに、オブジェクトの状態に変更を加えるメソッドがある場合。
- 理由: 副作用がないメソッドは、考えなければならないことが大幅に減る。
:::message
- 副作用があるメソッドか、副作用がないメソッドかどうかを**明確にする**。
- **メソッドの返り値が呼び出し元で使われている かつ 副作用がある**場合は分離すべき。
:::
（感想: 重要。使い手・読み手が考えることが少なくなり、結果として可読性も向上する。副作用があるかどうかは命名で明確にすること。GraphQLではQueryとMutationでこの考え方をしていたが、Railsでは考えたことが無かった。）

## 10.5 メソッドのパラメータ化
- 条件: 複数のメソッドが異なる値を使って、同じようなことをしている場合。

その異なる値を引数とする1つのメソッドにまとめる。

## 10.9 引数オブジェクトの導入
- 条件: 自然にまとめられる引数のグループがある場合。

それらの引数を、オブジェクトにする。

## 10.10 設定メソッドの削除
- 条件: インスタンス作成時に設定して、その後は変更すべきでないフィールドがある場合。

設定メソッド（セッター）を削除する。
→ `attr_writer`(`attr_accessor`) や `def フィールド=(value)`を削除する。

## 10.12 コンストラクタからファクトリメソッドへ
- 条件: オブジェクトを生成するときに、単なる構築以上のことをしたい場合。

コンストラクタを取り除いて、ファクトリメソッドを作る。

:::message
コンストラクタ : クラスからインスタンスを作る時に実行される処理
:::

```ruby:リファクタ前
class ProductController
  def create
    # どういう値かによって、作るプロダクトの種類が異なる
    # → この判定をオブジェクトクラスでやっていないことが問題。色々な箇所で毎回このロジックを書く必要があるため。
    @product = if imported
                  ImportedProduct.new(base_price)
                else
                  if base_price > 1000
                    LuxuryProduct.new(base_price)
                  else
                    Product.new(base_price)
                  end
                end
  end
end
```
```ruby:リファクタ後
class ProductController
  def create
    @product = Product.create(base_price, imported)
  end
end

class Product
  # ファクトリメソッドへ
  def self.create(base_price, imported=false)
    if imported
      ImportedProduct.new(base_price)
    else
      if base_price > 1000
        LuxuryProduct.new(base_price)
      else
        Product.new(base_price)
      end
    end
  end
end
```

## 10.13 エラーコードから例外へ
- 条件: エラーを示すために、特別なエラーコード（エラーと知らせるための変な値）を返している。

代わりに例外を生成する。

# 11章 一般化の処理
## 11.1 メソッドの上位階層への移動
複数の子クラスで同じ結果になるメソッドは、親クラスへ移動する。

## 11.3 モジュールの抽出
- 条件: 複数のクラスに重複する振る舞いがある場合。

振る舞いを新たなモジュールに移動させ、`include`する。

:::message
重複を取り除くときは、できるだけ**クラスの抽出**を使う。
ただし、他の（第3の）クラスに再利用できないなら、**モジュールの抽出**を使う。
:::

## 11.5 サブクラスの抽出
- 条件: クラスが、一部のインスタンスしか使わないフィールドがある。

そのフィールドのために子クラスを作る。

```ruby:リファクタ前
class JobItem
  attr_reader :quantity, :employee

  def initialize(unit_price, quantity, is_labor, employee)
    @unit_price = unit_price
    @quantity = quantity
    @is_labor = is_labor
    @employee = employee
  end

  def total_price
    unit_price * @quantity
  end

  def unit_price
    # labor(修理するのが大変)かどうかで振る舞いが変わる
    labor? ? @employee.rate : @unit_price
  end

  def labor?
    @is_labor
  end
end
```
```ruby:リファクタ後
class JobItem
  attr_reader :unit_price, :quantity

  # employeeは不要になった
  def initialize(unit_price, quantity, is_labor=false)
    @unit_price = unit_price
    @quantity = quantity
    @is_labor = is_labor
  end

  def total_price
    unit_price * @quantity
  end

  def labor?
    false
  end
end

# 子クラス
class LaborItem < JobItem
  attr_reader :employee

  # LaborItemの生成には、unit_price, is_laborは不要
  def initialize(quantity, employee)
    super(0, quantity, true) # is_laborはtrue
    @employee = employee
  end

  def labor?
    true
  end

  def unit_price
    @employee.rate
  end
end
```

## 11.6 継承の導入
- 条件: 同じような機能を持つクラスが2つある場合。

継承を使い、親子にする。

:::message
- `継承の導入`を使うか迷うような場合は、`クラスの抽出`を使えばいい。
  - `クラスの抽出`が使えないなら、`モジュールの抽出`。
- 2つのクラスが振る舞いだけでなく、インターフェイスも同じなら、`継承の導入`を使う。
:::


```ruby:リファクタ前
class MountaionBike
  TIRE_WIDTH_FACTOR = 6
  attr_accessor :tire_diameter

  def wheel_circumference
    Math::PI * (@wheel_diameter + @tire_diameter)
  end

  def off_road_ability
    @tire_diameter * TIRE_WIDTH_FACTOR
  end
end

class FrontSuspensionMountainBike
  TIRE_WIDTH_FACTOR = 6
  FRONT_SUSPENTION_FACTOR = 8
  attr_accessor :tire_diameter, :front_fork_travel

  def wheel_circumference
    # MountaionBikeと同じ
    Math::PI * (@wheel_diameter + @tire_diameter)
  end

  def off_road_ability
    # MountaionBikeと少し違う
    @tire_diameter * TIRE_WIDTH_FACTOR + @front_fork_travel * FRONT_SUSPENTION_FACTOR
  end
end
```
```ruby:リファクタ後
class MountaionBike
  TIRE_WIDTH_FACTOR = 6
  attr_accessor :tire_diameter

  def wheel_circumference
    Math::PI * (@wheel_diameter + @tire_diameter)
  end

  def off_road_ability
    @tire_diameter * TIRE_WIDTH_FACTOR
  end
end

# MountaionBikeの派生なので、MountaionBikeの子クラスにする
class FrontSuspensionMountainBike < MountaionBike
  FRONT_SUSPENTION_FACTOR = 8
  attr_accessor :front_fork_travel

  def off_road_ability
    # MountaionBikeの結果から、FrontSuspensionMountainBike独自の計算をする
    super + @front_fork_travel * FRONT_SUSPENTION_FACTOR
  end
end
```

## 11.8 テンプレートメソッドの作成
- 条件: 同じような処理をするメソッドが別々の子クラスにあるが、内容がわずかに違う。

違いのある処理を抽出して、子クラスで同じメソッド名で実装。
共通する処理を親クラスで実装。

### 継承を使ったテンプレートメソッド
```ruby:リファクタ前
# レシート表示
def statement
  result = "レンタル #{name}"
  @rentals.each do |rental|
    result << "#{rental.movie.title} #{rental.charge}" # 映画のタイトル、料金
  end
  result << "合計#{total_charge}"
  result << "#{total_frequent_rental_points}"
  result
end

# レシートをHTMLで表示（なのでstatementと少し違う）
def html_statement
  result = "<h1>レンタル #{name}</h1>"
  @rentals.each do |rental|
    result << "#{rental.movie.title} #{rental.charge}<br/>"
  end
  result << "<p>合計#{total_charge}</p>"
  result << "<p>#{total_frequent_rental_points}</p>"
  result
end
```
```ruby:リファクタ後
# クライアントコード``````
class Customer
  def statement
    TextStatement.value(self)
  end

  def html_statement
    HtmlStatement.value(self)
  end
end
# ````````

class Statement
  # 2つの子クラスで共通している処理
  def value(customer)
    result = header_string(customer)
    customer.rentals.each do |rental|
      result << each_rental_string(rental)
    end
    result << footer_string(customer)
  end
end

# 子クラス側では、独自の実装をする
class TextStatement < Statement
  def header_string(customer)
    "レンタル #{customer.name}"
  end

  def each_rental_string(rental)
    "#{rental.movie.title} #{rental.charge}"
  end

  def footer_string(customer)
    <<-EOS
      "合計#{customer.total_charge}"
      result << "#{customer.total_frequent_rental_points}"
    EOS
  end
end

class HtmlStatement < Statement
  def header_string(customer)
    "<h1>レンタル #{customer.name}</h1>"
  end

  def each_rental_string(rental)
    "#{rental.movie.title} #{rental.charge}<br/>"
  end

  def footer_string(customer)
    <<-EOS
      "<p>合計#{customer.total_charge}</p>"
      "<p>#{customer.total_frequent_rental_points}</p>"
    EOS
  end
end
```

### モジュールのextendを使ったテンプレートメソッド
Statementクラスのインスタンスを作ることがない場合は、モジュールでextendするのが良い。

継承を使った場合、親クラスは1つだけなのに対し、
extendを使うと、複雑な継承の問題を避けられる。

:::message
**extend**
extendを使うと、moduleのメソッドをそのオブジェクトのインスタンスメソッドとして取り込むことができる。
:::

```ruby:リファクタ後
# クライアントコード``````
class Customer
  def statement
    Statement.new.extend(TextStatement).value(self)
  end

  def html_statement
    Statement.new.extend(HtmlStatement).value(self)
  end
end
# ````````

class Statement
  # ...
end

module TextStatement
  # ...
end

module HtmlStatement
  # ...
end
```

#### 参考記事
https://qiita.com/shiopon01/items/fd6803f792398c5219cd#%E3%82%AF%E3%83%A9%E3%82%B9%E3%81%AB%E7%B5%84%E3%81%BF%E8%BE%BC%E3%82%93%E3%81%A7%E5%A4%9A%E9%87%8D%E7%B6%99%E6%89%BF%E3%82%92%E5%AE%9F%E7%8F%BE%E3%81%99%E3%82%8Bmix-in
→ 名前空間を作ってモジュール名やメソッド名の衝突を防ぐ。

https://qiita.com/leon-joel/items/f7c4643023f44def5ebd#activesupportconcern
→ ActiveSupport::Concernについても記載あり。

## 11.9 継承から委譲へ
- 条件: 子クラスが親クラスのインターフェイスの一部しか使っていない or データを継承することが望ましくない 場合。

親クラスに処理を委譲し、継承構造を解消する。

## 11.10 委譲から継承へ
- 条件: 多数の委譲メソッドを書いている。

委譲先のクラスをモジュールにして、委譲元のクラスでincludeする。
（<11.9 継承から委譲へ>の逆だが、基本的には継承でなくモジュールを使って階層を作る。）

## 11.11 抽象スーパークラスからモジュールへ
- 条件: 継承階層を持っているが、親クラスのインスタンスは作るつもり(予定)がない。

継承→モジュールに書き換える。

# 12章 大規模なリファクタリング
この章では、6~11章のような1つ1つの指し手ではなく、試合全体を説明している。

## 12.4 複合的な継承階層の分割
- 条件: 2つの仕事をしている継承階層がある。
- 理由: 継承関係がもつれると、コードの重複が発生し、メンテしづらいコードになるため。また、単一責務でないため。

2つの階層に分け、片方からもう片方を実行するには委譲を使う。

## 12.5 手続き型設計からオブジェクト指向設計へ
（感想: 本書にははっきりとした理由が書いていなかった。なので、手続き型/オブジェクト指向のメリット/デメリットを調べた。再利用ができない点、値がグローバルである点が手続き型のデメリットであり、大きなシステムになるとそのデメリットが膨れ上がると感じた。）
https://agency-star.co.jp/column/procedural-linguistics

## 12.6 ドメインのプレゼンテーションからの分離
ドメインロジックはモデルに移す。

:::message
ビューには、ユーザーインターフェイスを処理するために必要なロジックだけを収める。
:::

以上