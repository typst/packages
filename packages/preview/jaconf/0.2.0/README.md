# Japananese Conference of Engineering

This is a template for **academic conference papers in Japanese**.

日本語の学会論文テンプレート。

## Usage

You can use this template in the Typst web app by clicking "Start from template"
on the dashboard and searching for `jaconf`.

Alternatively, you can use the CLI to kick this project off using the command

```
typst init @preview/jaconf
```

Typst will create a new directory with all the files needed to get you started.

## Configuration

This template exports the `jaconf` function with the following named arguments:

- 基本　Basic
  - `title-ja`: 日本語タイトル。The paper's title in Japanese.
  - `title-en`: 英語タイトル。The paper's title in English.
  - `authors-ja`: 日本語著者名。The Authors' name and affiliations in Japanese.
  - `authors-ja`: 英語著者名。The Authors' name and affiliations in English.
  - `abstract`: 概要。The content of a brief summary or `none`.
  - `keywords`: キーワード。Array of index terms to display after the abstract.
- フォント名　Font family
  - `font-heading`: 見出しに使うフォント。サンセリフ体、ゴシック体などの指定を推奨。Heading font. A sans-serif style (e.g., Gothic) is recommended.
  - `font-main`: 本文に使うフォント。セリフ体、明朝体などの指定を推奨。Main body font. A serif style (e.g., Mincho) is recommended.
  - `font-latin`: 英文に使うフォント。The Latin font used for description in English.
  - `font-math`: 数式に使うフォント。The math font used for equations.
- 外観　Appearance
  - `paper-columns`: 段組みの数。Number of columns.
  - `page-number`: ページ番号の体裁。Page numbering style.
  - `margin-top`: 上部余白
  - `margin-bottom`: 下部余白
  - `margin-side`: 両端余白
  - `column-gutter`: 左右余白（それぞれ）
  - `spacing-heading`: 見出しと本文の空き。Spacing between headings and main texts.
  - `bibliography-style`: 参考文献リストの体裁。
  - `abstract-language`: アブストラクトの言語。これによってアブストラクトのフォントが決まります。The language of the abstract determines the fonts used for Japanese and English.
- 見出し　Headings
  - `heading-abstract`: アブストラクトの見出し
  - `heading-keywords`: キーワードの見出し
  - `heading-bibliography`: 参考文献の見出し
  - `heading-appendix`: 付録の見出し
- フォントサイズ　Font size
  - `font-size-title-ja`: 日本語タイトルのフォントサイズ
  - `font-size-title-en`: 英語タイトルのフォントサイズ
  - `font-size-authors-ja`: 日本語著者名のフォントサイズ
  - `font-size-authors-en`: 英語著者名のフォントサイズ
  - `font-size-abstract`: 概要のフォントサイズ
  - `font-size-heading`: 見出しのフォントサイズ
  - `font-size-main`: 本文のフォントサイズ
  - `font-size-bibliography`: 参考文献リストのフォントサイズ
- 補足語　Supplement
  - `supplement-image`: 図タイトルの接頭辞
  - `supplement-table`: 表タイトルの接頭辞
  - `supplement-separator`: 接頭辞とタイトルの区切り文字
- 番号付け　Numbering
  - `numbering-headings`: 本文の見出し番号の体裁
  - `numbering-equation`: 式番号の体裁
  - `numbering-appendix`: 付録の見出し番号の体裁。`#show: appendix.with(numbering-appendix:` の呼び出しにも同じ引数を与えてください。

The function also accepts a single, positional argument for the body of the
paper.

The template will initialize your package with a sample call to the `jaconf`
function in a show rule. If you want to change an existing project to use this
template, you can add a show rule like this at the top of your file:

```typ
// デフォルト値でよい引数は省略可能
#show: jaconf.with(
  // 基本 Basic
  title-ja: [日本語の学会論文Typstテンプレート \ jaconf ],
  title-en: [How to Write a Conference Paper in Japanese],
  authors-ja: [◯ 著者姓1 著者名1、著者姓2 著者名2(○○○大学)、著者姓3 著者名3 (□□□株式会社)],
  authors-en: [\*A. First, B. Second (○○○ Univ.), and C. Third (□□□ Corp.)],
  abstract: [#lorem(80)],
  keywords: ([Typst], [conference paper writing], [manuscript format]),
  // フォント名 Font family
  font-heading: "Noto Sans CJK JP",  // サンセリフ体、ゴシック体などの指定を推奨
  font-main: "Noto Serif CJK JP",  // セリフ体、明朝体などの指定を推奨
  font-latin: "New Computer Modern",
  font-math: "New Computer Modern Math",
  // 外観 Appearance
  paper-columns: 2,  // 1: single column, 2: double column
  page-number: none,  // e.g. "1/1"
  margin-top: 20mm,
  margin-bottom: 27mm,
  margin-side: 20mm,
  column-gutter: 4%+0pt,
  spacing-heading: 1.2em,
  bibliography-style: "sice.csl",  // "sice.csl", "rsj.csl", "ieee", etc.
  abstract-language: "en",  // "ja" or "en"
  // 見出し Headings
  heading-abstract: [*Abstract--*],
  heading-keywords: [*Key Words*: ],
  heading-bibliography: [参　考　文　献],
  heading-appendix: [付　録],
  // フォントサイズ Font size
  font-size-title-ja: 16pt,
  font-size-title-en: 12pt,
  font-size-authors-ja: 12pt,
  font-size-authors-en: 12pt,
  font-size-abstract: 10pt,
  font-size-heading: 11pt,
  font-size-main: 10pt,
  font-size-bibliography: 9pt,
  // 補足語 Supplement
  supplement-image: [図],
  supplement-table: [表],
  supplement-separator: [: ],
  // 番号付け Numbering
  numbering-headings: "1.1",
  numbering-equation: "(1)",
  numbering-appendix: "A.1",  // #show: appendix.with(numbering-appendix: "A.1") の呼び出しにも同じ引数を与えてください。
)
```
