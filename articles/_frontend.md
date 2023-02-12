---
title: "フロントエンドの技術"
emoji: "🐥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

取り上げるフロントエンド領域・技術

フレームワーク
- Vue.js
- Nuxt.js


# UI設計

## <Atomic Design>

### atoms（原子）
それ以上分解できない最小単位。
ラベル、ボタン、アイコンなど。

### molecules（分子。モレキュルス）
atomsを組み合わせてできたもの。
ヘッダーナビゲーションや検索フォームなど。

### organisms（生物）
atomsやmoleculesを組み合わせてできたもの。意味を持っている単位。
ヘッダーそのものがorganisms。
atomsとmoleculesが組み合わさってヘッダーになる。

### templates（骨組み）
例えば、「ヘッダーとサイドナビゲーションは全てのページで共通だが、メインコンテンツだけが異なる」というページでいうと、そのページのメインコンテンツ部だけ空白地帯になっていて未完成状態の骨組み。

### pages（ページ）
atoms, molecules, organisms, templatesが組み合わさって1つのページとなる。

https://qiita.com/Kazuhiro_Mimaki/items/3d9a8594064aab5119da