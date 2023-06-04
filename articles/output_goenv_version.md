---
title: "goenvの設定"
emoji: "💭"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Go", "goenv"]
published: true
---

# 何が起きたか
私は（anyenv経由で）goenvを使っています。
Goの1.20.4を使用したいと思い`goenv local 1.20.4`を実行しましたが、`go version`で確認すると指定したものとバージョンが異なっていました。

# 結論
GOROOTとGOPATHが設定できていなかったことが原因のようでした。

私はfish使いなので、設定ファイルである`~/.config/fish/config.fish`を下記のとおりに編集したところ、無事にgoenvで好きなバージョンを自在に設定できるようになりました。

```sh
# goenvの設定
set -x GOENV_ROOT $HOME/.anyenv/envs/goenv
set -x PATH $GOENV_ROOT/bin $PATH
set -gx PATH $GOENV_ROOT/shims $PATH

# GOROOT, GOPATHの設定ができていなかった
set -x PATH $GOROOT/bin $PATH
set -x PATH $PATH $GOPATH/bin

# eval要らない。
#eval (goenv init - | source)
goenv init - | source
```

設定ファイルを編集した後は、シェルの再起動（`exec $SHELL -l`）をお忘れなく。
