---
title: "Go_その他"
---

# Go のインストール、バージョン管理

## インストール

インストールは、ここから普通に GUI で MacOS(ARM64)用の.pkg ファイルを落とした。
https://go.dev/doc/install

```sh
$ go version
go version go1.22.4 darwin/arm64

$ which go
/usr/local/go/bin/go

# /usr/local/go は GOROOT

$ cat .zshrc
export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
eval "$(anyenv init -)"

$ echo $PATH
/Users/itoutakuya/.anyenv/envs/nodenv/shims:/Users/itoutakuya/.anyenv/envs/nodenv/bin:/opt/homebrew/bin:/usr/local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/go/bin
# 長くて分かりづらいが、出力の最後が ...:/usr/local/go/bin となっている → パスが通っている
```

## 複数バージョン管理

今後、別のバージョンを追加したい場合は下記。

```sh:go1.17.7の例
$ go install golang.org/dl/go1.17.7@latest
$ go1.17.7 download
```

### 導入時のエラー

ここに書いているとおり。なのだがエラー起きたりしたのでそれはメモに残す。
https://go.dev/doc/manage-install#installing-multiple

- go install 時、バージョンが古すぎると M1Mac では動かなかったので、ある程度は新しめのバージョン以降じゃないとダメ。

  ```sh
  $ go install golang.org/dl/go1.10.7@latest # NG

  $ go install golang.org/dl/go1.17.7@latest # OK
  ```

- go install 後、`go1.17.7 download`が実行できなかったが、パスを通して解決。
  go の 1.17.7 自体は、~/go/bin にあるのだが、PATH になかったことが原因。

  ```sh
  $ go env GOPATH
  /Users/itoutakuya/go

  $ ls ~/go/bin
  go1.17.7	gopls		staticcheck

  $ vi .zshrc
  $ cat .zshrc
  export PATH=/opt/homebrew/bin:/usr/local/bin:$PATH
  eval "$(anyenv init -)"
  # 追加
  export PATH=$PATH:$(go env GOPATH)/bin
  ```

