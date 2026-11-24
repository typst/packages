#import "@preview/hanko-kitei:0.1.0": article, regulation

#show: regulation.with(
  title: "規程サンプル",
  config: (
    body-font: "Noto Serif CJK JP",
    heading-font: "Noto Sans CJK JP",
  ),
)

= 総則

#article(<目的>)[
  + この規程の目的を定めます。
]

#article(<適用範囲>)[
  + #ref(<目的>)に定める目的に従い、適用範囲を定めます。
]

== 手続

#article(<届出>)[
  + 届出は、次の各号に従って行います。
    + 必要事項を記載すること。

    + 指定された期限までに提出すること。

  + 前項の届出に変更があった場合は、速やかに届け出ます。
]
