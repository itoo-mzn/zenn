---
title: "Go_エラー"
---

# エラー処理

- Go の**エラーはただの値** である。
  他の言語のような例外機構とは異なり、Go のエラーは return を使って戻り値として返す。

- エラーが予想されていなくても、エラーがないかどうかを常に確認して、不要な情報がエンドユーザーに公開されないようにすること。（本当に例外的な場合のみ panic する。）

:::message

#### リトライしたい場合

一度のエラーで失敗とするのでなく、（特にネットワーク越しの処理など）何回かリトライしたい場合は`Songmu/retry`が使える。（[実用 Go 言語]より）
:::

## エラーの作成

- エラーを作成する方法は 2 つ。

  1. `errors.New()`
  2. `fmt.Errorf()` : ヴァーブ（Verb, %s や%d のこと）を使って動的な情報を埋め込むときはこっちを使う。
     また、`fmt.Errorf()`はエラーを埋め込むヴァーブ`%w`を使うことで、他のエラーをラップすることもできる。

- エラーメッセージ（文字列）は他のコンテキストで使われるケースがあるため、頭文字を大文字にしたり、句読点で終わってはいけない。（他のメッセージと組み合わせないことが確かな場合は除く。）
  つまり、`log.Print("Reading %s: %v", filename, err)` が途中で大文字を出力することがないように `fmt.Errorf("Something bad")` ではなく、 `fmt.Errorf("something bad")` を使う。

- `fmt.Errorf()`でエラーメッセージにプレフィックスを含めて、エラーの発生元がわかるようにすること。（例: パッケージや関数の名前を含める。）
  err をそのまま返すことは少ない。

## エラーの判定

エラーの**値**を判定するには`errors.Is()`を使う。エラーがラップされていても、引数同士が同一か判定できる。（内部で再帰的に Unwrap している。）
`errors.As()`を使うと、（ラップされているエラーに対しても）特定の**型**に変換して取得・判定できる。

```go:errors.Is
if errors.Is(err, os.ErrExist) {
  // os.ErrExistだった場合のエラー処理
}
```

外部 API からのレスポンスについては、そのステータスコードによってエラーを区別してハンドリングする。
（AWS SDK から 404 が返ってきたらクライアントにも 404 を返す など）[参考](https://future-architect.github.io/articles/20200709/#4-SDK%E3%81%8C%E5%87%BA%E5%8A%9B%E3%81%99%E3%82%8BNotFound%E3%82%92%E6%84%8F%E5%91%B3%E3%81%99%E3%82%8Berror%E3%81%A8%E3%80%81%E3%81%9D%E3%81%AE%E4%BB%96%E3%81%AE%E3%82%A8%E3%83%A9%E3%83%BC%E3%82%92%E5%8C%BA%E5%88%A5%E3%81%97%E3%81%A6%E3%83%8F%E3%83%B3%E3%83%89%E3%83%AA%E3%83%B3%E3%82%B0%E3%81%99%E3%82%8B)

## 独自エラーの宣言

### 独自エラー変数

エラー変数を作成して、特定のエラー状態が発生したことを表す。
（例: `var ErrNotFound = errors.New("Employee not found")`）

### 独自のエラー構造体

独自エラー変数で識別するだけでなく、エラーに詳細（独自の code 値など）を格納したり、独自メソッドを用意したい場合、独自のエラー構造体を定義する。

## エラーに文脈をもたせる

**`fmt.Errorf`の`%w`を使うことで、既にあるエラーにラップした（1 枚上乗せした）エラーを作ることができる**。[参考](https://zenn.dev/mixi/articles/f07be7f476e2f3#14.-%E3%82%A8%E3%83%A9%E3%83%BC%E3%81%AE%E9%81%A9%E5%88%87%E3%81%AA%E4%BC%9D%E6%90%AC%E3%82%92%E3%81%97%E3%82%88%E3%81%86)

また、そうやって上乗せされたエラーの根本（根本原因）を取得するには、`errors.Unwrap()`を使う。

```go
err := fmt.Errorf("bar: %w", errors.New("foo"))
fmt.Println(err) // bar: foo
fmt.Println(errors.Unwrap(err)) // foo
```

ちなみに、`fmt.Errorf`以外で、独自のエラー構造体を作ってそれに err を格納するように実装した場合は、err を取り出せる Unwrap()メソッドを用意してあげるのがベスト。

## 複数のエラーをまとめて処理する

エラーが発生する可能性がある処理を複数回実行し、それをまとめて処理したい場合、以下のような方法がある。

###### 処理の全てが成功すれば成功で、1 つでもエラーがあればそれ以降はスキップして最終的にエラーとして処理する場合

内部でエラー`err`を保持しておく構造体を作り、エラーが発生すればそれに err を格納し、最終的にその構造体の中にエラーがあった場合に return err するような方法。

###### 処理の全てが成功すれば成功で、1 つエラーが起きてもそれ以降はスキップせず、複数エラーが起きてもそれぞれの詳細を保持する場合

uber-go/multier を使う。

##### 主処理でのエラーと defer 内でのエラーを切り分ける

```go
func getByID(db *sql.DB, id int) (customer Customer, err error) {
	// ...（DB接続）
	defer func() {
		// rows.Scan()にエラーなく、rows.Close()でエラー　→　後者を返す
		// rows.Scan()にエラーあり、rows.Close()でエラーなし　→　前者を返す
		// rows.Scan()にエラーあり、rows.Close()でもエラーあり　→　後者はログに残すのみで、前者を返す
		closeErr := rows.Close()
		if err != nil {
			if closeErr != nil {
				log.Printf("failed to close rows: %v", closeErr)
			}
			return
		}
		err = closeErr
	}()

	err = rows.Scan(&customer)
	if err != nil {
		return nil, err
	}
	// ...（いろいろな処理）
}
```

# 例外処理

panic と recover の組み合わせは、Go での特徴的な例外処理方法。
（他のプログラミング言語では、try/catch。）

## panic 関数

プログラムを強制的にパニックにする。スタックトレースを出力してクラッシュする。

`error`は呼び出し元の関数などに順々に伝わるのに対して、**`panic`は大域脱出**する。

:::message
**想定される異常状態は`error`を使って表現**すべきで、
**プログラムが対処できないような問題やロジック上のバグは`panic`を使って対応**する。

（例えば、ユーザ入力で指定されたファイル名のファイルが無い という場合は`error`。呼び出している CSS ファイルが存在しない 場合は`panic`。）

:::

:::message alert
`panic`、`log.Fatal`（= `os.Exit(1)`）は、基本的に main 以外では呼ばないこと。テストが難しくなる。
:::

## recover 関数

`panic()`後に、制御できる。
`defer()`の中で実行できる。
`panic()`と違い、それ単体では自動でスタックトレースを出力しない。

```go
func main() {
	// panicが起きたときに、catchすることを予約しておく
	defer func() {
		if r := recover(); r != nil {
			fmt.Println("panicしたら実行", r)
		}
	}()

	g(0)
	fmt.Println("finish!!") // panicするので、この行は絶対に実行されない
}

func g(i int) {
	if i > 3 {
		panic("パニック") // panicを起こす
	}

	defer fmt.Println("defer:", i) // recoverより先に実行される

	fmt.Println("print:", i)
	g(i + 1) // 無限再帰
}
```

:::message alert
**`recover`では、異なるゴルーチンで発生した`panic`を捉えることができない**。
新たなゴルーチンで起動する場合は、その処理の中で panic が発生しないか確認しておく必要がある。
:::

# 参考文献

http://golang.org/doc/effective_go.html#errors

## まだ読んでないやつ

https://zenn.dev/spiegel/books/error-handling-in-golang

https://qiita.com/Maki-Daisuke/items/80cbc26ca43cca3de4e4
