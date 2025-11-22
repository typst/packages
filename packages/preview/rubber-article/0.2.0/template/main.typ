#import "@preview/rubber-article:0.2.0": *

#show: article.with()

#maketitle(
  title: "The Title of the Paper",
  authors: (
    "Authors Name",
  ),
  date: datetime.today().display("[day padding:none]. [month repr:long] [year]"),
)

// Some example content has been added for you to see how the template looks like.
= Introduction
#lorem(60)

== In this paper
#lorem(20)
$
x_(1,2) = (-b plus.minus sqrt(b^2 - 4 a c))/ (2 a)
$
#lorem(20)

=== Contributions
#lorem(40)

= Related Work
#lorem(500)