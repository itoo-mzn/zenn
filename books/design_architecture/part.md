---
title: "分類"
---

## 設計、アーキテクチャとは

ソフトウェアの文脈では、設計とアーキテクチャは同じ意味。

## レイヤー

1 口に設計と言っても、どのレイヤー・領域を対象としているのかが違ったりする。

https://camo.qiitausercontent.com/d0aad7757f6ce1f55cb752f55a4987d96022608a/68747470733a2f2f71696974612d696d6167652d73746f72652e73332e61702d6e6f727468656173742d312e616d617a6f6e6177732e636f6d2f302f3437393039352f63343166343864372d633835312d323561662d363561312d6633643538333237656234662e706e67

こちらのスタック表を元に分類する。
（上から 高レイヤー → 低レイヤー となる。）

##### 9. エンタープライズパターン

ドメイン駆動設計（DDD）、MVC、サービス指向アーキテクチャ（SOA）、コマンドとクエリの責任分離（CQRS）、イベントソーシング、マイクロサービス、イベント駆動アーキテクチャ（EDA）

##### 8. アーキテクチャパターン

MVC、マイクロサービス、イベント駆動、レイヤードアーキテクチャ、パイプ・アンド・フィルター、コマンドとクエリの責任分離（CQRS）、ブラックボード、マイクロカーネル、サーバーレス、メッセージキューとストリーム、イベントソーシング

##### 7. アーキテクチャスタイル

マイクロサービス、イベント駆動、レイヤードアーキテクチャ、サービス指向、データ中心、コンポーネントベース、ドメイン駆動

##### 6. アーキテクチャ原則

関心の分離、疎結合、高い凝集性、コンポーネント設計の原則、方針 vs 詳細、境界 など

##### 5. デザインパターン

オブザーバー、ストラテジー、ファクトリー など

##### 4. 設計原則

SOLID 原則、DRY、YAGNI、KISS、LoD（デメテルの法則）、継承よりコンポジション（合成）、カプセル化、ハリウッドの原則 など

##### 3. オブジェクト指向プログラミング

継承、ポリモーフィズム、カプセル化、抽象化

##### 2. プログラミングパラダイム

構造化プログラミング、オブジェクト指向プログラミング、関数型プログラミング

##### 1. クリーンコード

命名、可読性、明確さ、簡潔さ、コメント、スタイル・書式設定、機能性、エラー処理、テスト、再利用性、パフォーマンス など

:::message alert
クリーンアーキテクチャは、それまでのアーキテクチャの共通コンセプトのまとめ という立ち位置で、上記のどのレイヤーに属するのもおそらく適さない。
:::