// SPDX-License-Identifier: MIT-0
= Introduction <introduction>

*Synthetic example.* This text and all reported values are invented for this
template. The two bibliography entries are genuine public
publications; their authors did not conduct or endorse this illustrative exercise.

Information retrieval provides the context for the sample. @manning2008 is a
general textbook reference, while @robertson1995 records a real retrieval system.
No wording, diagrams or experimental results from either publication are reproduced.

== Scope

The fictional collection contains twelve short notes about imaginary garden tools.
Four invented queries are used only to demonstrate how to report a small comparison.
The workflow is shown in @workflow, and the invented scores appear in @scores.
The metric is defined in @precision. Additional example identifiers are listed in
@appendix-material.

#figure(
  grid(
    columns: (1fr, auto, 1fr, auto, 1fr),
    align: center + horizon,
    column-gutter: 8pt,
    block(width: 100%, inset: 12pt, stroke: 0.6pt)[Synthetic notes],
    [→],
    block(width: 100%, inset: 12pt, stroke: 0.6pt)[Toy ranking],
    [→],
    block(width: 100%, inset: 12pt, stroke: 0.6pt)[Illustrative scores],
  ),
  kind: image,
  supplement: [Figure],
  alt: "A left-to-right workflow: synthetic notes feed a toy ranking step, which produces illustrative scores.",
  caption: [An original diagram of the fictional workflow. It depicts no deployed system.],
) <workflow>
