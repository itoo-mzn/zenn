---
title: "オブジェクト指向設計実践ガイド"
emoji: "📘"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

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
**SOLID**
1. Single Responsibility Principle：単一責任の原則
2. Open/closed principle：オープン/クロースドの原則
3. Liskov substitution principle：リスコフの置換原則
4. Interface segregation principle：インターフェース分離の原則
5. Dependency inversion principle：依存性逆転の原則
:::message
本書のメイン。
:::
### デザイン(設計)パターン
いわゆる**GoF**
:::message alert
本書ではデザインパターンは解説していない。
:::

# 2章　単一責任のクラスを設計する
