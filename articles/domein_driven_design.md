---
title: "ドメイン駆動設計入門"
emoji: "🐶"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["ドメイン駆動設計", "DDD"]
published: false
---

# 書籍
https://www.shoeisha.co.jp/book/detail/9784798150727

この書籍は、ドメイン駆動設計において重要な`モデリング`、`パターン`の内、**パターンを重点的に説明している**。
パターンを理解することで、モデリングを含めたドメイン駆動設計という大きなテーマを理解する準備ができる。

- **モデリング** : ソフトウェアにとって重要な概念を抽出するためのもの。
- **パターン** : 概念を実装に落とし込むためのもの。

:::message
**知識は連鎖する。**
:::

# 目的
本書を読む理由は、[エリック・エヴァンスのドメイン駆動設計](https://www.shoeisha.co.jp/book/detail/9784798126708)を理解・読破するため。
難解だと聞いたため、いきなり挑む前に本書でドメイン駆動設計の基本を理解することを目的としている。

# Gitリポジトリ
本書に登場するJavaのコードの**一部**を、「Rubyで表現してみる」「動かして理解する」ためのコードを置いています。
https://github.com/ito0804takuya/domein-driven-design

# ドメイン駆動設計とは
## ドメイン駆動設計のコンセプト
ビジネスの問題を解決するためにビジネスの理解を進め、ビジネスの表現をする。
**ビジネスとコードを結びつけて**、継続的な改良ができるように枠組みを作ることで、ソフトウェアをより役立つものにする。

## ドメインとは
ドメインとは**プログラムを適用する対象となる領域**のこと。 (ドメインの和訳 = *領域*)

重要なのは、ドメインとは何か でなく、ドメインに含まれるものが何なのか。
つまり、**システムで問題を解決する上で重要な知識は何か。**

## モデル、モデリングとは
モデルとは、現実の事象や概念を抽象化した概念。
抽象とは、抽出して象る(かたどる)ため、現実を忠実に再現しない。

では何を抽出したらいいのか？
例えば、物流システムにおいて、トラックは`貨物を運ぶもの`と表現すればいい。
`キーを回すとエンジンが動く`ということは不要。

**モデリング**とは、こういうように**事象・概念を抽象化する作業**のことを言う。
モデリングをした結果得られる結果がモデル。
(ドメイン駆動設計では、ドメインの概念をモデリングして得られたモデルをドメインモデルと言う。)

## ドメインオブジェクトとは
ドメインオブジェクトとは、**ドメインモデルをソフトウエアで動くモジュールとして表現（実装）したもの。**

ドメインで起こった変化は、ドメインモデルを媒介として、ドメインオブジェクトに伝えられる（変更される）。
`ドメインの概念 ⇔ ドメインモデル ⇔ ドメインオブジェクト`

# 値オブジェクト
システム固有の値を表現するために定義したオブジェクト。

## なぜ値オブジェクトを使うのか
システムで必要な処理にしたがって、**システムならではの値の表現があるため(それを表現するため)**。

#### 具体例 : 名前
例えば名前の姓を表現するとき、プリミティブな値では、色々な国の人の名前を表現することが難しい。
*※ プリミティブ : intやstringなど、言語が元々用意してくれている型のこと。*
```ruby:プリミティブな値
fullname = "山田 太郎"
lastname = fullname.split(' ')[0] # 姓
p lastname # 山田

fullname = "john smith"
lastname = fullname.split(' ')[0] # 姓
p lastname # 姓はsmithなのに、johnと出力されてしまう
```

```ruby:値オブジェクト
class Fullname
  attr_accessor :firstname, :lastname

  def initialize(firstname:, lastname:)
    @firstname, @lastname = firstname, lastname
  end
end

fullname = Fullname.new(firstname: "太郎", lastname: "山田")
p fullname.lastname # 山田

fullname = Fullname.new(firstname: "john", lastname: "smith")
p fullname.lastname # smith
```

## どこまで値オブジェクトにするか
例えば、上では`名前(姓名)`はオブジェクトにしたが、`姓`と`名`は別々のオブジェクトにすべきか？
→それはシステムによって異なる。
:::message
#### 値オブジェクトにするか（値クラスを作るか）どうかを判断する基準
1. **そこにルールが存在するか**
2. **それ単体で扱うことがあるか**
:::

## 値オブジェクトを使うモチベーション
### 1. 表現力が増す
**定義したクラスを見ることで、その値オブジェクトがどういったものであるかが分かる**。
(= **自己文書化**される。)

また、**独自の振る舞いを定義できる**。
### 2. 不正な値を存在させない
クラス内でバリデーションを設けることができるため、システム内に不正な値が存在しない。
(値オブジェクトにしない場合、使用する箇所すべてで不正な値でないかチェックしないといけなく、1箇所でも修正されないと**破綻**が起きる。）
### 3. 誤った代入を防ぐ
```ruby
class User
  attr_accessor :id

  def self.create_user(name)
    user = User.new()
    user.id = name # 正しい代入?
    user
  end
end

user = User.create_user("田中")
```
このコードで、`id`に`name`が代入されていることは、正しいのか分からない。
(システムによっては、名前がidになっている可能性も捨てきれないため。)
UserIdオブジェクトを`id`プロパティに定義していれば、何が代入されるべきかが明確に分かる。

(Rubyでは3.0以降でRBS(Rubyの型定義のための言語)を使えば、IDEで型エラーを見つけれれるはず。)
### 4. ロジックの散在を防ぐ
ルールをクラス内でまとめることができる。

:::message
**ドメイン駆動設計によってドメインの知識をコードに落とし込むことで、コードがドキュメントとして機能し始める。**
:::


# エンティティ
ドメイン駆動設計における`エンティティ`とは、**同一性(identity)で区別される**ドメインオブジェクト。
※ ER図やORMで登場するエンティティとは別の概念。

これとは反対に、属性によって区別されるのが`値オブジェクト`。

## 同一性とは
値オブジェクトは、**等価性**によって区別するため、属性が同じであれば全く同じものとして扱うが、
エンティティは、属性が同じでも区別される。

###### < 例: ユーザの名前(姓名) >
- 値オブジェクトの場合は、ユーザの名前が同じなら、同じ人物として見なす。
  (現実的にはそうでないのに、そう見なしてしまう)
- エンティティの場合は、ユーザの名前が同じでも、別の人物として見なす。

では、エンティティは何で区別するのか。それが識別子(identifier = ID)。

逆に、識別子が同じなら、名前が変更されてもそれは同じ人物である。

## エンティティの判断基準
値オブジェクトとエンティティはドメインの概念を表現するオブジェクトとして似通っている。
(値オブジェクトでなく)エンティティにすべきと判断する基準は下記。
:::message
**判断基準 : ライフサイクルが存在し、そこに連続性があるかどうか**
:::
###### < 例: ユーザ >
システム上の`ユーザ`という概念は、作成されて生を受けて、削除されて死を迎える。
→ ライフサイクルが存在し、連続性があるため、エンティティとして表現すべき。

(当然、同じ概念を指していても、システムによっては値オブジェクトorエンティティにすべきかというのは異なってくる。)


# ドメインオブジェクトを定義するメリット
(値オブジェクトとエンティティはいずれもドメインオブジェクト)

## 1. コードのドキュメント性が高まる
例えば、`ユーザの名前は3文字以上でなければいけない`というルール(仕様)がある場合、
ドメインオブジェクトとして定義していれば、クラス内にバリデーションとして存在するため、新たにジョインした開発者でも、**コードを手がかりにルール(仕様)が把握できる**。

逆に、ドメインオブジェクトにしていない場合、更新されているかも分からないドキュメントを頼りにしないといけない。(ドキュメントが誤っていても、コードは動く)

## 2. ドメインにおける変更をコードに伝えやすくなる
例えば、`ユーザの名前は3文字以上でなければいけない`というルールが`6文字以上`というように変更された場合(ドメインに変更があった場合)、ドメインオブジェクトとして定義していれば、**クラス内で1箇所を修正すればいい**。
(ドメインオブジェクトにルールや振る舞いが定義されているため。)

逆に、ドメインオブジェクトにしていない場合、クラスとして定義していないため、散在する文字数チェック箇所をすべて探し出して修正しないといけない。


# ドメインサービス
**値オブジェクトやエンティティに記述すると不自然になる振る舞いを解決する**オブジェクト。
複数のドメインオブジェクト間を横断するような操作に多く見られる。

:::message
重要なのは、**不自然な振る舞いに限定**すること。
:::

## 不自然な振る舞いとは
例えば、ユーザの名前は重複してはいけないという要件があるとする。
`ユーザに関する関心事はUserクラスに`と単に考えてコード(下記)を書くと、ユーザが自分自身に`重複していない？`と聞くことになる。

```ruby:不自然な振る舞い
class User
  attr_accessor :name

  def initialize(name:)
    @name = name
  end

  def exists?(user:)
    # 重複を確認するコード
  end
end

user = User.new(name: '山田')
is_duplicate = user.exists?(user) # 自分自身に問い合わせている
```

```ruby:ドメインサービス
class User
  attr_accessor :name

  def initialize(name:)
    @name = name
  end
end

class UserService
  def exists?(user:)
    # 重複を確認するコード
  end
end

user = User.new(name: '山田')
user_service = UserService.new
is_duplicate = user_service.exists?(user) # UserServiceに問い合わせる
```

## ドメインモデル貧血症とは
本来ドメインモデルに記述されるべき知識や振る舞いが、ドメインサービスやアプリケーションサービスに記述され、語るべきことを語っていないドメインオブジェクトの状態。

オブジェクト指向設計の`データと振る舞いをまとめる`という基本戦略の**真逆**をいくもの。

<!-- 01.ドメインモデル貧血症！というコード例 -->
```ruby
class User
  attr_accessor :name

  def initialize(name:)
    @name = name
  end
end

class UserService
  def exists?(user:)
    # 重複を確認するコード
  end

  # このメソッドはUserクラスにあるべき
  def change_user_name(name:)
    # ユーザの名前を変更するコード
  end
end
```

:::message
振る舞いを`値オブジェクトやエンティティ`か、`ドメインサービス`に定義するべきか迷ったら、
`値オブジェクトやエンティティ`に定義すること。
**可能限り、ドメインサービスは利用しない**。
:::

## Railsでは (余談)
Railsではサービスを使わないため、Railsは思想が異なるのか？と思い調べてみたところ、こんな記述があった。

> テーブルとActiveRecordモデルが一対一の関係にあるため、例えばUserに関するデータ・振る舞い(CRUD操作も含む)・制約などがActiveRecordのUserモデルに集約されがち。
( https://ryota21silva.hatenablog.com/entry/2021/09/12/153120 )

つまり、**モデルに何もかも書き過ぎてしまう傾向になりやすい**ため、モデルの肥大化に注意してコーディングしないといけない。


# リポジトリ
データを永続化・再構築する処理を抽象的に扱うためのオブジェクト。（リポジトリの和訳 : 保管庫）

(オブジェクトの)インスタンスを保存するとき、データストアに書き込む処理を直接実行するのでなく、リポジトリに依頼する。
（永続化したデータからインスタンスを再構築したいときも同様。）

## 利用例
以下のコードではデータを保存・検索する処理を直接記述しているため、本来の目的（何をしたいのか）がぼやける。

```ruby:リポジトリ利用前
require 'mysql2'

class User
  attr_accessor :name

  def initialize(name:)
    @name = name
  end
end

class UserService
  def exists?(user:)
    connection = Mysql2::Client.new(host: '127.0.0.1', username: '', password: '', encoding: 'utf8',
      database: 'sample')
    sql = "SELECT * FROM users WHERE name = #{user.name}"
    result = connection.query(sql)
    connection.close

    # 以下、重複を確認するコード (略)
  end
end

# main
user = User.new(name: "山田")
user_service = UserService.new

raise StandardError.new("#{user.name}は既に存在しています。") if user_service.exists?(user: user)

# 以降、DBへの保存処理
connection = Mysql2::Client.new(host: '127.0.0.1', username: '', password: '', encoding: 'utf8',
                                database: 'sample')
sql = "INSERT INTO users (name) VALUES (#{name});"
connection.query(sql)
connection.close
```

データの保存・検索といったDBへの操作は、リポジトリに任せることで、本来やりたい処理の趣旨が際立つ。（= 意図を示す）
```ruby:リポジトリ利用
require 'mysql2'

class User
  attr_accessor :name

  def initialize(name:)
    @name = name
  end
end

class UserService
  def exists?(user:)
    user_repository = UserRepository.new
    user_repository.find(user.name)
  end
end

class UserRepository
  def save(object)
    # 保存処理
  end

  def find(name)
    # 重複確認処理
  end
end

# main
user = User.new(name: "山田")
user_service = UserService.new

raise StandardError.new("#{user.name}は既に存在しています。") if user_service.exists?(user: user)

# 以降、DBへの保存処理
user_repository = UserRepository.new
user_repository.save(user)
```

↑のコードは生のRubyで書いたが、今はORMを使うことが大半。
（生で書いたことが無かったので、勉強になった。やっぱりORMのほうが手軽に書ける。）

# アプリケーションサービス
**ドメインオブジェクトを操作し、利用者の目的(ユースケース)を達成する**ように導くオブジェクト。

:::message
ドメインのルールは、アプリケーションサービスに記述しないこと。

**ドメインの知識はドメインオブジェクト(or ドメインサービス)に記述し、アプリケーションサービスがドメインオブジェクトを利用する**ように仕立てる。
:::

- サービス
  - **ドメインサービス**
    ドメインの知識を表現する。
    （例：ユーザ名の重複確認）
  - **アプリケーションサービス**
    アプリケーションを成り立たせるための操作を行う。
    （例：ユーザの登録処理、退会処理）

```ruby
# ドメインオブジェクト
class User
  attr_accessor :name

  def initialize(name:)
    @name = name
  end
end

# リポジトリ
class UserRepository
  def save(object)
    # 保存処理
  end
end

# アプリケーションサービス
class UserApplicationService
  def register(name:)
    user = User.new(name: name)
    user_repository = UserRepository.new
    user_repository.save(user)
  end
end
```

# 依存関係のコントロール
依存とは、依存先のオブジェクトが無くなると成り立たない状態。

###### < 例 >
例えば、上のコードでは`UserApplicationService`は`UserRepository`に依存している。

オブジェクト同士の依存は避けられないもの。避けるのでなく、コントロールする。

:::message
**抽象に依存すると、ビジネスロジックをより純粋なものに昇華できる**。その抽象を色々な具象に差し替えることができるため。
:::
（下記の記事にも書いた内容。）
> 「自身よりも変更されないもの」に依存すること

https://zenn.dev/itoo/articles/object-oriented_design#%E4%BE%9D%E5%AD%98%E6%96%B9%E5%90%91%E3%81%AE%E7%AE%A1%E7%90%86

## 依存関係逆転の原則
1. **上位レベルのモジュールは、下位レベルのモジュールに依存してはいけない。どちらのモジュールも抽象に依存すべき。**
( レベル = 入出力からの距離。)
2. **抽象 は 実装の詳細 に依存してはいけない。実装の詳細 が 抽象 に依存すべき。**

###### < 例 >
先程の例では、`UserApplicationService`は`UserRepository`に依存している。
`UserRepository`のほうが(より機械に近い)具体的な処理を行っているため、下位レベル。
`UserApplicationService`はそれよりは上位のレベルなので、原則に反している。

そこで、**`UserRepository`の抽象**を作り、2つのモジュールはそれに依存させる。（原則1が解決）

また、`UserRepositoryの抽象`は、`UserApplicationService`のために存在することになり、その抽象によって`UserRepository`は具体的に実装される。（原則2が解決）

:::message
**主体となるべきは、重要なドメインの知識が含まれている高レベルなモジュール。**

低レベルのモジュールの変更によって高レベルの変更が起きるべきでない。
（例：データストアの変更を理由に、ビジネスロジックが変更される。）

**高レベルのモジュールはクライアントとして、低レベルのモジュールを呼び出す。**
:::

:::message alert
Rubyには抽象クラスや抽象インターフェースの概念がないため、依存性(依存オブジェクト)の注入が使える。
https://techracho.bpsinc.jp/hachi8833/2019_05_09/62314
:::

## 依存性の注入
オブジェクト内に依存関係を記述する（クラス内で他のインスタンスを生成する）のではなく、外部からオブジェクトを注入する。

（下記の記事にも書いたので詳細は割愛。）
https://zenn.dev/itoo/articles/object-oriented_design#%E7%96%8E%E7%B5%90%E5%90%88%E3%81%AA%E3%82%B3%E3%83%BC%E3%83%89%E3%82%92%E6%9B%B8%E3%81%8F

# ファクトリ
**複雑なオブジェクトの生成処理**を責務とするオブジェクト。
ファクトリを使って生成処理をカプセル化することで、コードの論点が明確になる。

コンストラクタは単純であるべき。
コンストラクタが単純でなくなるときは、ファクトリを定義する。

```ruby:ファクトリ使用前
class User
  attr_accessor :id, :name

  def initialize(name:)
    @name = name
    
    # 重複していないIDをDBから取得するためのコード
    # connection = Mysql2::Client.new(...)
    # id = ...

    @id = id
  end

  # インスタンスを再構築
  def rebuild_user(id:, name:)
    @id = id
    @name = name
  end
end
```
```ruby:ファクトリ使用後
class UserFactoryInterface
  def create(name:)
    # サブクラスにcreateメソッドの実装を強制させるコード
  end

end

class UserFactory < UserFactoryInterface
  def create(name:)
    # 重複していないIDをDBから取得するためのコード
    # connection = Mysql2::Client.new(...)
    # id = ...
    User.new(id: id, name: name)
  end
end

class User
  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end

  # 不要になった（コンストラクタが1つになった）
  # def rebuild_user(id:, name:)
  #   @id = id
  #   @name = name
  # end
end

class UserApplicationService
  def register
    user_factory = UserFactory.new
    user = user_factory.create(name: name)
    
    # 略 (UserRepositoryを使って保存)
  end
end

# ------------------------------------------------------

# 開発時の検証用にメモリ上で動かしたい場合、このファクトリに切り替えるだけでよい
class InMemoryUserFactory < UserFactoryInterface
  @@current_id = 0

  def create(name:)
    # テスト用にメモリ上で動かす
    current_id += 1
    User.new(id: current_id, name: name)
  end
end
```

# 整合性
データの整合性を保つための手段として2つの手段がある。
1. ユニークキー制約
2. トランザクション

## ユニークキー制約
ユニークキー制約を設定さえすれば良いのではない。
コードを見て、データに重複が許されないというドメインの重大なルールが読み取れないため。
ユニークキー制約は主体でなく、セーフティネットとして併用して活用すべき。
:::message
ビジネスロジックが技術基盤に依存するべきでない。
:::

## トランザクション
トランザクションを使うとき、データがどこまでロックされるかは常に念頭に置く必要がある。
ロックは可能な限り小さくすべき。（処理が失敗する可能性を下げるため）
一度のトランザクションで保存するオブジェクトを1つに限定し、さらにそのオブジェクトをなるべく小さくする。

# アプリケーションを組み立てるフロー
1. 要求に対して必要な機能を考える。
2. 機能を成立させるために必要なユースケースを洗い出す。
3. ユースケースを実現するために必要な概念とそこに存在するルールから、アプリケーションが必要とする知識を選び出し、ドメインオブジェクトを準備する。
4. ドメインオブジェクトを用いて、ユースケースを実現するアプリケーションサービスを実装する。

###### < 例 >
1. 同じ趣味をもつユーザ同士で交流したい。そのためにサークル機能を作る。
2. ユースケースとして、サークルの作成、サークルへの参加が考えられる。
3. サークル名は3文字以上、20文字以下。サークル名は重複してはいけない。サークルの人数は30人までというルールがある。サークルはライフサイクルがあるオブジェクトなのでエンティティ。
4. サークルオブジェクトを使って実装する。

# 集約

<!-- TODO: 02.ドメインモデルに拘るとどんな現実的な問題がでてくるのか？ -->
<!-- クラスのフィールド(DBのカラム)ごとに値オブジェクトやエンティティを生成することになり、値オブジェクトやエンティティまみれになってしまう...？ User.new(UserId, UserName, ...) -->