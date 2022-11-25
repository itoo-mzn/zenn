---
title: "Railsのアセットパイプライン"
emoji: "📌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Rails"]
published: false
---

# Railsのアセットパイプライン

## アセットとは
アセットとはスタイルシートやJavaScriptなどのリソースのこと。

## パイプラインとは
アセットを次々に一連の処理が施される仕組みです。

## アセットパイプライン(Asset Pipeline)とは
JavaScriptやCSSを最小化や圧縮して連結するフレームワークです。
(画像はしない。)

<!-- ここどっちが正しいか不明 -->
Rails6から、Sprocketsに代わってWebpack（er）がRailsアプリケーションでJavaScriptを書くための新しい標準となりました。
(RailsにはSprocketsも同梱されています。SprocketsもWebpackerと同様のアセットパッケージングツールで、Webpackerと機能が重複しています。)

特徴としては下記です。
- ファイルのミニファイ : スペースや改行を詰めてサイズを減らすこと。
- ファイルの結合 : あるページに5ファイル必要であれば、通常は5回に渡りファイルを取得します。当然5回分はサーバに負担はかかり、通信帯域も埋めます。これを5ファイルを1つに結合してしまえば、その分パフォーマンスは向上します。
- ファイルの変換 : CoffeeScriptやSassへの変換。
これらをデプロイ前に事前に処理（プリコンパイル）します。

マニフェスト毎に集めたアセット群から1つのマスターファイルを作成する。
(マニフェストファイルが2個あれば、マスターファイルは2つ作成されます。)

### マニフェストファイルとは
マニフェストとはロードするアセットの集まりであり、マニフェストファイルとはそのマニフェストが書かれたファイルです。
マニフェストファイルにはアセットの一覧となるマニフェストが書かれており、マニフェストの表現にディレクティブ（命令）を使います。

### アセットパイプラインの全体フローを知る
(例) アセットパイプラインを使って複数のスタイルシートから1つのスタイルシートがロードされるまでの流れ

1. application.scss内のディレクティブに沿ってファイルをロード
  ロード対象の検索先は`app/assets/stylesheets`です。
  デフォルトファイルapplication.scssは自身の位置するフォルダ配下のアセットを対象としたマニフェストが書かれている。
  そのため、Controllerを作成すればスタイルシートはapp/assets/stylesheetsフォルダ配下に作成されますが、マニフェストの対象となっているため、自動でマスターファイル(application.css)に結合されます。
2. ロードしたファイルをコンパイル
3. マスターファイルとなるapplication.cssにコンパイル済みファイルを結合
  <!-- 具体的にどうなるのかわからん。 -->
4. マスターファイルをapplication.html.hamlからロードする

本番環境の場合はコンパイル処理は事前に実施(プリコンパイル)され、`public/assets`フォルダに配置されます。

### 自動コンパイル
- 開発環境では、ファイルのロード時に動的でコンパイルされます。これは開発中にアセットが変更されても、自動でコンパイルするので開発しやすいです。
- 本番環境ではコンパイルはOFFにされており、事前にアセットのコンパイル(プリコンパイル)が必要です。
```ruby
config.assets.compile = true
```

本番環境用にマスターファイルを作成するには、rails assets:precompileタスクを使います。
```sh
$ RAILS_ENV=production bin/rails assets:precompile
```
プリコンパイルされたファイルはpublic/assetsに展開され、publicディレクトリ同様に静的ファイルとして扱われます。

### フィンガープリントでキャッシュ制御
キャッシュが有効な場合、マスターファイルにはフィンガープリントでキャッシュ制御が必要です。
なぜなら、キャッシュはパスで管理されるが、アセットに変更が加わってもマスターファイルのパスは変わらないので、キャッシュ有効と誤って判断されます。

そのため、**プリコンパイルするたびにファイル名にフィンガープリントが付与されます**。
フィンガープリントは、ファイルの内容が変わると変わる。

## Babel
すべてのブラウザがES6を理解できるとは限らないため、ES6のJavaScriptがどんなブラウザでも動くようにするには、ES6のJavaScriptコードを読み取って旧来のES5 JavaScriptに変換するツールが必要になります。Babelはそのための変換を行うコンパイラです。


# Webpack

# Webpacker
アセットファイルはassetsディレクトリ
Webpackerでビルドされたファイルの出力先であるpacks


app
  - assets
    - config
      - manifest.js
    - images
    - javascripts
    - stylesheets

- public
  - assets
  - css
  - images
  - js
  - portal
  - recruit
  - shared
  - system

config/webpacker.yml
  source_path: app/webpacker
  source_entry_path: packs
  public_root_path: public
  public_output_path: assets/pack
  cache_path: tmp/cache/webpacker
config/

# dev_server
https://webpack.js.org/configuration/dev-server/


# asset_sync
asset_syncを利用してCloudFront + S3からアセットファイルを配信
S3に配置されるアセットファイルはassetsディレクトリのみで、Webpackerでビルドされたファイルの出力先であるpacksは含まれていません。

asset_syncを導入すると**assets:precompile実行後にアセットファイルの同期処理が走ります**。
その結果、プロジェクトに存在するアセットファイルが外部リソースに配置されます。

しかし、『assets:precompile』後に行われる同期対象のファイルはSprocketsのビルド出力先（public/assets/）のみで、Webpackerのビルド出力先（public/packs/）は対象外です。

今のcmapは、
ファルダ → S3
`app/assets/stylesheets` → 
`app/webpacker/packs` → 
`public/assets` → ?

新cmap.devは、
ファルダ → S3
`app/assets/stylesheets` → 
`app/webpacker/packs` → 
`public/assets` → s3には無い or `assets`にちゃんとsyncされている

public/assets/smart_phone/title_activity-54d4a58a65bdeb4b231296fe0adc51005246a94db8ca823023c1efbae98d57e8.png
↓
assets/smart_phone/title_activity-54d4a58a65bdeb4b231296fe0adc51005246a94db8ca823023c1efbae98d57e8.png



# s3
## アクセス許可
### オブジェクト所有者
他の AWS アカウントからこのバケットに書き込まれたオブジェクトの所有権と、アクセスコントロールリスト (ACL) の使用を管理します。
オブジェクトの所有権は、オブジェクトへのアクセスを指定できるユーザーを決定します。



# 参考サイト
https://blog.mothule.com/ruby/rails/ruby-rails-assets-pipeline-use
https://numb86-tech.hatenablog.com/entry/2018/11/10/002439
https://techracho.bpsinc.jp/hachi8833/2021_05_13/85940
https://railsguides.jp/webpacker.html
https://zenn.dev/ysi831/books/66ba06d6a4a1d4/viewer/2e0c7f