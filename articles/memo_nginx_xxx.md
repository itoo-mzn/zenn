---
title: "Nginxについて"
emoji: "📚"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Nginx"]
published: false
---

# Nginxとは
Webサーバ。（Webアプリケーションだけあっても使えない。）

Apacheとよく比較される。
Apacheの「クライアント１万台問題（C10K問題）」を解消するために作られたWebサーバがNginx。

Nginxは動的コンテンツなどの処理は苦手なので、重たい処理はアプリケーションサーバに任せるなどの対策が必要。

## Nginxの設定ファイル
（yumの場合）Nginxの設定ファイルが置いてある場所は「/etc/nginx」。

（これは、yumでインストールした各サーバの設定ファイルは、「/etc」ディレクトリの下に作られるという決まりがあるから。
Nginxもこれに従い、「/etc/nginx」ディレクトリがインストールと同時に自動生成される。）

## ディレクティブとは
ここから先に出てくるNginxの設定ファイル内の「server」や「listen」、「location」などの項目を`ディレクティブ`という。
Nginxの設定は、この**ディレクティブを指定し、続けてどのような動きをさせたいのかを記述することで、設定していく**。

Nginxのディレクティブには大きくわけて２種類あります。
1. 変数型のディレクティブ
  ソースファイルのルートディレクトリを指定する`root /var/www/html;`や、
  ログを書き込むファイルを指定する`access_log /var/log/nginx/access_log;`など。
2. スコープで範囲指定するタイプのディレクティブ
  httpサーバ範囲を示す`http {}`や、ドメイン範囲を示す`server {}`など。

#### コンテキストとは
スコープ型ディレクトリの**範囲**のこと。
原則として、ディレクティブはコンテキストの中に記述しなければいけません。
## 設定ファイルが読み込まれる順番
Nginxの設定ファイルはデフォルトで２つあり、以下の順番で読み込まれます。
1. /etc/nginx/nginx.conf
2. /etc/nginx/conf.d/default.conf

これは、「nginx.conf」ファイルを確認することで説明できます。
```
$ cat /etc/nginx/nginx.conf
user  nginx;
worker_processes  1;
            ：
            ：
    include /etc/nginx/conf.d/*.conf;
}
```
「include」ディレクティブで、読み込むファイルを指定しています。
ここでは「/etc/nginx/conf.d/*.conf」のパターンにマッチするファイルを読み込むという意味になります。

## ドキュメントルートの場所
Nginxにブラウザからアクセスすると「Welcome to nginx!」という初期画面が表示されましたが、これはデフォルトのドキュメントルートにHTMLファイルが置かれているからです。
**ドキュメントルートとは、Webサーバにアクセスがあった際に参照するディレクトリのこと**です。

ドキュメントルートやHTMLファイルについては、「/etc/nginx/conf.d/default.conf」を開くことで確認できます。
```
$ cat /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
              ：
              ：
}
```
「root /usr/share/nginx/html;」でドキュメントルートを指定し、「index index.html index.htm;」でデフォルトで参照するファイルが指定されています。

つまり、Nginxにアクセスがあると、「/usr/share/nginx/html」ディレクトリの「index.html（なければ「index.htm」）」を参照する設定になっているのです。

---

# NginxとRails（Puma）をソケット通信で連携させる
Railsで開発したWebアプリケーションを公開するときは、「Nginx」などのWebサーバと連携するのが一般的です。
Railsは内部で「Puma」というWebサーバを起動していますが、Webサーバとしての機能が貧弱なため、アプリケーションサーバとして使われることのほうが多いからです。

今回は、アプリケーションサーバとして使っているPumaを、WebサーバであるNginxと連携させて、大量のアクセスにも耐えられるようにします。

:::message　alert
公開するアプリを置いておく場所として、ホームディレクトリは適切ではない。
今回は「nginxユーザー」がRailsアプリのディレクトリにアクセスする予定なので、ホームにあると都合が悪いのもあります。
ホームの下にRailsアプリがあると、NginxはPumaとソケット通信できないので注意。
:::

## Pumaのソケット通信設定
Rails（Puma）とNginxを連携させるために、Pumaの設定ファイルを修正します。
具体的には、「**UNIXドメインソケット通信**（**ソケット通信**）」をするための設定になります。
この**ソケット通信は、NginxとRailsが同じマシンに存在している場合のみできる設定**です。

### ソケットの設定
Pumaを起動したときに、ソケットである「puma.sock」を生成するよう設定します。
「puma.sock」は、Nginxとソケット通信をする際に必要になるファイルです。
```
# Puma.rbに下記1行を追記
bind "unix://#{Rails.root}/tmp/sockets/puma.sock"
```

### Pumaのデーモン化
「rails s」コマンド実行時、Pumaをバックグラウンドで動かしたい場合は、以下を記述してください。
（止めるときはkill）
```
# Puma.rbに下記1行を追記
daemonize true
```
# 参考サイト
https://kitsune.blog/engineer/nginx
https://shiro-secret-base.com/?p=436