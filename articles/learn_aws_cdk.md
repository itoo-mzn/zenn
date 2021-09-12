---
title: "AWS CDK"
emoji: "🐙"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

# AWS CDKとは
AWS Cloud Development Kit (AWS CDK)

AWSのリソースをTypescriptやPython等のコードで定義するフレームワーク。
コードで定義したリソースがCloudFormationテンプレートに変換され、デプロイされる。

CDK の対応言語は以下の５つです。(2020年5月現在)
- Typescript
- JavaScript
- Python
- Java
- C#

# 手順

## 参考資料
基本的には、公式のチュートリアルを参考にする。
https://cdkworkshop.com/15-prerequisites/200-account.html

随時、下記も確認。
https://dev.classmethod.jp/articles/aws-cdk-101-typescript/

## IAMユーザーを作成
1. 管理者ユーザでAWSアカウントにサインイン
2. IAMコンソールに移動して 新しいユーザーを作成
3. ユーザーの名前を入力（cdk-workshop）
4. 権限を設定。(既存のポリシーを直接添付する → AdministratorAccess)
5. 資格情報を設定(profile名もcdk-workshopにした)
```
aws configure --profile cdk-workshop

AWS Access Key ID [None]: <type key ID here>
AWS Secret Access Key [None]: <type access key>
Default region name [None]: <choose region (ap-notrheast-3 = 大阪にしてみた)>
Default output format [None]: <leave blank>
```
profileが追加されているか確認(AWS CLIのprofileを確認)
```
cat ~/.aws/credentials
```

## 前提環境確認
nodeは10.13.0以上でないといけない。
```
node --version
v16.3.0
```

Typesctiptを使えるか。
```
tsc --v
Version 4.3.5
```

cdkコマンドが使えるか。
```
cdk --version
1.117.0 (build 0047c98)
```

ディレクトリ作成。(cdk-sample)
```
mkdir cdk-sample
```

## 初期化
雛形を作成。
```
cdk init --language typescript
```

## コンパイル
TypeScriptはJavaScriptにコンパイルする必要があるため、ソースファイルに変更を加えるたびに、それらをにコンパイルする必要がある。
そのために、新しいターミナルのタブを開いて、`watch`を実行する。
（新しいタブで開くのは、バックグラウンドでずっと動いてほしいため）
```
npm run watch

Starting compilation in watch mode...
Found 0 errors. Watching for file changes.
```

# 主要ファイル
### lib/cdk-workshop-stack.ts
主要なファイル。CDKアプリケーションのメインスタックを定義。
### bin/cdk-workshop.ts
CDKアプリケーションのエントリポイント。
`lib/cdk-workshop-stack.ts`で定義されたスタックをロード。
### cdk.json
アプリの実行方法をツールキットに指示。

# コマンド（動作確認）
## cdk synth
`lib/cdk-workshop-stack.ts`にサンプル実装して、`cdk synth`を実行。
しかしエラー発生のため、下記のようにnpx経由で実行した。

:::message
npxを使うとローカル(node_modules\.bin)にインストールされたパッケージをパスを指定せずに実行できる。
:::

:::message alert
そもそも使うpackageをyarn addしていなかったので、そこも以後気をつける。
:::

```
cdk synth

This CDK CLI is not compatible with the CDK library used by your application. Please upgrade the CLI to the latest version.
(Cloud assembly schema version mismatch: Maximum schema version supported is 13.0.0, but found 14.0.0)
```

```
yarn global upgrade aws-cdk@latest
(これは必要かは不明)

npm install -g npx
npx cdk synth
```

## cdk bootstrap
`cdk bootstrap`: AWSアカウント、リージョン単位で一度だけ実行するコマンド。
CDKで利用するリソースを置いておくS3バケットを作成してくれる。
```
npx cdk bootstrap --profile cdk-workshop
```
:::message alert
メモ：エラー発生して格闘していたが、`~/.aws/config`の中でスペルミスしていただけだった。
:::

## cdk deploy
```
npx cdk deploy --profile cdk-workshop
```
リソースがAWS上に作成され、コンソール画面の CloudFormation にて、リソースタブを開くと作成されたリソースが確認できた。

## cdk diff
```
npx cdk diff --profile cdk-workshop
```

# AWS Lamdaリソースを作る
1. `lamda`ディレクトリを作り、hello.jsを作成。
実行したい関数を定義。
```js:lambda/hello.js
// "Hello"を返却するLambda関数
exports.handler = async function (event) {
  console.log("request: ", JSON.stringify(event, undefined, 2));
  return {
    statusCode: 200,
    headers: { "Content-Type": "text/plain" },
    body: `Hello, CDK! You've hit ${event.path}\m`
  }
}
```
2. AWSコンストラクトライブラリをインストール。

#### AWSコンストラクトライブラリ
AWSサービスごとに1つずつ、モジュールに分割されているライブラリ。
たとえば、AWS Lambda関数を定義する場合は、AWSLambdaコンストラクトライブラリを使用する。
```
yarn add @aws-cdk/aws-lambda
```
3. lib/cdk-sample-stack.tsに追加したいリソースを定義。
AWSLambda関数をスタックに追加。
```ts:lib/cdk-sample-stack.ts
import * as cdk from '@aws-cdk/core';
import * as lambda from '@aws-cdk/aws-lambda';

export class CdkSampleStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Lamdaリソースをスタックに追加
    const hello = new lambda.Function(this, 'HelloHandler', {
      runtime: lambda.Runtime.NODEJS_14_X, // 実行環境
      code: lambda.Code.fromAsset('lambda'), // lamdaディレクトリのコードを読み込む
      handler: 'hello.handler' // "hello"ファイルの"handler"関数を実行する
    });
  }
}
```