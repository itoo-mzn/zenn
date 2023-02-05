---
title: "GoFのデザインパターンをcmapに適用してみる"
emoji: "👻"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["デザインパターン", "typescript"]
published: false
---

<!-- GOFのデザインパターン23種類の中からCareerMapに適用すると良さそうなパターンを例として3つ上げる -->

# デザインパターンとは
**ソフトウェアの設計**をする上で**よく起きる問題の典型的な解決方法**。
先人が見つけた良い方法を整理したパターン集。

一番代表的なものが、GoFの23個のデザインパターン。(GoF = Gang of Four : 著者の4人)
例えば[こちら](https://www.hyuki.com/dp/dpinfo.html)にあるように、GoF以外のものもある。


# GoFのデザインパターン
全23パターンあるが、それらは大きく3つの分類に分けられる。
- **生成**に関するパターン (5個)
- **構造**に関するパターン (7個)
- **振る舞い**に関するパターン (11個)


## 生成に関するパターン
オブジェクトを生成する仕組みに関するもの。

※ なお、下表内で パターン名がリンクになっているもの についてはTypeScriptでサンプルコードを写経。

| パターン名 | 概要・何が嬉しいのか |
| :-: | - |
| [Factory Method](https://github.com/ito0804takuya/design-pattern_typescript/blob/main/src/factory/sample.ts)<br>（工場） | **生成するオブジェクト**(`製品`)**に依存しない、オブジェクト生成のインタフェース**(`工場`の持つ`生産メソッド`)**を提供する**。<br>つまり、色々な種類がある製品のどれを作るときでも、それを作る工場に共通の生産メソッドで依頼すれば作ってくれる。<br>（`Template Method`のインスタンス生成特化ver.）<br><br>乗用車工場にもトラック工場にも`createCar()`と依頼すればそれぞれの製品を作ってくれる。そして作られた車には各製品で異なるビジネスロジックであっても、共通して`deliver("東京")`と依頼できる。<br>こうなると、新たにタクシーを作る必要が出ても、生産メソッドやその製品のできること（メソッド）が他の製品と同じなので、**簡単に製品を追加できる**。 |
| **[Abstract Factory](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/abstract_factory/sample.ts)**<br>(抽象的な工場) | **関連するオブジェクト郡を**、その具象クラスを指定することなく**生成するためのインタフェース**を提供する。<br><br>使用例コードを次項に記載。 |
| [Builder](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/builder/sample.ts)<br>(構築者) | **生成過程を隠蔽**することで、**同じ過程で異なる内容のオブジェクトを生成**できる。<br><br>オブジェクトのフィールドとその作り方を持つ`Builder`を定義。<br>`Director`には、Builderを使ってどうやって組み立てるか という生成過程を定義。<br><br>``同じDirector``が、`砂糖水Builder`と`食塩水Builder`を使えば、同じ生成過程を経た砂糖水と食塩水が作れる。<br>この例でいうと、Biulderは「溶媒に水、溶質に砂糖を使うこと」、Directorは「それらを何gずつ混ぜるか 等」を決定する役割を持つ。 |
| Prototype<br>（原型） | 原型となるオブジェクトを元に複製する。つまり、**原型となるオブジェクト(のみ)が自身の複製方法を知っている**。<br><br>自分のクローンを作るメソッド`clone()`をPrototypeインターフェースに用意しておく。<br>そのインターフェースを実装するPrototypeクラスには、自身のインスタンスを複製するのに必要な手続きを`clone()`に実装する。<br><br>別のオブジェクトがオブジェクトを複製しようとする場合、その複製するオブジェクトのことをよく知っていないといけないため、そこに依存関係が生まれる。複製されるオブジェクト自身が複製方法を持つことで、その依存関係を解消できる。 |
| Singleton<br>(一人っ子) | クラスが**1つのインスタンスしか持たない**ことを保証する。<br><br>インスタンス生成の方法を外部に公開してはいけないため、コンストラクタをprivateにする。インスタンス生成時に既にインスタンスが存在しているのかチェックする。 |


## 構造に関するパターン
  **クラスの構造**に関するもの。オブジェクトをどう組み合わせるか。

| パターン名 | 概要・何が嬉しいのか |
| :-: | - |
| Adapter<br>(接続装置) | **互換性のないインタフェースを持つクラス同士の接続を可能にする**。<br><br>クライアントが使う側のクラスのインターフェースに合わせたアダプターを作る。もう片方のクラスとうまく変換できるように、アダプター内でそのインターフェースに合わせて実装する。 |
| Bridge<br>（橋） | あるクラスにおける**抽象部と実装部を分離**することで、管理・拡張しやすくする。<br><br>組み合わせて使用される2つのオブジェクト（例：リモコンとデバイス）が現状1つの一枚岩クラスになっているとして、それら各々に多彩な種類がある場合、それらの組み合わせは膨大に膨れ上がる。そういったときの拡張（組み合わせ）をどう実現するかという話。<br>1つになっているクラスをリモコン（抽象化層）とデバイス（実装）に分ける。リモコンクラスにデバイスを参照するフィールドを設けて、デバイスにはインターフェースを用意することで、リモコン・デバイスがそれぞれ独自に多品種開発できる。 |
| Composite<br>コンポジット<br>（合成物） | **個々のオブジェクト と それら複数から成る階層構造を持ったオブジェクト を同一視**することにより、**再帰的な構造を表現する**。<br><br>オブジェクト単体では、単に自己完結型で処理を行うよう実装。<br>合成オブジェクトでは、単体オブジェクトにメソッドを実行させて、その後、次に処理すべきオブジェクトがあれば再帰的にメソッドを呼び出す。<br><br>このオブジェクトを使う側は、それが多くの階層を持っているのか、それとも下階層が無い単一のものなのかを気にせず呼び出せる。 |
| [Decorator](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/decorator/sample.ts)<br>（装飾者） | ある核(コア)となるオブジェクトに、**機能を後から任意で追加できる**（マトリョーシカのようにコアの人形の上から何個も被せることができる）構成を提供する。<br>継承を使って**サブクラスを大量に作らずに**、Decoratorの組み合わせにより、**既存クラスのメソッド+αの機能を持った色々なパターンのメソッドを実現できる**。 |
| **[Facade](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/facade/sample.ts)**<br>ファサード<br>（見かけ） | 複数のクラスのメソッドを使って1つの機能が実現されている場合に、クライアントに使いやすくための窓口を提供する。<br>その機能を使うクライアント側のクラスにその複数のクラスを呼び出させるのでなく、**複数のクラスを呼び出す役割の`Facade`クラス**を作り、それをクライアントに使ってもらうようにする。<br><br>使用例コードを次項に記載。 |
| Flyweight<br>（軽量級） | 多数のオブジェクトの中で同じものと見なせるオブジェクトを共有し、オブジェクトの構築のための負荷を減らす。 <br>要は、**キャッシュしたいプロパティはFlyweightクラスとして保持**しておいて、**頻繁に（動的に）変化するプロパティはContextクラスとして切り出し**、全体での**メモリ（RAM）使用量を減らそう**という試み。 |
| [Proxy](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/proxy/sample.ts)<br>（代理人） | オブジェクトに送られるメッセージを、共通のインタフェースを持つ**Proxyオブジェクトがフック（横取り）して代理として働く**。<br>Proxyオブジェクトが間に存在することで、（プロキシサーバーのように）その**メッセージの前後に任意の処理を挿入することができる**。 |


## 振る舞いに関するパターン
  オブジェクト間の**責任の分担**に関するもの。

| パターン名 | 概要・何が嬉しいのか |
| :-: | - |
| Chain of Responsibility<br>(責任の連鎖) | 複数のオブジェクトを鎖状につなぎ、その中のどれかのオブジェクトが要求を処理するまで、その鎖に沿って他のオブジェクトに要求を受け流していく。<br><br>**`要求を受け入れるメソッド`と`自身が処理する or 次のオブジェクトに依頼するか を決めて実行するメソッド`を持つオブジェクトを作る**。<br><br>どういう順番にリクエストが来るか分からない等、様々な処理を様々な順番で処理しないといけないときに有効。 |
| Command<br>（命令） | **命令・操作をクラス(オブジェクト)で表現**して、**そのオブジェクトを切り替えることで操作の切り替えを実現**する。<br><br>料理メソッドを作るときにどうするかという例で言うと、引数に料理名を渡すと料理メソッド内に料理名ごとの条件分岐が必要になる。そうではなく、具体的な具材・調理方法を定義した調理（Commandオブジェクト）を渡す。 |
| Interpreter<br>インタプリタ<br>（通訳）| 文法規則をクラスで表現したものを用い構文解析し、その結果に基づき処理を実行していく機能を提供する。<br>処理をしたものがその次の処理のInputになるので、Compositeパターンと同じような構造をとる。<br>（滅多に必要とされないパターン。） |
| Iterator<br>イテレータ<br>（繰り返し） | 複雑なデータ構造であっても、その**内部表現を公開することなく、その要素に順にアクセスする方法**をクライアントに提供する。<br><br>オブジェクトAが、オブジェクトBの持つ配列データをループで呼び出して使う。こういう場合、AはBのことを知りすぎている。データが配列であることが前提のコードになっているため、そのBのデータ構造が変わったらAにも改修が必要になってしまう。<br>Bのデータ構造を非公開にして、代わりに`hasNext()`と`next()`という2つのメソッドだけを公開する。AからBにhasNext()で質問し、答えがtrueならnext()でデータを要求する。 |
| Mediator<br>（調停者） | **オブジェクト同士が**互いに参照し合うことがないように、**共同作業する際は仲介役となるオブジェクトを介することを強制**する。<br><br>プログラムは複数のオブジェクトを組み合わせて機能を作るという性質上、オブジェクト間の関連がゴチャゴチャになる問題がある。オブジェクトA, B, C, Dが互いに関連を持っている（= 他のオブジェクトの持つメソッドを呼び出している）とき、どれかを改造しようとしたら他に影響を与えてしまうため、変更が困難になる。<br>オブジェクト同士が互いに参照し合うことがないように、仲介役となるオブジェクトを介して制御することで、オブジェクト同士の関連を整理できる。オブジェクトA~Dは、他のオブジェクトを参照するとき、それらの調停者（仲介役）となるオブジェクトMを介して参照するようにする。そうすることで、A~Dに発生した変更の影響はMだけで済む。 |
| Memento<br>（形見） | データ構造に対する操作内容・状態を記録しておき、**以前の状態の復帰、操作の再実行を行える**ようにする。<br><br>Mementoオブジェクトがスナップショットとして機能する値オブジェクト。<br>（Railsで言うと[`XXX_was`, `XXX_changeメソッド`](https://morizyun.github.io/ruby/active-record-attribute-was-change.html)がしていることのイメージ。） |
| Observer<br>（観察者） | **あるオブジェクトの変化を、それに依存するオブジェクトに自動的に知らせる**仕組みを提供する。<br><br>通知先のオブジェクトに、通知を送信するメソッドの実装をインターフェースによって強制する。<br>通知元クラスは、通知先が複数あろうが、通知先を格納した配列にそのメソッドをループ処理すれば、複数の通知先に簡単に通知できる。<br>(Railsで言うと、`after_save`とかのイメージ。) |
| [State](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/state/sample.ts)<br>（状態）| 状態を表すStateオブジェクトを用意し、**あるオブジェクトは内包するStateオブジェクトを切り替えることによって、処理内容(振る舞い)を変えられる**ようにする。<br>（状態を表すクラスは、その状態ごとに1つずつ作る。）<br><br>状態を判定する条件分岐を大量に書かなくてよくなる。 |
| [Strategy](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/strategy/sample.ts)<br>（戦略）| 一連のアルゴリズム（戦略）をカプセル化（部品化）し、動的なアルゴリズムの切替えを可能とする。<br>**あることをするのに、いくつかの方法（ロジック）がある場合、その方法クラスを複数作り**、それを行うクラスは**その方法クラスを選択することでアルゴリズムを切り替え**できる。 |
| **[Template Method](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/template_method/sample.ts)**<br>（ひな型） | **スーパークラスで処理の流れを定義**し、その**処理の詳細はサブクラスで定義**することで、その**処理の流れをテンプレート化**できる。<br><br>いくつかのメソッド（処理）を呼び出すメソッド（処理の流れを定義）を、ひな型として定義したクラスを作成。<br>それを継承したクラスでその処理の流れを定義したメソッドの具体的な内容を実装する。<br><br>詳細は次項に記載。 |
| Visitor<br>（訪問者） | データ構造を表すクラス（受け入れ側。これが本体。）と、それに対する処理を行うクラス（Visitor）を分離する。<br><br>**本体クラスのメソッドの引数にVisitorを渡す形にして、そのメソッドの中でVisitorに実装した処理を実行させる**ことで、**本体クラスの中でVisitorが仕事をする**仕組みにできる。<br>そうなると、Visitorを変更することで、**本体クラスにほとんど変更せずに機能を追加・変更できる**。 |


# CareerMapに適用すると良さそうなパターン 3個
デザインパターンのうち、CareerMapに適用すると良さそうなパターンを3つ見つけて、TypeScriptにてサンプル実装を作成した。

## Abstract Factory（抽象的な工場）
#### < サンプル実装内容 >
①募集情報へ応募したときと、②説明会へ応募したときに生成されるオブジェクトは`Entry`と`Message`だが、それらの持つ値や挙動は異なる。

そのため、製品`Entry`の例で言うと、その製品を抽象化し、①の場合に生成するもの（`JobEntry`）と、②の場合に生成するもの（`CorporationEventEntry`）に分けた。（`Message`にも同じことをした。）
かつ、それらを生成する工場も抽象化し、分けた。

工場には`createEntry()`などと依頼できるため、クライアントはその工場が生産する製品（具象クラス）について知らなくて良い。

#### < メリット >
- 工場から得られる**製品同士は、互換**であることが保証される。
- （上記の通り）別の工場で生成する製品同士もそうだが、**工場同士にも互換性を持たせる**ことができる。
- **具象製品とクライアント側コードの密結合を防止**できる。
- **製品作成コードが一箇所に**まとめられ、保守が容易になる。（単一責任の原則）
- この例で言うと、（募集や説明会以外に）**企業実習を追加する場合でも**、同様のFactoryを作ることで**簡単に対応できる**。
#### < デメリット >
- コードが増えるため、**必要以上に複雑に**なる可能性がある。

```ts
interface EntryFactory {
  createEntry(): Entry;
  createMessage(): Message;
}
// 募集情報へのエントリー
class JobEntryFactory implements EntryFactory {
  createEntry(): Entry {
    return new JobEntry();
  }
  createMessage(): Message {
    return new EntryJobMessage();
  }
}
// 説明会へのエントリー
class CorporationEventEntryFactory implements EntryFactory {
  createEntry(): Entry {
    return new CorporationEventEntry();
  }
  createMessage(): Message {
    return new EntryCorporationEventMessage();
  }
}

interface Entry {
  entryTarget: string;
}
class JobEntry implements Entry {
  entryTarget = "job"; // 応募したのは、募集情報に対して。
}
class CorporationEventEntry implements Entry{
  entryTarget = "session"; // 応募したのは、説明会に対して。
}

interface Message {
  sendMessage(): void;
}
class EntryJobMessage implements Message {
  sendMessage(): void {
    console.log("募集情報へのエントリーがありました。");
  }
}
class EntryCorporationEventMessage implements Message {
  sendMessage(): void {
    console.log("説明会へのエントリーがありました。");
  }
}

// <使い方>
function jobEntry() {
  const factory = new JobEntryFactory();
  const entry = factory.createEntry();
  const message = factory.createMessage();
  // 以降、募集へのエントリーならではのビジネスロジック
}

function corporationEventEntry() {
  const factory = new CorporationEventEntryFactory();
  const entry = factory.createEntry();
  const message = factory.createMessage();
  // 以降、説明会へのエントリーならではのビジネスロジック
}
```


## Facade（見かけ）
#### < サンプル実装内容 >
応募（`Entry`）をした際にSlack（メールでも可）に通知を送る（`SlackNotifier`）。
その際、クライアント側から`Entryの登録`と`Slack通知`というサブシステムを別々に呼び出させるのでなく、Facadeクラスである`EntryNotifier`を使うことで、1つの窓口からその2つの機能を使うことができる。

#### < メリット >
- 複数のオブジェクトにそれぞれやってほしいことを書くのでなく、1つのインターフェースから依頼することで、**それぞれが組み合わさって機能している**ということが、コードを読む人から分かりやすい。
- **クライアント側のコードが簡素化**される。

#### < デメリット >
- Facade内で使用している、サブシステムのメソッドを他の箇所でFacadeからではなく単独で使う場合には、**そのメソッドの変更が、Facade経由でも正しく機能するか**確認が必要。

```ts
// エントリー通知
class EntryNotifier {
  protected entry: Entry;
  protected slackNotifier: SlackNotifier;
  constructor(entry: Entry, slackNotifier: SlackNotifier) {
    this.entry = entry || new Entry();
    this.slackNotifier = slackNotifier || new SlackNotifier();
  }

  // 2つのクラスの機能を組み合わせて実装したい機能
  operation(): void {
    this.entry.createEntry();
    this.slackNotifier.sendMessage(this.entry);
    console.log(`ログに残す。< エントリー内容: ${this.entry}, slack通知: ${this.slackNotifier}>`);
  }
}

// エントリー
class Entry {
  createEntry(): void {
    console.log("選考状況をセットし、エントリー情報をDBに登録");
  }
}

// Slack通知
class SlackNotifier {
  sendMessage(entry: Entry): void {
    console.log(`slackに通知を送信: <${entry}が登録されました。>`);
  }
}

// <使い方>
// この2つのクラスの機能(メソッド)を使って、1つの処理を行いたい
const entry = new Entry();
const slackNotifier = new SlackNotifier();
// ここで2つのクラスのメソッドを呼び出すのでなく、行いたい1つの処理を登録したFacadeに処理を依頼
const facade = new EntryNotifier(entry, slackNotifier);
console.log(facade.operation());
```

## Template Method
#### < サンプル実装内容 >
求職管理簿（`JobHuntingList`）と求人管理簿（`JobList`）という2つのCSVは、出力する内容は異なるが、大きな処理の流れは同じ。（下記1〜4）
なのでそれをテンプレートメソッド（`exportCSV()`）にした。
  1. CSVに出力するデータセットを取得。
  2. ヘッダーを1行目にセットする。
  3. 1.のデータを2行目以降に書き込み、CSV作成完了。
  4. CSVをクライアントに送る。

#### < メリット >
- システムに必要となる**帳票**（CSV）**が増えたとしても、Templateクラス**（この例で言う`SchoolDocument`）**のサブクラスを追加するだけで良い**。
- Templateクラスによって、テンプレートで使用する、サブクラスが持つべきメソッドの実装を強制できる。
- 各帳票に**共通するコードをTemplateクラスに配置**できる。

#### < デメリット >
- ある帳票の処理順序に変更が入る場合、**テンプレートを修正すると他の帳票に影響**が出る。
  （なので帳票が10種類あれば10種類に対して、問題がないか確認が必要。）

```ts
abstract class SchoolDocument {
  
  // これがTemplateMethod
  exportCSV(): void {
    // CSVに出力するデータセットを取得（今回の例でいうと、求職管理簿ならEntry、求人管理簿ならJobのデータ）
    const data: object[] = this.getData();

    // 各帳票のヘッダーをセット
    const header: string[] = this.setHeader();

    // CSVを作成
    const csv: object = this.createCSV(data, header);
    
    // CSVを返す　send_data
    this.sendCSV(csv);
  }

  // 共通の処理
  protected createCSV(data: object[], header: string[]): object {
    console.log("CSVを作成");
    return {}; // 本当はCSVオブジェクトを返す
  }
  protected sendCSV(csv: object): void {
    console.log("CSVをレスポンスする");
  }

  // クラス毎に異なる処理
  protected abstract getData(): object[];
  protected abstract setHeader(): string[];
}

// 求職管理簿
class JobHuntingList extends SchoolDocument {
  protected getData(): object[] {
    console.log("CSVに出力する活動情報（Entry）を取得");
    return [ {}, {} ];
  }
  protected setHeader(): string[] {
    console.log("求職管理簿用のヘッダーを取得");
    return ["エントリーID", "など"];
  }
}

// 求人管理簿
class JobList extends SchoolDocument {
  protected getData(): object[] {
    console.log("CSVに出力する募集情報（Job）を取得");
    return [ {}, {} ];
  }
  protected setHeader(): string[] {
    console.log("求人管理簿用のヘッダーを取得");
    return ["募集ID", "など"];
  }
}

// <使い方>
// 求職管理簿をCSVで出力
new JobHuntingList().exportCSV();
// 求人管理簿をCSVで出力
new JobList().exportCSV();
```


# 参考ページ
https://www.techscore.com/tech/DesignPattern/
http://www.itsenka.com/contents/development/designpattern/
https://refactoring.guru/ja/design-patterns/typescript


# 感想
- TypeScriptで書いたのだが、普段書くことの多いRubyとの差を実感した。（型注釈やインターフェース 等）
  言語レベルでの差を感じることができたため、他の言語を触る機会には、その言語の仕様に注意しながら取り扱おうと思えるようになった。
- デザインパターン23種について、参考サイトを見て（全種） + 写経（9種） + サンプル実装（3種）を行ったが、やはり概念や内容が難しいものは、見るだけでなく、写経したり独自に実装して使ってみないと理解が難しいと感じた。
  なので今後、名前や内容が咄嗟には思い出せないと思う。
- （覚えているものについては）「XXパターンみたいにして〜」という開発者同士の会話ができるようになるので、コミュニケーションがスムーズになる場面が増えるかもしれない。
- 設計について引き出しを増やすことができた。
- サンプル実装については、「このパターンは、キャリアマップの中で使えるところはないか〜」と、無理やり使おうという気持ちを持って考案した。
  現実、実務においてデザインパターンがぴったりハマり、使うメリットが大きいというタイミングは少ないかもと感じた。
- 使っているもの（言語やフレームワーク）によって、良いパターンとアンチパターンがあるのではと感じた。
  Ruby on Railsで言うと、[こういうパターン](https://applis.io/posts/rails-design-patterns)が良しとされている と調べて知ることができた。

---

### オブジェクト指向の「関係」について
デザインパターンや参考ページのクラス図を読む上で、継承・コンポジションなどの関連の知識が前提として必要だと感じたので、下項に整理した。
https://www.ogis-ri.co.jp/otc/hiroba/technical/DesignPatternsWithExample/chapter01.html

- 継承
  `サブクラス is a スーパークラス.（トラックは車。）`
- 集約
  部品として他のオブジェクトを持つが、弱い結びつき。関連先が消滅しても、自身は消滅しない。
  `A part of B.（駐車場Bと、そこに駐車された車A。）`
- コンポジション（合成）
  部品として他のオブジェクトを持つ、強い結びつき。関連先が消滅すると、自身も消滅する。
  集約と似ている概念。
  `A part of B.（エンジンAは車Bの一部。）`

  利用したオブジェクト

:::message alert
GoFとUMLで、集約とコンポジションの定義が異なる。（逆のことを指す。）
https://qiita.com/gatapon/items/5e3292f897ab4f817001
（上記の箇条書きで記載した集約とコンポジションは、今一般的に使われる、UMLにおける定義のほうで記載した。）
:::

#### 参考ページ （「関係」について）
http://teacher.nagano-nct.ac.jp/fujita/LightNEasy.php?page=oop4
https://thinkit.co.jp/article/13112
https://qiita.com/gatapon/items/5e3292f897ab4f817001
https://rakusui.org/design_pattern/
https://4geek.net/difference-between-inheritance-and-composition/

以上