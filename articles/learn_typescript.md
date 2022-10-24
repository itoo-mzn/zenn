---
title: "TypeScriptに入門"
emoji: "⛳"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["TypeScript"]
published: false
---

# 目的
TypeScriptの基礎を身につけ、スラスラをコードを書けることを目指す。
そのために、文法・仕様・実行方法・実行環境周辺について学ぶ。


# 実行環境
Nodeのバージョンは16.3.0。
TypeScriptのバージョンは4.3.5。
```bash
$ node -v
v16.3.0

$ tsc -v
Version 4.3.5
```

:::message alert
次のワードを調べて、網羅的に知識を整理すること。
package.json
node_modules
npx
yarn / npm
:::


# Typescriptとエコシステム

## 言語
TypeScriptの仕様には、下記が含まれる。
- ECMAScript由来の仕様 : JavaScriptのコア部分の仕様。
- WHATWG由来の仕様 : ブラウザ関連のJavaScript仕様。
- JSX : XMLの構文をJavaScriptに書けるようになる言語。
- TypeScript固有の仕様

### < ECMAScript >
JavaScriptのコア部分の仕様。
ECMAScriptは毎年1回、仕様改定され、そのたびにバージョンが上がる。

#### HTML Living Standard
**ECMAScriptが決める クライアントサイドJavaScript の仕様は部分的**。ECMAScriptが定める範囲は、言語の文法、構文の解釈方法、コアのAPIなど言語の中核部分。
JavaScriptのうち**ブラウザ仕様に関する部分は、HTML Living Standard が決めている**。（HTML Living Standardで決められる内容は、ブラウザでJavaScriptを使うと触れることになる、windowオブジェクトやHTMLDivElement、ローカルストレージなどのAPI。）

## フロントエンドフレームワーク
React、Vue、Angular、Next.js、Nuxt.jsなど

## 型定義ファイル
TypeScriptを使ったプロジェクトにJavaScript純正のライブラリを使いたいときは、ライブラリとは別途、*型定義ファイル*を入手すると、TypeScriptでの型チェックができるようになる。

## 実行環境
JavaScriptの実行環境は大きく分けて、「ブラウザ」と「サーバー」の2種類。

## 開発ツール
### < パッケージマネージャー >
JavaScriptのライブラリを管理するツール。
パッケージマネージャーを使うことで、JavaScriptのライブラリをインストールしたり、アップデートしたりできる。
また、ライブラリ同士の依存関係の管理も行ってくれる。

パッケージマネージャのうち、`npm`と`Yarn`が広く使われている。
https://zenn.dev/hibikine/articles/27621a7f95e761

npmやYarnでインストールされるライブラリは、`npmjs.com`という中央集権型のレジストリにホスティングされている。

### < モジュールバンドラー >
複数のJavaScriptファイルをひとつのファイルに結合するためのツール。（代表は`Webpack`。）
複数のJavaScriptファイルに依存関係がある場合、それをそのままブラウザに読み込ませるには、慎重に読み込み順を指定しないと、アプリケーションが壊れてしまう。このようなトラブルは、モジュールバンドラーを使うと回避できる。

また、フロントエンドでは、JavaScriptアプリケーションをブラウザにダウンロードさせる必要がある。数多くのファイルからなるアプリケーションは、モジュールバンドラーで結合した1ファイルのほうが効率的にダウンロードできる。

モジュールバンドラーを使うと、`CommonJS`を採用しているサーバーサイド向けに作られたライブラリをブラウザで使えるといったメリットもある。

https://zenn.dev/yodaka/articles/596f441acf1cf3

### < トランスパイラー（トランスコンパイラ） >
あるプログラミング言語でかかれたコードを、別の言語に変換するツール。（コンパイラーの一種。）
- 新しいバージョンのJavaScriptから古いバージョンのJavaScriptに変換するトランスパイラーがある。`Babel`や`swc`がこれにあたる。
- TypeScriptの`tsc(TypeScript compiler)`もトランスパイラー。tscはTypeScriptからJavaScriptへの変換を行う。

### < コードフォーマッター >
よく使われるのは`Prettier(プリティア)`。

### < リンター >
よく使われるのは`ESLint`。

### < Gitフック >
Gitフックとは、Gitにコミットするタイミングやプッシュするタイミングに、何らかのプログラムを実行する機能。
JavaScriptの開発現場では、Gitコミット時にTypeScriptのコンパイルで型チェックをしたり、リンターのチェックを起動したり、コードフォーマッターでコード整形をかけることがよくある。
Gitフックを手軽に利用できるようにするツールとして、`husky`や`lint-staged`がある。

## 何では無いか
### < TypeScriptランタイムというものが無い >
TypeScriptにはランタイムが無い。どういうことかというと、TypeScriptを直接実行するエンジンがないということ。
TypeScriptで書いたコードを実行するには、一度JavaScriptコードに変換する必要がある。そのため、**TypeScriptのパフォーマンスは、コンパイル後のJavaScriptがどうなっているかで決まる**。

### < TypeScriptコンパイラは最適化しない >
一般的に「コンパイラ」には、次の3つの仕事がある。
1. ソースコードを解析し、問題点をチェックする
2. ソースコードを別の言語に変換する
3. 最適化する
  実行速度が速くなるようにする
  少ないメモリで動くようにする
  少ない電力で済むようにする
  実行ファイルのサイズを小さくする

このうち、**TypeScriptコンパイラがするのは上の2つだけ**。**3つ目の最適化はしない**。

**TypeScriptコンパイラは、基本的に型に関する部分を消すだけ**で、**それ以外の部分はほぼそのままJavaScriptに変換する**。

:::message
- TypeScriptのランタイムはない。
- TypeScriptコンパイラは最適化しない。

この2つの特徴から、まったく同じロジックのコードをTypeScriptとJavaScriptで書いて比較したとき、その間にはパフォーマンスの違いはないと考えて差し支えない。
:::


# js/tsファイル実行方法

## jsファイル実行方法
```bash
node increment.js
```
## tsファイル実行方法
tsファイルの実行は、下記2通りある。
- `tsc`コマンドでコンパイルしてts→jsに変換してから、`node`コマンドでjsファイルを実行する
- `ts-node`でコンパイルと実行を1回で済ます。
  （ts-nodeを使うとコンパイルと実行が一度にできることは分かったが、ts-node自体が何者か、調べたがよくわからなかった。）
  ```bash
  yarn add -D typescript @types/node ts-node
  yarn ts-node ファイル名
  ```


# TypeScriptのコンパイル

コンパイルするコマンドは`tsc`。
```bash
tsc increment_typescript.ts
```

:::message
**コンパイルすると、同じ名前のjsファイルが自動生成される**。
（今回はincrement_typescript.jsファイルが自動で追加された。）

**コンパイルで生成されたjsファイルの配置場所は、tsconfig.jsonで設定できる**。

```json
{
  "compilerOptions": {
    "outDir": "dist" // コンパイルで生成されたjsファイルの配置ディレクトリ
  },
  "include": ["src"]
}
```

この（コンパイル後の）jsファイルには型注釈が無い。

**型注釈があるとブラウザやNode.jsでは実行できない**ため、**コンパイラが生成したjsファイルを成果物として、本番環境にデプロイすることになる**。
:::


# リンター

## 導入
**ESLint**を導入。
（-D(--dev)は開発環境のみにインストールするという意味。）
```bash
yarn add -D 'eslint@^8'
```

## 実行
ESLintを実行するのは下記コマンド。
```bash
npx eslint ./src
```

## 設定
ESLintでは、複数の**ルール**を組み合わせてコーディング規約を組み立てていく。
`.eslintrc.js`ファイルに設定を記述する。

一部、コードの自動修正ができるルールがある。
`semi`はそれに該当し、セミコロンが無い場合はリンターに怒られるのだが、`--fix`オプションを付けることで自動で修正してくれる。
```js:.eslintrc.js
module.exports = {
  // 設定ファイルを在り処を探す起点
  root: true,

  // コードがどの実行環境で使われるかをESLintに伝えるためのオプション
  // ESLintがグローバル変数を認識するようになる
  env: {
    browser: true, // windowやalertなどのグローバル変数が認識される
    es2021: true, // ES2021までに導入されたグローバル変数が認識される
  },

  // どの構文を使っているか
  parserOptions: {
    ecmaVersion: "latest", // どのバージョンのECMAScriptの構文を使うか
    sourceType: "module", // スクリプトモードとモジュールモードのどちらにするか
  },

  // ルール
  rules: {
    "no-console": "error", // console.logを書いてはならない
    camelcase: ["error", { properties: "never" }], // 変数名はキャメルケースのみ。ただし、プロパティ名は限っては強制しない。
    semi: ["error", "always"], // 文末のセミコロン必須
  },
};
```

### < shareable config >
公式ドキュメントのルールは下記。
https://eslint.org/docs/latest/rules/
だが、ルールの数があまりにも多いので、それをひとつひとる調べるのは大変。そこで、**shareable config**という誰かが作ったルールセットを使うのがオススメ。

`eslint-config-airbnb-base`や`eslint-config-google`が有名。

### < ルールを部分的に無効化する >
部分的にルールを無効にするには、その行の前にコメント`eslint-disable-next-line`を追加。
```js
// eslint-disable-next-line camelcase
export const hello_world = "Hello World";
```

## TypeScript用リンター
ESLintはJavaScript用だが、TypeScript用もあり、それが**TypeScript ESLint**。
（設定方法などは省略。参考情報の[サバイバルTypeScript]を参照。）

コンパイルで生成されるJavaScriptは、リントしないのが普通。なので、そのディレクトリはチェック対象外にしておく。


# 文法・仕様

- TypeScriptでは文末のセミコロンが省略できる。

- JavaScriptには元々バグだったものが仕様に変わった例がある。
  - 値の型を調べる`typeof`演算子は、`null`を渡すと`"object"`が返る。これはバグと考えられていたが、後方互換性のため修正されることなく仕様になった。
```js
typeof null;
// -> "object"
```

- JavaScriptはクラスベース（クラスからオブジェクト(インスタンス)を作る）ではなく、**プロトタイプベース**（オブジェクトからオブジェクトを作る）の言語。ただ、クラスベース風の書き方ができるように拡張された。

---

## 変数 : let, const
**基本は`const`で変数宣言をし、必要な場合にのみ`let`を使う**。
（`const`で変数宣言することで再代入を禁止して、意図せず変数が書き換えられることを予防できるので、より安全なコードになる。）

### < let >
**初期値無し**で変数を定義できる。
**再代入可能**。

### < const >
変数定義時に、**初期値が必須**。
**再代入不可**な**定数**。ただし、**変数自体への再代入はできないだけで、オブジェクトプロパティは変更できる**。
```js
const obj = { a: 1 };
obj = { a: 2 }; // これはできない
obj.a = 2; // これはできる
```

:::message alert
#### オブジェクト・配列を不変にするには
TypeScriptでオブジェクト・配列を不変にするには、`readonly`によって読み取り専用にする必要がある。
もしくは、constアサーション`as const`を使うことでも実現できる。
:::

:::message alert
#### `var`は使わないこと！
- 同名の変数宣言ができてしまう。
- グローバル変数として定義したときに、windowオブジェクトのプロパティとして定義されるため、標準APIのプロパティが上書きされてしまう恐れがある。
  （例えば、innerWidthという変数を定義すると、標準APIの`window.innerWidth`が上書きされる。）
- varで宣言した変数は、その変数の宣言前の場所に書かれたコードがエラーにならずに実行できてしまう。
  （変数の巻き上げ時点で、varは変数を`undefined`で初期化するため。）
  ```js
  console.log(num); // undefined と出力される。（変数numはこの時点で未定義なのに）
  var num = 10;
  ```

##### 変数の巻き上げ
JavaScriptで宣言された変数は、**スコープの先頭で変数が生成**されてから実行される。これを変数の巻き上げと呼ぶ。
:::

---

## 型注釈
```ts
// const <変数名>: <型> = 値;
const num: number = 10;
```

#### 型推論
型推論（コンパイラが型を自動で判別する機能）によって、型注釈を省略することもできる。
```ts
let x = 1; // let x: number = 1; と書かず、型注釈を省略。
x = "hello" // これはエラーになる。型推論により、xはnumberだと認識されているため。
```

---

## データ型
JavaScriptのデータ型は、「プリミティブ型」と「オブジェクト」の2つに大別される。

1. **プリミティブ型**（primitive = 基本）
  下記に示す7種類。
2. **オブジェクト**
  プリミティブ型以外の全て。

### < プリミティブ型 >
1. 論理型 `boolean`

2. 数値型 `number`
    - 2進数、8進数、16進数の表記が可能。それぞれ表現したい数値の前に`0b`、`0o`、`0x`をつける。（`0b111`は`7`。）
    - 桁区切りのアンダースコアを付けることができ、何桁ごとに区切るかも自由。
    - 小数点と区別をつけるため、プロパティを参照する場合は、ドットを2つ続けるか、数値をカッコで囲む必要がある。
      ```js
      5.toString(); // NG
      
      5..toString(); // OK
      (5).toString(); // OK
      ```
    - JavaScriptの数値型には、`NaN`と`Infinity`という特殊な値がある。
      - `NaN` : 処理の結果、数値にならない場合に`NaN`を返す。`NaN`かどうかは、`Number.isNaN()`でしか判定できない。（等号は常にfalseになる。）
      - `Infinity` : 無限大を表す。
    :::message alert
    #### JavaScriptに限らず、小数計算の誤差は生じる
    https://typescriptbook.jp/reference/values-types-variables/number/decimal-calculation-error
    https://zenn.dev/ymmt1089/articles/20220603_big_number
    https://qiita.com/suima4743/items/8d6b76682a188f061b07
    :::

3. 文字列型 `string`
    - `シングルクォート`と`ダブルクォート`は機能上の違いが無い。
      `バッククォート`はテンプレートリテラルと言い、改行(`\n`)と式の挿入(`${}`)ができる。
      （しかし、単純な文字列では、この3つは同じ意味になる。）
      :::message
      #### こう使い分けると良い
      1. 基本的に`ダブルクォート`を使用する。
      2. 文字列の中に`"`が含まれる場合は、`シングルクォート`を使用する。（`\`でエスケープしなくて済むので。）
      3. 文字列展開する必要があるときは、`バッククォート`を使用する。
      :::

4. undefined型 `undefined`
    - 値が未定義であることを表す型。
      変数に値がセットされていないとき、戻り値が無い関数、オブジェクトに存在しないプロパティにアクセスしたとき、配列に存在しないインデックスでアクセスしたときなどに現れる。
    - TypeScriptで戻り値なしを型注釈で表現する場合は、`undefined`でなく`void`を使う。

5. null型 `null`
    - 値がないことを表す型。
    - 値の型を調べる`typeof`演算子は、`null`を渡すと`"object"`が返るので要注意。
    :::message
    #### undefinedとnullの違い
    - undefinedは「値が代入されていないため、値がない」。
      nullは「代入すべき値が存在しないため、値がない」。

    - undefinedは言語仕様上、プログラマーが明示的に使わなくても、自然に発生してくる。
      nullはプログラマーが意図的に使わない限り発生しない。つまり、JavaScriptとしてはnullを提供することがないということ。（ただし、一部のDOM系のAPIはnullを返すこともあるため、ライブラリによってはnullと出会うことはある。）

    もしどちらを使うべきか迷ったら**undefinedを使っておくほうが無難**。

    https://typescriptbook.jp/reference/values-types-variables/undefined-vs-null
    :::

6. シンボル型 `symbol`
    - 一意で不変の値。
      論理型や数値型は値が同じであれば、等価比較がtrueになるが、シンボルは**シンボル名が同じであっても、初期化した場所が違うとfalseになる**。
      （Rubyのシンボルは値が同じなら等価と評価される。この点が異なるので要注意。）
      ```js:JavaScriptのシンボル
      const s1 = Symbol("foo");
      const s2 = Symbol("foo");
      console.log(s1 === s1); // true
      console.log(s1 === s2); // false
      ```
      ```ruby:Rubyのシンボル
      s1 = :foo
      s2 = :foo
      p s1 === s2 # true
      ```

7. bigint型 `bigint`
    - number型では扱えない大きな整数型。
    - bigint型とnumber型はそのままでは一緒に演算をすることはできず、どちらかに型を合わせる必要がある。小数が無い限り、より表現幅の広いbigint型に合わせる方が無難。

また、プリミティブ型からの派生系として、下記の型スタイルがある。
- リテラル型
  プリミティブ型の**特定の値だけを代入可能にする**型。
  リテラル型として表現できるのは、論理型のtrueとfalse、数値型の値、文字列型の文字列。
  ```js
  let x: number = 1; // 数値しか代入できない変数に、1を代入している
  let y: true = true; // trueしか代入できない変数に、trueを代入している
  let z: "foo" = "foo"; // 文字列fooしか代入できない変数に、fooを代入している
  ```
- any型
  **どんな型でも代入を許す**型。

:::message
#### ボックス化・ラッパーオブジェクト
JavaScriptでは、**内部的にプリミティブ型の値をオブジェクトに変換している**。
この暗黙の変換を**自動ボックス化**と呼ぶ。
```js:ボックス化の恩恵
const str = "abc";
// プリミティブ型でも、オブジェクトのように扱うことができる
str.length; // フィールドの参照
str.toUpperCase(); // メソッド呼び出し
```

自動ボックス化で変換先となるオブジェクトを**ラッパーオブジェクト**と呼ぶ。
| プリミティブ型 | ラッパーオブジェクト |
| - | - |
| boolean	| Boolean |
| number | Number |
| string | String |
| symbol | Symbol |
| bigint | BigInt |

プリミティブ型の`undefined`と`null`にはラッパーオブジェクトが無い。

プリミティブ型の代わりに、ラッパーオブジェクト型を型注釈に使う利点は無いので、**型注釈にはプリミティブ型を使うこと**。
:::

## オブジェクト
プリミティブ型以外の全てはオブジェクト。（クラス、インスタンス、配列、正規表現...）

プリミティブ型は値が同じであれば同一のものと判定されるが、オブジェクト型はプロパティの値が同じであっても、**インスタンスが異なると同一のものとは判定されない**。

### < オブジェクトリテラル >
他言語でオブジェクトを生成するには、まずクラスを定義してそれを元にインスタンスを作るのが普通。しかし、JavaScriptはクラス定義がなくてもオブジェクトリテラル`{}`を書くと、オブジェクトをインラインで作れる。
```js
const object = { key: "値", hoge: 10 };
```

### < プロパティ >
JavaScriptのオブジェクトは、プロパティ（**キーと値の対**）の集合体。
プロパティの値には、プリミティブ型、関数、オブジェクトを入れることができる。

プロパティの値となっている関数をメソッドと呼ぶ。（= メソッドとは、オブジェクトに関連づいた関数のこと。）
下記のように、原則通りにキーと値に分けて書くことも、短い構文で書くこともできる。
```js
const object = {
  // キーと値に分けて書いたメソッド定義
  printHello1: function () {
    console.log("Hello");
  },
  // 短い構文を使ったメソッド定義
  printHello2() {
    console.log("Hello");
  },
}
```

### < オブジェクトの型注釈 >
```ts:インラインで型注釈したパターン
let box: { width: number; height: number };
box = { width: 1080, height: 720 };
```
```ts:型エイリアスを使ったパターン
type Box = { width: number; height: number }; // 型に名前を付けることができる
let box: Box = { width: 1080, height: 720 };
```
複数のオブジェクトに同じ型を適用する場合は、型エイリアスを使ったほうが良い。

オブジェクトにおいても型推論は行われる。
```ts
let box = { width: 1080, height: 720 };
// こう定義すると、{ width: number, height: number }と型推論される。
```

#### メソッドの型注釈
:::message alert
関数のことを学んでから、ここの内容は戻ってきて学ぶこと。
https://typescriptbook.jp/reference/values-types-variables/object/type-annotation-of-objects#%E3%83%A1%E3%82%BD%E3%83%83%E3%83%89%E3%81%AE%E5%9E%8B%E6%B3%A8%E9%87%88
:::

### < readonlyプロパティ >
オブジェクトのプロパティの前に`readonly`を付けることで、それを**読み取り専用**にすることができる。
```ts
let object: { 
  readonly key1: string; // 読み取り専用
  key2: string;
};
```
ただし、オブジェクトが入れ子になっている場合は、子のオブジェクトまで再帰的にreadonlyになる訳ではない。そういうことがしたい場合、子や孫のプロパティすべてにreadonlyを付ける必要がある。

:::message
#### constとreadonlyの違い
**constが禁止するのは、変数への代入**。
しかし、変数の中身がオブジェクトの場合、当然そのオブジェクト自体を変更（= 変数への代入）することはできないが、そのオブジェクトの*プロパティを変更することはできる*。
```ts:const
const x = { a: 1 };
x = { a: 2 }; // これはできない（変数への代入）
x.a = 3; // これはできる（プロパティへの代入）
```
**readonlyが禁止するのは、プロパティへの代入**。
しかし、変数自体は変更できる。
```ts:readonly
let x: { readonly a: number } = { a: 1 };
x = { a: 2 }; // これはできる（変数への代入）
x.a = 3; // これはできない（プロパティへの代入）
```
`const`と`readonly`を組み合わせると、変数自体とオブジェクトのプロパティの両方を変更不能なオブジェクトを作ることができる。
:::

### < オプションプロパティ >
オプションプロパティを持ったオブジェクト型には、**そのオプションプロパティを持たないオブジェクトを代入できる**。
```ts
let size: { width?: number };
size = {}; // OK
size = { width: undefined }; // OK
size = { width: null }; // NG
```

### < 余剰プロパティチェック >
オブジェクト型に**存在しないプロパティを持つオブジェクトの代入を禁止**する検査機能。
```ts
let onlyX: { x: number };
onlyX = { x: 1 }; // OK
onlyX = { x: 1, y: 2 }; // NG (yは定義されていないプロパティなので)
```

### < インデックス型 >
オブジェクトの**フィールド名をあえて指定せず**、プロパティのみを指定したい場合に使う。
フィールド名として定義されていないプロパティも代入できる。
```ts
let object: {
  // 具体的なフィールド名は決まっていないが、キーがstringで値がnumberならOK
  [key: string]: number;
};

// 未定義だが、プロパティを追加できる
object = { a: 1, b: 2};
object.c = 3;
object["d"] = 4;
```

`Record<K, T>`ユーティリティ型というのがあり、下記のように書いても同じ意味になる。
```ts:Record<K, T>
let object: Record<string, number>;
```

### < object, Object, {} の違い >
- `object` : オブジェクト が代入可能。
- `Object`, `{}` : オブジェクト と、null, undefined以外のプリミティブ型 が代入可能。

※ オブジェクトとは、プリミティブ型以外の全て。

プリミティブ型も代入できてしまうため、`Object`型は使うべきでない。オブジェクト型ならなんでも代入可にしたい場合は、代わりに`object`型を検討すべき。

### < オブジェクトの分割代入 >
プロパティ名と同じ名前で変数を定義する場合、下記のように書ける。
```ts
const item = { price: 100, amount: 5 };

// < 普通にプロパティを参照して、それを変数に格納する方法 >
const price = item.price;
const amount = item.amount;

// < 分割代入する方法 >
const { price, amount } = item;

// いずれの方法でも、変数priceに100が、変数amountに5が入る。
```

新たに定義する変数に別名を付けるには、`:`の後に指定する。
また、デフォルト値は`=`のあとに指定する。
```ts
const item = { price: 100, amount: 5 };

const { price: item_price, amount: item_amount = 3 } = item;
console.log(item_price); // 100
```

### < オプショナルチェーン >
オプショナルチェーン`?`を付けることで、存在しないプロパティにアクセスしてもエラーを避けることができる。存在しない場合は`undefined`が返る。

また、NULL合体演算子`??`と組み合わせると、オプショナルチェーンで`undefined`になった場合のデフォルト値が設定できる。
```ts
let a: undefined | { title: string };
const b = a?.title;
console.log(b); // undefined

// < デフォルト値を設定した場合 >
const b = a?.title ?? "デフォルト";
console.log(b); // "デフォルト"
```

### <オブジェクトをループする方法>
```ts:Object.entries + for of文
type SampleObject = { [key: string]: number };
const object: SampleObject = { a: 1, b: 2 };

// Object.entries + for of文
for (const [key, value] of Object.entries(object)) {
  console.log(key, value);
}
```

keyだけループしたい場合は`Object.keys`、値だけの場合は`Object.values`で可能。

:::message alert
for-in文ではhasOwnPropertyを使わないといけないので、for-of文が良いかと思う。
:::

## 配列
- 配列はオブジェクトなので、同じ中身でも`===`でtrueにならない。
- 100個も要素がないstringが格納されている配列に`array[100]`とする 等、存在しない配列の要素にアクセスすると`undefined`が返ってくるが、それはTypescriptでは発見できない。
  これを注意してもらうためにはコンパイラーオプションの`noUncheckedIndexedAccess`を有効にする。（推奨）
- 配列の型は[共変](https://typescriptbook.jp/reference/values-types-variables/array/array-type-is-covariant)である。

### < 型注釈 >
配列の型注釈は、下記2パターンどっちでも良い。（プロジェクト内で統一しておくこと。）
```ts
let array1: number[];
array1 = [1, 2, 3];

let array2: Array<number>;
array2 = [1, 2, 3];
```

読み取り専用の配列は下記。
```ts:読み取り専用の配列
const nums1: readonly number[] = [1, 2, 3];

const nums2: ReadonlyArray<number> = [1, 2, 3];
```

### < 分割代入 >
```ts
const oneToFive = [1, 2, 3, 4, 5];

const [one, two, three] = oneToFive; // 1, 2, 3

// 途中から取得するにはコンマを入れる
const [, , , four, five] = oneToFive; // 4, 5

// 「残り」を取得するには、残余パターン[...]を使う
const [one, ...other] = oneToFive; // 1, [2, 3, 4, 5]
```
```ts:ネストした配列から取得
const nestArray = [[1, 2], [3, 4]];
const [[one, two], [three]] = nestArray;
```

### < メソッド >
| 分類 | メソッド | 概要 | 破壊的か |
| - | - | - | - |
| 結合 | join | 全要素を結合した文字列を返す | 非破壊的 |
| 結合 | concat | **複数の配列を結合**した配列を返す | 非破壊的 |
| 追加・除去 | push | 配列の**末尾**に要素を追加 | 破壊的 |
| 追加・除去 | unshift | 配列の**先頭**に要素を追加 | 破壊的 |
| 追加・除去 | push | 配列の**末尾**の要素を削除し、その要素を返す | 破壊的 |
| 追加・除去 | shift | 配列の**先頭**の要素を削除し、その要素を返す | 破壊的 |
| 追加・除去 | **splice** | 1. 指定した位置に要素を追加。<br>2. 指定した位置からn個の要素を削除。<br>3. 1,2の組み合わせ。 | 破壊的 |
| ソート | sort | ソートする | 破壊的 |
| ソート | reverse | sortの逆順 | 破壊的 |
| 値の書換え | fill | 指定した値で詰め変える | 破壊的 |
| 値の書換え | copyWithin | 配列の要素数は変えずに、指定位置の値を同じ配列内のコピー値に置き換える | 破壊的 |
| ループ | forEach | 配列の各要素に対してループ処理 | 非破壊的 |
| ループ | filter | テスト関数に合格した要素から成る配列を返す | 非破壊的 |
| ループ | map | 関数の結果から成る配列を返す | 非破壊的 |
| ループ | reduce | 初期値を定義し、それを利用した関数を各要素に実行して最終値を返す | 非破壊的 |
| ループ | reduceRight | reduceの処理実行順を右から左にしたもの | 非破壊的 |
| 探索 | find | テスト関数を満たす**最初の要素**を返す | 非破壊的 |
| 探索 | findIndex | テスト関数を満たす**最初の要素の位置**を返す | 非破壊的 |
| 探索 | indexOf | 指定の要素が見つかった最初の位置を返す | 非破壊的 |
| 探索 | lastIndexOf | 指定の要素が見つかった最後の位置を返す | 非破壊的 |
| 探索 | includes | 配列にその要素が含まれているかを返す | 非破壊的 |
| 探索 | every | すべての要素がテスト関数に合格するかを返す | 非破壊的 |
| 探索 | some | いずれかの要素がテスト関数に合格するかを返す | 非破壊的 |
| ネスト | flat | 指定した深さに結合させた配列を返す | 非破壊的 |
| ネスト | flatMap | flatとmapを同時に使いたいとき | 非破壊的 |
| 配列の情報 | keys | 配列のインデックスを返す | 非破壊的 |
| 配列の情報 | values | 配列の値を返す | 非破壊的 |
| 配列の情報 | entries | 配列のインデックスと値のペアを返す | 非破壊的 |
| 配列の情報 | slice | 配列の一部を切り出してそれを返す | 非破壊的 |

:::message alert
他の言語の同じような名前の非破壊的なメソッドでも、JavaScriptでは破壊的なメソッドであることもあるので使うときは要注意!!
:::

:::message
#### 元の配列は残したまま、破壊的なメソッドを使う方法
配列のコピーにスプレッド構文`...`を使う。
```ts
const original = [1, 2, 3];
// const copy = original; // originalに加えた変更がcopyにも反映されるため、この方法ではNG
const copy = [...original]; // スプレッド構文で中身だけ取り出して、器[]に入れる
copy.reverse();
console.log(copy); // [3, 2, 1]
console.log(original); // [1, 2, 3]
```
:::

### < ループ >
#### for文
```ts
const array = ["a", "b", "c"];
for (let i = 0; i < array.length; i++) {
  if (i === 1) {
    // break; // ループ全体が終了するため、"a" のみ出力される
    continue; // 今のループが終了して次のループに移るため、"a", "c" のみ出力される
  }
  console.log(array[i]);
}
```

#### for of文
配列の要素を1つずつ処理する場合（上記のfor文のような用途の場合）、for ofのほうがforより簡潔。（`break`と`continue`も使える。）
```ts
for (const value of array) {
  console.log(value);
}
```

:::message alert
**for in文は**順番通りに実行される保証がないため、**使わないこと**。
:::

#### Arrayのメソッド
`forEach`や`map`は、**`break`と`continue`が使えない**。

### < スプレッド構文 (`...`) >
配列や文字列などを展開することができる。

- 配列のコピーが簡単にできる。
  ```ts
  const arr = [1, 2, 3];
  const copy = [...arr]; // [1, 2, 3]
  const add = [0, ...arr, 4, 5]; // [0, 1, 2, 3, 4, 5]
  ```

- 配列では渡せないメソッドの引数に`...array`形式で渡せるようになる。
  ```ts
  // Math.min()の引数は要素。なので配列のままでは渡せない。
  // Math.min(array); // NG
  Math.min(...array);
  ```



---

:::details プログラム問題でよく使うもの

# プログラム問題でよく使うもの

## 標準入力を受け取る
```js:javascript
process.stdin.resume();
process.stdin.setEncoding('utf8');

var lines = [];
var reader = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});
reader.on('line', (line) => {
  lines.push(line);
});
reader.on('close', () => {
  // ここにロジックを書く。(標準入力を受け取った後に行うことを記述する場所)
  console.log(lines); // 標準入力で受け取った値が配列で格納されている
}
```

### 標準入力を文字列→整数に変換する
(例 : `5 2 4` → `[5, 2, 4]`)
```js
const input = lines[0].split(' ').map(str => (parseInt(str, 10)) );
```

50 * 80 - 1000 - 1000*3

## 条件分岐
```js
// if
if (a % b === 0) {
  // ...
}

// if文は1行にもできる
if (a % b === 0) { console.log("hoge"); }

// unless
// jsにunlessが無いので、条件を否定したものをifで判定
if (!(a % b === 0)) {
  // ...
}
```

## ループ
forはできるだけ使わないようにする。
https://qiita.com/diescake/items/70d9b0cbd4e3d5cc6fce

```js:filter
// 数値が並ぶ配列の中で、後ろの数値のほうが大きい要素(整列していない数値)のみを取得
const not_sorted_numbers = num_array.filter((num, index) => num > num_array[index+1]);
```

```js:for of文
for (const result of results) {
  // ...
}

// インデックスも欲しい場合
for (const [index, result] of results.entries()) {
  // ...
}
```


```js:for文 (仕方ない場合)
for(let count = 0; count < peopleSum; count++) {
  // ...
}
```

## 配列の中の数値を合計
```js
const sum = nums_array.reduce( (sum, i) => sum + i, 0);
```

## 配列の中の数値の最大値、最小値を取得
```js
Math.min(...array)
```

## ソート
javascriptの`sort()`は、()内で関数を実行してその返り値が0より大きいか/小さいか/等しいかによって並べ替えをコントロールできる。
https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Array/sort

```js
// < 降順(大→小)にソートする例 >
numbers_array.sort(function(first, second){
  if (first > second) {
    return -1; // 次の要素(second)より大きいfirstは、secondの前に整列
  } else if (first < second) {
    return 1; // secondより小さいfirstは、secondの後ろに整列
  } else {
    return 0; // 順序はそのまま
  }
});
```

:::

# 参考情報
https://typescriptbook.jp/