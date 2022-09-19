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

# 参考情報
https://typescriptbook.jp/