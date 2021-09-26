---
title: "Rubyによるデザインパターン"
emoji: "🎃"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

# 概要
1. Abstract Factory

# Abstract Factory （抽象ファクトリ）
## 目的
矛盾のないオブジェクトの組み合わせを作ること。
## 設定
- 動物（アヒル、カエル）
  - 食事(eat)メソッドを持っている。
- 植物（藻、スイレン）
  - 成長(grow)メソッドを持っている。
- 池
  - 池の環境(動物と植物の組み合わせ)は、次の2種類のみが許されている。
    - アヒル と スイレン
    - カエル と 藻

## 構成
1. **AbstractFactory** (= OrganismFactory)
ConcreteFactoryの共通部分の処理を定義。
2. **ConcreteFactory** (= FrogAndAlgaeFactory, DuckAndWaterLilyFactory)
AbstractFactoryを継承し、実際にオブジェクトの生成を行う。
3. **Product** (= アヒルなど)
ConcreteFactoryによって生成される側のオブジェクト。

## メリット
- 整合性が必要となるオブジェクト群（組み合わせ）を誤りなしに生成できる。
  インスタンス化が散在しなくなる。（各工場に任せるため）
- 組み合わせは各工場（ConcreteFactory）が変更できる。
## デメリット
- AbstractFactoryをinterfaceや抽象クラス（・抽象メソッド）のようにしないと、ConcreteFactoryにメソッドが増やしたい場合に、全てのConcreteFactoryにメソッドを追加し、本当に全てに追加できたか確認しないといけない。
（Rubyでは抽象クラス・抽象メソッド（オーバーライドを強要する）をサポートしていないので、別の仕組み（実装）を作って再現しないといけない。）

# 中断した。Builderから再開すること。　(コードはdesign-pattern_rubyディレクトリ)