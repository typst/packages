#import "@preview/kaodiss:0.1.0": *

= Additional Material <app:material>

The appendix uses the same layout as the main matter. Chapters are numbered
with letters, and so are figures, tables and equations
(@tab:appendix-example).

#figure(
  table(
    columns: 2,
    toprule,
    [Setting], [Value],
    midrule,
    [Batch size], [32],
    [Learning rate], [0.001],
    bottomrule,
  ),
  caption: [A table in the appendix.],
) <tab:appendix-example>

== Questionnaire

#lorem(120)
