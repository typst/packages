#import "@preview/bookcls:0.1.0": *
// #import "../../src/book.typ": *

// #show: chapter.with(title: "Second chapter")

= Second chapter
#minitoc
#pagebreak()

== Objectifs
#lorem(100)

$
arrow(V)(M slash R_0) = lr((d arrow(O M))/(d t)|)_(R_0) + theta
$

La Figure @b2 présente la carte du Cnam @Jon22.

#subfigure(
figure(image("../images/typst-logo.svg"), caption: []),
figure(image("../images/typst-logo.svg"), caption: []), <b2>,
columns: (1fr, 1fr),
caption: [(a) Left image and (b) Right image],
label: <fig:subfig2>,
)