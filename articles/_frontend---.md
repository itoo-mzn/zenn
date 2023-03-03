---
title: "フロントエンドの技術"
emoji: "🐥"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["HTML", "CSS", "Vue", "Nuxt"]
published: false
---

取り上げるフロントエンド領域・技術

- 基礎知識
- HTML
- CSS
- フレームワーク
  - Vue.js
  - Nuxt.js
- ApolloClient
- UI設計
  - Atomic Design


# 基礎知識


## <DOM (Document Object Model)>
HTMLなどの中の各要素をプログラミング言語で扱えるようにするための仕組み。
JavaScriptではDOMを操作する。

### 仮想DOM
DOMは、その状態を常にチェックできないが、仮想DOMならできる。

仮想DOMの値を変更→DOMの値が更新される→HTMLの表示が更新される。

---

## <イベント>
イベントは、重なっている一番上のタグで発生すると、その下のタグへと次々に伝搬する。
`（上）孫要素→子要素→親要素（下）`

### イベントハンドラ（イベントリスナ）
一般的には、イベントが発生したときに呼び出される処理のこと。
JavaScriptにおいては、イベントを受け取って後続の処理に引き渡す中継役の命令のこと。（onClick属性の値として記述されるもの）

---

## <Node.js>
Node.jsはJSを（ブラウザでなく手元で）動かすための実行環境。
### npm/yarn
npmはNode.jsを使うときに、ライブラリをインストールするための専用ツール。

---

## <HTML>

https://www.htmq.com/html/indexm.shtml

---

## <CSS>
https://web-cheatsheet.com/css-selector#%E5%9F%BA%E6%9C%AC%E7%9A%84%E3%81%AA%E3%82%BB%E3%83%AC%E3%82%AF%E3%82%BF
https://web-cheatsheet.com/sass
https://web-cheatsheet.com/css-flexbox
https://fuuno.net/web02/flex/flex.html

### インポート
他のCSSファイルをインポートして、その内容を（`@import`と書いた側で）使うことができる。

### ミックスイン
何度も使うプロパティをグループ化して使い回す。
```css
/* widthのデフォルト値は40px */
@mixin select-mark($width: 40px) {
  display: inline-block;
  width: $width;
}
```

### rem
- `px` : 文字サイズの拡大・縮小に対応できない。また、端末のディスプレイ解像度によって見た目のサイズが異なる。
- `%`, `em` : **親要素**の文字サイズからの割合。
- `rem` : HTMLの最上位要素であるhtmlタグの文字サイズを基準に文字サイズが設定され、親要素の影響を受けない。

### CSS Grid Layout（グリッドレイアウト）
2次元レイアウトを簡単に操作できるCSSの機能。

#### 要素
- コンテナ : グリッド全体を囲む要素。
- アイテム : コンテナの子要素。

https://qiita.com/kura07/items/e633b35e33e43240d363

### RSCSS

#### 要素
RSCSSには３つの分類がある。
###### Components（コンポーネント）
- パーツの大枠の要素で最低二つの単語（like-button、search-form）でクラス名を命名する。
  （→ AtomicDesignでいうと、`Molucules`以上の範囲）
- 1つ以上のエレメンツを持つ。
- コンポーネントは再利用されるので、positionやmarginといった**位置や余白に関するプロパティは設定しない**。
##### Elements（エレメンツ）
- コンポーネントの内の**要素**。1単語で命名する。（例：search-formコンポーネントの、入力欄がfield、ボタンがaction）
- **独立して使われない**。（→ AtomicDesignにおいては、`Atoms`に該当するため独立して使われる可能性もある。）
- 2単語以上使いたい場合は`-`等の区切り文字なしで連結する。（例：first-nameはダメで、firstnameとする。）
- 子セレクタ`>`の使用を推奨。（`>`：子要素のみに適用される。）
  タグセレクタは使わない。
```css
.article-card {
  > .item { }
}
```
##### Variants（バリアント）
- 既存のコンポーネントやエレメントと**構成が同じ**で、**見た目や機能が違うもの**を作りたい場合に使用する。
- クラス名の先頭に`-`を付ける。
```css
  .search-form {
    &.-wide { }
	&.-short { }
	&.-disabled { }
}
```
- コンポーネントのネスト
  - コンポーネントA内で他のコンポーネントBを使う際、Bにいつもとは違うスタイルを割り当てたい場合、
    コンポーネントをネストして記載する（Aの中にBのstyleを書く）のでなく、バリアントを使う。

#### その他
- SCSSのファイル名・ディレクトリ構成にも規則がある。（が、割愛）
- プロパティのオーバーライドはヘルパーを使う。
- ヘルパー名は先頭にアンダースコア（_）を付ける。

https://rfs.jp/sb/html-css/html-css-guide/rscss.html

---

## <TypeScript>
https://zenn.dev/itoo/articles/draft_learn-typescript

---

# フレームワーク


## <Vue.js>
- Vueで作ったプロジェクトそのものがwebサーバー。
  （HTMLを配置するwebサーバーがどこか別にあるわけではない。→クライアントはVueに問い合わせる）
- buildすると/dist内に公開用ファイルが生成される。
  （デプロイするのはこれ。）
- Vueでは仮想DOMを操作する。仮想DOMで扱うのが仮想ノード (VNode)。

### SPA, SSR
https://zenn.dev/rinda_1994/articles/e6d8e3150b312d
https://qiita.com/maruken24/items/71461c6a0247bbc9d4e5#ssr-with-rehydration

:::message
### ハイドレーションとは
静的ホスティング or サーバーサイドレンダリングによって配信された静的HTMLウェブページを、クライアントサイドのJavaScriptがHTML要素に**イベントハンドラをアタッチ**して動的ウェブページに変換する手法のこと。
具体的には、ボタンを押したときなどのイベントにJavaScriptを紐付けて、ページが変化するようにする。

1. サーバーサイドで、HTMLが作成される。
2. クライアントサイドにHTMLをダウンロードし、JavaScriptのコードたちもダウンロードが終わり実行できる状態になったときに、ComponentなどのコードをもとにHTMLを生成し直し、**参照透過性のチェックを行う**。
3. サーバーサイドで生成したHTMLにイベントハンドラをアタッチしていく。

#### 参照透過性
同じpropsを渡してるのに、違うレンダリングがされてはいけない。
「**サーバーサイドのHTML === クライアントサイドで作ったHTML**」となるのが期待値。
:::


### テンプレート構文
- マスタッシュ `{{ }}`
  ```pug:(pug)
  span {{ msg }}
  ```
- v-html : テキストでなく生のHTMLを渡したいときに使う。

:::message
### Vueディレクティブ
- Vueディレクティブとは、**接頭辞 `v-` が付いたVue.jsの特別な属性**のこと。
- **ディレクティブの役割**は、**式が示す値が変化したとき、リアクティブに更新を DOM に適用する**こと。

![Alt text](https://ja.vuejs.org/assets/directive.386ba0f0.png)
:::

#### 属性バインディング v-bind
- バインドとは、`<script>`内と`<template>`内とで、値を結びつけること。

- *HTMLタグの属性*（id, classとか）に設定する値を渡すと、属性値を動的に設定・変更。
  ```pug
  div(v-bind:id="dynamicId")
  //- 省略形
  div(:id="dynamicId")
  ```

- オブジェクトを渡すことで、複数の属性を一度にバインドできる。
  ```tsx
  <template>
  div(v-bind="attrsObject")
  </template>
  <script setup>
  const attrsObject = {
    id: 'container',
    class: 'wrapper'
  }
  </script>
  ```

- ①`{{ }}`内 or ②Vueディレクティブの属性値の中 では、JSを書ける。
  ```pug
  {{ isOk ? 'Yes' : 'No' }}

  div(:id="`list-${id}`")
  ```


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


### 算出プロパティ
#### computed
```ts:computed
const number = ref(10);
const double = computed(() => number * 2);
```

1行でtemplate内に書き収めるのでなく、computedでロジックを切り出すほうがいい。
```pug:✕
span {{ author.books.length > 0 ? 'Yes' : 'No' }}
```
```tsx:○
<template>
span {{ publishedBooksMessage }}
</template>
<script setup>
const publishedBooksMessage = computed(() => {
  return author.books.length > 0 ? 'Yes' : 'No'
})
</script>
```

##### 関数との違い
算出プロパティはリアクティブな依存関係にもとづき**キャッシュされる**。（関数は再描画が起きると常に実行される。）
逆にいうと、**リアクティブな依存関係が更新されたときだけ再評価される**。


### 条件付きレンダリング
#### v-if, v-show
**頻繁に何かを切り替える**必要があれば `v-show`を、
変更することがほとんどない場合は、`v-if`を選ぶ。


### リストレンダリング
#### v-for
- indexも取れる。
- ループ回数指定もできる。（`v-for="n in 10"`で10回ループする。）
- keyは必要。`v-for="item in items" :key="item.id"`


### イベントハンドリング
#### v-on
`v-on:click='hogeHandler'` または `@click='hogeHandler'`。


### フォーム入力バインディング
#### v-model
```html
<div>{{ name }}</div>
<input v-model="name">
```
https://ja.vuejs.org/guide/essentials/forms.html


### ライフサイクルフック
下記はComposition APIでの書き方。（Option APIは少し異なる。）
（誰のlifeなのか = Vueインスタンスのlifeのことを指している。）

- `onMounted()`, `onBeforeMount()` : **DOMが読み込まれた直後**（Vueインスタンスが生成された後）のタイミング。（`onBeforeMount`はその直前。）
- `onUpdated()`, `onBeforeUpdate()` : **データの変更・画面の更新時**。
- `onUnmounted()` , `onBeforeMounted()` : Vueインスタンスが破棄されるタイミング。（よく理解できていない）


### ウォッチャー
#### watch
watchを使う場面。（computedとの違い。）
- computedでは処理できない**非同期通信などの複雑な処理**を行う場合
- **更新前**と**更新後**の値を使う場合
- 処理を実行しても、データは返さない場合

computedで書ける場合はcomputedのほうが簡素に書ける。

#### watchEffect
watchとは違い、**callback関数の内部で使われている値の変更**を検知して実行される。
watchに比べると監視対象を一つ一つ宣言にせずに済むのはメリットだが、逆に、何がトリガーで実行されているか分かりにくくなる。
また、watchと違い、定義時に実行される。


### props
propsは**コンポーネントのプロパティ**。
**親→子コンポーネントに値を渡す**。

<親コンポーネント内>
`<template>`内で`:hoge="val"`でhogeという名前のものを渡す。

<子コンポーネント内>
`<script>`内で`defineProps`で受け取って、`props.hoge`でアクセスする。
`<template>`内では`{{ hoge }}`。

**親→子**へはプロパティの更新が流れるが、その逆は無い。（**一方向バインディング**）

**親コンポーネントが更新されるたびに、子コンポーネント内のすべてのプロパティが最新の値に更新される**。
子コンポーネント内でプロパティの変更はできない。

#### プロパティのバリデーション
バリデーションの要件に合致しないと、コンソールに`warning`が出る。（動きはするので注意！）
- 型 (type)
- 必須かどうか (required)
- デフォ (default)
- 独自の（カスタム）バリデーション関数 (validator)



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


---

# ApolloClient
**GraphQL APIのクライアント**ライブラリ。

1. 状態管理を行う
  グローバルな状態管理もApolloで完結できる。
2. キャッシュを行う
  APIレスポンスを正規化やキャッシュしながらのデータ取得が可能。

## <1. 状態管理を行う>
https://zenn.dev/furharu/articles/0397d183760970

## <2. キャッシュを行う>
https://zenn.dev/furharu/articles/ece72dac5feffe
https://zenn.dev/furharu/articles/26557d977b1b8c


---

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

---

# UX
- UXデザイン
  UXを向上させることを目的としてプロダクトを設計すること。
- UXライティング
  ユーザー(読み手)の体験を助け、体験の価値を高めるように配慮した文章の書き方、技術のこと。
  Webサービスでいうと、ボタンの文言、入力フォームのラベル、エラーメッセージなど、ユーザーが接する全ての文章が対象。
