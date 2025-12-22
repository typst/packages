#import "@preview/bookly:1.0.0": *
// #import "../../src/bookly.typ": *

// #show: chapter.with(
//   title: "Foundations",
//   toc: false
// )

= Foundations

#lorem(100)

$
  #boxeq($bold(y)_(k + 1) = bold(C) space.thin bold(x)_(k + 1)$)
$

#nonumeq($
y(x) = f(x)
$)

La Figure @fig:B

#figure(
image("../images/typst-logo.svg", width: 75%),
caption: [#lorem(10)],
) <fig:B>

La Figure @b3 présente la carte du Cnam.

#subfigure(
figure(image("../images/typst-logo.svg"), caption: []),
figure(image("../images/typst-logo.svg"), caption: []), <b3>,
columns: (1fr, 1fr),
caption: [(a) Left image and (b) Right image],
label: <fig:subfig3>,
)