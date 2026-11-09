// Compile with --input compact=true to compare caption-free figure/table lists.
#import "@preview/satz:0.2.0": report, satz-figure, placeholder

#show: report.with(config: (
  page: (binding: left, headers: true),
  toc: (depth: none),
  lof: (depth: none, compact: sys.inputs.at("compact", default: "false") == "true"),
  lot: (depth: none, compact: sys.inputs.at("compact", default: "false") == "true"),
))

= Introduction
This example uses ordinary numbered headings and captioned figures and tables.

== Research question
A contents entry inherits the heading's numbering and links to its page.

== A deliberately long subsection title illustrating the hanging indentation of a wrapped contents entry in a report with multiple levels
Wrapped entries keep their text aligned below the title rather than the number.

=== Scope
Third-level headings inherit the complete section number too.

= Methods
== Recording
- First list item with enough words to show how a wrapped item's lines keep the ordinary paragraph leading while item boundaries receive their own spacing.
- Second list item.
- Third list item.

== Summary table
#figure(
  table(columns: (1fr, 1fr),
    table.hline(),
    table.header([*Measure*], [*Value*]),
    table.hline(stroke: 0.5pt),
    [Sample A], [12],
    [Sample B], [18],
    table.hline(),
  ),
  kind: table,
  caption: [Summary of the example measurements.],
) <tab:summary>

== Diagram
#satz-figure(
  placeholder(height: 25mm, label: [Example diagram]),
  caption: [A longer explanation of the example diagram, shown beneath the figure.],
  short-caption: [Example diagram],
) <fig:diagram>

= Discussion
The table in @tab:summary and the diagram in @fig:diagram appear in separate lists.

== Interpretation
Numbered list items use the same item spacing as bullet lists.
+ First result.
+ Second result.
+ Third result.
