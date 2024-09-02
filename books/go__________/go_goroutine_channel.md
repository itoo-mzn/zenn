---
title: "Go_ゴルーチン、チャネル"
---

# コンカレンシー
## 追加で参考にした文献
  https://zenn.dev/hsaki/books/golang-concurrency/viewer

## goroutineとは
オペレーティング システムでの従来のアクティビティではなく、軽量スレッドでの同時アクティビティです。 
（並列でなく）並行処理ができる。

```go:main.go
func main() {
  start := time.Now()

  apis := []string{
  "https://management.azure.com",
  "https://dev.azure.com",
  "https://api.github.com",
  "https://outlook.office.com/",
  "https://api.somewhereintheinternet.com/",
  "https://graph.microsoft.com",
  }
  
  // 1つ1つのサイトに、順番にGETする
  for _, api := range apis {
    // GETリクエストを送る
  _, err := http.Get(api)

  // エラー時
  if err != nil {
  fmt.Printf("ERROR: %s is down!\n", api)
  continue
  }
  // 成功時
  fmt.Printf("SUCCESS: %s is up and runnging!\n", api)
  }

  elapsed := time.Since(start)
  fmt.Printf("Done! It took %v seconds\n", elapsed.Seconds())

  // 2秒ぐらいかかってしまう
}
```

上記のコードを改良。
```go:main.go
func main() {
  start := time.Now()

  apis := []string{
  "https://management.azure.com",
  "https://dev.azure.com",
  "https://api.github.com",
  "https://outlook.office.com/",
  "https://api.somewhereintheinternet.com/",
  "https://graph.microsoft.com",
  }

  ch := make(chan string)

  for _, api := range apis {
  // APIごとにgoroutineを作成
  go checkAPI(api, ch)
  }

  // サイト数と同じだけ、channelから受信し、出力
  for i := 0; i < len(apis); i++ {
  fmt.Print(<-ch)
  }

  elapsed := time.Since(start)
  fmt.Printf("Done! It took %v seconds\n", elapsed.Seconds())

  // 0.6秒ほどに短縮
}

func checkAPI(api string, ch chan string) {
  _, err := http.Get(api)
  if err != nil {
  ch <- fmt.Sprintf("ERROR: %s is down!\n", api)
  return
  }
  // Sprintfを使うのは、まだ出力はしたくないため
  ch <- fmt.Sprintf("SUCCESS: %s is up and running!\n", api)
}
```

## チャネルの方向
```go:main.go
// チャネルに送信
func send(ch chan<- string, message string) {
  fmt.Printf("Senging: %#v\n", message)
  ch <- message
}
// チャネルに受信
func read(ch <-chan string) {
  fmt.Printf("Receving: %#v\n", <-ch)
}

func main() {
  ch := make(chan string, 1)
  send(ch, "hello") // Senging: "hello"
  read(ch) // Receving: "hello"
}
```

## 多重化
selectステートメントはswitchステートメントと同じように機能しますが、チャネル用です。

```go:main.go
func process(ch chan string) {
  time.Sleep(3 * time.Second)
  ch <- "Done processing!"
}

func replicate(ch chan string) {
  time.Sleep(1 * time.Second)
  ch <- "Done replicating!"
}

func main() {
  // チャネルを作成
  ch1 := make(chan string)
  ch2 := make(chan string)

  // goroutineを作成
  go process(ch1)
  go replicate(ch2)

  for i := 0; i < 2; i++ {
  // select句でイベント(チャネルからの送信)を待ち、来たらcase内を実行する
  // さらに(2つ以上の)イベントが発生するまで待機したい場合、必要に応じてループを使う必要がある(for)
  select {
  case process := <-ch1:
  fmt.Println(process)
  case replicate := <-ch2:
  fmt.Println(replicate)
  }
  fmt.Println("ここはイベント終了毎に実行される")
  }
}
  /*
  Done replicating!
  ここはイベント終了毎に実行される
  Done processing!
  ここはイベント終了毎に実行される
  /*
```




# 並行と並列

## 並行処理(Concurrency)

同時にいくつかの**質の異なること**を扱うことを指す。
（一人がファイルを読み込んでいて、一人がファイルに書き込んでいる イメージ。）

## 並列処理(Parallelism)

同時にいくつかの**質の同じこと**を扱うことを指す。
（全員がファイルに書き込んでいる イメージ。）

:::message
Go で扱うのは**並行処理**(**Concurrency**)。
それを実現するのが**ゴールーチン**。
:::

https://zenn.dev/hsaki/books/golang-concurrency/viewer

# ゴールーチン と 並行処理(Concurrency)

ゴールーチンは**軽量なスレッドのようなもの**。（※正確ではない）
Linux や Unix のスレッドよりもコストが低い。（→ 軽い）
**1 つのスレッドの上で複数のゴールーチンが動く**。

複数のゴールーチンで、同時に複数のタスク（質の異なること）を行う。

使うには、`go`キーワードをつけて関数を呼び出すだけ。

```go:ゴールーチンの作り方
go f()
```

:::message
main 関数も main ゴールーチン で動いている というイメージ。
:::

# チャネル

複数の**ゴールーチン間で値を共有**したいとき、**片方からもう片方へチャネル（経路）を通して共有する**。

チャネルはファーストクラスオブジェクト。（string とか int とか同じ）
→ 変数への代入や、引数に渡すこと、返り値にすることができる。

## <基本>

### 定義方法

- チャネルの作成 : `ch = make(chan int)`
  送受信できる値の型を定義する。
- 送信 : `ch<-100`
- 受信 : `n := <-ch`

### ブロック

（チャネルの）**送信側**はその**値をだれかが受け取ってくれるまで**、
**受信側**は**チャネルから何かを受け取るまで**、**以降の処理には進まない**。

## <select チャネル>

select チャネルによって、複数のチャネルの**先に受信したほうのデータを使う**という処理が書ける。

```go
func main() {
  ch1 := make(chan int)
  ch2 := make(chan string)
  go func() { ch1 <- 100 }()
  go func() { ch2 <- "hi" }()

  select {
  case v1 := <-ch1:
    fmt.Println("v1:", v1)
  case v2 := <-ch2:
    fmt.Println("v2:", v2)
  }
}
```

## <nil チャネル>

チャネルのゼロ値は nil。
nil のチャネルから受信しようとすると、永遠にブロックされる。

```go
func main() {
  ch1 := make(chan int)
  var ch2 chan string // ゼロ値 nil
  go func() { ch1 <- 100 }()
  go func() { ch2 <- "hi" }()

  select {
  case v1 := <-ch1:
    fmt.Println("v1:", v1)
  case v2 := <-ch2:
    // ch2がnilである間は、この処理は実行されない
    fmt.Println("v2:", v2)
  }
}
```

## <単方向チャネル>

チャネルは双方向なので、送信用として作ったつもりでも誤って受信に使ってしまったりする可能性がある。

単方向（受信 or 送信）チャネルによってそういった誤った使い方ができなくなるよう制限できる。

```go
func plusOne(recv <-chan int) int {
  // recvは受信用なので、送信には使えない
  v := <-recv + 1
  return v
}

func main() {
  ch := make(chan int)
  go func(ch chan<- int) {
    // chは送信用なので、受信には使えない
    ch <- 100
  }(ch)
  fmt.Println(plusOne(ch))
}
```

:::message

#### 解説

```go
go func(ch chan<- int) {
  // chは送信用なので、受信には使えない
  ch <- 100
}(ch)
```

このコードは、

```go
go 関数(ch)
```

を表しており、

```go
func(ch chan<- int) {
  // chは送信用なので、受信には使えない
  ch <- 100
}
```

は無名関数である。

つまり、最初に記載したコードは「無名関数を定義 + （引数に ch を渡して）即時実行」している。
:::

# コンテキスト

コンテキストとは、下記を行うためのもの。
- ゴールーチンをまたいだキャンセル処理
- ゴールーチンをまたいだ値の共有（チャネルでなくコンテキストで行いたい場合）

コンテキストは木構造みたいになっていて、必ずrootが存在し、新たなコンテキストはその上にラップしている。

## <コンテキストでキャンセル>
```go
func main() {
  gen := func(ctx context.Context) <-chan int {
    dst := make(chan int)
    n := 1

    go func() {
      for {
        select {
        // 引数に受け取っているコンテキストの状態をctx.Done()で見ることによって、
        // それがキャンセルされたのかを確認
        case <-ctx.Done():
          return
        case dst <- n:
          n++
        }
      }
    }()
    return dst
  }

  // rootコンテキスト
  bc := context.Background()
  // rootコンテキストから作成した、キャンセル機能を持つコンテキスト
  ctx, cancel := context.WithCancel(bc)

  // 下のforループが終わったら、コンテキストをキャンセルして、チャネルを閉じる
  defer cancel()

  for n := range gen(ctx) { // forループには、チャネル（gen()の返り値）も取れる
    fmt.Println(n)
    if n == 5 {
      break
    }
  }
}

```