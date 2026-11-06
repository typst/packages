#import "@preview/js:0.1.2": *
// or put your modified `js.typ` in the same folder and `#import "js.typ": *`

#show: js.with(
  lang: "ja",
  seriffont: "New Computer Modern",
  seriffont-cjk: "Harano Aji Mincho", // or "Yu Mincho" or "Hiragino Mincho ProN"
  sansfont: "Source Sans Pro", // or "Arial" or "Helvetica"
  sansfont-cjk: "Harano Aji Gothic", // or "Yu Gothic" or "Hiragino Kaku Gothic ProN"
  paper: "a4", // "a*", "b*", or (paperwidth, paperheight) e.g. (210mm, 297mm)
  fontsize: 10pt,
  baselineskip: auto,
  textwidth: auto,
  lines-per-page: auto,
  book: false, // or true
  cols: 2, // 1, 2, 3, ...
  non-cjk: regex("[\u0000-\u2023]"),  // or "latin-in-cjk" or any regex
  cjkheight: 0.88, // height of CJK in em
)

#maketitle(
  title: "Typst日本語用テンプレートjs",
  authors: "奥村 晴彦",
  // authors: ("奥村 晴彦", "何野 何某"),
  // authors: (("奥村 晴彦", "三重大"), ("何野 何某", "某大")),
  // authors: (("奥村 晴彦", "三重大", "okumura@okumuralab.org"), ("何野 何某", "某大")),
  abstract: [
    p#LaTeX のjsarticle/jsbookに似た出力をするTypstテンプレートです。自由に修正してお使いください。
  ]
)

#outline() #v(1em)

= これは何？

Typst日本語用テンプレートです。(u)p#LaTeX のjsarticle/jsbook相当品のつもりです。このファイル `example.typ` の頭の部分（特に使用フォント）を必要に応じて書き直してお試しください。

冒頭の「目次」は `#outline()` で出しています。邪魔ならこの1行を消してください。

`book: true` にすると書籍用のレイアウトになります。この場合、#LaTeX の `\frontmatter` に相当するものとして
```
#set heading(numbering: none)
#set page(numbering: "i")
```
#noindent[`\mainmatter` に相当するものとして]
```
#pagebreak(weak: true, to: "odd")
#set heading(numbering: "1.1")
#counter(page).update(1)
#set page(numbering: "1")
```
#noindent[`\backmatter` に相当するものとして]
```
#set heading(numbering: none)
```
#noindent[のような感じにするとよさそうです。]

= 数式

慣れないうちは #LaTeX で書いて
```
pandoc in.tex -o out.typ
```
#noindent[でTypstに翻訳すると楽です。]

$ (integral_0^oo (sin x) / sqrt(x) d x)^2
  &= sum_(k = 0)^oo ((2 k)!) / (2^(2 k) (k!)^2) 1 / (2 k + 1) \
  &= product_(k = 1)^oo (4 k^2) / (4 k^2 - 1) = pi / 2 $

= おまけ

簡単なマクロもいくつか含めています。例：

```
#kintou(5em)[超電磁砲]
```

#quote[
  #kintou(5em)[超電磁砲]
]

```
とある#ruby[科][か]#ruby[学][がく]の#ruby[超電磁砲][レールガン]
```

#quote[
  とある#ruby[科][か]#ruby[学][がく]の#ruby[超電磁砲][レールガン]
]
