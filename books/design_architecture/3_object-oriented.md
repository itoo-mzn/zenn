---
title: "3. オブジェクト指向プログラミング"
---

## 継承とは
- animal
  - dog
  - cat
の関係。

## 合成（コンポジション）


## 集約


## 委譲


- 継承
  `サブクラス is a スーパークラス. （トラックは車。）`
  **汎化-特化の関係**。
- 集約
  部品として他のオブジェクトを持つが、弱い結びつき。
  関連先が消滅しても、自身は消滅しない。
  `A part of B. （駐車場Bと、そこに駐車された車A。）`
- コンポジション（合成）
  部品として他のオブジェクトを持つ、強い結びつき。
  関連先が消滅すると、自身も消滅する。
  集約と似ている概念。
  `A part of B. （エンジンAは車Bの一部。）`


一般的なルールとして、コンポジションで解決できるものであれば、コンポジションを使うべき。
コンポジションが持つ依存は、継承よりも少ないため。

# 多態性（ポリモーフィズム）
同じ指示方法（メソッド）を複数のインスタンスで実行できること。

# カプセル化とは
内部のことを知らずとも、それを外部から利用できる

# 抽象化とは
dog, catからanimalという1つ抽象度が高い概念・分類を見つけ、
共通の処理を指示できるよう括りだすこと。
