---
title: "ChatGPT"
emoji: "🌟"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["ChatGPT"]
published: false
---

# 用途例
- 要約してもらう。

- コード、SQLを教えてもらう。

https://qiita.com/devneko/items/0dc9fd8b37419d9e369c?utm_source=Qiita%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9&utm_campaign=0879695d15-Qiita_newsletter_555_03_01_2023&utm_medium=email&utm_term=0_e44feaa081-0879695d15-34065145

- 要件定義

https://dev.classmethod.jp/articles/gpt-requirement-definition/

- 学習に役立てる

https://qiita.com/tak001/items/7605f0be7b424118e5a5?utm_source=Qiita%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9&utm_campaign=0879695d15-Qiita_newsletter_555_03_01_2023&utm_medium=email&utm_term=0_e44feaa081-0879695d15-34065145


# プロンプトエンジニアリング
## プロンプトエンジニアリング　ガイド
https://www.promptingguide.ai/jp
↑のガイドのまとめ記事
https://dev.classmethod.jp/articles/how-to-design-prompt-engineering/

## 基本構文
4つの要素に分解して質問する。

1. Instruction（質問・指示）
・絶対にやって欲しいことを簡潔・明瞭に記載する。
・絶対に最初に書く。

2. Input（入力）
・インストラクションで処理してもらいたいテキスト・コードなどを貼り付ける。

3. Context（予備知識）
・やって欲しいことをこなす際に、絶対に必要になる知識や文脈。

4. Output（出力）
・どういう形式で回答して欲しいかを定める。

```
## Instruction ##
1. ## input ##の内容を踏まえて、私にキャリアパスを提案してください。

## Input ##
1. https://logmi.jp/tech/articles/328014
2. https://qiita.com/vankobe/items/9a951d814db6b1180074

## Context ##
1. 私はwebエンジニアです。
2. 私は現在32歳で、65歳まで働きます。

## Output ##
1. 提案するキャリアパスは5つです。
2. 提案するキャリアパスには職種名を含めてください。
```
※ *ちなみに↑のプロンプトは上手く動かない。Inputとしてwebサイトを載せてもその内容まで読み取ってくれない。*

## パターン
https://qiita.com/sonesuke/items/981925cfcc610a602e94?utm_source=Qiita%E3%83%8B%E3%83%A5%E3%83%BC%E3%82%B9&utm_campaign=9a40bfae49-Qiita_newsletter_558_03_22_2023&utm_medium=email&utm_term=0_e44feaa081-9a40bfae49-34065145


# 生存戦略
- エンジニアには「コードを書くこと」自体では無く、「ビジネスサイドが実現したいこと」を実現する能力がより強く求められるようになる。

- 「要件定義はビジネスサイドがやるもの」という意識のまま、要件どおりにコードを書くだけの仕事をしているとAIに仕事を奪われるリスクが高い。

- 「人間でないとできないこと」をできるようにならないといけない。

- 自分が培ってきたスキル・専門性とAI（GPT）を掛け合わせて価値を出す。
  （自分のスキル ✕ AI = 新たな価値）


## (参考情報)
https://qiita.com/lazy-kz/items/e4932f1a90c2a7986ef5#3-%E3%81%93%E3%82%8C%E3%82%92%E5%89%8D%E6%8F%90%E3%81%A8%E3%81%97%E3%81%9F%E3%82%A8%E3%83%B3%E3%82%B8%E3%83%8B%E3%82%A2%E3%81%AE%E7%94%9F%E5%AD%98%E6%88%A6%E7%95%A5

以上