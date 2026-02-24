// MIT No Attribution
// Copyright 2024, 2025 Shunsuke Kimura

#import "@preview/jaconf:0.6.0": jaconf, definition, lemma, theorem, corollary, proof, appendix

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

// この文書特有の関数を定義
// 赤字で警告する
#let red-warn(it) = text(it, fill: rgb(red), weight: "bold")
// リンクを青文字にする
#show link: set text(fill: blue)
// 句読点をカンマとピリオドに変換
#show "、": "，"
#show "。": "．"

= はじめに <sec:intro>
#red-warn[実用の際には適宜投稿先の規定を必ずご確認ください。]
発表論文原稿をPDFでご執筆いただき、学会のホームページにアップロードしてください。
このファイルはこのテンプレートの使い方を示しており、同時に発表論文の見本でもあります。
執筆の時は以下の説明をよく読み、執筆要項に従ったフォーマットでご提出ください。
アップロードしたPDFがそのまま公開されます。
などの説明が書かれるであろうテンプレートを作ってみました。
本稿では、このテンプレートファイルの使い方および Typst による執筆作業の概要について解説します。
この原稿のソースコードは https://github.com/kimushun1101/typst-jaconf で公開しております。
ご要望や修正の提案があれば、Issue や Pull Request でお知らせください。筆者に届く形であればSNSなど他の手段でも構いません。
Typst の概要についてお知りになりたい方は、https://github.com/kimushun1101/How-to-use-typst-for-paper-jp にもスライド形式の資料を用意しておりますので、ぜひこちらもご覧ください。

= テンプレートファイルの使い方 <sec:usage>

== コードの例
数式番号は @eq:system のように数式の右側に、図のタイトルは "@fig:quadratic タイトル名"のように図の下部に、表のタイトルは "@tab:fonts タイトル名" のように図の上部につきます。
投稿先に応じてキャプションの言語は日本語や英語で指定されるかと思いますので、指示に従ってください。

=== 数式
出力例はつぎの通りです。
以下のシステムを考える。
$ dot(x) &= A x + B u \
 y &= C x $ <eq:system>
ここで $x in RR^n$ は状態、$u in RR^m$ は入力、$y in RR^l$ は出力、$A in RR^(n times n)$、$B in RR^(n times m)$。および $C in RR^(l times n)$ は定数行列である。
このシステムに対して、目標値 $r(t)$ に対する偏差を $e = r - y$ とした以下の PI 制御器を使用する。
$ u = K_P e + K_I integral_0^t e d t $ <eq:PI-controller>
ただし、$K_P$ と $K_I$ はそれぞれ比例ゲイン、積分ゲインとする。

=== 表
表の例は @tab:fonts です。
#figure(
  placement: bottom,
  caption: [フォントの設定],
  table(
    columns: 3,
    stroke: none,
    table.header(
      [項目],
      [サイズ (pt)],
      [フォント],
    ),
    table.hline(),
    [タイトル], [16], [ゴシック体],
    [著者名], [12], [ゴシック体],
    [章タイトル], [12], [ゴシック体],
    [節、小節、本文], [10], [明朝体],
    [参考文献], [9], [明朝体],
  )
) <tab:fonts>

=== 画像
画像の例は @fig:quadratic です。
#figure(
  placement: top,
  box(stroke: 1pt, height:5cm, width: 90%),
  // image("figs/quadratic.svg", width: 90%),
  caption: [$x^2$ のグラフ],
) <fig:quadratic>

=== 定理環境 <sec:theorem>
以下はtheorem環境の使用例です。
定理などのタイトルフォントを`font-heading`（見出しのフォント）にしています。
#red-warn[`definition`, `lemma`, `theorem`, `corollary`, `proof`はこのテンプレートで定義している関数です。]
```typ
#import "@preview/jaconf:0.6.0": jaconf, definition, lemma, theorem, corollary, proof, appendix
```
#red-warn[他のテンプレートを使用する際には#link("https://github.com/kimushun1101/typst-jaconf/blob/5862f4fd21b4f00488a56657e198864625d117b8/jaconf-eng/lib.typ#L9-L35")[`lib.typ`のコード]を参考に、以下のようにご自身のコード内で定義および有効化をしてください。]

```typ
// Theorem environments
#let thmja = thmplain.with(base: {}, separator: [#h(0.5em)], titlefmt: strong, inset: (top: 0em, left: 0em))
#let definition = thmja("definition", context{text(font: query(<gothic-font>).first().value)[定義]})
#let lemma = thmja("lemma", context{text(font: query(<gothic-font>).first().value)[補題]})
#let theorem = thmja("theorem", context{text(font: query(<gothic-font>).first().value)[定理]})
#let corollary = thmja("corollary", context{text(font: query(<gothic-font>).first().value)[系]})
#let proof = thmproof("proof", context{text(font: query(<gothic-font>).first().value)[証明]}, separator: [#h(0.9em)], titlefmt: strong, inset: (top: 0em, left: 0em))
// Enable packages.
#show: thmrules.with(qed-symbol: $square$)
```

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

=== 引用
引用は "\@label" と記述することで、数式であれば@eq:system、図であれば@fig:quadratic、表であれば@tab:fonts、セクションであれば@sec:intro、節や項があるセクションであれば@sec:theorem、付録セクションであれば@appendix:edit、参考文献であれば@kimura2015asymptotic のように表示されます。
参考文献は連続して引用すると @kimura2023doctor @kimura2021control @kimura2020facility @khalil2002control @sugie1999feedback @caamp2025aisuitcase と表示されます。
文法上では特に規則はありませんが、個人的にはラベルの命名規則として、数式の場合には "eq:" から、図の場合には "fig:" から、表の場合には"tab:" から、セクションの場合には "sec:" から、付録セクションであれば "appendix:" から始めるようにラベル名を設定しており、参考文献のラベルは "著者名発行年タイトルの最初の単語"で名付けております。

= おわりに <sec:conclusion>
対応していただきたい内容や修正していただきたい内容などありましたら、#link("https://github.com/kimushun1101/typst-jaconf")[GitHub] を通して、Issues や Pull Requests をいただけますと幸いです。
このテンプレートは日本語論文のために作成しておりますため、日本語での投稿で構いません。
誤字脱字や文法、表現など細かい修正でも大変ありがたいです。

#heading(numbering: none)[謝辞]
謝辞のように章番号が振られたくない見出しは以下のように設定します。
```typst
#heading(numbering: none)[謝辞]
```
謝辞のセクションでは、「この研究は☆☆☆の助成を受けて行われました。」や「〇〇〇大学との共同研究です。」
などの文章が書かれることを想定しています。
最後までお読みいただき誠にありがとうございました。

#bibliography("refs.yml", full: false)

#show: appendix

= 付録の書き方 <appendix:edit>
参考文献の後ろに付録を付けたい場合には、
```typ
  #show: appendix.with(numbering-appendix: "A.1")
```
を追加してください。
その場所に`heading-appendix`で設定した文字（デフォルトでは「付　録」）が挿入されます。
それ以降の章番号と図表番号が`numbering-appendix`で設定した体裁で見出しがつきます。
デフォルトである`"A.1"`ではアルファベット順につきます。

#figure(
  placement: bottom,
  box(stroke: 1pt, height:5cm, width: 90%),
  // image("figs/sqrt.svg", width: 90%),
  caption: [$sqrt(x)$ のグラフ],
) <fig:appendix>

`#show: appendix.with(numbering-appendix`の値を変更する場合には、
`#show: temp.with(`の引数である`numbering-appendix`の値も合わせて変更してください。
見出し番号をデフォルトから変更した際にこれを怠ると、付録の番号と@appendix:edit のようなラベルの番号の表記が一致しなくなります。

また、@sec:theorem に示す定理環境と同様に、
#red-warn[`appendix`はこのテンプレートで定義している関数です。]
