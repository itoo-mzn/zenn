---
title: "terraformメモ"
emoji: "📚"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["terraform"]
published: false
---

```
.
├── README.md
├── build
│   ├── プロジェクト1用(cmap-rails)
│   │   ├── main.tf (main関数)
│   │   ├── templates
│   │   │   ├── appspec.yml (CodeDeployが使用。)
│   │   │   ├── buildspec.yml
│   │   │   └── task_definition.json
│   │   └── variables.tf (変数だが、スコープがわからない????????)
│   └── プロジェクト2用(cmap-universe)(略)
├── diagram
│   └── 構成図.drawio
└── modules (共通部品)
    ├── acm (ディレクトリ名は自由に決められる)
    │   ├── main.tf (モジュールのmain関数)
    │   ├── outputs.tf (返り値)
    │   └── variables.tf (変数だが、スコープがわからない????????)
    ├── alb
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── security_group.tf (outputs.tfで定義すれば、alb.aws_security_groupなど（名前は好きに決める）として参照できる)
    │   ├── subnet.tf
    │   └── variables.tf
（以下略）
```