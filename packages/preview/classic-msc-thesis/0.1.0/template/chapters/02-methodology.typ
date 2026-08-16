// `flex-caption` gives a figure a long caption (shown beneath it) and a short
// title (shown in the List of Figures / Tables). Import it in every chapter
// that has figures — chapters are `#include`d and do not inherit main.typ's
// imports.
#import "@preview/classic-msc-thesis:0.1.0": flex-caption

= Methodology

Describe what you did in enough detail that a competent reader could reproduce
it. This chapter is a good place to show the two figure styles the template
supports: an ordinary image, and a multi-panel figure.

== Materials

Introduce the data, samples, or inputs of your study, and cite their sources
@lee2022. When you refer to a figure or table, use a cross-reference so the
number stays correct if you reorder things: the overall design is summarised in
@fig:method-overview.

#figure(
  image("../figures/placeholder.svg", width: 80%),
  caption: flex-caption(
    [A schematic overview of the method. This is the long caption that appears
     beneath the figure; it should explain what the figure shows well enough to
     stand on its own, without repeating the body text. Replace the placeholder
     image with your own diagram or plot.],
    [Schematic overview of the method],
  ),
) <fig:method-overview>

== Procedure

Lay out the steps of your method in order. Short commands and identifiers can be
written inline, like running `typst compile main.typ`, while longer listings go
in a fenced code block, which the template renders on a shaded background:

```python
def rollup(records, ranks):
    """Aggregate raw records up a taxonomic (or any) hierarchy."""
    totals = {}
    for record in records:
        for rank in ranks:
            totals.setdefault(rank, 0)
            totals[rank] += record.count
    return totals
```

Multi-panel figures are built by placing several images (or panels) in a `grid`
inside a single `#figure`, so they share one number and one caption
(@fig:two-panel).

#figure(
  grid(
    columns: 2,
    column-gutter: 6pt,
    image("../figures/placeholder.svg", width: 100%),
    image("../figures/placeholder.svg", width: 100%),
  ),
  caption: flex-caption(
    [A two-panel figure. *(A)* The first panel. *(B)* The second panel. Refer to
     individual panels as @fig:two-panel\A and @fig:two-panel\B in the text.],
    [A two-panel figure],
  ),
) <fig:two-panel>

== Analysis

Explain how the data were processed and analysed. Tables use booktabs-style
rules (a heavier rule under the header, light rules between rows) and, unlike
figures, place their caption above the table:

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, right),
    table.header([*Parameter*], [*Description*], [*Value*]),
    [`threshold`], [Minimum score to keep a record], [0.80],
    [`window`], [Size of the sliding window], [50],
    [`seed`], [Random seed for reproducibility], [42],
    [`workers`], [Number of parallel workers], [8],
  ),
  caption: flex-caption(
    [Parameters used in the analysis. Values are illustrative; document the
     settings needed to reproduce your results.],
    [Analysis parameters],
  ),
) <tab:parameters>

State any assumptions and how you validated the results, so the reader can judge
their reliability @nakamura2023.
