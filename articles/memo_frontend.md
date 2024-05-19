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
- UI 設計
  - Atomic Design

# 基礎知識

## <DOM (Document Object Model)>

HTML などの中の各要素をプログラミング言語で扱えるようにするための仕組み。
JavaScript では DOM を操作する。

### 仮想 DOM

DOM は、その状態を常にチェックできないが、仮想 DOM ならできる。

仮想 DOM の値を変更 →DOM の値が更新される →HTML の表示が更新される。

---

## <イベント>

イベントは、重なっている一番上のタグで発生すると、その下のタグへと次々に伝搬する。
`（上）孫要素→子要素→親要素（下）`

### イベントハンドラ（イベントリスナ）

一般的には、イベントが発生したときに呼び出される処理のこと。
JavaScript においては、イベントを受け取って後続の処理に引き渡す中継役の命令のこと。（onClick 属性の値として記述されるもの）

---

## <Node.js>

Node.js は JS を（ブラウザでなく手元で）動かすための実行環境。

### npm/yarn

npm は Node.js を使うときに、ライブラリをインストールするための専用ツール。

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

他の CSS ファイルをインポートして、その内容を（`@import`と書いた側で）使うことができる。

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
- `rem` : HTML の最上位要素である html タグの文字サイズを基準に文字サイズが設定され、親要素の影響を受けない。

### CSS Grid Layout（グリッドレイアウト）

2 次元レイアウトを簡単に操作できる CSS の機能。

#### 要素

- コンテナ : グリッド全体を囲む要素。
- アイテム : コンテナの子要素。

https://qiita.com/kura07/items/e633b35e33e43240d363

### RSCSS

#### 要素

RSCSS には３つの分類がある。

###### Components（コンポーネント）

- パーツの大枠の要素で最低二つの単語（like-button、search-form）でクラス名を命名する。
  （→ AtomicDesign でいうと、`Molucules`以上の範囲）
- 1 つ以上のエレメンツを持つ。
- コンポーネントは再利用されるので、position や margin といった**位置や余白に関するプロパティは設定しない**。

##### Elements（エレメンツ）

- コンポーネントの内の**要素**。1 単語で命名する。（例：search-form コンポーネントの、入力欄が field、ボタンが action）
- **独立して使われない**。（→ AtomicDesign においては、`Atoms`に該当するため独立して使われる可能性もある。）
- 2 単語以上使いたい場合は`-`等の区切り文字なしで連結する。（例：first-name はダメで、firstname とする。）
- 子セレクタ`>`の使用を推奨。（`>`：子要素のみに適用される。）
  タグセレクタは使わない。

```css
.article-card {
  > .item {
  }
}
```

##### Variants（バリアント）

- 既存のコンポーネントやエレメントと**構成が同じ**で、**見た目や機能が違うもの**を作りたい場合に使用する。
- クラス名の先頭に`-`を付ける。

```css
.search-form {
  &.-wide {
  }
  &.-short {
  }
  &.-disabled {
  }
}
```

- コンポーネントのネスト
  - コンポーネント A 内で他のコンポーネント B を使う際、B にいつもとは違うスタイルを割り当てたい場合、
    コンポーネントをネストして記載する（A の中に B の style を書く）のでなく、バリアントを使う。

#### その他

- SCSS のファイル名・ディレクトリ構成にも規則がある。（が、割愛）
- プロパティのオーバーライドはヘルパーを使う。
- ヘルパー名は先頭にアンダースコア（\_）を付ける。

https://rfs.jp/sb/html-css/html-css-guide/rscss.html

---

## <TypeScript>

https://zenn.dev/itoo/articles/draft_learn-typescript

---

# フレームワーク

## <Vue.js>

- Vue で作ったプロジェクトそのものが web サーバー。
  （HTML を配置する web サーバーがどこか別にあるわけではない。→ クライアントは Vue に問い合わせる）
- build すると/dist 内に公開用ファイルが生成される。
  （デプロイするのはこれ。）
- Vue では仮想 DOM を操作する。仮想 DOM で扱うのが仮想ノード (VNode)。

### テンプレート構文

- マスタッシュ `{{ }}`
  ```pug:(pug)
  span {{ msg }}
  ```
- v-html : テキストでなく生の HTML を渡したいときに使う。

:::message

### Vue ディレクティブ

- Vue ディレクティブとは、**接頭辞 `v-` が付いた Vue.js の特別な属性**のこと。
- **ディレクティブの役割**は、**式が示す値が変化したとき、リアクティブに更新を DOM に適用する**こと。

![Alt text](https://ja.vuejs.org/assets/directive.386ba0f0.png)
:::

| Vue ディレクティブ | 説明                                                                                      |
| ------------------ | ----------------------------------------------------------------------------------------- |
| v-bind             | HTML タグの属性（id, class とか）を動的に設定。`:id`と省略可。                            |
| v-if               | 条件分岐。                                                                                |
| v-show             | v-if より頻繁に変更が起きる場合に使う。                                                   |
| v-for              | ループ。                                                                                  |
| v-on               | イベントをトリガーとして関数を実行。`@click`と省略可。                                    |
| v-model            | 双方向バインディング。template 内で起きた更新も script 内に反映されるし、その逆もしかり。 |

#### 属性バインディング v-bind

- バインドとは、`<script>`内と`<template>`内とで、値を結びつけること。

- _HTML タグの属性_（id, class とか）に設定する値を渡すと、属性値を動的に設定・変更。

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

- ①`{{ }}`内 or ②Vue ディレクティブの属性値の中 では、JS を書ける。

  ```pug
  {{ isOk ? 'Yes' : 'No' }}

  div(:id="`list-${id}`")
  ```

### リアクティブ

リアクティブとは、`値が監視されており、変更が検知される状態`のこと。

Vue.js や React などには、値の変更を検知可能な状態にするリアクティブシステムがあり、
*コンポーネントが保持している状態*を変更すれば、その変更が検知されて HTML に反映される。
（= データが更新されると自動で表示も更新される。）

Vue.js の主なリアクティブシステムは下記。

- ref : プリミティブ型に使う。
- reactive : オブジェクトに使う。
- effect
- computed : ある値から計算・処理した結果を、別の値として定義。ある値が更新されると自動で再計算が行われる。

#### ref

```ts:ref
const text = ref('Hello');
```

このように定義した値は、script 内では`.value`でアクセスし、template 内では`{{ }}`でアクセスする。

```ts
const changeText = () => (text.value = "Changed!!");
```

```html
<p>{{ text }}</p>
```

:::message
OptionAPI でいうところの`data`は、CompositionAPI でいうところの`ref()`や`reactive()`で定義した変数。
:::

:::message
console とかで確認したとき、`RefImp`と表示されているのはリアクティブなオブジェクト。
:::

### 算出プロパティ

#### computed

```ts:computed
const number = ref(10);
const double = computed(() => number * 2);
```

1 行で template 内に書き収めるのでなく、computed でロジックを切り出すほうがいい。

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

- index も取れる。
- ループ回数指定もできる。（`v-for="n in 10"`で 10 回ループする。）
- key は必要。`v-for="item in items" :key="item.id"`

### イベントハンドリング

#### v-on

`v-on:click='hogeHandler'` または `@click='hogeHandler'`。

### フォーム入力バインディング

#### v-model

```html
<div>{{ name }}</div>
<input v-model="name" />
```

https://ja.vuejs.org/guide/essentials/forms.html

### ライフサイクルフック

下記は Composition API での書き方。（Option API は少し異なる。）
（誰の life なのか = Vue インスタンスの life のことを指している。）

- `onMounted()`, `onBeforeMount()` : **DOM が読み込まれた直後**（Vue インスタンスが生成された後）のタイミング。（`onBeforeMount`はその直前。）
- `onUpdated()`, `onBeforeUpdate()` : **データの変更・画面の更新時**。
- `onUnmounted()` , `onBeforeMounted()` : Vue インスタンスが破棄されるタイミング。（よく理解できていない）

### ウォッチャー

#### watch

watch を使う場面。（computed との違い。）

- computed では処理できない**非同期通信などの複雑な処理**を行う場合
- **更新前**と**更新後**の値を使う場合
- 処理を実行しても、データは返さない場合

computed で書ける場合は computed のほうが簡素に書ける。

#### watchEffect

watch とは違い、**callback 関数の内部で使われている値の変更**を検知して実行される。
watch に比べると監視対象を一つ一つ宣言にせずに済むのはメリットだが、逆に、何がトリガーで実行されているか分かりにくくなる。
また、watch と違い、定義時に実行される。

### props

props は**コンポーネントのプロパティ**。
**親 → 子コンポーネントに値を渡す**。

- 使い方

  - <親コンポーネント内>
    `<template>`内で`:hoge="val"`で hoge という名前のものを渡す。

  - <子コンポーネント内>
    `<script>`内で`defineProps`で受け取って、`props.hoge`でアクセスする。
    `<template>`内では`{{ hoge }}`。

:::message alert

- **親 → 子**へはプロパティの更新が流れるが、その逆は無い。（**一方向バインディング**）
- **親コンポーネントが更新されるたびに、子コンポーネント内のすべてのプロパティが最新の値に更新される**。
- 子コンポーネント内でプロパティの変更はできない。
  :::

#### プロパティのバリデーション

バリデーションの要件に合致しないと、コンソールに`warning`が出る。（動きはするので注意！）

- 型 (type)
- 必須かどうか (required)
- デフォ (default)
- 独自の（カスタム）バリデーション関数 (validator)

### emits

**子 → 親**コンポーネントへイベントを発する。
（emit = 放つ）

- 使い方
  - <親コンポーネント内>
    `<SampleComponent @hoge-event="callback"/>`でイベントを購読。
    (イベント名はケバブケース)
  - <子コンポーネント内>
    `<button @click="$emit('hogeEvent')">`で親に`hogeEvent`が起きたことを知らせる。
    (イベント名はキャメルケース)

### コンポーネント間の v-moel(emit)

子コンポーネントにおける変更を、親コンポーネントに反映させるためには、下記のように v-model と emit を使う必要がある。
（computed の setter,getter で実装する方法もあるが、それは割愛）

```pug:親
<template>
  <!-- textを、子コンポーネントにtitleという名前で渡す -->
  <VModelComponent v-model:title="text"/>

  <!-- 子コンポーネントでの変更が、↓のtextに反映される -->
  {{ text }}
</template>
<script setup lang="ts">
import VModelComponent from '@/components/VModelComponent.vue'
import { ref } from 'vue'
const text = ref('ほげ')
</script>
```

```pug:子
<template>
  <!-- inputイベントに反応して、[update:title]がemitされる -->
  <input :value='title' @input="$emit('update:title', $event.target.value)">
</template>
<script setup lang="ts">
defineProps(['title'])
// update : (HTML要素の)イベントの種類
// title : 対象のプロパティ(props)名
defineEmits(['update:title'])
</script>
```

### slot

- `v-slot:hoge`は`#:hoge`と省略できる。
- 使い方
  - <親コンポーネント内>
    `<template v-slot:hoge>`
  - <子コンポーネント内>
    `<slot name="hoge">`

### コンポーザブル (composable)

**状態を持つロジック**をカプセル化して再利用するための関数。

- 慣習として、**コンポーザブル関数の名前は`use`で始める**。
- `<script setup>`の中か、ライフサイクルフックで**同期的に呼ぶこと**。
- **DOM を操作するような関数の場合**は、`onMounted()`などの**マウント後のライフサイクルフック内で実行すること**。そうすることで、DOM にアクセスすることが保証される。
  その場合、**`onUnmounted()`で掃除することも忘れず**。コンポーザブルが DOM イベントリスナーを登録したなら、そのリスナーを削除しないといけない。

#### カスタムフック

カスタムフックとは、複数のコンポーネントの中に存在する共通の処理を取り出して作成した関数。
Vue や Nuxt では`composables`ディレクトリ配下に配置する。（Nuxt の場合は auto import される）

https://qiita.com/powdersugar828828/items/0d0eff27437faf5fcc06#:~:text=%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%A0%E3%83%95%E3%83%83%E3%82%AF%E3%81%A8%E3%81%AF%E3%80%81state,%E3%81%97%E3%81%9F%E9%96%A2%E6%95%B0%E3%81%AE%E3%81%93%E3%81%A8%E3%81%A7%E3%81%99%E3%80%82

#### フックとは

https://zenn.dev/poteboy/articles/ce47ec05498cfa#hooks
https://ja.reactjs.org/docs/hooks-overview.html

:::message

### キャメルケース、ケバブケースの使い分け

Vue.js で一番ややこしいと感じている。

- プロパティ : キャメルケース (`firstName`)
- メソッド : キャメルケース (`getName`)
- props
  - 渡す側 : ケバブケース (`user-count`)
    ```pug
    <UserList user-count=20 />
    ```
  - 受け取る側 : キャメルケース (`userCount`)
    ```ts
    defineProps({
      userCount: Number,
    });
    ```
- イベント名 : ケバブケース (`click-create-button`)

https://qiita.com/ngron/items/ab2a17ae483c95a2f15e
:::

---

## Nuxt.js

Vue.js では主に UI を担当する。Nuxt.js はその他の色々な機能を含んでいる。

### ルーティング

vue.js は 1 枚なので、ルーティングの仕組みがない。（パスを作れない）
Vue Router で簡単に複数ページを作れる。
pages フォルダに.vue ファイルを追加するだけでアドレスが自動で割当てられる。
`$route`からルーティング情報を取り出せる（`<template>`内では`$route.params`、`<script>`内では`useRoute()`。）

基本的にはページ遷移には`NuxtLink`を使う。外部サイトへの遷移には普通に a タグを使う。

### ナビゲーション

`aタグ`でページ移動すると、移動の度にページ読み込みが発生する。
ページ全体でなく、**更新が必要な部分だけが更新されるように、`NuxtLinkタグ`を使う**。

### プラグイン

plugins ディレクトリに置いたプラグイン（拡張機能）は、コンポーネントから useNuxtApp 関数を使って取り出して、使うことができる。

### middleware ディレクトリ

Route middleware を使うと、ページ遷移時にユーザの権限チェックを行う等の処理を挟むことができる。

### Data Fetching

Nuxt3 でのデータ取得に関する関数は、useFetch, useLazyFetch, useAsyncData, useLazyAsyncData の 4 つ。
（useFetch のみ記載。）

#### useFetch

Promise を返す。

```ts
const response = await useFetch("https://jsonplaceholder.typicode.com/posts/");
```

戻されたデータの構成は下記。

- data : 取得したデータ。data と error と pending は RefImp なので、リアクティブな状態。（data.value でアクセスできる。）
- error : エラー。
- pending : 取得中かどうか。bool。
- execute : 関数。???
- refresh : データを再取得する関数。

https://zenn.dev/coedo/articles/cc000738a0f069

### useState

コンポーネント間やページ間で状態管理（データ共有）したいときに使う。
（状態を変更した状態で、別のページに移動して、その後そのページに戻ったときに、状態が変更されたままであってほしいとき 等）
`composables`配下ファイルに`useState`を定義すると、アプリ全域で共有できる。

```ts
// useState('ID（キー名）', 初期値を提供する関数)
const counter = useState("counter", () => 0);
```

https://nuxt.com/docs/examples/composables/use-state
https://note.com/taatn0te/n/n8c3bc521b3e7
https://zenn.dev/coedo/articles/use-state-nuxt3
https://developer.mamezou-tech.com/nuxt/nuxt3-state-management/

### エラーハンドリング

- NuxtErrorBoundary : エラーをキャッチしてエラー内容を表示するときに使われるコンポーネント。
- ヘルパー関数 : createError などのヘルパー関数がある。

### Server API Route

Nuxt3 には**Nitro Engine**というサーバエンジン（内部では**h3**という http サーバを使用）が含まれている。
Nitro サーバによって、クライアントからアクセス可能な API Route を作ることができる。

server ディレクトリ以下にディレクトリを切るとルーティングができる。
（routes ディレクトリ以下に置くことでも同じことができるよう。おそらく routes ディレクトリに置くのが良さそう。）
middleware ディレクトリには、リクエストが API Routes に入る前に挟みたい処理を置く。

### レンダリングモード

レンダリングモードを**ページごとに変更**できる。

#### Nuxt のレンダリングモード

1. **CSR**（クライアントサイドレンダリング）
   **要は、SPA**(Single Page Application)。
   クライアント（つまりブラウザ上）でレンダリングするモード。

:::message

#### SPA

一つのページをまずサーバーから取得。そのページを基軸に、表示したいものがあれば、そのための差分を都度 API から取得してくる。

まず、中身がほとんど無い HTML が返ってくる。それと別のリクエストで画面に表示するデータ（JSON）を取得していて、それらをクライアント側でレンダリング（組み立てて表示）している。

##### メリット

- ページ遷移ごとに、サーバで組み立てた HTML や CSS/JS を取得する MPA(例:Rails の erb)と比較して早い。
- ユニバーサルレンダリングと比較して開発が容易。（サーバー環境でのレンダリングを意識する必要がない）
- サーバー実行環境が不要。

##### デメリット

- ページが表示されるまでの初期ロード(クライアントレンダリングの完了)に時間がかかる。
- JavaScript がメインとなっているため、SEO には不利。
  :::

2. **Universal Rendering**（ユニバーサルレンダリング）
   Nuxt3 のデフォルト。
   **要は、SSR**(Server-Side Rendering)だが、**CSR(SPA)と SSR を組み合わせて**レンダリングを行う。

:::message

#### SSR

サーバサイドで HTML を生成して、クライアント（ブラウザ）に返す。（content-type が text/html）

ただし、サーバーサイドでレンダリングした HTML のままでは、ユーザー操作に対するリアクティブ性が無い。
そこで、**ハイドレーション**を行うステップを設けることで、SPA と同じリアクティブ性を後付けで追加している。

このように、**サーバー、クライアントサイド双方でレンダリングされる**ため、ユニバーサルレンダリングという名称となっている。

##### メリット

- SPA の欠点である初期ロードの遅さや SEO の問題を解消できる。
  :::

:::message

### ハイドレーションとは

静的ホスティング or サーバーサイドレンダリングによって配信された静的 HTML ウェブページを、クライアントサイドの JavaScript が HTML 要素に**イベントハンドラをアタッチ**して動的ウェブページに変換する手法のこと。
具体的には、ボタンを押したときなどのイベントに JavaScript を紐付けて、ページが変化するようにする。

1. サーバーサイドで、HTML が作成される。
2. クライアントサイドに HTML をダウンロードし、JavaScript のコードたちもダウンロードが終わり実行できる状態になったときに、Component などのコードをもとに HTML を生成し直し、**参照透過性のチェックを行う**。
3. サーバーサイドで生成した HTML にイベントハンドラをアタッチしていく。

#### 参照透過性

同じ props を渡してるのに、違うレンダリングがされてはいけない。
「**サーバーサイドの HTML === クライアントサイドで作った HTML**」となるのが期待値。
:::

3. その他
   今後の予定として、両者を組み合わせた Hybrid Rendering（ハイブリッドレンダリング）やエッジ環境でのレンダリングもサポート予定のよう。

- Hybrid Rendering : Route Rules を nuxt.cofig.ts 内で設定することでページ毎にレンダリングモードを変更することができる。

https://zenn.dev/rinda_1994/articles/e6d8e3150b312d
https://qiita.com/maruken24/items/71461c6a0247bbc9d4e5#ssr-with-rehydration
https://zenn.dev/mm67/articles/nuxt3-rendering-modes#summary
https://developer.mamezou-tech.com/nuxt/nuxt3-rendering-mode/

---

# ApolloClient

**GraphQL API のクライアント**ライブラリ。
（Apollo には、クライアントとサーバーがある。サーバーについてはよく分かっていない。）
https://v4.apollo.vuejs.org/guide/#what-is-apollo

1. 状態管理を行う
   グローバルな状態管理も Apollo で完結できる。
2. キャッシュを行う
   API レスポンスを正規化やキャッシュしながらのデータ取得が可能。

## <1. 状態管理を行う>

https://zenn.dev/furharu/articles/0397d183760970

## <2. キャッシュを行う>

https://zenn.dev/furharu/articles/ece72dac5feffe
https://zenn.dev/furharu/articles/26557d977b1b8c

## Vue Apollo

Vue と連結する Apollo。
https://v4.apollo.vuejs.org/

## vue/apollo-composable

**`vue/apollo-composable`というのは、Vue Apollo の中でも、compositionAPI に対応したもの**のこと。

_Apollo Client を使用して GraphQL API を呼び出し、
Vue3 Composition API を使用して API からのデータを取得し、
リアクティブに Vue コンポーネントに反映する_ ためのユーティリティ関数を提供している。

- `useQuery`: GraphQL のクエリを使用してデータを取得するためのフック
- `useMutation`: GraphQL のミューテーションを使用してデータを更新するためのフック
- `useSubscription`: GraphQL のサブスクリプションを使用してデータをリアルタイムに取得するためのフック
- `useResult`: **useQuery の結果を加工する**ためのフック
- `useLazyQuery`: useQuery と同様にクエリを実行するが、手動で呼び出すことができるフック

### useQuery

Component が render されたらクエリを実行する。
引数には`gql`で生成したクエリを食わせる。

useQuery（useSubscription も）のイベントフックには下記がある。

- onResult : 新しい結果が利用可能になるたびに呼び出される。
- onError : エラーが発生したときにトリガーされる。

https://v4.apollo.vuejs.org/guide-composable/query.html#graphql-document
https://v4.apollo.vuejs.org/api/use-query.html#return

:::message
上のリンク先に記載があるが、useQuery の return には、上記のイベントフック以外にも、result や loading、refetch などがある。

その中の`refetch`とは、キャッシュを利用せず、問い合わせを再度行うこと（再取得すること）。

- onResult はキャッシュされる。
  refetch はキャッシュされない。（ネットワーク通信あり）
  使い分けは、キャッシュしていい画面なのかどうか。
  :::

### useLazyQuery

任意のイベントをトリガーにしてクエリを実行できるようになる。
（= 好きなタイミングで。例えばボタンを押した時とか）

useLazyQuery のイベントフックには下記がある。

- onDone : ミューテーションが正常に完了すると呼び出される。
- onError : エラーが発生したときにトリガーされる。

:::message alert
**バインディングしたものは、`<template>`内で呼ばないと動かない**。（GraphQL Query とか）
（なぜか Query が実行されない みたいなときにチェックすること。）
:::

https://note.com/tabelog_frontend/n/n7360fd7bc007
https://zenn.dev/furharu/articles/26557d977b1b8c
https://tech.raksul.com/2021/12/05/combination-of-vue-js-v2-composition-api-vue-apollo-v4/

---

# UI 設計

## <Atomic Design>

### atoms（原子）

それ以上分解できない最小単位。
ラベル、ボタン、アイコンなど。

### molecules（分子。モレキュルス）

atoms を組み合わせてできたもの。
ヘッダーナビゲーションや検索フォームなど。

### organisms（生物）

atoms や molecules を組み合わせてできたもの。意味を持っている単位。
ヘッダーそのものが organisms。
atoms と molecules が組み合わさってヘッダーになる。

### templates（骨組み）

例えば、「ヘッダーとサイドナビゲーションは全てのページで共通だが、メインコンテンツだけが異なる」というページでいうと、そのページのメインコンテンツ部だけ空白地帯になっていて未完成状態の骨組み。

### pages（ページ）

atoms, molecules, organisms, templates が組み合わさって 1 つのページとなる。

https://qiita.com/Kazuhiro_Mimaki/items/3d9a8594064aab5119da

---

# UX

- UX デザイン
  UX を向上させることを目的としてプロダクトを設計すること。
- UX ライティング
  ユーザー(読み手)の体験を助け、体験の価値を高めるように配慮した文章の書き方、技術のこと。
  Web サービスでいうと、ボタンの文言、入力フォームのラベル、エラーメッセージなど、ユーザーが接する全ての文章が対象。
