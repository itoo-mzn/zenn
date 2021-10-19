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
**論理的にひとかたまりになっているコードを見つけ、メソッドの抽出を行う。**
:::