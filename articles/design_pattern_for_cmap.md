---
title: "GoFのデザインパターン"
emoji: "👻"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["デザインパターン", "typescript"]
published: false
---

<!-- GOFのデザインパターン23種類の中からCareerMapに適用すると良さそうなパターンを例として3つ上げる				 -->

# デザインパターンとは
ソフトウェアの設計をする上でよく起きる問題の典型的な解決方法。
先人が見つけた良い方法を整理したパターン集。

一番代表的なものが、GoFの23個のデザインパターン。(GoF = Gang of Four : 著者の4人)
例えば[こちら](https://www.hyuki.com/dp/dpinfo.html)にあるように、GoF以外のものもある。


# GoFのデザインパターン
全23パターンあるが、それらは大きく3つの分類に分けられる。
- 生成に関するパターン (5個)
- 構造に関するパターン (7個)
- 振る舞いに関するパターン (11個)


## 生成に関するパターン
オブジェクトを生成する仕組みに関するもの。

※ なお、下表内で パターン名がリンクになっているもの についてはTypeScriptでサンプルコードを写経。

| パターン名 | 概要・何が嬉しいのか |
| :-: | - |
| [Factory Method](https://github.com/ito0804takuya/design-pattern_typescript/blob/main/src/factory/sample.ts)<br>（工場） | **生成するオブジェクト**(`製品`)**に依存しない、オブジェクト生成のインタフェース**(`工場`の持つ`生産メソッド`)**を提供する**。<br>つまり、色々な種類がある製品のどれを作るときでも、それを作る工場に共通の生産メソッドで依頼すれば作ってくれる。<br>（`Template Method`のインスタンス生成特化ver.）<br><br>乗用車工場にもトラック工場にも`createCar()`と依頼すればそれぞれの製品を作ってくれる。そして作られた車には各製品で異なるビジネスロジックであっても、共通して`deliver("東京")`と依頼できる。<br>こうなると、新たにタクシーを作る必要が出ても、生産メソッドやその製品のできること（メソッド）が他の製品と同じなので、**簡単に製品を追加できる**。 |
| [Abstract Factory](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/abstract_factory/sample.ts)<br>(抽象的な工場) | 詳細は次項に記載。 |
| [Builder](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/builder/sample.ts)<br>(構築者) | 生成過程を隠蔽することで、同じ過程で異なる内容のオブジェクトを生成できる。<br><br>オブジェクトのフィールドとその作り方を持つ`Builder`を定義。<br>`Director`には、Builderを使ってどうやって組み立てるか という生成過程を定義。<br><br>``同じDirector``が、`砂糖水Builder`と`食塩水Builder`を使えば、同じ生成過程を経た砂糖水と食塩水が作れる。<br>この例でいうと、Biulderは「溶媒に水、溶質に砂糖を使うこと」、Directorは「それらを何gずつ混ぜるか 等」を決定する役割を持つ。 |
| Prototype<br>（原型） | 原型となるオブジェクトを元に複製する。つまり、**原型となるオブジェクト(のみ)が自身の複製方法を知っている**。<br><br>自分のクローンを作るメソッド`clone()`をPrototypeインターフェースに用意しておく。<br>そのインターフェースを実装するPrototypeクラスには、自身のインスタンスを複製するのに必要な手続きを`clone()`に実装する。<br><br>別のオブジェクトがオブジェクトを複製しようとする場合、その複製するオブジェクトのことをよく知っていないといけないため、そこに依存関係が生まれる。複製されるオブジェクト自身が複製方法を持つことで、その依存関係を解消できる。 |
| Singleton<br>(一人っ子) | クラスが**1つのインスタンスしか持たない**ことを保証する。<br><br>インスタンス生成の方法を外部に公開してはいけないため、コンストラクタをprivateにする。インスタンス生成時に既にインスタンスが存在しているのかチェックする。 |


## 構造に関するパターン
  **クラスの構造**に関するもの。

| パターン名 | 概要・何が嬉しいのか |
| :-: | - |
| Adapter<br>(接続装置) | **互換性のないインタフェースを持つクラス同士の接続を可能にする**。<br><br>クライアントが使う側のクラスのインターフェースに合わせたアダプターを作る。もう片方のクラスとうまく変換できるように、アダプター内でそのインターフェースに合わせて実装する。 |
| Bridge<br>（橋） | あるクラスにおける**抽象部と実装部を分離**することで、管理・拡張しやすくする。<br><br>組み合わせて使用される2つのオブジェクト（例：リモコンとデバイス）が現状1つの一枚岩クラスになっているとして、それら各々に多彩な種類がある場合、それらの組み合わせは膨大に膨れ上がる。そういったときの拡張（組み合わせ）をどう実現するかという話。<br>1つになっているクラスをリモコン（抽象化層）とデバイス（実装）に分ける。リモコンクラスにデバイスを参照するフィールドを設けて、デバイスにはインターフェースを用意することで、リモコン・デバイスがそれぞれ独自に多品種開発できる。 |
| Composite<br>コンポジット<br>（合成物） | **個々のオブジェクト と それら複数から成る階層構造を持ったオブジェクト を同一視**することにより、**再帰的な構造を表現する**。<br><br>オブジェクト単体では、単に自己完結型で処理を行うよう実装。<br>合成オブジェクトでは、単体オブジェクトにメソッドを実行させて、その後、次に処理すべきオブジェクトがあれば再帰的にメソッドを呼び出す。<br><br>このオブジェクトを使う側は、それが多くの階層を持っているのか、それとも下階層が無い単一のものなのかを気にせず呼び出せる。 |
| [Decorator](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/decorator/sample.ts)<br>（装飾者） | ある核(コア)となるオブジェクトに、**機能を後から任意で追加できる**（マトリョーシカのようにコアの人形の上から何個も被せることができる）構成を提供する。<br>継承を使って**サブクラスを大量に作らずに**、Decoratorの組み合わせにより、**既存クラスのメソッド+αの機能を持った色々なパターンのメソッドを実現できる**。 |
| [Facade](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/facade/sample.ts)<br>ファサード<br>（見かけ） | 詳細は次項に記載。 |
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
| [State](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/state/sample.ts)<br>（状態）| 状態を表すStateオブジェクトを用意し、あるオブジェクトは内包するStateオブジェクトを切り替えることによって、処理内容(振る舞い)を変えられるようにする。<br>（状態を表すクラスは、その状態ごとに1つずつ作る。）<br><br>状態を判定する条件分岐を大量に書かなくてよくなる。 |
| [Strategy](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/strategy/sample.ts)<br>（戦略）| 一連のアルゴリズム(戦略)をカプセル化(部品化)し、動的なアルゴリズムの切替えを可能とします。<br>あることをするのに、いくつかの方法（ロジック）がある場合、その方法クラスを複数作り、それを行うクラスはその方法クラスを選択することでアルゴリズムを切り替えできる。 |
| [Template Method](https://github.com/ito0804takuya/design-pattern_typescript/tree/main/src/template_method/sample.ts)<br>（ひな型） | 詳細は次項に記載。 |
| Visitor<br>（訪問者） | データ構造を表すクラス（受け入れ側。これが本体。）と、それに対する処理を行うクラス（Visitor）を分離する。<br><br>**本体クラスのメソッドの引数にVisitorを渡す形にして、そのメソッドの中でVisitorに実装した処理を実行させる**ことで、**本体クラスの中でVisitorが仕事をする**仕組みにできる。<br>そうなると、Visitorを変更することで、**本体クラスにほとんど変更せずに機能を追加・変更できる**。 |


# CareerMapに適用すると良さそうなパターン 3個

## Abstract Factory（抽象的な工場）
  互いに関連する一連のオブジェクト郡を、その具象クラスに依存しないで生成するためのインタフェースを提供します。
  
```ts
interface EntryFactory {
  createEntry(): Entry;
  createMessage(): Message;
  createActivity(): Activity;
}
// 募集情報へのエントリー
class JobEntryFactory implements EntryFactory {
  public createEntry(): Entry {
    return new Entry("job");
  }
  public createMessage(): Message {
    return new Message("job");
  }
  public createActivity(): Activity {
    return new Activity("job");
  }
}
// 説明会へのエントリー
class CorporationEventEntryFactory implements EntryFactory {
  public createEntry(): Entry {
    return new Entry("internship");
  }
  public createMessage(): Message {
    return new Message("internship");
  }
  public createActivity(): Activity {
    return new Activity("internship");
  }
}

class Entry  {
  protected entry_target: string;
  public constructor(value: string) {
    this.entry_target = value;
  }
  // ...
}
class Message {
  // ...
}
class Activity{
  // ...
}

// <使い方>
function jobEntry() {
  const factory = new JobEntryFactory();
  const entry = factory.createEntry();
  const message = factory.createMessage();
  const activity = factory.createActivity();
  // 以降、募集へのエントリーならではのビジネスロジック
}

function corporationEventEntry() {
  const factory = new CorporationEventEntryFactory();
  const entry = factory.createEntry();
  const message = factory.createMessage();
  const activity = factory.createActivity();
  // 以降、説明会へのエントリーならではのビジネスロジック
}
```


## Facade（見かけ）
複数のサブシステムの統一窓口となる高レベルなインタフェースを提供します。

複数のクラスのメソッドを使って1つの機能が実現されている。
その機能を使う側のクラスにその複数のクラスを呼び出させるのでなく、複数のクラスを呼び出す役割のFacadeクラスを作って、それを使うようにする。

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
  public operation(): void {
    this.entry.createEntry();
    this.slackNotifier.sendMessage(this.entry);
    console.log(`ログに残す。< エントリー内容: ${this.entry}, slack通知: ${this.slackNotifier}>`);
  }
}

// エントリー
class Entry {
  public createEntry(): void {
    console.log("選考状況をセットし、エントリー情報をDBに登録");
  }
}

// Slack通知
class SlackNotifier {
  public sendMessage(entry: Entry): void {
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
スーパークラスで処理の流れを定義し、その処理の詳細はサブクラスで定義。

いくつかのメソッド（処理）を呼び出すメソッド（処理の流れを定義）を、ひな型として定義したクラスを作成。それを継承したクラスでその処理の流れを定義したメソッドの具体的な内容を実装する。

色々な種類のcsvを作る工程をテンプレート化。

```ts
abstract class SchoolDocument {
  
  // これがTemplateMethod
  public exportCSV(): void {
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