#import "@preview/kaodiss:0.1.0": *

= Figures, Tables and Mathematics <ch:foundations>

== Figures

Figures use Typst's `figure` function. Their caption is set in the margin and
aligned with the bottom of the figure (@fig:example). The figure number
contains the chapter number.

#figure(
  rect(width: 100%, height: 45mm, fill: luma(92%), stroke: none)[
    #set align(center + horizon)
    A figure in the text block
  ],
  caption: [A figure with its caption in the margin. Long captions wrap in
    the margin column; the last line is aligned with the bottom of the figure.],
) <fig:example>

#lorem(60)

Small figures go into the margin with `#marginfigure`.
#marginfigure(
  rect(width: 100%, height: 25mm, fill: luma(92%), stroke: none),
  caption: [A figure in the margin.],
  label: <fig:margin>,
)
@fig:margin shows such a figure. #lorem(50)

Wide figures extend into the margin. Their caption is set below them:

#wide[
  #figure(
    rect(width: 100%, height: 35mm, fill: luma(92%), stroke: none)[
      #set align(center + horizon)
      A wide figure spanning text block and margin
    ],
    caption: [A wide figure. The caption is set below the figure and spans the
      whole width.],
  ) <fig:wide>
]

== Tables

Tables follow the booktabs style. Their caption is set in the margin and
aligned with the top of the table (@tab:example).

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, right),
    toprule,
    [Element], [Position], [Size],
    midrule,
    [Body text], [Text block, 107 mm wide], [9.7 pt],
    [Sidenotes and captions], [Margin column, 47.7 mm wide], [7.8 pt],
    [Chapter number], [Margin column, next to the title], [57 pt],
    bottomrule,
  ),
  caption: [The main elements of the page and their type sizes, in a table
    with booktabs rules.],
) <tab:example>

== Mathematics

Equations are numbered per chapter, like the Gaussian integral in
@eq:gauss:

$ integral_(-oo)^oo e^(-x^2) dif x = sqrt(pi) $ <eq:gauss>

Inline mathematics such as $e^(i pi) + 1 = 0$ uses TeX Gyre Pagella Math,
which matches the text font.

#definition(title: [Sidenote])[
  A sidenote is a numbered note that is set in the margin next to the line it
  refers to.
] <def:sidenote>

#theorem[
  Every definition, theorem, lemma or example is numbered within its section
  and can be referenced like @def:sidenote.
]

#example[
  Examples and remarks are set upright.
]

== Lists

- Bullet lists use the triangle of kaobook.
- Items follow each other without extra space.
  - A second level uses a dash.

+ Numbered lists
+ work as usual.

/ Term: Description lists put the term in bold.
