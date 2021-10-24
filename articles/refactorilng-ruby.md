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