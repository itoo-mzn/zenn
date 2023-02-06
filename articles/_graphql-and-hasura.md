---
title: "GraphQL, Hasura 技術要点メモ"
emoji: "🤖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GraphQL", "Hasura"]
published: false
---

# GraphQL
## 仕様
- HTTPリクエストはすべてPOST
- HTTPレスポンスはすべて200OK
  - errorにエラーメッセージが入るため、errorがnullかどうかでハンドリングする。
  - すべて200なので、HTTPステータスコードでヘルスチェックするモニタリングとは相性✕

スキーマ
キャッシング
フラグメント

codegen
`graphql-code-generator`
GraphQLのスキーマから自動的に型を生成してくれます。

## 参考記事
https://speakerdeck.com/sonatard/graphql-knowhow?slide=10
https://speakerdeck.com/yukukotani/graphql-schema-design-practice


# Hasura
- Hasura (Hasura GraphQL Engine) とは、クライアントとDBをつなぐ**GraphQLサーバ**を簡単に構築できるツール。
  （REST APIも作れる）
  ```
  client <- (GraphQL) -> Hasura server <- (SQL) -> PostgreSQL server
  ```

- 基本的なCRUDのGraphQLリゾルバ、および集計用リゾルバ(`aggregate`)やupsert mutationも自動生成してくれる。
  （N+1も気にしなくていいらしい。）
  `where`, `order_by`, `limit`, `offset` といった条件句と `max`, `count`, `avg` といった集計がデフォルトで可能。

- GraphQLオペレーションが直接SQLに変換される。そのSQLと実行計画をhasuraコンソールから見ることができる。

:::message
GraphQLリゾルバ (resolver) とは、
スキーマ (schema) とは
:::

## <使用方法>
ざっくりだが、下記。
1. 実際に使う前にはクラウド上 (Hasura Cloud等) にデプロイする必要がある。（ローカルではlocalhost）
2. Hasura管理画面上でテーブルやリレーションを作成したり、権限を設定したり...。
3. codegenでクライアントコードを生成。

## <メタデータ>
Hasuraでは、下記の情報をメタデータとして管理している。
- マイグレーション履歴
- テーブル・カラムごとの権限（認可）
- Hasura Action　　等


## <認証・認可>
### 認可
roleという単位で、データに対するCRUDの制御ができる。（認可されたroleでないとアクセスできないデータ 等を設定できる。）

### 認証
認可を行う上で、まず認証が必要。
Hasura自体に認証機構はなく、Auth0やFirebaseなどを利用することになる。


JWT
カスタムクレーム

HasuraがAuth0などの認証プロバイダと通信して JWT を取得。その JWT に含まれた Auth0 から設定したデータを Hasura がGraphQLオペレーション実行時に読むことができ、Hasura のコンソールでルールを決めます。
JWT に埋め込んだ X-Hasura-User-Id を使って自分のデータだけを取得するといったルールが設定できます。

このルールが適用されたときに、

query Users {
  users {
    name
    comments {
      content
    }
  }
}
のような全ユーザの名前をコメントを取得するような Query が発行されたとしても "user_id": { "_eq": "X-Hasura-User-Id" } の条件が Query に埋め込まれるために他のユーザーのデータが参照されることはないといった感じです。

アカウント登録（サインアップ）や*認証完了時（？）*にuserテーブルにINSERTするような設定を行うことになる。

#### JWT
JSON Web Token。
認証用のトークンとして利用される。

https://qiita.com/knaot0/items/8427918564400968bd2b

#### Auth0
認証・認可のサービス。
（Auth0 Inc.は、そのサービスを提供している認証プロバイダ）

https://qiita.com/furuth/items/68c3caa3127cbf4f6b77
https://ssaits.jp/promapedia/technology/auth0.html

## <ビジネスロジック>
Hasura Remote Schema
Hasura Action


## 参考記事
https://blog.uzumaki-inc.jp/hasuragraphqlspa
https://qiita.com/sho-hata/items/2dbd41be42662007071e
https://qiita.com/maaz118/items/9e198ea91ad8fc624491