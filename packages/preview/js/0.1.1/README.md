# Typst template based on LaTeX jsarticle/jsbook

A package/template created in the same spirit as the widely used Japanese LaTeX document classes jsarticle and jsbook, designed by their original author. For Typst 0.13.0 and later. Licensed under MIT-0. Feel free to use or modify it as you wish.

## Usage

```
#import "@preview/js:0.1.1": *

#show: js.with(
  // lang: "ja",
  // seriffont: "New Computer Modern", // or "Libertinus Serif", ...
  // seriffont-cjk: "Harano Aji Mincho", // or "Yu Mincho", "Hiragino Mincho ProN", ...
  // sansfont: "Source Sans Pro", // or "Arial", "Helvetica", ...
  // sansfont-cjk: "Harano Aji Gothic", // or "Yu Gothic", "Hiragino Kaku Gothic ProN", ...
  // paper: "a4", // "a*", "b*", or (paperwidth, paperheight) e.g. (210mm, 297mm)
  // fontsize: 10pt,
  // baselineskip: auto,
  // textwidth: auto,
  // lines-per-page: auto,
  // book: false, // or true
  // cols: 1, // 1, 2, 3, ...
  // non-cjk: regex("[\u0000-\u2023]"),  // or "latin-in-cjk" or any regex
  // cjkheight: 0.88, // height of CJK in em
)

#maketitle(
  title: "Typst日本語用テンプレートjs",
  authors: "奥村 晴彦",
  // authors: ("奥村 晴彦", "何野 何某"),
  // authors: (("奥村 晴彦", "三重大"), ("何野 何某", "某大")),
  // authors: (("奥村 晴彦", "三重大", "okumura@okumuralab.org"), ("何野 何某", "某大")),
  abstract: [
    p#LaTeX のjsarticle/jsbookに似た出力をするTypstテンプレートです。
  ]
)

= はじめに

日本語の説明は https://github.com/okumuralab/typst-js をご覧ください。
```

## ChangeLog

### 0.1.1

* Improved spacing around headings for non-`book` mode (default) to ensure they occupy integer multiples of lines.
