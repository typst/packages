# jaconf

This is a template for **academic conference papers in Japanese**.

日本語の学会論文テンプレート。

## 使い方

- Typst CLIを使用する方法：Typstをインストールして以下のコマンドを実行。

   ```
   typst init @preview/jaconf
   ```

- Typst Appを使用する方法：Typst Appでアカウントを作成してログイン。`Start from template`からテンプレート名を検索して`Project Title`を記入して`Create`をクリック。

日本語でより詳細な情報をお求めの方は[Zennの記事](https://zenn.dev/kimushun1101/articles/typst-template)をご覧ください。

## 関数

このテンプレートが提供する `jaconf` 関数は、以下の名前付き引数を持ちます。

- 基本　Basic
  - `title`: 日本語タイトル
  - `title-en`: 英語タイトル
  - `authors`: 日本語著者名とその所属
  - `authors`: 英語著者名とその所属
  - `abstract`: 概要
  - `keywords`: キーワード。配列で渡してください
- フォント名
  - `font-heading`: 見出しに使うフォント。サンセリフ体、ゴシック体などの指定を推奨。
  - `font-main`: 本文に使うフォント。セリフ体、明朝体などの指定を推奨。
  - `font-latin`: 英文に使うフォント
  - `font-math`: 数式に使うフォント
- 外観　Appearance
  - `paper-margin`: 余白
  - `paper-columns`: 段組みの数
  - `page-number`: ページ番号の体裁
  - `column-gutter`: 左右余白（それぞれ）
  - `spacing-heading`: 見出しと本文の空き
  - `front-matter-order`: 前付けのコンテンツの表示順番。カスタムコンテンツの追加も利用可能。
  - `front-matter-spacing`: 前付けの各コンテンツ間のスペース
  - `front-matter-margin`: 前付けと本文とのマージン
  - `abstract-language`: アブストラクトの言語。これによってアブストラクトのフォントが決まります。
  - `keywords-language`: キーワードリストの言語。これによってキーワードのフォントが決まります。
  - `bibliography-style`: 参考文献リストの体裁
- 見出し　Headings
  - `heading-abstract`: アブストラクトの見出し
  - `heading-keywords`: キーワードの見出し
  - `heading-bibliography`: 参考文献の見出し
  - `heading-appendix`: 付録の見出し
- フォントサイズ　Font size
  - `font-size-title`: 日本語タイトルのフォントサイズ
  - `font-size-title-en`: 英語タイトルのフォントサイズ
  - `font-size-authors`: 日本語著者名のフォントサイズ
  - `font-size-authors-en`: 英語著者名のフォントサイズ
  - `font-size-abstract`: 概要のフォントサイズ
  - `font-size-heading`: 見出しのフォントサイズ
  - `font-size-main`: 本文のフォントサイズ
  - `font-size-bibliography`: 参考文献リストのフォントサイズ
- 補足語　Supplement
  - `supplement-image`: 図タイトルの接頭辞
  - `supplement-table`: 表タイトルの接頭辞
  - `supplement-separator`: 図表の接頭辞とタイトルの区切り文字
  - `supplement-equation`: 本文中で引用する際に、数式番号につける接頭辞
- 番号付け　Numbering
  - `numbering-headings`: 本文の見出し番号の体裁
  - `numbering-equation`: 式番号の体裁
  - `numbering-appendix`: 付録の見出し番号の体裁。`#show: appendix.with(numbering-appendix:` の呼び出しにも同じ引数を与えてください。

文書ファイルの先頭で `jaconf` テンプレートを`import`して、引数付きのshowルールで呼び出してください。

```typ
#import "@preview/jaconf:0.7.0": jaconf, definition, lemma, theorem, corollary, proof, appendix

// デフォルト値でよい引数は省略可能
#show: jaconf.with(
  // 基本 Basic
  title: [日本語の学会論文Typstテンプレート \ jaconf ],
  title-en: [How to Write a Conference Paper in Japanese],
  authors: [◯ 著者姓1 著者名1、著者姓2 著者名2(○○○大学)、著者姓3 著者名3 (□□□株式会社)],
  authors-en: [\*A. First, B. Second (○○○ Univ.), and C. Third (□□□ Corp.)],
  abstract: [#lorem(80)],
  keywords: ([Typst], [conference paper writing], [manuscript format]),
  // フォント名 Font family
  font-heading: "Noto Sans CJK JP",  // サンセリフ体、ゴシック体などの指定を推奨
  font-main: "Noto Serif CJK JP",  // セリフ体、明朝体などの指定を推奨
  font-latin: "New Computer Modern",
  font-math: "New Computer Modern Math",
  // 外観 Appearance
  paper-margin: (top: 20mm, bottom: 27mm, left: 20mm, right: 20mm),
  paper-columns: 2,  // 1: single column, 2: double column
  page-number: none,  // e.g. "1/1"
  column-gutter: 4%+0pt,
  spacing-heading: 1.2em,
  front-matter-order: ("title", "authors", "title-en", "authors-en", "abstract", "keywords"),  // 独自コンテンツの追加も可能
  front-matter-spacing: 1.5em,
  front-matter-margin: 2.0em,
  abstract-language: "en",  // "ja" or "en"
  keywords-language: "en",  // "ja" or "en"
  bibliography-style: "sice.csl",  // "sice.csl", "rsj.csl", "ieee", etc.
  // 見出し Headings
  heading-abstract: [*Abstract--*],
  heading-keywords: [*Keywords*: ],
  heading-bibliography: [参　考　文　献],
  heading-appendix: [付　録],
  // フォントサイズ Font size
  font-size-title: 16pt,
  font-size-title-en: 12pt,
  font-size-authors: 12pt,
  font-size-authors-en: 12pt,
  font-size-abstract: 10pt,
  font-size-heading: 12pt,
  font-size-main: 10pt,
  font-size-bibliography: 9pt,
  // 補足語 Supplement
  supplement-image: [図],
  supplement-table: [表],
  supplement-separator: [: ],
  supplement-equation: [],  // 式、Eq. など
  // 番号付け Numbering
  numbering-headings: "1.1",
  numbering-equation: "(1)",
  numbering-appendix: "A.1",  // #show: appendix.with(numbering-appendix: "A.1") の呼び出しにも同じ引数を与えてください。
)

= はじめに
本文を記載していく。
```

## 定理環境

定理環境を使用するために、以下の関数も提供します。

- `definition`: 定義
- `lemma`: 補題
- `theorem`: 定理
- `corollary`: 系
- `proof`: 証明

以下のように使用できます。

```typ
#definition("用語 A")[
  用語 A の定義を書きます。
]<def:definition1>
#lemma[
  補題を書きます。タイトルは省略することもできます。
]<lem:lemma1>
#lemma("補題 C")[
  補題を書きます。番号は定義や補題ごとに 1 からカウントします。
]<lem:lemma2>
#theorem("定理 D")[
  ここに定理を書きます。
]<thm:theorem1>
#corollary[
  系を書きます。@def:definition1 のように、ラベルで参照することもできます。
]
#proof([@thm:theorem1 の証明])[
  証明を書きます。証明終了として□印をつけています。
]
```

## 付録

付録を追記するために、`appendix`関数も提供します。
参考文献の後ろに付録を付けたい場合には、引数として`jaconf`に設定したものと同様の`numbering-appendix`を与えて、showルールで呼び出してください。
この関数の呼び出し以降の見出し番号と図表番号が、設定した番号へと変化します。

```typ
#show: appendix.with(numbering-appendix: "A.1")
```
