---
title: "Rubyでcsvからjsonに変換"
emoji: "😎"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["Ruby", "csv", "json"]
published: true
---

# 概要
あるWebサイトから取得し、CSVに整形したデータ(数十件)をcurlでPOSTしたいと場面があった。
そこで、CSVをJSONに変換して、curlのbodyはコピペで済ませられるようにした。

```ruby
require 'csv'
require 'json'

body = File.open('csv_file.csv').read

# csvオブジェクトを作成
csv = CSV.new(
  body,
  headers: true, # CSVファイルの一行目をヘッダとして扱う
  header_converters: :symbol, # ヘッダをシンボルに変換
  force_quotes: true # 文字をダブルクォーテーションで囲む
)

# csvを1行ずつハッシュに変換(この時点でヘッダがキーになっている)
rows = csv.to_a.map { |row| row.to_hash }

# jsonに変換してファイルに書き込み(作成)
File.open("json_file.json", "w") { |f| f.write rows.to_json }
```

これでできたJSONを1件ずつコピってcurl。

以上