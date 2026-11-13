#import "@preview/satz:0.2.0": article, placeholder
#show: article.with(
  title: [Two-column writing with satz],
  authors: (name: "Example Author", affiliations: (1,)),
  affiliations: ([Example Research Institute],),
  abstract: [This example exercises a full-width title and abstract above native
    two-column text, with a footnote, ordinary figure, and full-width figure.],
)

= Introduction

Native page columns retain the document's footnotes and page breaks.
#footnote[An example footnote in the article.]
#lorem(130)

= Methods

#figure(placeholder(height: 20mm), caption: [An ordinary column-width figure.]) <fig:column>
#lorem(170)

// Start a new page so the wide float cannot overtake the column figure.
#pagebreak()
#figure(
  placeholder(height: 30mm, label: [Full-width figure]),
  caption: [A figure spanning the page columns.],
  placement: top,
  scope: "parent",
) <fig:wide>

= Results

The two figure widths are illustrated in @fig:column and @fig:wide.
#lorem(180)
