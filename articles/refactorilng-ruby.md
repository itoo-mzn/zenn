---
title: "リファクタリング (Rubyエディション)"
emoji: "💎"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Ruby"]
published: false
---

# 書籍
https://www.fukkan.com/fk/CartSearchDetail?i_no=68327896

# Gitレポジトリ
書いたコードはGitレポジトリに保存。
https://github.com/ito0804takuya/refactoring-ruby

# この記事について
個人のメモとして、下記の事項のみを抜粋して記載している。
1. 自分が今後使いそうな内容
2. 忘れそうな内容
3. 初めて知って、感動した内容

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

## 3.1 コードの重複

**！！　この章は飛ばして先に進む。あとで戻ってくること。！！**

#### 同じクラスの2つのメソッドに同じ式が含まれている場合
技法: メソッドの抽出
内容: 2つのメソッドが、切り出したメソッドを呼ぶようにする。

#### 2つの兄弟クラスに同じ式が含まれている場合
2つのクラスで＜メソッドの抽出＞
技法: メソッドの抽出
内容: 
メソッドの上位階層への移動

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

（感想: とても重要。特に「メソッドを複数回呼び出しまって良いのか」という点。この点は、個人的にはこれまで抵抗があったが、この本を読んで考え方が理解でき、納得した上でこれから一時変数をメソッド化できるようになった。）


```ruby:リファクタ前
def price
  base_price = @quantity * @item_price
  if base_price > 1000
    discount_factor = 0.95
  else
    discount_factor = 0.98
  end
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

```ruby:リファクタ前
class Select
  def options
    @options ||= []
  end

  def add_option(arg)
    options << arg
  end
end

selection = Select.new
selection.add_option(2000)
selection.add_option(2001)
selection.add_option(2002)
# add_optionは配列を返すので、このままでは
# selection.add_option(2000).add_option(2001).add_option(2002) とできない
selection #<Select:0x00007fee63075fe0 @options=[2000, 2001, 2002]>
```

```ruby:リファクタ後
class Select
  # インスタンス初期化 + option追加 メソッドを追加 (newするのでクラスメソッド)
  def self.with_option(option)
    selection = self.new
    selection.options << option
    selection
  end

  def options
    @options ||= []
  end

  def add_option(arg)
    options << arg
    self # optionsでなく、self(インスタンス)を返す
  end
end

Select.with_option(2000).add_option(2001).add_option(2002)
```

## 6.6 説明用変数の導入
処理の目的を説明する名前の一時変数に、式orその一部 の結果を保管する。
- 条件: 式が複雑な場合。
- 理由: 可読性向上のため。
:::message alert
6.6 ~ 6.8項で一時変数を導入するが、**軽々しく一時変数を導入してはいけない**。
**<6.6 説明用変数の導入>の前に、<6.1 メソッドの抽出>ができないか考える**こと。
:::

```ruby:リファクタ前
def price
  # 基本価格 - 数量割引 + 配送料
  return @item_price * @quantity - 
    [0, @quantity - 500].max * @item_price * 0.05 +
    [@item_price * @quantity * 0.1, 100].min
end
```

```ruby:<6.6 説明用変数の導入>後
def price
  base_price = @item_price * @quantity
  quantity_discount = [0, @quantity - 500].max * @item_price * 0.05
  shipping = [base_price * 0.1, 100].min

  return base_price - quantity_discount + shipping
end
```

```ruby:<6.1 メソッドの抽出>後
def price
  return base_price - quantity_discount + shipping
end

def base_price
  @item_price * @quantity
end

def quantity_discount
  [0, @quantity - 500].max * @item_price * 0.05
end

def shipping
  [base_price * 0.1, 100].min
end
```

## 6.7 一時変数の分割
代入ごとに別の一時変数を用意する。
- 条件: ループ変数でも計算結果蓄積用の変数でもないのに、複数回代入される一時変数がある場合。
- 理由: 2つの異なる目的のために1つの一時変数を使い回すと混乱するため。

## 6.8 引数への代入の除去
代わりに一時変数を使う。
- 条件: コードが引数に代入を行っている場合。
- 理由: Rubyは(参照渡しでなく)値渡しなため、呼び出し元ルーチンには影響はないが、紛らわしいため。また、引数の用途は渡されたものを表すことなので、それに代入して別の役割を持たせないようにするため。

```ruby
def discount(input_val)
  input_val -= 2 if input_val > 50 # 引数への代入
end
# ↓
def discount(input_val)
  result = input_val
  result -= 2 if input_val > 50
end
```

## 6.9 メソッドからメソッドオブジェクトへ
メソッドを独自のオブジェクト(クラス)に変える。ローカル変数をそのオブジェクトのインスタンス変数にする。
- 条件: <メソッドの抽出>を適用できないようなローカル変数の使い方をしている場合。
- 理由: 独自のオブジェクト内で、メソッドの分解(<メソッドの抽出>)ができる。

```ruby:リファクタ前
class Account
  # 大きなメソッド
  def gamma(input_val, quantity, year_to_date)
    important_value1 = (input_val * quantity) + delta
    important_value2 = (input_val * year_to_date) + 100
    
    if (year_to_date - important_value1) > 100
      important_value2 -= 20
    end

    important_value3 = important_value2 * 7
    # 色々な処理
    important_value3 - 2 * important_value1
  end
end
```

```ruby:リファクタ後
class Account
  # 大きなメソッド
  def gamma(input_val, quantity, year_to_date)
    Gamma.new(self, input_val, quantity, year_to_date).compute
  end
end

# メソッド→クラスに
class Gamma
  attr_reader :account, # 元のクラス
              # 引数
              :input_val, 
              :quantity, 
              :year_to_date,
              # 一時変数
              :important_value1, 
              :important_value2,
              :important_value3

  # 元のクラス + 元のメソッドの引数 を受け取る
  def initialize(account, input_val_arg, quantity_arg, year_to_date_arg)
    @account = account
    @input_val = input_val_arg
    @quantity = quantity_arg
    @year_to_date = year_to_date_arg
  end

  # 元のメソッドのロジック
  def compute
    @important_value1 = (input_val * quantity) + @account.delta
    @important_value2 = (input_val * year_to_date) + 100
    
    important_thing

    @important_value3 = important_value2 * 7
    # 色々な処理
    important_value3 - 2 * important_value1
  end

  # メソッドの抽出が簡単にできるようになった
  def important_thing
    if (year_to_date - important_value1) > 100
      @important_value2 -= 20
    end
  end
end
```

## 6.10 アルゴリズム変更
より簡単なアルゴリズムに変更。

```ruby:リファクタ前
def fount_friends(people)
  friends = []
  people.each do |person|
    if(person == "Don")
      friends << "Don"
    end
    if(person == "John")
      friends << "John"
    end
    if(person == "Kent")
      friends << "Kent"
    end
  end
  return friends
end
```

```ruby:リファクタ後
def fount_friends(people)
  people.select do |person|
    %w(Don John Kent).include?(person)
  end
end
```

## 6.11 ループからコレクションクロージャメソッドへ
ループでなく、コレクションクロージャメソッドを使う。
each系の処理をmap系の処理にすること。
繰り返し処理した結果を返却したい場合に、ループの外から変数として渡す必要がなくなる。

### select
条件に合致するものだけを抽出する。
```ruby
managers = []
employees.each do |e|
  managers << e if e.manager?
end
# ↓
managers = employees.select { |e| e.manager? } # {}内は真偽値
```

### map
ブロックを実行した戻り値を格納する。
```ruby
offices = []
employees.each { |e| offices << e.office }
# ↓
offices = employees.map { |e| e.office } # {}内は実行するブロック
```


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
合計を出すとき など、ループ内で値を生み出すような場合に使う。

`inject(返り値の初期値)　{ | 返り値, 配列内のオブジェクト| ブロック }`
(デフォルト引数は0 なので(0)は省略可)

```ruby
total = 0
employees.each { |e| total += e.salary }
# ↓
total = employees.inject(0) { |sum, e| sum + e.salary }
```

## 6.12 サンドイッチメソッドの抽出
```ruby:リファクタ前
class Person
  attr_reader :mother, :children, :name

  def initialize(name, date_of_birth, date_of_death=nil, mother=nil)
    @name, @mother = name, mother
    @date_of_birth, @date_of_death = date_of_birth, date_of_death
    @children = []
    @mother.add_child(self) if @mother
  end

  def add_child(child)
    @children << child
  end

  def alive?
    @date_of_death.nil?
  end

  def number_of_living_descendants # 子孫の数
    children.inject(0) do |count, child| 
      count += 1 if child.alive?
      count + child.number_of_living_descendants
    end
  end

  def number_of_descendants_named(name) # 名前が一致する数
    children.inject(0) do |count, child| 
      count += 1 if child.name == name
      count + child.number_of_descendants_named(name)
    end
  end
end
```
```ruby:リファクタ後
class Person
  # 略

  def number_of_living_descendants # 子孫の数
    count_descendants_matching { |descendant| descendant.alive? }
  end

  def number_of_descendants_named(name) # 名前が一致する数
    count_descendants_matching { |descendant| descendant.name == name }
  end

  protected
  def count_descendants_matching(&block)
    children.inject(0) do |count, child|
      count += 1 if yield(child) # ブロックを実行。(ここは&blockを必要としない。)
      count + child.count_descendants_matching(&block)
      # ここ↑で再帰しており、再帰的にcount_descendants_matchingを実行したいので、
      # count_descendants_matchingには &block が必要。(再帰処理でなければ &block 不要。)
    end
  end
end
```

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

## 6.16 使われていないデフォルト引数の除去
使われていないデフォルト引数を除去。
引数による条件分岐などが削除できる可能性がある。

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
メソッドが未定義の際にNoMethodErrorを発行するメソッド。ここにバグがあると発見しにくい。
:::

## 6.19 動的レセプタの分離
`method_missing`のロジックを、新しく作ったクラスに移す。
- 条件: `method_missing`を使っているクラスが、容易に書き換えられない場合。

## 6.20 evalを実行時からパース時へ
*メソッド定義の中で*`eval`を使うのでなく、*メソッドを定義するとき*に使う。
- 条件: `eval`を使う必要があるが、実行回数を減らしたい場合。

```ruby:リファクタ前
class Person
  # attribute名の変数がまだ定義されてなければ、default_valueで定義する
  def self.attr_with_default(options)
    options.each_pair do | attribute, default_value |
      define_method attribute do
        eval "@#{attribute} ||= #{default_value}"
      end
    end
  end

  attr_with_default emails: "[]",
                    employee_number: "EmployNumberGenerator.next"
end
```
```ruby:リファクタ後
class Person
  # attribute名の変数がまだ定義されてなければ、default_valueで定義する
  def self.attr_with_default(options)
    options.each_pair do | attribute, default_value |
      # ループ処理ごとevalでまとめる
      eval　"define_method #{attribute} do
              @#{attribute} ||= #{default_value}
            end"
    end
  end

  attr_with_default emails: "[]",
                    employee_number: "EmployNumberGenerator.next"
end
```

# 7章 オブジェクト間でのメンバの移動

## 7.1 メソッドの移動
**メソッドを最もよく使っている他のクラスに、同じ内容の新メソッドを作る**。
古いメソッドは、そのメソッドに処理を委ねる or 削除する。
- 条件: メソッドが、自身のクラスよりも他クラスをよく利用している or 利用されている場合。（今はそうでなくても、そうなりつつあるとき。）

```ruby:リファクタ前
# 口座
class Account
  def overdraft_charge
    if @account_type.premium?
      result = 10
      resut += (@day_overdrawn -7) * 0.85 if @day_overdrawn > 7
      result
    else
      @day_overdrawn * 1.75
    end
  end

  def bank_charge
    result = 4.5
    result += overdraft_charge if @day_overdrawn > 0
    result
  end
end

# 口座の種類
def AccountType
  # ...
end
```
これから口座の種類が増えるものと仮定する。
`overdraft_charge`は`@account_type`によって処理が異なっているため、`AccountType`に移す。
`@day_overdrawn`は口座ごとに異なる値なので、`Account`に残す。
```ruby:リファクタ後
# 口座
class Account
  # Account固有の情報である@day_overdrawnは引数で渡す
  def overdraft_charge
    @account_type.overdraft_charge(@day_overdrawn)
  end

  def bank_charge
    result = 4.5
    result += overdraft_charge if @day_overdrawn > 0
    result
  end
end

# 口座の種類
def AccountType
  # ...
  def overdraft_charge(day_overdrawn)
    if premium?
      result = 10
      resut += (day_overdrawn -7) * 0.85 if day_overdrawn > 7
      result
    else
      day_overdrawn * 1.75
    end
  end
end
```

さらに、`Account`の`overdraft_charge`を削除するには、`overdraft_charge`を参照している箇所をすべて書き換えることで実現できる。
（今回は、参照箇所が`bank_charge`1つだけだったと仮定。）
```ruby:リファクタ後
# 口座
class Account
  # overdraft_chargeは削除した
  def bank_charge
    result = 4.5
    result += @account_type.overdraft_charge(@day_overdrawn) if @day_overdrawn > 0
    result
  end
end

# 口座の種類
def AccountType
  # ...
  def overdraft_charge(day_overdrawn)
    if premium?
      result = 10
      resut += (day_overdrawn -7) * 0.85 if day_overdrawn > 7
      result
    else
      day_overdrawn * 1.75
    end
  end
end
```

## 7.2 フィールドの移動
**移すクラスに新しいフィールドのreader（必要ならwriterも)を作り、フィールドを使っているコードを書き換える**。
- 条件: フィールドが、自身のクラスよりも他クラスをよく利用している or 利用されている場合。（今はそうでなくても、そうなりつつあるとき。）

```ruby:リファクタ前
# 口座
class Account
  # ...
  def interest_for_amount_days(amount, days)
    @interest_rate * amount * days /365
  end
end
```
```ruby:リファクタ後
class Account
  # ...
  def interest_for_amount_days(amount, days)
    interest_rate * amount * days /365
  end

  def interest_rate
    @account_type.interest_rate
  end
end
```

## 7.3 クラスの抽出
新しいクラスを作成。関連フィールド・メソッドを移す。
- 条件: 2つのクラスで行うべき仕事をしているクラスがある場合。

```ruby:リファクタ前
class Person
  attr_reader :name
  attr_accessor :office_area_code
  attr_accessor :office_number
  
  def telephone_number
    '(' + @office_area_code + ')' + @office_number
  end
end

person = Person.new
person.office_area_code = 123
p person.office_area_code
```

```ruby:リファクタ後
class Person
  attr_reader :name

  # 新しいクラスへのリンクを作る
  def initialize
    @office_telephone = TelephoneNumber.new
  end

  # 下記のコメント部のようにゲッター・セッターを容易すれば、フィールドへのアクセス方法は変えないで済む。
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
p person.office_telephone.area_code
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
オブジェクトがシステムの他の部分についてあまり知識を持たなくていい。
→　システムに変更を加えても、その変更を知らせないといけないオブジェクトが減るため、変更しやすい。

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

