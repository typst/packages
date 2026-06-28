#import "@preview/bookly:1.0.0": *
// #import "../../src/bookly.typ": *

// #show: chapter.with(
//   title: "Introduction",
//   abstract: [#lorem(50)],
//   numbered: false
// )

#show: chapter-nonum
= Introduction

== Goals
#lorem(100)

#lorem(25)

$
y = f(x) \
g = h(x)
$

#v(1.25em)
=== Sub-goals

#figure(
image("../images/typst-logo.svg", width: 75%),
caption: [#ls-caption([#lorem(10)], [#lorem(2)])],
) <fig:intro>

#lorem(50) (cf. Figure @fig:intro)

#pagebreak()
== Methodology

#lorem(1000)