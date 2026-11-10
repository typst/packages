#import "@preview/numera:0.1.0": (
  my-numbering, numera, outer-figure-counter-value, ref-dependent,
  subfigure-counter-dependent, subfigure-dependent,
)

#show: numera()

// Custom figure kinds require an explicit supplement.
#show figure.where(kind: "subfigure"): set figure(supplement: [Figure])

// Figure numbering: 1 inline, 1.1 in refs
// Subfigure numbering: (a) inline, full reference (e.g. 1.1a) in refs
#show figure: set figure(numbering: ref-dependent(
  subfigure-dependent("(a)", figure-numbering: "1"),
  subfigure-counter-dependent("1a", figure-numbering: auto),
))

= Subfigures Example

This example demonstrates side-by-side subfigures using a grid layout.

#figure(
  grid(
    columns: 3,
    gutter: 1.5em,
    align: center,
    [
      #figure(
        "Sub-figure A",
        caption: "First sub-figure",
        kind: "subfigure",
      ) <sub-a>
    ],
    [
      #figure(
        "Sub-figure B",
        caption: "Second sub-figure",
        kind: "subfigure",
      ) <sub-b>
    ],
    [
      #figure(
        "Sub-figure C",
        caption: "Third sub-figure",
        kind: "subfigure",
      ) <sub-c>
    ],
  ),
  caption: "Three sub-figures arranged in a grid",
) <fig-grid>

@sub-a, @sub-b, @sub-c and the parent @fig-grid.

#figure(
  grid(
    columns: 3,
    gutter: 1.5em,
    align: center,
    [
      #figure("Sub-figure A", caption: "First sub-figure", kind: "subfigure")
    ],
    [
      #figure("Sub-figure B", caption: "Second sub-figure", kind: "subfigure")
    ],
    [
      #figure("Sub-figure C", caption: "Third sub-figure", kind: "subfigure")
    ],
  ),
  caption: "Three sub-figures arranged in a grid",
) <fig-grid2>

Manual references like @fig-grid2 (a), @fig-grid2 (b), @fig-grid2 (c) are also possible.
