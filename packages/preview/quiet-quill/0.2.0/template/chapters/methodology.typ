// SPDX-License-Identifier: MIT-0
= Methodology and Illustrative Results <methodology>

== A metric for the example

Precision at cutoff $k$ is the fraction of the first $k$ retrieved items that are
relevant. For this example, let $r_k$ be the number of relevant items in that set:

$ P "@" k = r_k / k. $ <precision>

The denominator must be positive. Relevance judgments and ranking outputs here
are invented, so the values must not be interpreted as evidence about an actual
retrieval method. The formula demonstrates mathematical notation and numbering.

== Synthetic comparison

@scores lists made-up scores for two toy runs. Each query has three retrieved
items; the scores correspond to zero, one, two or three relevant items. Values
are rounded for display. No participants, private datasets or measured timings
were used.

#figure(
  table(
    columns: (1fr, 1fr, 1fr),
    align: (left, right, right),
    table.header([*Synthetic query*], [*Run A: P\@3*], [*Run B: P\@3*]),
    [Garden-Q1], [0.33], [0.67],
    [Garden-Q2], [0.67], [0.67],
    [Garden-Q3], [0.00], [0.33],
    [Garden-Q4], [1.00], [0.67],
  ),
  caption: [Invented precision scores, included only to illustrate a numbered table.],
) <scores>

== Interpretation limits

These four cases cannot support general claims about retrieval quality. Their
purpose is to provide legible examples of alignment, references and captions.
The workflow in @workflow and the metric in @precision describe the same toy
exercise. @conclusion states the limited conclusion.
