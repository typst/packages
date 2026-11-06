#import "@preview/ijimai:0.0.2": *
#let conf = toml("paper.toml")
#let author-photos = conf.authors.map(author => read(author.name + ".jpg", encoding: none))
#show: ijimai.with(
  conf: conf,
  photos: author-photos,
  logo: image("unir logo.svg", width: 17.5%),
  bib-data: read("bibliography.bib", encoding: none),
)

#set text(lang: "en")

= Introduction
#first-paragraph(
  first-word: "Typst",
)[is a new markup-based typesetting system for the sciences. It is designed to be an alternative both to advanced tools like LaTeX and simpler tools like Word and Google Docs.
  Our goal with Typst is to build a typesetting tool that is highly capable and a pleasure to use @Madje2022 @Haug2022. An axes is shown in @axes.]

#figure(
  image("axes.svg", width: 95%),
  caption: [Coordinate system used in the problem.],
) <axes>



== Subsection title
#lorem(47)
$ G_(mu nu) + Lambda g_(mu nu) = kappa T_(mu nu) $
where:
- $G_(mu nu)$ is the Einstein tensor, and
- $T_(mu nu)$ is the stress–energy tensor.

== Subsection title
Another subsection.
#table(
  columns: (0.5fr, 2cm, 4cm),
  inset: 3pt,
  align: horizon,
  table.header(
    [],
    [*Volume*],
    [*Parameters*],
  ),

  image("cylinder.svg", width: 0.8cm),
  $ pi h (D^2 - d^2) / 4 $,
  [
    $h$: height \
    $D$: outer radius \
    $d$: inner radius
  ],

  image("tetrahedron.svg", width: 0.8cm), $ sqrt(2) / 12 a^3 $, [$a$: edge length],
)


= Declaration of conflicts of interest
We just want to declare our love to Typst and IJIMAI.
= Acknowledgment
Thanks, Typst!
