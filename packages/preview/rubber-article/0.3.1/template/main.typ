#import "@preview/rubber-article:0.3.1": *

#show: article.with(
  show-header: true,
  header-titel: "The Title of the Paper",
  eq-numbering: "(1.1)",
  eq-chapterwise: true,
)

#maketitle(
  title: "The Title of the Paper",
  authors: ("Authors Name",),
  date: datetime.today().display("[day]. [month repr:long] [year]"),
)

// Some example content has been added for you to see how the template looks like.
= Introduction
#lorem(60)

#figure(
  rect(width: 4cm, height: 3cm),
  caption: [#lorem(30)],
)

== In this paper
#lorem(20)
$
x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c))/ (2 a)
$
#lorem(20)

=== Contributions
#lorem(40)

= Related Work
#lorem(300)

$
y = k x + d
$
#lorem(50)

#show: appendix.with(
  title: "Appendix",
)

= Appendix 1
#lorem(35)

== Some more details
#lorem(20)


