---
title: "サーバーの基本"
emoji: "🐱"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["サーバー"]
published: false
---

# 書籍
https://www.amazon.co.jp/%E3%82%A4%E3%83%A9%E3%82%B9%E3%83%88%E5%9B%B3%E8%A7%A3%E5%BC%8F-%E3%81%93%E3%81%AE%E4%B8%80%E5%86%8A%E3%81%A7%E5%85%A8%E9%83%A8%E3%82%8F%E3%81%8B%E3%82%8B%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%81%AE%E5%9F%BA%E6%9C%AC-%E3%81%8D%E3%81%AF%E3%81%97-%E3%81%BE%E3%81%95%E3%81%B2%E3%82%8D/dp/4797386665

# 1. サーバーとは
- サーバーとは、サーバーソフトウェアを入れたPC。
  - webサーバー用ソフトウェアをインストールして起動すれば、webサーバーになる。
- 1台のPCに、複数のサーバーソフトウェアを入れて、複数の（サーバーの）役割を任せることができる。
- メールの送信はSMTP、受信はPOPというプロトコルを使う。(webはHTTP(S))

| サーバーの種類 | 要約 | 代表的なソフトウェア |
| ---- | ---- | ---- |
| webサーバー | HTTPに則りクライアントと通信し、リクエストを受け取って何らかの処理をするもの。そして、場合によってはアプリケーション(例:Rails)にリクエストを投げる。 | Apache, IIS(マイクロソフト), nginx |
| webアプリケーションサーバー | RailsでいうとPumaやUnicornなど。Railsアプリケーションを動かしているもの。 | Tomcat, WeblogicServer(オラクル), IIS(マイクロソフト) |
| SSLサーバー | 証明書 | OpenSSL |
| DNSサーバー |  | 略 |
| プロキシサーバー |  | 略 |
| メール(SMTP/POP)サーバー |  | 略 |
| FTPサーバー |  | 略 |
| DBサーバー |  | MySQL, Oracle(オラクル), SQL Server(マイクロソフト) |
| NTPサーバー |  | 略 |
| Syslogサーバー |  | 略 |
| SNMPサーバー |  | 略 |

##### 参考記事
https://qiita.com/jnchito/items/3884f9a2ccc057f8f3a3

# 3. サーバーを用意する
- サーバー用のOSをサーバーOSという。UNIX系サーバーOSとWindows系サーバーOSがある。
  - UNIX系 : Linux, AIX(IBM)など
    - Linuxのディストリビューション (=Linuxカーネルとその他の機能をまとめ、ユーザが使いやすいようにしたもの。)
      - RedHat : 大規模システムで使われる。有料。
      - CentOS : RedHatの商用部分を除いたもの。
      - Debian : 広く使われている。
      - Ubuntu : Debianベース。使いやすい。
  - Windows系

# 4. 