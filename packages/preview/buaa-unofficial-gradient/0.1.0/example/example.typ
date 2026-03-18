#import "@preview/buaa-unofficial-gradient:0.1.0": *


#set text(font: ("Arial", "Source Han Sans"))

#show: buaa-theme.with(
  config-info(
    title: [Buaa in Touying: Customize Your Slide Title Here],
    subtitle: [Customize Your Slide Subtitle Here],
    author: [Authors],
    date: datetime.today(),
    institution: [Institution],
  ),
)


#title-slide()

#outline-slide()

= Section 1

== Article title

#let example-article-fig = block(
  stroke: 1pt,
  height: 100%,
  width: 50%,
  [Article Figure],
)

#article-title(
  article-fig: example-article-fig,
  journal: [Science],
  impf: [45.8],
  pub-date: [20XX-XX-XX],
  quartile: [中科院 综合性期刊1区],
  core-research: [#lorem(10)],
  authors: [#lorem(10)],
  institution: [#lorem(10)],
)

== Section 1.2
#grid(
  columns: (1fr, 1fr),
  rows: 1fr,
  column-gutter: 1em,
  align(
    horizon,
    image("./figures/bar_chart.svg"),
  ),
  block(
    width: 100%,
    inset: (top: 1em),
    [#h(2em)#lorem(50)],
  ),
)

== Section 1.3
#grid(
  columns: (2fr, 3fr),
  rows: 1fr,
  column-gutter: 0.5em,
  grid(
    align: center,
    rows: (1fr, 1fr),
    image("./figures/heatmap_field.svg"),
    image("./figures/line_comparison.svg"),
  ),
  block(
    inset: (top: 1em),
    h(2em) + [#lorem(70)],
  ),
)

== Section 1.4
#lorem(20)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 0.5em,
  align: center + horizon,
  image("./figures/bar_chart.svg"), image("./figures/heatmap_field.svg"), image("./figures/line_comparison.svg"),
)
#lorem(20)

= Section 2

== Section 2.1
#lorem(20)
#tblock(title: [Title])[#lorem(20)]
#rblock(title: [Title])[#lorem(20)]

== Section 2.2
#lorem(20)
#gblock(title: [Title])[#lorem(20)]
#sblock(title: [Title])[#lorem(20)]

= Section 3

== Section 3.1
#lorem(10)
#horz-block()[
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/heatmap_field.svg")
  #lorem(10)
][
  #image("./figures/line_comparison.svg")
  #lorem(10)
]

== Section 3.1
#lorem(20)
#horz-block()[
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
][
  #image("./figures/bar_chart.svg")
  #lorem(10)
]

= Section 4

== Section 4.1
#lorem(20)

#end-slide()
