---
title: "フロントエンドの技術"
emoji: "🐥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

取り上げるフロントエンド領域・技術

- 基礎知識
- HTML
- CSS
- フレームワーク
  - Vue.js
  - Nuxt.js
- UI設計
  - Atomic Design


# 基礎知識


## <DOM (Document Object Model)>
HTMLなどの中の各要素をプログラミング言語で扱えるようにするための仕組み。
JavaScriptではDOMを操作する。

### 仮想DOM
DOMは、その状態を常にチェックできないが、仮想DOMならできる。

仮想DOMの値を変更→DOMの値が更新される→HTMLの表示が更新される。


## <イベント>
イベントは、重なっている一番上のタグで発生すると、その下のタグへと次々に伝搬する。
`（上）孫要素→子要素→親要素（下）`

### イベントハンドラ（イベントリスナ）
一般的には、イベントが発生したときに呼び出される処理のこと。
JavaScriptにおいては、イベントを受け取って後続の処理に引き渡す中継役の命令のこと。（onClick属性の値として記述されるもの）


## <Node.js>
Node.jsはJSを（ブラウザでなく手元で）動かすための実行環境。
### npm/yarn
npmはNode.jsを使うときに、ライブラリをインストールするための専用ツール。


## <HTML>


## <CSS>
grid css
rscss


## <TypeScript>
https://zenn.dev/itoo/articles/draft_learn-typescript


# フレームワーク


## <Vue.js>
- Vueで作ったプロジェクトそのものがwebサーバー。
  （HTMLを配置するwebサーバーがどこか別にあるわけではない。→クライアントはVueに問い合わせる）
- buildすると/dist内に公開用ファイルが生成される。
  （デプロイするのはこれ。）
- Vueでは仮想DOMを操作する。仮想DOMで扱うのが仮想ノード (VNode)。

### SPA, SSR
https://zenn.dev/rinda_1994/articles/e6d8e3150b312d

### リアクティブ
リアクティブとは、`値が監視されており、変更が検知される状態`のこと。

Vue.jsやReactなどには、値の変更を検知可能な状態にするリアクティブシステムがあり、
*コンポーネントが保持している状態*を変更すれば、その変更が検知されてHTMLに反映される。
（= データが更新されると自動で表示も更新される。）

Vue.jsの主なリアクティブシステムは下記。
- ref : プリミティブ型に使う。
- reactive : オブジェクトに使う。
- effect
- computed : ある値から計算・処理した結果を、別の値として定義。ある値が更新されると自動で再計算が行われる。

#### ref
```ts:ref
const text = ref('Hello');
```
このように定義した値は、script内では`.value`でアクセスし、template内では`{{ }}`でアクセスする。
```ts
const changeText = () => text.value = 'Changed!!';
```
```html
<p>{{ text }}</p>
```

#### computed
```ts:computed
const number = ref(10);
const double = computed(() => number * 2);
```


## Nuxt.js

/composablesとは？

- **composableな関数**を配置するディレクトリ
- ここに配置したものは自動importされる（コンポーネントで毎回わざわざimportすることなく使える）
- **composableな関数とは？**
    - **状態を持つロジック**をカプセル化して利用するための関数
    - 慣習としてコンポーザブル関数の名前は**use**~~~から始める



// computedつけてないとただの配列で、
// ただの配列のままではそれが読み込まれるときにまだpropsが読み込まれていないので
// 初期画面表示時に表示されなくなってしまう

// computed : propが変わるたび
// onMounted : DOM読み込まれたときのみ

vue3からはtypeをつけないといけないらしい
import type { Academy_School } from '~~/src/graphql/generated/graphqlOperations';

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