= Methods and examples <methods>

Replace this chapter with the methods and evidence for your research.
The values below are illustrative examples, not research results.

== Equations and tables

=== Illustrative relationship

A simple relationship is given in @linear-model:

$ y = 2 x + 1. $ <linear-model>

@example-data shows three values generated from this relationship.

#figure(
  table(
    columns: 2,
    align: center,
    inset: 8pt,
    stroke: 0.5pt,
    table.header([$x$], [$y$]),
    [0], [1],
    [1], [3],
    [2], [5],
  ),
  caption: [Illustrative values for the example relationship.],
) <example-data>

== Figures and code

@workflow shows an example workflow drawn with native Typst shapes.

#figure(
  grid(
    columns: (auto, auto, auto, auto, auto),
    align: center + horizon,
    gutter: 8pt,
    rect(inset: 8pt, fill: luma(95%))[Input],
    [→],
    rect(inset: 8pt, fill: luma(95%))[Model],
    [→],
    rect(inset: 8pt, fill: luma(95%))[Output],
  ),
  kind: image,
  alt: "Three boxes labelled Input, Model, and Output, connected in that order by arrows.",
  caption: [An illustrative three-stage workflow.],
) <workflow>

The following code calculates the example values:

```python
for x in range(3):
    print(x, 2 * x + 1)
```
