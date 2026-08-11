#import "@preview/jastylest:0.1.1"
#import jastylest: empty-slide, finished-page, title-block
#import jastylest.katex-font: * // ここを消すといつも通りのcal, frakが使えます

#show: jastylest.slide.with(
  // font: "Arial",
  // font-cjk: "Harano Aji Gothic",
  // paper: "presentation-4-3",
  // height: 1080pt,
  // font-size: 24pt,
  // margin: 30pt,
  // title-color: red,
  title: [jslideの使い方],
  author: ("raygo", "etc."),
  // date: none,
)

== 目次
#outline()

= ここにセクションが書けます

== ページを分けることができます
こんにちは

== 長い時はタイトルにナンバーが割り振られます

#lorem(500)

そして中段に配置されます

= 二つ目のセクション

== タイトルブロック
#title-block(title: [定理])[
  これは定理です
  $ forall n in NN, n + 0 = n $
]
#title-block(title: [例], title-color: red)[色をかえられます]
#title-block[
  タイトルがなくてもよいです
]

== 白紙
次のページは白紙です

#empty-slide()

headingを更新しないとナンバリングが引き継がれます


ページもここで終了しときましょう
#finished-page()

== ここからは補足

補足として書くといいかもしれません


