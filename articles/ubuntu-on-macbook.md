---
title: "MacbookにUbuntuを入れてデュアルブート"
emoji: "😺"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

# 用意するもの
- もう使わないMac(Macbook Air 2019)
  - インターネットと通信可能であること。
- [USB(3.0)](https://www.amazon.co.jp/gp/product/B00TMYO5LK/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1)
- [USBハブ(Type C - USB(3.0対応)変換。MacにUSB差し込む用。)](https://www.amazon.co.jp/gp/product/B097MBFCXK/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1)

# MacにUbuntuを入れてデュアルブート起動させる手順

https://sy-base.com/myrobotics/mac/mac_ubuntu/

1. ハードディスクのパーティションを作成する。
ハードディスクを分割して、Ubuntuを使用する専用スペースを作成します。
2. ブータブルUSBの作成
Ubuntuをインストールするための専用のUSBを作成します。
3. ブータブルUSBを用いてUbuntuをインストール
2.で作成したブータブルUSBを用いてUbuntuをインストールします。
4. rEFIndをインストール
rEFIndというOSのセレクタを導入することで、起動時にUbuntuのディスクが見えるようにします。