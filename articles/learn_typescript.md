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


# js/tsファイル実行方法

## jsファイル実行方法
```bash
node increment.js
```
## tsファイル実行方法
tsファイルの実行は、下記2通りある。
- `tsc`コマンドでコンパイルしてts→jsに変換してから、`node`コマンドでjsファイルを実行する
- `yarn ts-node`でコンパイルと実行を1回で済ます。
:::message alert
2つ目の方法がよく理解できていないので、後で調べる。
:::


# TypeScriptのコンパイル

コンパイルするコマンドは`tsc`。
```bash
tsc increment_typescript.ts
```

:::message
コンパイルすると、同じ名前のjsファイルが自動生成される。
（今回はincrement_typescript.jsファイルが自動で追加された。）

この（コンパイル後の）jsファイルには型注釈が無い。

**型注釈があるとブラウザやNode.jsでは実行できない**ため、**コンパイラが生成したjsファイルを成果物として、本番環境にデプロイすることになる**。
:::


# 文法

- TypeScriptでは文末のセミコロンが省略できる。

## シングルクォート、ダブルクォート、バッククォートについて
`シングルクォート`と`ダブルクォート`は機能上の違いが無い。
`バッククォート`はテンプレートリテラルと言い、文字列リテラルとは仕様が異なる。
しかし、単純な文字列では、この3つは同じ意味になる。


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

### <shareable config>
公式ドキュメントのルールは下記。
https://eslint.org/docs/latest/rules/
だが、ルールの数があまりにも多いので、それをひとつひとる調べるのは大変。そこで、**shareable config**という誰かが作ったルールセットを使うのがオススメ。

`eslint-config-airbnb-base`や`eslint-config-google`が有名。

### <ルールを部分的に無効化する>
部分的にルールを無効にするには、その行の前にコメント`eslint-disable-next-line`を追加。
```js
// eslint-disable-next-line camelcase
export const hello_world = "Hello World";
```

# 参考情報
https://typescriptbook.jp/