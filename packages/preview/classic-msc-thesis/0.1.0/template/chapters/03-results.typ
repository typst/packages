#import "@preview/classic-msc-thesis:0.1.0": flex-caption

= Results

Report your findings here, in a logical order, without interpreting them (save
interpretation for the Discussion). Lead with the result, then point to the
figure or table that supports it. The method that produced these numbers was
described in the previous chapter (@fig:method-overview).

== Primary outcome

Present the main result first. Where a figure carries the message, refer to it
directly (@fig:results-overview) and let the caption supply the legend the
reader needs to read it.

#figure(
  image("../figures/placeholder.svg", width: 85%),
  caption: flex-caption(
    [The primary result. Replace this placeholder with the plot that best
     conveys your main finding, and keep the caption to the context a reader
     needs to interpret it — not a restatement of the body text.],
    [The primary result],
  ),
) <fig:results-overview>

Quantitative results are often clearest in a table. Report exact values in the
body or the table, and keep the caption for definitions and context.

#figure(
  table(
    columns: (1fr, auto, auto, auto),
    align: (left, right, right, right),
    table.header([*Group*], [*n*], [*Mean*], [*SD*]),
    [Group A], [128], [3.42], [0.51],
    [Group B], [131], [3.97], [0.48],
    [Group C], [119], [4.15], [0.55],
    [Combined], [378], [3.85], [0.58],
  ),
  caption: flex-caption(
    [Summary statistics by group. *n* is the number of observations; *SD* is the
     standard deviation.],
    [Summary statistics by group],
  ),
) <tab:summary>

== Secondary findings

Report any further results that support or qualify the primary outcome. Note
patterns the reader should carry into the Discussion, and flag anything
unexpected. Additional analyses or large tables that would interrupt the flow
belong in the appendix rather than here.
