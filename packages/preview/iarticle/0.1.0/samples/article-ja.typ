// iarticle (ireport の章立てなし版) のサンプル文書。章はなく、節が
// トップレベルになり、強制改ページや既定の目次自動挿入もない (すべて
// 呼び出し側で上書き可能 - README 参照)。章立てのある側は
// samples/report-ja.typ を参照。
//
// コンパイルする前に、ローカルのチェックアウトを
// @preview/iarticle:0.1.0 として登録するため、一度だけ
// ../install_for_test.sh を実行してください。
#import "@preview/iarticle:0.1.0": iarticle, appendix

#show: iarticle.with(
  lang: "ja",
  title: "TODO: 論文タイトル",
  authors: ("TODO: 著者名",),
  abstract: [
    TODO: 本論文の概要を一段落で。
  ],
)

= TODO: はじめに

TODO: 導入部分の本文。

== TODO: 関連研究

TODO: サブセクションの本文。例えば Knuth の Literate Programming
@knuth1984 のように参考文献を引用できます。#cite(<tufte2001>, form: "prose")
も参照。

#figure(
  rect(width: 4cm, height: 2.5cm, stroke: 0.5pt),
  caption: [TODO: 図のキャプション],
)

#figure(
  table(
    columns: 3,
    [*列A*], [*列B*], [*列C*],
    [TODO], [TODO], [TODO],
  ),
  caption: [TODO: 表のキャプション],
)

= TODO: 手法

TODO: 本文。

#appendix[
  = TODO: 補足データ

  TODO: 補足資料。`appendix(..)` は ireport と同じ仕組みで動作します -
  両テンプレートの違いはラベルが「章」か「節」かだけです。
]

#bibliography("refs.bib")
