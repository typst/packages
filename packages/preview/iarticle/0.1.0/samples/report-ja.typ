// l10n が対応している 8 つのラベルを一通り確認するためのサンプル文書:
// 概要・目次・章・節・表・図・付録・参考文献。
// 章立てのない (iarticle) 側は samples/article-ja.typ を参照。
//
// コンパイルする前に、ローカルのチェックアウトを
// @preview/iarticle:0.1.0 として登録するため、一度だけ
// ../install_for_test.sh を実行してください。
#import "@preview/iarticle:0.1.0": ireport, appendix

#show: ireport.with(
  lang: "ja",
  title: "人気動画の作成手法の調査",
  authors: ("山田太郎","佐藤花子"),
  abstract: [
    TODO: 本文書の概要を一段落で。
  ],
)

= はじめに

TODO: 導入部分の本文。

== 背景

TODO: サブセクションの本文。

#figure(
  rect(width: 4cm, height: 2.5cm, stroke: 0.5pt),
  caption: [図のキャプション],
)

#figure(
  table(
    columns: 3,
    [*列A*], [*列B*], [*列C*],
    [これこれ], [それそれ], [あれあれ],
  ),
  caption: [TODO: 表のキャプション],
)

= 本論

TODO: 例えば Knuth の Literate Programming @knuth1984 のように、
参考文献を引用できます。#cite(<tufte2001>, form: "prose") も参照。

#appendix[
  = 構成テクニック集

  TODO: 補足資料。`appendix(..)` で囲むと、ラベルが「第N章」から
  「付録A」に、番号がアルファベットに自動的に切り替わります。
]

#bibliography("refs.bib")
