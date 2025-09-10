#import "@preview/rubber-article:0.4.0": *

#show: article.with(
  header-display: true,
  header-title: "The Title of the Paper",
  eq-numbering: "(1.1)",
  eq-chapterwise: true,
  margins: 1.75in,
)

#maketitle(
  title: "The Title of the Paper",
  authors: ("Authors Name",),
  date: datetime.today().display("[day]. [month repr:long] [year]"),
)

// Some example content has been added for you to see how the template looks like.
= Introduction
#lorem(140)

#lorem(100)
$
x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c))/ (2 a)
$
#lorem(100)

== In this paper
#lorem(70)

#figure(
  rect(width: 4cm, height: 3cm),
  caption: [#lorem(30)],
)

#lorem(20)

=== Contributions
#lorem(40)

= Related Work
#lorem(200)

$
y = k x + d
$
#lorem(50)

// Example of a custom table
#figure(
  ctable(
    cols: "l|cr",
    [A],
    [B],
    [C],
    ..range(1, 16).map(str),
  ),
  caption: "This is a custom table",
)

#show: appendix.with(
  title: "Appendix",
)

= Appendix 1
#lorem(35)

== Some more details
#lorem(20)
