---
title: "Go_log"
---

# ログ

```go:log.Fatal, log.SetPrefix
func main() {
	log.Print("Printログ1")

	log.SetPrefix("main(): ") // ログにprefixを設定
	log.Print("Printログ2")

	log.Fatal("最終ログ")
	log.Print("Printログ3 log.Fatalで終了させるためこれは実行されない")
	/*
		2023/08/24 06:48:09 Printログ1
		main(): 2023/08/24 06:48:09 Printログ2
		main(): 2023/08/24 06:48:09 最終ログ
		exit status 1
	*/
}
```

```go:log.Panic
func main() {
  log.Print("printろぐ")
  // → 2021/08/09 07:23:53 printろぐ

  log.Panic("panicろぐ")
  fmt.Print("これは見えない")
  // → panic: panicろぐ
  //   goroutine 1 [running]:
  //   log.Panic(0xc0000c3f58, 0x1, 0x1)
  //       /usr/local/go/src/log/log.go:354 +0xae
  //   main.main()
  //       /Users/itotakuya/projects/go/src/helloworld/main.go:814 +0xa5
  // Panic()以降は実行されない
}
```

## ファイルにログを記録

```go:main.go
func main() {
  // ファイル作成
  file, err := os.OpenFile("ingo.log", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
  if err != nil {
    log.Fatal("エラー発生")
  }
  defer file.Close()

  // 通常通り、標準出力へ
  log.Print("ログ1")

  // fileにログを記録することを宣言
  // これ以降、log出力すると、ファイルに記録される
  log.SetOutput(file)

  // ファイルに書き込まれる
  log.Print("ログ2")
}
```
