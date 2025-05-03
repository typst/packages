#import "../lib.typ": article, author-meta, appendix, suffix, booktab
#import "@preview/cjk-unbreak:0.1.0": remove-cjk-break-space
#import "@preview/kouhu:0.2.0": kouhu

#show: remove-cjk-break-space

#set text(lang: "zh", font: ("Times New Roman", "FandolSong"))

#let affiliations = (
  "UCL": "单位A地址",
  "TSU": "单位B地址"
)

#let author-list(authors, template, affiliations: affiliations) = {
  stack(dir: ltr, spacing: 1em, ..authors.map(it => template(it)))
}

#show: article.with(
  title: "论文标题",
  authors: (
    "作者一": author-meta(
      "UCL", "TSU",
      email: "author.one@inst.ac.uk",
    ),
    "作者二": author-meta(
      "TSU",
      cofirst: true
    ),
    "作者三": author-meta(
      "TSU"
    )
  ),
  affiliations: affiliations,
  abstract: [#kouhu(indices: range(1, 2))],
  keywords: ("Typst", "模板", "期刊论文"),
)

#set heading(numbering: "1.")

= 简介

#kouhu(indices: range(2, 3), length: 100)
#footnote[#kouhu(length: 30)。]
#kouhu(indices: range(3, 4), length: 100)
@fig:demo 和@tbl:demo #kouhu(indices: range(4, 5), length: 20)
莫兰指数@Moran_1950, #kouhu(indices: range(5, 6), length: 20)

#figure(
  booktab(
    columns: 3,
    rows: 3,
    ..((kouhu(length: 4),) *9)
  ),
  caption: [表题注。],
  placement: bottom
) <tbl:demo>

#figure(
  rect([图片内容]),
  caption: [图题注。],
  placement: bottom
) <fig:demo>

在@app:demo 中，#kouhu(length: 200)。

#show: suffix

= 致谢

#kouhu(length: 20)

#bibliography(
  bytes("@article{Moran_1950, title={Notes on Continuous Stochastic Phenomena}, volume={37}, ISSN={0006-3444}, DOI={10.2307/2332142}, number={1/2}, journal={Biometrika}, publisher={[Oxford University Press, Biometrika Trust]}, author={Moran, P. A. P.}, year={1950}, pages={17–23} }"),
  style: "apa"
)

#show: appendix

= #lorem(5) <app:demo>

#lorem(10)

== #lorem(2)

#lorem(20) @tbl:demo-app and @fig:demo-app #lorem(10)

#figure(
  table(
    columns: 3,
    rows: 3,
    ..((kouhu(length: 4),) *9)
  ),
  caption: [表题注。]
) <tbl:demo-app>

#figure(
  rect([图片内容]),
  caption: [图题注。]
) <fig:demo-app>

= #lorem(3)

#lorem(10)

#figure(
  rect([图片内容]),
  caption: [图题注。]
) <fig:demo-app2>
