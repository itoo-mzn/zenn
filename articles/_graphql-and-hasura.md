---
title: "GraphQL, Hasura 技術要点メモ"
emoji: "🤖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["GraphQL", "Hasura"]
published: false
---


# GraphQL

## <仕様>
- HTTPリクエストはすべてPOST
- HTTPレスポンスはすべて200OK
  - errorにエラーメッセージが入るため、errorがnullかどうかでハンドリングする。
  - すべて200なので、HTTPステータスコードでヘルスチェックするモニタリングとは相性✕

- 操作の種類（operation type）
  - query
  - mutation
  - subscription

## <スキーマ (schema)>
GraphQL APIの仕様を表現するもの。

`.graphql`ファイルに、SDL（スキーマ定義言語）で記述する。（[.graphql**s**ファイルのほうが良いらしい？](https://maku.blog/p/5s5jvfz/)）

```graphql:xx.graphql
# オブジェクト型
type Book {
  id: ID!
  name: String
  pageCount: Int
  author: Author
}

# Query
type Query {
  books: [Book!]!
  book(id: ID!): Book
}

# Mutation
type Mutation {
  createBook(title: String!): Book
  deleteBook(id: String!): Boolean!
}
```

## <リゾルバ (resolver)>
スキーマは型情報だけを定義しているが、リゾルバはその具体的な実装。
特定のフィールドのデータを操作・返却する関数（メソッド）。

プログラミング言語で記述する。

例えば、こういうスキーマがあった場合には、
```graphql:xxx.graphql
type Query {
  quoteOfTheDay: String
  random: Float!
}
```
こういうリゾルバを開発者の手で作る必要がある。
（本来は。→ 後述の`Hasura`は基本的なものを自動生成してくれる。）
```ts:xxx.ts
quoteOfTheDay: () => {
  return Math.random() < 0.5 ? "Take it easy" : "Salvation lies within";
},
//random: Float! をスキーマで定義
random: () => {
  return Math.random();
}
```

## <GraphQL Code Generator>
GraphQLのスキーマから自動的に型を生成してくれます。

例えばtypescriptを使う場合は下記。
```
.graphqlファイル → (codegen) → xxx.ts（出力先に設定した）ファイル 
```


## <参考記事>
https://speakerdeck.com/sonatard/graphql-knowhow?slide=10
https://speakerdeck.com/yukukotani/graphql-schema-design-practice
https://reffect.co.jp/html/graphql


---


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

*TODO*
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

例えば、「リクエスト内のidが`X-Hasura-User-Id`と一致している場合、userのupdateを許可する」等。

### 認証
認可を行う上で、まず認証が必要。
Hasura自体に認証機構はなく、Auth0やFirebaseなどを利用することになる。

:::message
#### Auth0
認証・認可のサービス。
（Auth0 Inc.は、そのサービスを提供している認証プロバイダ）

https://qiita.com/furuth/items/68c3caa3127cbf4f6b77
https://ssaits.jp/promapedia/technology/auth0.html
:::

#### 処理の流れ
HasuraがAuth0などの認証プロバイダと通信してJWTを取得。
そのJWTに含まれている、Auth0から設定したデータ（カスタムクレーム）をHasuraがGraphQLオペレーション実行時に読む。
（Hasuraのコンソールで設定した）ルールに則って、その操作が実行できるかどうか決まる。

*TODO: カスタムクレームの理解。よく分かってない*

例えば、下記のような全ユーザの名前をコメントを取得するQueryが発行されたとしても、`"user_id": { "_eq": "X-Hasura-User-Id" }`の条件がQueryに埋め込まれるため、他のユーザーのデータが参照されることはないといった感じ。
```
query Users {
  users {
    name
    comments {
      content
    }
  }
}
```

:::message
#### JWT
JSON Web Token。
認証用のトークンとして利用される。

https://qiita.com/knaot0/items/8427918564400968bd2b
:::

#### アカウント登録の実装
アカウント登録（サインアップ）時には、userテーブルにINSERTするような設定を行うことになる。
そういった場合、カスタムJWTクレームのルールを設定し、認証時に得られるJWTにroleやuser_idの情報が格納されるようにしたりと、諸々の事前準備が必要。


## <ビジネスロジック>
*TODO: おいおいキャッチアップする。下記がキーワード*
- Hasura Remote Schema
- Hasura Action


## <参考記事>
https://blog.uzumaki-inc.jp/hasuragraphqlspa
https://qiita.com/sho-hata/items/2dbd41be42662007071e
https://qiita.com/maaz118/items/9e198ea91ad8fc624491


以上