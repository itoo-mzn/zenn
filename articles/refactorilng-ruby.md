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

# リファクタリングとは
**コードの外からみた振る舞いは変えずに、内部構造を改良すること**。

- バグを持ち込む危険を最小限に抑えてコードをクリーンナップする方法。
- コードが書かれた後で設計を改良すること。
  - コードは設計してから書いているはずではあるが、時間が経つとともにコードは書き換えられ、設計に基づく構造は次第に変わっていく。

# 1章 リファクタリング -最初のサンプル
## 1.1 最初の状態
仕様
・ビデオレンタルの料金を計算して印刷する
・貸出日数に基づいてレンタル料を計算
・映画の種類が何か（一般、子供用、新作）を判定
・映画が新作か否かで、レンタルポイントが異なり、その計算が必要

入力
・顧客が借りた映画が何か
・貸出日数が何日か

クラス
・Movie (1) ↔ (多) Rental (多) ↔ (1) Customer

```ruby
class Movie
  REGULAR = 0
  NEW_RELEASE = 1
  CHILDRENS = 2

  attr_reader :title
  attr_accessor :price_code

  def initialize(title, price_code)
    @title = title # 映画のタイトル
    @price_code = price_code # 映画の料金コード
  end
end

class Rental
  attr_reader :movie, :days_rented

  def initialize(movie, days_rented)
    @movie = movie # レンタルした映画
    @days_rented = days_rented # 貸出日数
  end
end

def Customer
  attr_reader :name

  def initialize(name)
    @name = name # 顧客の名前
    @rentals = [] # レンタルしている映画
  end

  def add_rental(arg)
    @rentals << arg
  end

  # 状態とは??
  def statement
    total_amount = 0
    frequent_renter_points = 0
    result = "Rental Record for #{@name}\n"

    @rentals.each do |element|
      this_amount = 0

      # 各行の金額を計算
      case element.movie.price_code
      when Movie::REGULAR
        this_amount += 2
        this_amount += (element.days_rented - 2) * 1.5 if element.days_rented > 2
      when Movie::NEW_RELEASE
        this_amount += element.days_rented * 3
      when Movie::CHILDRENS
        this_amount += 1.5
        this_amount += (element.days_rented - 3) * 1.5 if element.days_rented > 3
      end

      # レンタルポイントを加算
      frequent_renter_points += 1
      # 新作の場合、2日間レンタルでボーナス点をレンタルポイントに加算
      frequent_renter_points += 1 if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1

      # このレンタルの料金を表示
      result += "\t" + element.movie.title + "\t" + this_amount.to_s + "\n"
      total_amount += this_amount
    end

    # フッター行を追加
    result += "Amount owed is #{total_amount}\n" # 合計金額
    result += "You earned #{frequent_renter_points} frequent renter points" # 加算されたレンタルポイント
    result
  end
end
```
このコードは動くが、変更しにくい。

:::message
**機能を追加しにくいプログラムに機能を追加するとき、まずリファクタリングして作業をしやすくしてから進めること。**
:::

## 1.2 リファクタリングの第一歩
リファクタリングするときの第一歩は、テストを作ること。

## 1.3 statementメソッドの分解、再配置
最初のターゲットは、長過ぎて、いくつも役割を持っているstatementメソッド。
:::message
**長いメソッドは、小さい部品にできないか考える**。
**論理的にひとかたまりになっているコードを見つけ、＜メソッドの抽出＞を行う。**
:::

#### テクニック（注意点）
(抽出後の)新メソッドにスコープが限られる変数、つまり、**ローカル変数と引数になるべきものを元のコードから探す**。
- 今回はstatementメソッドのcase文を抽出してみるので、ここでは、`element`と`this_amount`。
  - `element`はこのcase文で変更されないが、`this_amount`は変更される。
    - 変更されるものが1つであれば戻り値として返せる。(2つなら、受け取り側も2つ変数を用意)

```diff ruby
def Customer
  #（略）

  # 状態とは??
  def statement
    total_amount = 0
    frequent_renter_points = 0
    result = "Rental Record for #{@name}\n"

    @rentals.each do |element|
-     this_amount = 0
+     this_amount = amount_for(element)

-     # 各行の金額を計算
-     case element.movie.price_code
-     when Movie::REGULAR
-       this_amount += 2
-       this_amount += (element.days_rented - 2) * 1.5 if element.days_rented > 2
-     when Movie::NEW_RELEASE
-       this_amount += element.days_rented * 3
-     when Movie::CHILDRENS
-       this_amount += 1.5
-       this_amount += (element.days_rented - 3) * 1.5 if element.days_rented > 3
-     end

      # レンタルポイントを加算
      frequent_renter_points += 1
      # 新作の場合、2日間レンタルでボーナス点をレンタルポイントに加算
      frequent_renter_points += 1 if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1

      # このレンタルの料金を表示
      result += "\t" + element.movie.title + "\t" + this_amount.to_s + "\n"
      total_amount += this_amount
    end

    # フッター行を追加
    result += "Amount owed is #{total_amount}\n" # 合計金額
    result += "You earned #{frequent_renter_points} frequent renter points" # 加算されたレンタルポイント
    result
  end

+  def amount_for(rental)
+    result = 0
+
+    # 各行の金額を計算
+    case rental.movie.price_code
+    when Movie::REGULAR
+      result += 2
+      result += (rental.days_rented - 2) * 1.5 if rental.days_rented > 2
+    when Movie::NEW_RELEASE
+      result += rental.days_rented * 3
+    when Movie::CHILDRENS
+      result += 1.5
+      result += (rental.days_rented - 3) * 1.5 if rental.days_rented > 3
+    end
+  end
end
```

:::message
**プログラムを少しずつ変更すること**。
そうすると、間違えても簡単にバグを見つけられる。
:::

:::message
コンピュータが理解できるコードは誰でも書ける。
**優れたプログラマは、人間が理解できるコードを書く。**
:::

## 1.4 金額計算ルーチンの移動
`amount_for`メソッドはCustmerの情報を使っていない。Rentalに属するべきである。
そのため、
1. メソッドを移動する。

このとき、
- 引数を取り除くこと。（クラスのselfへのメソッドのため）
- 最適な名前を考えること。（amount_for → charge）
```diff ruby
class Rental
  #（略）
+  # 料金
+  def charge
+    result = 0
+
+    case rental.movie.price_code
+    when Movie::REGULAR
+      result += 2
+      result += (rental.days_rented - 2) * 1.5 if rental.days_rented > 2
+    when Movie::NEW_RELEASE
+      result += rental.days_rented * 3
+    when Movie::CHILDRENS
+      result += 1.5
+      result += (rental.days_rented - 3) * 1.5 if rental.days_rented > 3
+    end
+  end
end
```

- 新メソッドに処理を委ねる。
``` ruby
def Customer
  #（略）
  def amount_for(rental)
    renral.charge
  end
end
```

2. 古いメソッドを参照している箇所を探して、新しいメソッドに置き換える。
3. 古いメソッドを削除する。
- （今回は1箇所にのみだったが）この古いメソッドを使っている可能性のあるクラス全てにサーチをかけないといけない。
```diff ruby
def Customer
  #（略）
  def statement
    total_amount = 0
    frequent_renter_points = 0
    result = "Rental Record for #{@name}\n"

    @rentals.each do |element|
-      this_amount = amount_for(element)
+      this_amount = element.charge

      # レンタルポイントを加算
      frequent_renter_points += 1
      # 新作の場合、2日間レンタルでボーナス点をレンタルポイントに加算
      frequent_renter_points += 1 if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1

      # このレンタルの料金を表示
      result += "\t" + element.movie.title + "\t" + this_amount.to_s + "\n"
      total_amount += this_amount
    end

    # フッター行を追加
    result += "Amount owed is #{total_amount}\n" # 合計金額
    result += "You earned #{frequent_renter_points} frequent renter points" # 加算されたレンタルポイント
    result
  end

-  def amount_for(rental)
-    renral.charge
-  end
end
```

`this_amount`の存在意義がほとんどなくなっている。`element.charge`を代入しているが、それに変更が加えられていない。
**＜一時変数から問合せメソッドへ＞**を適用して、`this_amount`を削除する。

この変更で不安なのは下記2点。
- 同じメソッドを2回呼び出している。パフォーマンスは大丈夫か。
  - **リファクタリングは、わかりやすくすることに集中すべき。**（パフォーマンスを上げるのは別の仕事）
  - **メソッド呼び出し回数が増えても、ほとんどの場合問題ない。**
- 複数回呼び出しているメソッドが、**冪等かどうか**。（今回はOK）

:::message
**一時変数は無いほうがいい**。なぜそこに一時変数があるのか分からなくなってしまうため。
**コードが何をしようとしているか**が、はっきりと分かるようになる。
:::

## 1.5 レンタルポイント計算メソッドの抽出
1.4で金額計算をRentalに移したように、レンタルポイント計算も移す。
```diff ruby
def Customer
  #（略）
  def statement
    total_amount = 0
    frequent_renter_points = 0
    result = "Rental Record for #{@name}\n"

    @rentals.each do |element|
      # レンタルポイントを加算
-      frequent_renter_points += 1
-      # 新作の場合、2日間レンタルでボーナス点をレンタルポイントに加算
-      frequent_renter_points += 1 if element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1
+      frequent_renter_points += element.frequent_renter_points

      # このレンタルの料金を表示
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
      total_amount += element.charge
    end

    # フッター行を追加
    result += "Amount owed is #{total_amount}\n" # 合計金額
    result += "You earned #{frequent_renter_points} frequent renter points" # 加算されたレンタルポイント
    result
  end
end

class Rental
  #（略）
+  def frequent_renter_points
+    # 新作の場合、2日間レンタルで2ポイント（ボーナス点）
+    # それ以外（通常）は1ポイント
+    element.movie.price_code == Movie::NEW_RELEASE && element.days_rented > 1 ? 2 : 1
+  end
end
```

## 1.6 一時変数の削除
＜一時変数から問合せメソッドへ＞を適用して、一時変数である`total_amount`を削除する。

```diff ruby
def Customer
  #（略）
  def statement
-   total_amount = 0
    frequent_renter_points = 0
    result = "Rental Record for #{@name}\n" # 出力する文字列

    @rentals.each do |element|
      # レンタルポイントを加算
      frequent_renter_points += element.frequent_renter_points

      # このレンタルの料金を表示
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
-     total_amount += element.charge
    end

    # フッター行を追加
-   result += "Amount owed is #{total_amount}\n" # 合計金額
+   result += "Amount owed is #{total_charge}\n" # 合計金額
    result += "You earned #{frequent_renter_points} frequent renter points" # 加算されたレンタルポイント
    result
  end

+ private
  
+ # レンタル料金合計
+ def total_charge
+   @result.inject(0) { |result, rental| result += rental.charge } # 
+ end
end
```
`total_charge`として切り出す際、＜ループからコレクションクロージャメソッドへ＞を適用した。

### ＜ループからコレクションクロージャメソッドへ＞
each系の処理をmap系の処理にすること。
繰り返し処理した結果を返却したい場合に、ループの外から変数として渡す必要がなくなる。
```ruby:each使用時
array = 1..6

sum = 0
array.each do |num|
  sum += num
  p sum
end
```
```ruby:mapやinject使用時
array = 1..6

array.inject (0){ |sum,num| p sum+=num} # injectの引数は、sumの初期値
```

`total_amount`と同様、一時変数である`frequent_renter_points`を削除する。
```diff ruby
def Customer
  #（略）
  def statement
-   frequent_renter_points = 0
    result = "Rental Record for #{@name}\n" # 出力する文字列

    @rentals.each do |element|
-     frequent_renter_points += element.frequent_renter_points

      # このレンタルの料金を表示
      result += "\t" + element.movie.title + "\t" + element.charge.to_s + "\n"
    end

    # フッター行を追加
    result += "Amount owed is #{total_charge}\n" # 合計金額
-   result += "You earned #{frequent_renter_points} frequent renter points" # 加算されたレンタルポイント
+   result += "You earned #{total_frequent_renter_points} frequent renter points" # 加算されたレンタルポイント
    result
  end

  private

  # レンタル料金合計
  def total_charge
    @rentals.inject(0) { |sum, rental| sum += rental.charge }
  end

+ def total_frequent_renter_points
+   @rentals.inject(0) { |sum, rental| sum += rental.frequent_renter_points }
+ end
end
```

## 1.7料金コードによる条件分岐からポリモーフィズムへ
**case文を使うときは、他のオブジェクトでなく、自身のデータ（状態）によって分岐すべき。**

Rentalクラスの`charge`メソッドはMovieの情報で分岐していたため、インターフェイスは変えずに、Movieに移す。
（`frequent_renter_points`メソッドも同様に移したが、記載は省略。）
```diff ruby
class Rental
  #（略）
  # 料金
  def charge
-    result = 0
-
-    case rental.movie.price_code
-    when Movie::REGULAR
-      result += 2
-      result += (rental.days_rented - 2) * 1.5 if rental.days_rented > 2
-    when Movie::NEW_RELEASE
-      result += rental.days_rented * 3
-    when Movie::CHILDRENS
-      result += 1.5
-      result += (rental.days_rented - 3) * 1.5 if rental.days_rented > 3
-    end
+    # Rentalが持つデータ(days_rented)を渡して、Movieに委譲する
+    movie.charge(days_rented)
  end
end
```
```diff ruby
class Movie
  #（略）
+  def charge(days_rented)
+    result = 0
+
+    case price_code
+    when REGULAR
+      result += 2
+      result += (days_rented - 2) * 1.5 if days_rented > 2
+    when NEW_RELEASE
+      result += days_rented * 3
+    when CHILDRENS
+      result += 1.5
+      result += (days_rented - 3) * 1.5 if days_rented > 3
+    end
+    result
+  end
end
```

## 1.8 ついに継承の導入か
省略

# 2章 リファクタリングの原則
## リファクタリングはいつすべきか
特別な時間を割いて、決意してすることでなく、何か他のことをするときに、役立つからリファクタリングするという性質のもの。

:::message
**3度目の原則**
何かを初めてするときは、ただそれをすること。
同じようなことを2度目にするときは、重複が気になっても、同じことをすること。
3度目にするときは、リファクタリングすること。
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
リファクタリングにテストは必要。(赤→緑→リファクタリング)
`例外`もテストする必要がある。

# 5章 リファクタリングのカタログに先立って
（6~12章の構成の説明 のため省略。）

# 6章 メソッドの構成方法
## 6.1 メソッドの抽出
コードの一部をメソッドにして、その目的を説明する名前をつける。
- 条件: なし。
- 理由: メソッドの粒度が細ければ、流用性が高くなる。
- 注意: 意味のある良い名前が思いつかないなら、それは抽出すべきでない。

```ruby:リファクタ前
def printing_owing
  outstanding = 0.0

  # バナーを出力
  puts "*****************************"
  puts "****** Customer Owes ********"
  puts "*****************************"

  # 料金を計算
  @orders.each do |order|
    outstanding += order.amount
  end

  # 詳細を表示
  puts "name: #{@name}"
  puts "amount: #{outstanding}"
end
```

### 6.1.1 パターン: ローカル変数なし
```ruby
def printing_owing
  outstanding = 0.0

  # <メソッドの抽出>
  print_banner

  # 料金を計算
  @orders.each do |order|
    outstanding += order.amount
  end

  # 詳細を表示
  puts "name: #{@name}"
  puts "amount: #{outstanding}"
end

# バナーを出力
def print_banner
  puts "*****************************"
  puts "****** Customer Owes ********"
  puts "*****************************"
end
```

### 6.1.2 パターン: ローカル変数あり
```ruby
def printing_owing
  outstanding = 0.0

  print_banner

  # 料金を計算
  @orders.each do |order|
    outstanding += order.amount
  end

  # <メソッドの抽出>
  print_details(outstanding)
end

# バナーを出力
def print_banner
  puts "*****************************"
  puts "****** Customer Owes ********"
  puts "*****************************"
end

# 詳細を表示
def print_details(outstanding)
  puts "name: #{@name}"
  puts "amount: #{outstanding}"
end
```

### 6.1.3 パターン: ローカル変数への再代入

```ruby
def printing_owing
  print_banner

  # <メソッドの抽出>
  # ローカル変数に代入することで、以降のコードに影響を与えない
  outstanding = calculate_outstanding

  print_details(outstanding)
end

# バナーを出力
def print_banner
  puts "*****************************"
  puts "****** Customer Owes ********"
  puts "*****************************"
end

# 詳細を表示
def print_details(outstanding)
  puts "name: #{@name}"
  puts "amount: #{outstanding}"
end

# 料金を計算
def calculate_outstanding
  # outstanding = 0.0
  # @orders.each do |order|
  #   outstanding += order.amount
  # end
  # outstanding
  @order.inject(0.0) { |sum, order| sum + order.amount}
end
```

## 6.2 メソッドのインライン化
メソッドを呼び出し元に組み込み、そのメソッドを削除。
- 条件: メソッドの本体が、名前と同じぐらいわかりやすい場合。
- 理由: 過剰な間接化はイライラの原因。

```ruby:リファクタ前
def get_rating
  more_than_five_late_deliveries ? 2 : 1
end

def more_than_five_late_deliveries
  @number > 5
end
```

```ruby:リファクタ後
def get_rating
  @number > 5 ? 2 : 1
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
