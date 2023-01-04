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

:::message alert
次のワードを調べて、網羅的に知識を整理すること。
package.json
node_modules
npx
yarn / npm
:::

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

### < 変数のスコープ >
#### グローバルスコープ
JavaScriptでグローバルなオブジェクトは`window`のみ。
実は`Date`や`console`はwindowオブジェクトのプロパティ。
```ts
console.log(Date === window.Date); // true
console.log(console === window.console); // true
// （ちなみに、これらはサーバサイド側でなく、クライアント側でしか実行できないのでブラウザで確認した）
```

#### ローカルスコープ
- **関数スコープ**
  関数の中でのみ参照できる。関数の中で宣言された変数は、関数の外では参照できない。
  ```ts
  function hoge() {
    const variable = 123;
    // ...
  }
  console.log(variable); // エラー
  ```
- **レキシカルスコープ**
  （実行した時点でなく）関数を定義した時点で決定されるスコープのこと。
  ```ts
  const x = 100;
  function hoge() {
    console.log(x);
  }
  // この位置から変数xは参照できるため、hoge関数の中でxが使える
  hoge(); // 100
  ```
- **ブロックスコープ**
  ブレース`{ }`で囲まれた範囲。ブロックスコープ内で宣言された変数は、そのブロックスコープの外で参照できない。


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
    - JavaScriptの**数値型には、`NaN`と`Infinity`という特殊な値がある**。
      - `NaN (Not-A-Number)` : 処理の結果、数値にならない場合に`NaN`を返す。つまり、数値ではない。**`NaN`かどうかは、`Number.isNaN()`でしか判定できない**。（等号は常にfalseになる。）
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
    - 値が**未定義**であることを表す型。
      下記の状況で現れる。
      - 変数に値がセットされていないとき
      - オブジェクトに存在しないプロパティにアクセスしたとき
      - 配列に存在しないインデックスでアクセスしたとき　等
    - TypeScriptで**戻り値なしを型注釈で表現する場合は、`undefined`でなく`void`を使う**。
    :::message
    ### `void`
    **戻り値が無い関数**を型注釈するときに`void`を使う。
    （普通は関数のみに使い、変数の型注釈には使わない。）
    :::

5. null型 `null`
    - 値がないことを表す型。
    - **`typeof`演算子に`null`を渡すと`"object"`が返るので要注意**。
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
- **`any`型**
  **どんな型でも代入を許す**型。
  つまり、**型のチェックを放棄**した型。

- **`unknown`型**
  **型が何か分からないときに使う**型。
  「型安全なany型」と言われる。
  **unknownの値はそのままでは使えない。型ガードで型を絞り込むと、それ以降はその型として扱える**。

| 項目 | any型 | unknnown型 |
| - | - | - |
| その型への代入 | any型へはどんな値でも代入できる | unknnown型へはどんな値でも代入できる |
| 別の型への代入 | 別の型に代入できる | 別の型に代入できない |
| プロパティへのアクセス<br>メソッド呼び出し | できる | できない |


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


---


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


---


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


## タブル
TypeScriptには**複数の型の値を保持できる型**があり、タプル型という。（配列型とは異なりはするが酷似しており（おそらく）同じように使える。）
```ts
const array: number[] = [1, 2, 3]; // 配列
const tuple: [string, number] = ["hoge", 1]; // タプル
```


## 列挙型 (enum)
enumはJavaScriptには無く、TypeScript独自のもの。
```ts:列挙型
enum UserType {
  student,
  school,
  corporation,
}

console.log(UserType.student); // 0
console.log(UserType.school); // 1
console.log(UserType.corporation); // 2
```
数値列挙型 (numeric enum)もある。メンバーに値を代入でき、それに続くメンバーはそれにも代入をしない限り連番になる。
```ts:数値列挙型
enum UserType {
  student = 10,
  school,
  corporation,
}

console.log(UserType.student); // 10
console.log(UserType.school); // 11
console.log(UserType.corporation); // 12

console.log(UserType[10]); // student
console.log(UserType[11]); // school
```
文字列列挙型 (string enum)もある。
```ts
enum UserType {
  student = "学生",
  school = "学校",
  corporation = "企業",
}

console.log(UserType.student); // 学生
console.log(UserType.school); // 学校
console.log(UserType.corporation); // 企業
```

https://typescriptbook.jp/reference/values-types-variables/enum/enum-problems-and-alternatives-to-enums


## ユニオン型
*いずれか* を表す型。
```ts
type numberOrString: number | string;

type numberOrStringList: (number | string)[]; // 配列の場合
```

ユニオン型の中身を判定するには、if文でtypeofをチェックする方法がある。
```ts
if (typeof numberOrString === "string") {
  // ↑のチェックが無いとエラーになり代入できない
  const comment: string = numberOrString;
}
```

### < 判別可能なユニオン型 (discriminated union) >
ディスクリミネータという、オブジェクト型を判別するためのしるしを持ったユニオン型のこと。
ある型でしか持たないプロパティがある等、通常のユニオン型では実装が面倒な場面で有効。
```ts
type UploadStatus = InProgress | Success | Failure;
// typeプロパティ : ディスクリミネータ
type InProgress = { type: "InProgress"; progress: number};
type Success = { type: "Success" };
type Failure = { type: "Failure"; error: Error };

function printStatus(status: UploadStatus) {
  switch (status.type) {
    case "InProgress":
      console.log(`アップロード中:${status.progress}`);
      break;
    case "Success":
      console.log("アップロード成功");
      break;
    case "Failure":
      console.log(`アップロード失敗:${status.error.message}`);
      break;
    default:
      console.log("不正なステータス", status);
  }
}
```

:::message
#### in演算子
オブジェクトの中に指定したプロパティが存在するかどうか判定する。
```ts
const car = { make: 'Honda', model: 'Accord', year: 1998 };
console.log('make' in car); // true
```
:::


## インターセクション型
ユニオン型（**いずれか**）とは逆で、**いずれも**を示す。
インターセクション型はオブジェクト同士を`&`で列挙する。
```ts
type XY = {
  x: number;
  y: number;
}

type Z = {
  z: number;
}

// インターセクション型
type XYZ = XY & Z;

const p: XYZ = {
  x: 0,
  y: 1,
  z: 2
}
```


## 型エイリアス
型に別名をつけたものを指す。`type`で定義する。
```ts
type StringOrNumber = string | number;
```


## 型アサーション
コンパイラによる型推論でなく、自分でコンパイラに型を伝える方法。
*型アサーションよりも型推論のほうが安全なため、どうしようもないとき以外は使わないこと。*

as構文とアングルブラケット構文があるが、アングルブラケット構文はJSX（HTML風に書けるJSの拡張構文）と見分けがつかない場合があるため、as構文のほうがいい。
```ts
const value: string | number = "this is string";
// as構文
const strLength: number = (value as string).length;
// アングルブラケット構文
const strLength: number = (<string>value).length;
```

## constアサーション
オブジェクトリテラルの末尾に`as const`を記述すると、`readonly`なオブジェクトになる。
（`readonly`はそのプロパティ1つのみ。`as const`はオブジェクトのすべてのプロパティが対象。）
```ts
const user = {
  name: "山田",
  age: 25
} as const;
```


## typeof演算子
値の型を調べることができる。
```ts
console.log( typeof "hoge" ); // string
console.log( typeof undefined ); // undefined
console.log( typeof Symbol() ); // symbol
console.log( typeof { a: 1, b: 2 } ); // object
console.log( typeof (() => {}) ); // function

console.log( typeof null ); // object !!

console.log( typeof [1, 2, 3] ); // object !!
console.log( Array.isArray([1, 2, 3]) ); // true
```

:::message alert
#### null はobject
`typeof null`は`object`なので、「オブジェクトかどうか」判定する際には、その値が「nullでないこと」も判定する必要がある。

#### 配列[] はobject
`typeof []`も`object`なので、配列かどうかを判定するには、専用のメソッド`Array.isArray()`を使う。
:::


## 等価演算子
**基本的には厳密等価演算子`===`を使うこと**。
`null` or `undefined`であることを確認したい場合のみ、`== null`を使う。

```ts
// @ts-ignore
console.log( 0 === "0" ); // false
// @ts-ignore
console.log( 0 == "0" ); // castしてから判定するので、true
```

```ts:== null
const x = null;
console.log( x == null ); // true

const y = undefined;
console.log( y == null ); // true。undefinedも弾きたいときに有用
console.log( y === null ); // false
```

### < NaNの判定 >
`Number.isNaN()`で判定すること。

### < object型、symbol型の判定 >
同じ値であっても、同じ変数を参照しない限り`false`となる。
```ts
// @ts-ignore
console.log({ age: 18 } == { age: 18 }); // 異なる参照なので、false

const obj1 = { age: 18 };
const obj2 = { age: 18 };
const obj3 = obj1;
console.log(obj1 === obj1); // 同じ参照なので、true
console.log(obj1 === obj2); // 異なる参照なので、false
console.log(obj1 === obj3); // 同じ参照なので、true
```

:::message
比較は、**参照**に対して行われる。
:::


## truthyな値、falsyな値
if文などでの判定に使えるのはboolean型だけではなく、**true, falseのような値**を使える。
**falsyな値は限りられていて、それ以外がtruthy**。なので下記のfalsyだけ覚えればいい。
- falsy : `false`, `0`, `NaN`, `""`, `null`, `undefined`


---


## 文

### < if文 >
```ts
if (a % b === 0) {
  // ...
} else if {
  // ...
}
```
```ts:1行ver.
// if文は1行にもできる
if (a % b === 0) { console.log("hoge"); }
```
```ts:unlessは無い
// JSにunlessは無いので、条件を否定したものをifで判定
if (!(a % b === 0)) {
  // ...
}
```
式で条件分岐したい場合は三項演算子しか使えない。
```ts:三項演算子
const result = value === 0 ? "OK" : "NG";
```

### < switch >
**各分岐に`break;`が必要**なので書き忘れに要注意。
```ts
switch (lang) {
  case "js":
  case "ts": // case は連続して記述可能
    console.log("フロント");
    break;
  case "ruby":
  case "java":
    console.log("サーバサイド");
    break;
  default:
    console.log("デフォ");
    break;
}
```

case節の中で変数を定義したい場合、複数のcaseで同じ名前の変数を定義するとエラーになる。
caseを中カッコ`{ }`で囲むと、case毎に変数スコープが作れるので定義できる。
```ts:中カッコあり
switch (lang) {
  case "js": {
    const val = "JS"; // 
    break;
  }
  case "ts": {
    const val = "TS"; // 同じ名前の変数
    break;
  }
}
```

### < 例外処理 >
```ts
try {

  if (word === "何かの処理に失敗") {
    throw new Error("これは例外");
  }
  console.log("通常は行われる処理");

} catch (e: any) {

  // エラーの種類で例外処理を分ける場合はこんな感じでif文で分岐する
  if (e instanceof TypeError) {
    // TypeError に対する処理
  } else if (e instanceof RangeError) {
    // RangeError に対する処理
  } else {
    // ...
  }

} finally {
  // 例外が発生してもしなくても、必ず実行される
}
```

#### never型
「値を持たない」という意味の特別な型。

必ず例外を発生させる関数の戻り値は絶対に取れないため、never型になる。
```ts
function throwError(): never {
  throw new Error();
}
```

### < 制御フロー分析 >
コードが実行されるタイミングでの型の可能性を判断してくれるTypeScriptの機能。

下記のコードの最後の`console.log`が実行できるのは、制御フローにより`val`は`number`であるはずと判断されているため。
```ts
function returnNumber(val: string | number) {
  if (typeof val === "string") { // 型ガード
    console.log(val.length);
    return; // この早期リターンが無いと、下のコードはエラーになる
  }
  
  console.log(val.toString); // numberの場合しか実行できないメソッドを使用
}
```

### < 型ガード >
上記のコードにおける`if (typeof val === "string")`のような、型チェックのコードのこと。

- **typeof**
  指定の型かどうか。
- **instanceof**
  指定したクラスのインスタンスかどうか。
- **in**
  オブジェクトが指定したプロパティを持つかどうか。


## 関数
- 引数の型注釈を省略すると`any`になる。
- 戻り値の型注釈を省略すると、コンパイラがコードから型推論する。
- 関数は値。変数に代入できたりする。
- 関数はオブジェクト。

```ts:関数宣言
function increment(num: number): number {
  return num + 1;
}
```
```ts:関数式
const increment = function (num: number): number {
  return num + 1;
};
```
```ts:アロー関数
// ブロック文体
const increment = (num: number): number => {
  return num + 1;
};

// 簡潔文体 = {}とreturnを省略 (関数内のコードが式1つだけの場合に使用可)
const increment = (num: number): number => num + 1;
```

:::message alert
**アロー関数は引数が1つだけの場合にカッコ`()`が省略できる**が、**その場合は引数と戻り値のどちらも型注釈を書けない**。
```ts:アロー関数　カッコ省略
const increment = num => { // 型注釈できない
  return num + 1;
};
```
:::

### < 関数の型宣言 >
関数の型宣言とは、関数の実装を示さずに、関数のインターフェースを定義すること。
```ts:構文
type 型の名前 = (引数名: 引数の型) => 戻り値の型;
```

`関数式`、`アロー関数`には使えるが、**`関数宣言`の型注釈には使えない**。
```ts:例
type Increment = (num: number) => number;

// 関数式 に適用
const increment: Increment = function (num: number): number {
  return num + 1;
};

// アロー関数 に適用
const increment: Increment = (num: number): number => num + 1;
```

関数の型宣言を使った場合、（実装側の）関数の型注釈は省略できる。（実際は省力形で書くのが一般的）
```ts
const increment: Increment = (num) => num + 1;
```

関数（の実装）から関数の型を宣言できる。（関数→型宣言を抽出するイメージ）
```ts
function increment(num: number): number {
  return num + 1;
}
// typeofで関数から型宣言を抽出
type Increment = typeof increment; // (num: number) => number
```

### < 関数の巻き上げ >
`関数宣言`では巻き上げがあり、`関数式`には巻き上げがない。
```ts
hello();

// 関数宣言 : 呼び出し時点では未定義だが、巻き上げがあるため実行できる
function hello() {
  console.log("hello world!");
}

// 関数式 : 呼び出し時点では未定義なので、実行できない
const hello = function () {
  console.log("hello world!");
};
```

### < 従来の関数 と アロー関数 の違い >
従来の関数（`関数宣言`、`関数式`）とアロー関数には違いがある。

- アロー関数はコールバックが簡潔に書ける。
  :::message
  #### コールバック関数とは
  関数の引数として渡される関数。
  :::
  ```ts
  // 引数のfunction がコールバック関数
  [1, 2, 3].map(function (n) {
    return n + 1;
  });

  // アロー関数はコールバックが簡潔に書ける
  [1, 2, 3].map((n) => n + 1 );
  ```

- thisの指すものが違う。
  従来の関数の`this`が指すものは、定義したときに決定せず、呼び出されたときに決まり、その時々で異なる。
  アロー関数の`this`はレキシカルスコープで静的。定義した時点で決定する。
  （TODO: レキシカルスコープの理解。）

- アロー関数は同じ関数名、引数名を許可しない。
  従来の関数は関数名、引数名が重複していてもエラーにならず実行できてしまっていた。

:::message
### < 値渡しと参照渡し >
#### 値渡し
変数が関数に渡るとき、変数の中身だけ（値）を別の変数にコピーする方式。
関数に渡った変数が変更されても、元の変数は変更されない。（変数同士が別の存在であるため。）

#### 参照渡し
変数が関数に渡るとき、**その変数への参照を渡す**方式。
そのため、関数に渡った変数が変更されると、元の変数も変更される。（変数は1つの存在であるため。）

#### JavaScriptは値渡し
JavaScriptは**基本は値渡し**だが、オブジェクトだけは特殊で、**オブジェクトは参照渡し**になる。
```ts
const x = { n: 1 };
let y = x;

y.n = 2; // プロパティを変更

console.log(x); // { n: 2 }
// → プロパティの変更が反映されている（参照渡し）
```
```ts
const x = { n: 1 };
let y = x;

y = { n: 2 }; // 別のオブジェクトを代入!!
y.n = 3; // プロパティを変更

console.log(x); // { n: 1 }
// → オブジェクトの代入があったことで、yとxは参照関係でなくなった
```
:::

### < オプション引数, デフォルト引数 >
デフォルト引数があると、そのデフォルト値によって型推論が効く。
```ts
// オプション引数
function 関数名(引数名?: 型) { }

// デフォルト引数
function 関数名(引数名: 型 = "デフォルト値") { }

// オプション引数+デフォルト引数
function 関数名(引数名?: 型 = "デフォルト値") { }
```

### < 残余引数（可変長引数） >
引数の数が決まっていない関数を作れる。
受け取った引数は配列になる。
```ts
function func(...params: number[]) {
  console.log(params); // [ 1, 2, 3 ] ← 勝手に配列になる
}
func(1, 2, 3);
```

### < 分割代入引数 >
```ts:オブジェクトの分割代入引数
function foo({ a, b }: { a: number; b: number }) {
  console.log(a, b);
}
foo({ a: 1, b: 2 }); // 1 2
```
```ts:配列の分割代入引数
function bar([a, b]: [number, number]) {
  console.log(a, b);
}
bar([1, 2]); // 1 2
```
```ts:オプション引数+デフォルト引数を使う場合
function foo({ a = 0, b = 0 }: { a?: number, b?: number } = {}) {
  console.log(a, b);
}
foo(); // 0 0
foo({ a: 1 }); // 1 0
foo({ a: 1, b: 2}); // 1 2
```

### < キーワード引数 と OprionsObjectパターン >
JavaScriptにはRubyやPythonにあるキーワード引数が無い。
だが、OprionsObjectパターンを使うことで同じことが実現できる。

```ts:普通の関数
function normal(a: number, b: number, c: number) {
  console.log(a, b, c);
}
// 渡す引数の順番に、a, b, cに代入される
// → 引数の順番をミスできない
normal(1, 2, 3); // 1 2 3
```
```ts:OprionsObjectパターンでキーワード引数を実現
// 引数にオブジェクトを渡す
function optionsObjectPattern({a, b, c}: { a: number, b: number, c: number}) {
  console.log(a, b, c);
}
// 引数の順番は関係ない（= キーワード引数）
optionsObjectPattern({c: 3, b: 2, a: 1 }); // 1 2 3
```

### < 型ガード関数 >
TypeScriptに元々用意されている型ガードとしては`typeof`や`instanceof`があるが、下記のように独自に型ガードを定義できる。
```ts
function isDuck(animal: Animal): animal is Duck {
  // ここがtrueの場合、animalはAnimal型でなく、Duck型と解釈される
  return animal instanceof Duck;
}

if (isDuck(animal)) {
  // ここでは、animalはDuck型 だと解釈される
}
```

### < オーバーロード関数 >
異なる引数+戻り値のパターンがいくつかある関数のこと。
「関数シグネチャ（それぞれのパターンの列挙）」と「その実装」で構成される。
（シグネチャ = 署名。プログラミングにおいては、関数を識別するための情報。）
```ts
// 関数シグネチャ（取りうるパターンをすべて書く）
function hello(person: string): void; // シグネチャ1
function hello(person: string[]): void; // シグネチャ2

// 実装
function hello(person: string | string[]): void {
  // if文で、どのシグネチャなのか（どのパターンか）の判定が必要
  if (typeof person === "string") {
    console.log(`Hello, ${person}`);
  } else {
    console.log(`Hello, ${person.join(",")}`);
  }
}

hello("taro"); // Hello, taro
hello(["taro", "hanako"]); // Hello, taro,hanako
```

---


## Promise / async / await

### < 同期処理と非同期処理 >
プログラム言語のコードの評価方法として、同期処理（sync）と非同期処理（async）に分けられる。
同期処理の場合、ある処理が終わるまでは、次の処理が実行されない。
非同期処理というのは、その処理が終わるのを待たずに次の処理に移る処理。

**同期・非同期のどちらも、（表示の更新なども行う）メインスレッドで処理される**。
これは、JavaScriptが並行処理（concurrent）であるため。（処理を一定の単位ごと処理を切り替えながら実行する。）
（並列処理（parallel）ではない。（複数の処理を同時に実行する。））
そのため、**非同期処理の前に重い処理があると、その非同期処理の実行も遅れる**。（同期処理によって**メインスレッドに待ち行列ができ、非同期処理はその同期処理の後ろに並ぶ**ため。）

### < 非同期処理における例外処理 >
非同期処理では`try...catch`構文を同期処理と同じように使っても例外をキャッチできない。

```ts:例外をキャッチできない
console.log("同期的な処理1");
try {
  setTimeout( () => {
    throw new Error("非同期的なエラー");
  }, 10);
} catch (error) {
  // ここは実行されない
  console.log("例外をキャッチ", error);
}
console.log("同期的な処理2");
```
setTimeoutが実行されるのは、同期処理（例でいうと`console.log("同期的な処理2");`）が終わった後なので、tryが捕捉できる範囲外。
なので、下記のように非同期処理のコールバック関数内で、同期的にキャッチする必要がある。
```ts:例外をキャッチできる
console.log("同期的な処理1");
setTimeout( () => {
  try {
    throw new Error("非同期的なエラー");
  } catch (error) {
    // ここが実行される
    console.log("例外をキャッチ", error);
  }
}, 10);
console.log("同期的な処理2");
```
ただし、この方法では**非同期処理の外からは、非同期処理の中で例外が発生したのかが分からない**。
そのため、**例外が起きたことを外に伝達する必要がある**。

その**非同期処理で発生した例外を扱う方法**として、**主に`Promise`と`Async Function`の2つがある**。

### < Promise >
Promiseは、**非同期処理の状態や結果を表現する**ビルトインオブジェクト。
**Promiseインスタンスに、状態変化（成功/失敗）をしたときに呼び出されるコールバック関数を登録**する。`new Promise((resolve, reject) => { ... }`

#### thenとcatch
**`then`メソッド**には、**第一引数に非同期処理がresolve（成功）時に実行したいコールバック関数**を、**第二引数にreject（失敗）時に実行したいコールバック関数を登録**する。
ただし、どちらも省略することもできる。（下記の例3, 4）

```js:例1 試しに、rejectを考えないでやってみる
function dummyFetch(path) {
  return new Promise( (resolve, reject) => {
    // ひとまず、rejectされた場合のことを考えないで使ってみる
    resolve({ body: `${path}のレスポンス`});
    // → then()の第一引数のコールバック関数（onFulfilled）に渡される
  });
}

dummyFetch("/success/data").then(function onFulfilled(response) {
  console.log(response); // { body: '/success/dataのレスポンス' }
}, function onRejected(error) {
  // ここには絶対に入ってこない
  console.log(error);
});
```

```js:例2 resolve状態, reject状態が起こり得る
function dummyFetch(path) {
  return new Promise( (resolve, reject) => {
    setTimeout( () => {
      if (path.startsWith("/success")) {
        // resolve（成功）状態のPromiseオブジェクトを返す
        resolve({ body: `${path}のレスポンス`});
      } else {
        // reject（失敗）状態のPromiseオブジェクトを返す
        reject(new Error("NOT FOUNT"));
      }
    }, 1000);
  });
}

dummyFetch("/success/data").then(function onFulfilled(response) {
  console.log(response); // 実行され、{ body: '/success/dataのレスポンス' } と出力される
}, function onRejected(error) {
  console.log(error);
});

dummyFetch("/failure/data").then(function onFulfilled(response) {
  console.log(response);
}, function onRejected(error) {
  console.log(error); // 実行され、Error: NOT FOUNT と出力される
});
```

```js:例3 resolve時のコールバック関数だけ登録する
function delay(timeoutMs) {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve();
    }, timeoutMs);
  });
}

delay(10).then(() => {
  console.log("10ms後に呼ばれる");
});
```
```js:例4 reject時のコールバック関数だけ登録する
function delay(timeoutMs) {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      reject();
    }, timeoutMs);
  });
}

// 非推奨（thenの第一引数はundefinedで殺して、第二引数だけ登録する方法）
delay(10).then(undefined, () => {
  console.log("失敗! 10ms後に呼ばれる");
});

// 推奨（thenでなくcatchを使う）
delay(10).catch(() => {
  console.log("失敗! 10ms後に呼ばれる");
});
```

#### Promiseと例外
Promise内で例外が発生すると、失敗時と同じコールバック関数（`then`の第二引数や、`catch`で登録したコールバック）が呼ばれる。
そのため、Promise内では`try...catch`しなくていい。

#### Promiseの状態
Promiseインスタンスには、内部的に次の3つの状態がある。
（内部的な話なので、状態を目で見て確認することはできない。）
- **Pending**
  `new Promise`でインスタンスを生成したときの初期状態。`Fulfilled`でも`Rejected`でもない状態。
- **Fulfilled**
  `resolve`（成功）した状態。
- **Rejected**
  `reject`（失敗） or 例外が発生 した状態。

`Fulfilled`と`Rejected`は不変な状態（Settled）なので、その状態になると、以降状態は変化しない。

**同期的な処理が行われた後**に、非同期なタイミングで`then`メソッドのコールバック関数が実行される。
```js
const promise = Promise.resolve(100); // new Promiseしてresolve()を登録するコードのシンタックスシュガー
promise.then(v => {
  console.log(v);
})
console.log(20);
// 出力結果
// 20
// 100
```
```js
const promise = new Promise((resolve) => {
  console.log("1. resolveします");
  resolve();
});
promise.then(() => {
  console.log("3. コールバック関数が実行されました");
});
console.log("2. 同期的な処理が実行されました");
// 出力結果
// 1. resolveします
// 2. 同期的な処理が実行されました
// 3. コールバック関数が実行されました
```

#### Promiseチェーン
Promiseに`then`や`catch`メソッドを繋いで、成功時や失敗時の処理を書いていくことをPromiseチェーンと言う。
```js
function asyncTask() {
  return Math.random() > 0.5
    ? Promise.resolve("成功") 
    : Promise.reject(new Error("失敗"));
}

asyncTask()
  .then((value) => {
    // この処理が実行されるとき、catch()は処理されない
    console.log(value); // 成功
  })
  .catch((error) => {
    // この処理が実行されるとき、then()は処理されない
    console.log(error); // Error: 失敗
  });
```

#### Promiseチェーンで値を返す
Promiseチェーンでは、コールバックで返した値を次のコールバックへ引数として渡せる。
```js
Promise.resolve(1)
  .then((v) => {
    console.log("1番目: ", v); // 1番目:  1
    return v * 2;
  })
  .then((v) => {
    console.log("2番目: ", v); // 2番目:  2
  })
  .then((v) => {
    // 直前のthen()で値をreturnしていないので、undefined
    console.log("3番目: ", v); // 3番目:  undefined
  });
```
```ts
async function take3Sec(): Promise<string> {
  return "3秒かかる";
}
async function take5Sec(): Promise<number> {
  return 1;
}

const tuple: [string, number] = await Promise.all([
  take3Sec(), // 返り値はstring
  take5Sec(), // 返り値はnumber
]);
// ↓
// 2つの関数の呼び出し順序を入れ替えたい
// → この場合、タプルの定義もその順序に入れ替える必要がある
//   [string, number] → [number, string]
const tuple: [number, string] = await Promise.all([
  take5Sec(), // 入れ替えた
  take3Sec(),
]);
```


---


## オブジェクト指向

### < クラス >
- クラスはオブジェクト。

```ts
// クラス定義
class Person {
  // フィールド
  name: string;
  age: number | undefined; // コンストラクタで定義していないので、undefinedの可能性がある
  type: string = "ヒト科"; // stringなのは自明なため、型注釈の省略も可能

  // コンストラクタ
  constructor(name: string) {
    this.name = name;
  }

  // メソッド
  someMethod(name: string): string {
    return `Hello, ${name}!`;
  }
}

// インスタンス生成
const person: Person = new Person("太郎");
console.log(person.name); // 太郎

person.age = 27;
console.log(person.age); // 27

console.log(person.someMethod("花子")); // Hello, 花子!

console.log(person.type); // ヒト科
```

#### アクセス修飾子

| アクセス修飾子 | 説明 | 用途 |
| - | - | - |
| (宣言なし) | publicと同じ | - |
| public | どこからでもアクセス可 | - |
| protected | 自身のクラスとサブクラス（子クラス）からのみアクセス可 | インスタンスからはアクセス禁止にする場合。<br>詳細の実装はサブクラスに任せる場合。 |
| private | 自身のクラスからのみアクセス可 | メソッドを切り分けて自身のクラスの中でのみ呼び出す場合。 |

#### readonly修飾子
そのフィールドを読み取り専用にできる。

#### 静的フィールド (static)
通常のフィールドはインスタンスのプロパティだが、静的フィールドは**クラスのプロパティ**。（*Rubyでいうところのクラス変数みたいなもの*。）
`static`で宣言する。
```ts
class Person {
  // type: string = "ヒト科";
  public static type: string = "ヒト科";
}

// const person: Person = new Person();
// console.log(person.type); // personインスタンスに対してアクセス

console.log(Person.type); // Personクラスに対してアクセス
```

#### 静的メソッド
*Rubyでいうところのクラスメソッド*。
`static`で宣言する。

#### メソッド戻り値のthis と メソッドチェーン
メソッドの戻り値にthisを指定することで、メソッドチェーンが実現できる。
```ts
class Operator {
  protected value: number;
  public constructor(value: number) {
    this.value = value;
  }

  // 加算
  // public sum(value: number): void { // voidを返すこのメソッドではメソッドチェーンにできない
  //   this.value += value;
  // }
  public sum(value: number): this { // 戻り値にthisを指定することでメソッドチェーンにできる
    this.value += value;
    return this;
  }

  // 減算
  // public subtract(value: number): void {
  //   this.value -= value;
  // }
  public subtract(value: number): this {
    this.value -= value;
    return this;
  }

  // 乗算
  // public multiply(value: number): void {
  //   this.value *= value;
  // }
  public multiply(value: number): this {
    this.value *= value;
    return this;
  }

  // 除算
  // public divide(value: number): void {
  //   this.value /= value;
  // }
  public divide(value: number): this {
    this.value /= value;
    return this;
  }
}

const op: Operator = new Operator(0);

// メソッドの戻り値がthisでなくvoidだったときは、下記のように演算ごとに1行ずつ書かないといけない。
// op.sum(5); // 5
// op.subtract(3); // 2
// op.multiply(6); // 12
// op.divide(3); // 4

// メソッドチェーンが実現
op.sum(5).subtract(3).multiply(6).divide(3);
console.log(op); // Operator { value: 4 }

// サブクラス（子クラス）
class NewOperator extends Operator {
  public constructor(value: number) {
    super(value);
  }

  // べき乗
  public power(value: number): this {
    this.value **= value;
    return this;
  }
}

const newOp: NewOperator = new NewOperator(2);
// メソッドの返り値を具体的なクラス名でなくthisにすることで、サブクラスにおいても同じようにメソッドチェーンで繋げることができる
newOp.power(3).multiply(2).power(3);
console.log(newOp); // NewOperator { value: 4096 }
```

#### クラスの継承
- 上のコード（NewOperatorクラス）にもあるように、`extends`で継承ができる。

- サブクラス（子クラス）に**コンストラクタを書く場合**は、**スーパークラス（親クラス）のコンストラクタを必ず呼び出す必要がある**。
  `super()`でスーパークラスのコンストラクタを呼び出す。
  ```ts
  class NewOperator extends Operator {
    public constructor(value: number) {
      super(value);
    }
    // ... 略
  ```

- `instanceof`で継承関係のチェックができる。
  ```ts
  class Parent {}
  class Child extends Parent {}

  const parent = new Parent();
  const child = new Child();

  console.log(parent instanceof Parent); // true
  console.log(parent instanceof Child); // false

  console.log(child instanceof Parent); // true → 子クラスのインスタンスだがtrueになる
  console.log(child instanceof Child); // true
  ```

#### 抽象クラス (abstract class)
- 抽象クラスとは、**直接インスタンスを作れないクラス**のこと。
  つまり、**必ずスーパークラス（親クラス）として利用されることが保証される**。

- JavaScriptでは定義できないが、TypeScriptではクラスに`abstract`修飾子を付けることで実現できる。

- メソッドにも`abstract`を付けて抽象メソッドを作れる。
  **`interface`と同じく、サブクラス（子クラス）は抽象メソッドを実装する必要がある**。

```ts
// 抽象クラス
abstract class Food {
  // 抽象メソッド
  abstract canEat(): boolean;
}

class Meat extends Food {
  // 抽象メソッドの実装
  canEat(): boolean {
    return true;
  }
}
```


### < インターフェース >
- インターフェースとは、**クラスが実装すべきフィールドやメソッドを定義**した型。
　(ちなみに、クラスだけでなく、単なるオブジェクトにも型注釈として適用できる。)
- JavaScriptには無い。
- インターフェースを別のインターフェースに継承できる。

```ts
interface Human {
  name: string;
  think(): void;
}

interface Programmer {
  writeCode(): void;
}

class Developer implements Human, Programmer {
  name: string = "太郎";

  think(): void {
    console.log("どういう実装にしようかな");
  }

  writeCode(): void {
    console.log("カタカタ");
  }
}
```

#### インターフェースと型エイリアスの使い分け
どちらが良いとかでは無い。
下表のように異なる点があるので、プロジェクト内でルールを決めて遵守すること。

| 内容 | インターフェース | 型エイリアス |
| :-: | - | - |
|継承 | 可能 | 不可。ただし交差型で表現は可能 |
| 継承による上書き | 上書きまたはエラー | フィールド毎に交差型が計算される |
| 同名のものを宣言 | 定義がマージされる | エラー |
| Mapped Types | 使用不可 | 使用可能 |


---


## 組み込みAPI
JavaScriptに組み込まれているAPI。

### < Map >
連想配列。RubyでいうところのHash。
```ts:使い方（基本）
// 型注釈は省略しても、型推論してくれるのでOK
const map = new Map<string, number>([
  ["a", 1],
  ["b", 2]
]);
console.log(map); // Map(2) { 'a' => 1, 'b' => 2 }

// 取得
console.log(map.get("a")); // 1
// 追加
map.set("c", 3);
console.log(map); // Map(3) { 'a' => 1, 'b' => 2, 'c' => 3 }
// 削除
map.delete("c");
console.log(map); // Map(2) { 'a' => 1, 'b' => 2 }
// 存在確認
console.log(map.has("a")); // true
console.log(map.has("c")); // false
// 要素数
console.log(map.size); // 2
// 全keyを取得
console.log(map.keys()); // [Map Iterator] { 'a', 'b' }
console.log([...map.keys()]); // [ 'a', 'b' ]
// 全valueを取得
console.log(map.values()); // [Map Iterator] { 1, 2 }
console.log([...map.values()]); // [ 1, 2 ]
// keyとvalueの全セットを取得
console.log([...map.entries()]); // [ [ 'a', 1 ], [ 'b', 2 ] ]
```

JSON化するには、一度オブジェクトに変換しないといけない。（Map→オブジェクト→JSON）
```ts:JSON化
const obj = Object.fromEntries(map);
console.log(JSON.stringify(obj)); // {"a":1,"b":2}
```


### < Set >
値の重複を許さない配列。

メソッドに関してはほぼ`Map`と同じ。
```ts
const set = new Set(["a", "b", "a"]);
console.log(set); // Set(2) { 'a', 'b' }

// 追加
set.add("c");
console.log(set); // Set(3) { 'a', 'b', 'c' }

// 配列化
const array = [...set];
console.log(array); // [ 'a', 'b', 'c' ]
```


### < RegExp >
正規表現のためのクラス。

2つの記法があるが、基本的にリテラルで良い。
（動的に検索ワードを切り替える場合はコンストラクタが良い。が、バックスラッシュ`\`1文字を検索したいとき、`\\\\`と4文字書く必要がある。これが個人的に嫌。）
1. リテラルでの表記
2. コンストラクタを利用した表記

また、一致した文字列を取得する方法も2つあるが、ほぼ同じ。
1. RegExpの`exec()`を使う。
2. Stringの`match()`を使う。

```ts
// 1. リテラルでの表記
const regexp2 = new RegExp("0(8|9)0-\\d{4}-\\d{4}", "g");

// 2. コンストラクタを利用した表記
const regexp2 = new RegExp("0(8|9)0-\\d{4}-\\d{4}", "g"); // \が多く必要

// 一致したかどうか
console.log(regexp1.test("080-1234-1234")); // true
console.log(regexp1.test("080-12-12")); // false

// 一致した文字列を取得
// 1. RegExpの exec() を使う。
const result_exec = regexp1.exec("080-1234-1234");
console.log(result_exec);
// [
//   '080-1234-1234',
//   '8',
//   index: 0,
//   input: '080-1234-1234-11',
//   groups: undefined
// ]

// 2. Stringの match() を使う。
const result_match = "080-1234-1234".match(regexp1);
console.log(result_match);
// [ '080-1234-1234' ]
```


---


## import/export、require/exports
`import`や`export`を1つ以上含むファイルを、モジュールと言う。（無いものは、スクリプト。）
importで他のモジュールから変数・関数・クラスなどを取り込み、exportで公開する。

モジュール設定の記載方法には2種類ある。（JSの仕様はこういうのがあるからややこしい。）
1. `import`, `export`を使う方法
  ESMAScriptの仕様（ES Module）。比較的新しい記法。主にフロントエンドJSで使われる。
2. `require`, `exports`を使う方法
  CommonJSの仕様。Node.jsではこちらが使われる。

:::message
ブラウザ用であればES Moduleを、サーバー用であればCommonJSが無難な選択肢。
:::

CommonJSの記法（2.）だけ記載する。
```ts:util.ts
exports.increment = (i: number) => i + 1;
exports.decrement = (i: number) => i - 1;
```
```ts:main.ts
const util = require("./increment");
console.log( util.increment(2) ); // 3
console.log( util.decrement(2) ); // 1
```


---


## シングルプロセス・シングルスレッドとコールバック
JavaScriptは**シングルプロセス、シングルスレッド**の言語。
つまり、プログラムは**直列に処理される**。
（シングルスレッドなので、コールスタック（次の命令の情報などが格納されている場所）も1つ。）

https://knowledge.sakura.ad.jp/24148/
https://resanaplaza.com/%E3%80%90%E7%B0%A1%E5%8D%98%E8%A7%A3%E8%AA%AC%E3%80%91%E4%B8%80%E7%9B%AE%E3%81%A7%E5%88%86%E3%81%8B%E3%82%8B%E3%83%97%E3%83%AD%E3%82%BB%E3%82%B9%E3%80%81%E3%82%BF%E3%82%B9%E3%82%AF%E3%80%81%E3%82%B9/

「直列に処理される」ということは、時間のかかる処理を行っている間、他の処理が実行されないということ。（ブロッキングという。）
:::message
- ブロッキング = 同期
- ノンブロッキング ≒ 非同期 （少し違う）

https://blog.takanabe.tokyo/2015/03/%E3%83%8E%E3%83%B3%E3%83%96%E3%83%AD%E3%83%83%E3%82%AD%E3%83%B3%E3%82%B0i/o%E3%81%A8%E9%9D%9E%E5%90%8C%E6%9C%9Fi/o%E3%81%AE%E9%81%95%E3%81%84%E3%82%92%E7%90%86%E8%A7%A3%E3%81%99%E3%82%8B/
https://penpen-dev.com/blog/burokkinngu/
:::

Node.jsはノンブロッキングを扱える。
```ts:ノンブロッキングの例
console.log("first");

setTimeout(() => {
  console.log("second");
}, 1000);

console.log("third");
// first
// third
// second
```
:::message
setTimeoutは、`setTimeout(関数, 時間[ms])`なので、第一引数に渡しているのは関数。（今回はアロー関数で書いている。）
こういう、**他の関数に渡される関数**のことを、**コールバック関数**という。

コールバック関数の中でコールバック関数を使い、その中でもコールバック関数を使い、...ということをやるとコールバック地獄になる。
:::


---


## 型の再利用

### < typeof型演算子 >
**変数から型を抽出**する型演算子。
（値の型を調べる`typeof演算子`とは全く別のものなので注意。）

```ts
const point = { x: 135, y: 40};
type Point = typeof point;
// 下記のような型が生成される
// type Point = {
//   x: number;
//   y: number;
// }
```

### < keyof型演算子 >
**オブジェクトからプロパティ名を型として抽出**する型演算子。
```ts
type Person = {
  name: string;
  age: number;
};
type PersonKey = keyof Person;
// type PersonKey = "name" | "age"; と同じ
```

### < ユーティリティ型 >
**型から別の型を導出**する型。
（*型の世界の関数* のようなイメージ。）

#### Required<T>
任意のプロパティを表す`?`を取り除くユーティリティ型。（全て必須にする。）
```ts
type Person = {
  name: string;
  address?: string;
  tel?: number;
}
type FullPropatyPerson = Required<Person>;
// type FullPropatyPerson = {
//   name: string;
//   address: string;
//   tel: number;
// }
```

#### Readonly<T>
読み取り専用になる。

#### Partial<T>
全てのプロパティを任意（オプショナル）にする。
```ts
type Person = {
  name: string;
  address?: string;
  tel?: number;
}
type OptionalPropatyPerson = Partial<Person>;
// type OptionalPropatyPerson = {
//   name?: string | undefined;
//   address?: string | undefined;
//   tel?: number | undefined;
// }
```

##### [ Partialを用いたOptions Objectパターン ]
Partialを応用して、余分な引数の指定を省略可能な使いやすい関数を実装できる。

<例>
下記のように、ageだけを指定してユーザを検索・取得するfindUser関数を使う際に、ageより前の引数にはundefinedを指定しないといけない。
```ts
type User = {
  name: string;
  tel?: string;
  address: string;
  age?: number;
}

function findUsers(
  name?: string,
  tel?: string,
  address?: string,
  age?: number
) {
  // ...
}

findUsers(undefined, undefined, undefined, 22);
```

Partialを使い、任意に指定可能な引数用オブジェクトを作成。
これをfindUsers関数の引数に指定することで、上記の問題が解消され、使いやすい関数になる。
```ts
type FindUsersArgs = Partial<User>;

function findUsers({
  name,
  tel,
  address,
  age,
}: FindUsersArgs) {
  // ...
}

findUsers({}); // 殻のオブジェクトを渡さないといけない
findUsers({ age: 22 });
```

（何も指定せずにuserを検索するとき、空のオブジェクトを渡さないといけないようになっている。これは、下記のようにデフォルト引数を使うことで解消できる。）
```ts
function findUsers({
  name,
  tel,
  address,
  age,
}: FindUsersArgs = {}) {
  // ...
}

findUsers();
findUsers({ age: 22 });
```

#### Record<Keys, Type>
プロパティの*キー*が`Keys`で、プロパティの*値*が`Type`となるオブジェクトを作るための型。
```ts
type Person = Record<"firstName" | "middleName" | "lastName", string>;
const person: Person = {
  firstName: "Robert",
  middleName: "Cecil",
  lastName: "Martin"
}
```

#### Pick<T, Keys>
既存の**オブジェクト型**`T`から、`Keys`に**指定したキーだけの型**を生成するユーティリティ型。
（指定したものだけpickする。）

<例>
ユーザーのアカウントとなるUserというオブジェクトが必要だが、実際にユーザーが登録時に入力するのは`名前`と`住所（任意）`で良い場合、Pick型が役に立つ。

```ts:悪い例
// id, createdAt, updatedAtは、システム内で自動生成される
type User = {
  id: number;
  name: string;
  address?: string;
  createdAt: Date;
  updatedAt: Date;
}

// 登録時にユーザーが入力する値
// → Userのnameやaddressの型に変更が入った場合、UserInputDataにも変更の手入れが必要
type UserInputData = {
  name: string;
  address?: string;
}
```
```ts:良い例
type UserInputData = Pick<User, "name" | "address">
```

#### Omit<T, Keys>
既存の**オブジェクト型**`T`から、`Keys`に**指定したキーを除外**した型を生成するユーティリティ型。
（指定したものだけomit（省略）する。）

#### Exclude<T, U>
既存の**ユニオン型**`T`から、`U`に**指定したキーを除外した型**を生成するユーティリティ型。
（`Pick`のユニオン型ver.）

#### Extract<T, U>
既存の**ユニオン型**`T`から、`U`に**指定したキーだけの型**を生成するユーティリティ型。
（`Omit`のユニオン型ver.）

#### Mapped Types
インデックス型ではキーを自由に設定できてしまうため、アクセス時にundefinedかどうかチェックする必要がある。
Mapped Typesで、オブジェクトに設定できるプロパティを指定できるため、それを解消できる。

Mapped Typesは`{ [P in K]: T }`のように記述する。
『オブジェクトの**プロパティPは型K**で、**値は型T**』ということ。

すでに定義されているUnion型やオブジェクトのキーを再利用（マップ）して新しい型を定義するため、Mapped Typesという名前がつけられている。
```ts
type SystemSupportLanguage = "en" | "jp" | "fr" | "it";
type Butterfly = {
  [key in SystemSupportLanguage]: string;
};

const Butterflies: Butterfly = {
  en: "Butterfly",
  jp: "蝶",
  de: "hoge" // SystemSupportLanguage（ユニオン型）に含まれていないため、エラーになり設定できない
}
```

https://nishinatoshiharu.com/mapped-types-overview/

#### インデックスアクセス型
プロパティの値の型や、配列の要素の型を参照する。

```ts
type Person = { name: string, age: number};

type PersonDataType = Person["name" | "age"];
// type PersonDataType = string | number
```
```ts:keyofを使う方法
type PersonDataType = Person[keyof Person];
```


---


## ジェネリクス
型も引数のように扱うことで、型の安全性とコードの共通化を両立する。
`T`という**型変数**を使う。

```ts:改善前のコード
// 渡された2つの文字列の中からランダムに一方を返す
function chooseRandomlySrting(v1: string, v2: string): string {
  return Math.random() <= 0.5 ? v1 : v2;
}
const winOrLose = chooseRandomlySrting("勝ち", "負け");

// 渡された2つの数値の中からランダムに一方を返す
// → chooseRandomlySrting()に対して、型だけが異なる
function chooseRandomlyNumber(v1: number, v2: number): number {
  return Math.random() <= 0.5 ? v1 : v2;
}
```
上の2つの関数を共通化しようとすると、関数の引数・返り値の型を`any`にすればできるが、型の安全性が失われる。

そこで、ジェネリクスを使うと下記のように解決する。
```ts:ジェネリクスによる改善後
function chooseRandomly<T>(v1: T, v2: T): T {
  return Math.random() <= 0.5 ? v1 : v2;
}
console.log( chooseRandomly<string>("勝ち", "負け") );
console.log( chooseRandomly<number>(0, 1) );
```

### < 型引数の制約 >
型引数にはどんな型でも指定できるため、下記のコードはエラーになる。
（型引数`element`の型によっては`style`というプロパティが存在しないため。）
```ts:エラー発生
function changeBackGroudColor<T>(element: T) {
  element.style.backgroundColor = "red"; // styleにアクセスできないためエラー発生している
  return element;
}
```

そこで、**`extends`キーワードで型引数に制約をつける**ことで解消できる。
```ts
function changeBackGroudColor<T extends HTMLElement>(element: T) {
  element.style.backgroundColor = "red";
  return element;
}
```

また、`<T extends 型 = デフォルト型>`と書けば、デフォルト型引数を設定できる。


---


## Tips

### < オブジェクトを浅くコピーする >
```ts:オブジェクト
const sample = { a: 1, b: 1 };
const shallowCopied: object = { ...sample } // sampleと同じ中身のオブジェクトになる { a: 1, b: 1 }

console.log(sample == shallowCopied); // だが、等しくない（別の空間にあるため）
```

```ts:配列
const arr1 = [1, 2, 3];
const arr2 = [...arr1]; // [ 1, 2, 3 ]
```

```ts:Map
const map1 = new Map([
  [".js", "JS"],
  [".ts", "TS"],
]);
const map2 = new Map(map1);
```

```ts:Set
const set1 = new Set([1, 2, 3]);
const set2 = new Set(set1);
```

### < オブジェクトをマージ（結合）する >
```ts
const obj1 = { a: 1 };
const obj2 = { b: 2 };
const obj3 = { c: 3 };
const merged = {
  ...obj1,
  ...obj2,
  ...obj3
}; // { a: 1, b: 2, c: 3 }
```

### < オブジェクトのサブセット（一部を切り取ったもの）を得る >
即時関数・分割代入・shorthand property nameの合わせ技で、下記のように書ける。
（別の方法として、lodashというライブラリを使う方法もある。）
```ts
const user = {
  name: "田中",
  age: 22,
  tel: "00-1234-1234",
  prefecture: "東京都",
  city: "千代田区",
  address: "丸の内1-2-3",
  createdAt: "2022-01-01",
  updatedAt: "2022-01-01"
}

// userの住所に関する情報だけを取得
const userAddress = ( ({prefecture, city, address}) => ({prefecture, city, address}))(user);
console.log(userAddress);
// { prefecture: '東京都', city: '千代田区', address: '丸の内1-2-3' }

// userの住所に関する情報 以外を取得
const excludeUserAddress = ( ({prefecture, city, address, ...rest}) => rest)(user);
console.log(excludeUserAddress);
// {
//   name: '田中',
//   age: 22,
//   tel: '00-1234-1234',
//   createdAt: '2022-01-01',
//   updatedAt: '2022-01-01'
// }
```

### < オブジェクトで受け、オブジェクトで返す >
```ts:改善前
function findUser(
  name?: string,
  age?: number,
  country?: string
): User {
  if (age && age >= 20) {
    // ... (検索ロジック)
  } else {}
}
```

関数の引数にオブジェクトを渡すようにする。
```ts
type UserInfo = {
  name?: string;
  age?: number;
  country?: string;
}

function findUser(info: UserInfo): User {
  if (info.age && info.age >= 20) {
    // ... (検索ロジック)
  } else {}
}
```
https://zenn.dev/itoo/articles/refactorilng-ruby#10.9-%E5%BC%95%E6%95%B0%E3%82%AA%E3%83%96%E3%82%B8%E3%82%A7%E3%82%AF%E3%83%88%E3%81%AE%E5%B0%8E%E5%85%A5

```ts:（応用）名前だけの検索を行う場合
function findUserByName({ name }: UserInfo): User {
  // ... (nameを使った検索ロジック)
}

```

---


# プログラム問題でよく使うもの

:::details 標準入力を受け取る
  ## 標準入力を受け取る
  パターン1は長すぎる。パターン2で良い。
  ```js:javascript パターン1
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
  ```js:javascript パターン2
  function Main(input) {
    console.log(input);
  }

  Main(require("fs").readFileSync("/dev/stdin", "utf8"));
  ```

  ### 標準入力を文字列→整数に変換する
  (例 : `5 2 4` → `[5, 2, 4]`)
  ```js
  const input = lines[0].split(' ').map(str => (parseInt(str, 10)) );
  ```
:::

:::details ループ
  ## ループ
  forはできるだけ使わないようにする。https://qiita.com/diescake/items/70d9b0cbd4e3d5cc6fce

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
:::

:::details 配列
  ## 連番の配列を作る
  ```js
  const arr = Array.from({ length: 5 }).map( (v, k) => k+1); // [1, 2, 3, 4, 5]
  ```

  ## 配列の中の数値を合計
  ```js
  const sum = nums_array.reduce( (sum, i) => sum + i, 0);

  // 入力値までの総和が欲しい場合（num=10の場合、1+2+3+... = 55）
  const sum = [...Array(num)].reduce(function(sum, _, i) {
      return sum + i + 1 
    } , 0);
  ```

  ## 配列の中の数値の最大値、最小値を取得
  ```js
  Math.min(...array)
  ```
:::

:::details ソート
  ## ソート
  **Array#sort()は文字列比較による辞書順でソートするので注意!!**
  なので、異なる桁数の数値のsortは、期待する結果にならない。
  `[3, 2, 1, 10, 100].sort()`は、`[1, 10, 100, 2, 3]`になってしまう。

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


# 参考文献
https://typescriptbook.jp/

### < 便利そうなのでインデックスしておくページ >
https://typescriptbook.jp/symbols-and-keywords