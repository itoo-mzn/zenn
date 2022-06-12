---
title: "Reactチュートリアル"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["React"]
published: false
---

# 目的
Reactを初めて触るため、概念や使い方をメモしておく。

# 教材
https://ja.reactjs.org/

# JSX
```jsx
const element = <h1>Hello, world!</h1>;
```
この構文は文字列でもなく、HTMLでもない。
JavaScriptに変換される、JSX(言語)。

## JSXの実体
```jsx
import React from 'react'

function render() {
  return <div className="sample">Foo</div>; // JSXは式として評価されるので、このように受け渡しできる。
}
```
は、下記のように変換・実行される。
```jsx
import React from 'react'

function render() {
  return React.createElement('div', {className: 'sample'}, 'Foo');
}
```

:::message
JSXは、実際はReact.createElementである。
:::

さらに、以下のReactオブジェクトに変換される。
```jsx
function render() {
  return {
    type: 'div',
    props: {
      className: 'sample',
      children: 'Foo'
    }
  }
}
```

#### 参考サイト
https://qiita.com/nabepon/items/87bb3b4f1e7bfa342489

## JSXの文法
### JSXに式を埋め込む
変数や式、関数などを`{ }`で囲って使用できる。
```jsx
const name = '太郎';
const element = <h1>Hello, {name}</h1>;
```
### JSXで属性を指定する
```jsx
const element = <a href="https://www.reactjs.org"> Link </a>;

const element = <img src={user.avatarUrl}></img>
```
:::message alert
`{ }`を囲む`" "`を書いてはいけない。（例: `"{user.email}"`）
どちらか一方を使うようにする。
:::
:::message
JSXはHTMLよりJavaScriptに近いため、**命名規則はキャメルケース**。
例えば、classは`className`となる。
:::

# コンポーネントとprops
```jsx
// 関数コンポーネント
function Welcome(props) {
  return <h1>Hello, {props.name}</h1>;
}

const root = ReactDOM.createRoot(document.getElementById('root'));
// props(name="太郎")を渡して、コンポーネントを呼び出している
const element = <Welcome name="太郎" />;
root.render(element);
```

:::message
コンポーネント名は必ず**大文字**で始める。
:::


## コンポーネントの抽出
```jsx
function Comment(props) {
  return (
    <div className="Comment">
      <div className="UserInfo">
        <img className="Avatar"
          src={props.author.avatarUrl}
          alt={props.author.name}
        />
        <div className="UserInfo-name">
          {props.author.name}
        </div>
      </div>
      <div className="Comment-text">
        {props.text}
      </div>
      <div className="Comment-date">
        {formatDate(props.date)}
      </div>
    </div>
  );
}
```
↓
```jsx
// コンポーネントとして抽出
function Avatar(props) {
  return (
    <img className="Avatar"
      src={props.user.avatarUrl} // より汎用的な名前に変更(author→user)
      alt={props.user.name}
    />
  );
}

function UserInfo(props) {
  return (
    <div className="UserInfo">
      <Avatar user={props.user} />
      <div className="UserInfo-name">
        {props.user.name}
      </div>
    </div>
  )
}

function Comment(props) {
  return (
    <div className="Comment">
      <UserInfo user={props.author} />
      <div className="Comment-text">
        {props.text}
      </div>
      <div className="Comment-date">
        {formatDate(props.date)}
      </div>
    </div>
  );
}
```

## Props は読み取り専用
:::message alert
Reactコンポーネントは、自己の**props（プロパティ）を決して変更してはいけない**。
:::

# state
```jsx:修正前
const root = ReactDOM.createRoot(document.getElementById('root'));
  
function tick() {
  const element = (
    <div>
      <h1>Hello, world!</h1>
      <h2>It is {new Date().toLocaleTimeString()}.</h2>
    </div>
  );
  root.render(element);
}
// 毎秒動作させるトリガーが、コンポーネント外部のものが行っている
setInterval(tick, 1000);
```
1秒ごとに現時刻を表示する上記のコードを、真に再利用可能 かつ カプセル化されたものに直す。
コンポーネント自身がタイマーをセットアップして、自身を毎秒更新するようにする。

つまり、このように記述して、`Clock`自身に表示を更新させたい。そのために`state`が必要。
```jsx:やりたいこと
root.render(<Clock />);
```

```jsx:修正後
// Reactでクラスを作るには、React.Componentを継承させる
class Clock extends React.Component {
  // 2. コンストラクタで初期化。
  constructor(props) {
    super(props); // なんせ必要らしい
    this.state = { date: new Date() }; // 最初に表示する時刻
  }

  // ライフサイクルメソッド (lifecycle method) -----------
  // 4. 最初にClockがDOMとして描写されたときのみに行う処理(mount)を実行。
  componentDidMount() {
    this.timerID = setInterval(
      () => this.tick(), // 毎秒tick()を実行(タイマー設定)
      1000
    );
  }

  // Clockが生成したDOMが削除されたときのみに行う処理(unmount)を実行。
  componentWillUnmount() {
    clearInterval(this.timerID); // タイマー解除
  }
  // ----------------------------------------------

  // 5. dateというstateを更新。
  //    Reactはstateが変わったということが分かるので、render()メソッドを再度呼び出す。
  tick() {
    this.setState({
      date: new Date() // dateがstateの1つ
    });
  }
  
  // 3. 最初の時刻を画面に表示。
  render() {
    return (
      <div>
        <h1>Hello, world!</h1>
        <h2>It is {this.state.date.toLocaleTimeString()}.</h2>
      </div>
    );
  }
}

const root = ReactDOM.createRoot(document.getElementById('root'));
// 1. Clockコンポーネントがrootに渡される。
root.render(<Clock />);
```

## クラス
Reactでクラスを作るには、React.Componentを継承させる。
### コンストラクタ
コンストラクタでpropsやstateを初期化する。`constructor(props) { ... }`
### `render()`
stateが変更されるたびに`render()`を実行。(表示を変更する)
### ライフサイクルメソッド
- `componentDidMount()`
そのコンポーネントが最初にDOMとして描写されたときのみに行う処理(mount)。
- `componentWillUnmount()`
そのコンポーネントが生成したDOMが削除されたときのみに行う処理(unmount)。
### `setState()`
**stateは直接変更せず、`setState()`を使う。**
(stateに直接代入して良い場所は、コンストラクタのみ。)
