// An article in English, divided in sections, for reading on screen.
#import "@preview/quire:0.1.0": *

#show: quire.with(
  title: [On the Folding of Sheets],
  subtitle: [How quires, signatures and folios shaped the book],
  authors: (
    (name: "Jane Doe", affiliation: [Institute of Book History], email: "jane@example.org"),
    (name: "John Roe", affiliation: [School of Typography]),
  ),
  date: datetime(year: 2026, month: 6, day: 1),
  lang: "en",
  top-level: "section",
  output: "digital",
  kicker: [Working paper · 2026],
  abstract: [
    A sheet folded once gives a folio; twice, a quarto; three times, an octavo. We review how these gatherings,
    called quires, determined the size and structure of books, and how their arithmetic survives in modern
    imposition.
  ],
  keywords: ("bookbinding", "imposition", "typography"),
)

= Introduction <sec:intro>

Before a book is sewn, its printed sheets are folded into _quires_ (or gatherings). A sheet folded $n$ times gives
$2^n$ leaves and $2^(n + 1)$ pages, a fact that every printer had to master, since the pages of a quire are not
printed in reading order. @sec:imposition derives the order; @tab:formats summarizes the classical formats.

#figure(
  table(
    columns: 4,
    stroke: none,
    table.hline(stroke: 0.6pt),
    table.header([*Format*], [*Folds*], [*Leaves*], [*Pages*]),
    table.hline(stroke: 0.4pt),
    [Folio], [1], [2], [4],
    [Quarto], [2], [4], [8],
    [Octavo], [3], [8], [16],
    table.hline(stroke: 0.6pt),
  ),
  caption: [Classical book formats.],
) <tab:formats>

= Imposition <sec:imposition>

== The arithmetic of folding

#definition[
  A _quire_ of $n$ folds is a sheet folded $n$ times, giving $L = 2^n$ leaves and $P = 2 L$ pages.
]

Pages facing each other on the same side of the unfolded sheet add up to a constant:
$ p + p' = P + 1. $ <eq:sum>

#proposition[
  In a quire of $P$ pages, page $p$ and page $P + 1 - p$ are printed side by side.
] <prop:pairs>

#proof(of: [@prop:pairs])[
  Folding preserves adjacency of the outer edges; unfolding the innermost fold first, induction on $n$ gives
  @eq:sum.
]

== Computing the layout

The order of pages on each side of the sheet can be computed directly:

#code-file(filename: "impose.py")[
  ```python
  def pairs(pages: int) -> list[tuple[int, int]]:
      """Pages printed side by side in a quire."""
      return [(p, pages + 1 - p) for p in range(1, pages // 2 + 1)]
  ```
]

#remark[
  Modern imposition software, e.g. #href("https://typst.app")[Typst]-based workflows, still relies on this rule.
]

= Conclusion

The quire is the atom of the codex; its arithmetic, sketched in #ref-titled(<sec:imposition>), explains formats
that are still named after it @knuth1984.

#bibliography("refs.yaml")
