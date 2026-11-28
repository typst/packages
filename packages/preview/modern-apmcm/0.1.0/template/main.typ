#import "@preview/modern-apmcm:0.1.0": *

#show: apmcm-paper.with(
  team-number: "apmcm263XXXXX",
  problem: "A",
  year: 2026,
  // Optional: uncomment to display paper title on the summary sheet
  // title: "Your Mathematical Modeling Paper Title",
  keywords: ("Mathematical Modeling", "Optimization", "Sensitivity Analysis"),
  summary: [
    Write your one-page executive summary here. Summarize the background, modeling methodology for each subproblem, key quantitative findings, sensitivity analysis, and conclusions clearly and concisely.

    Note that according to the APMCM specification, the entire solution paper (including figures and tables) must be written in English with no Chinese characters, and the main body should be controlled within 25 pages (excluding appendices).
  ],
)

= Introduction

In order to indicate the origin of the problem, the background and motivation are introduced in this section.

== Problem Background

== Literature Review and Our Approach

= Problem Analysis and Assumptions

== Problem Restatement

== Modeling Assumptions

#assumption[
  Key physical or statistical relationships remain consistent within the observed operating domain, except where explicitly modeled as regime shifts.
]

== Notations and Symbols

#figure(
  three-line-table(
    columns: (auto, 1fr, auto),
    align: (left, left, center),
    table.header([*Symbol*], [*Description*], [*Unit*]),
    [$x_i$], [Decision or state variable for index $i$], [---],
    [$alpha$], [Regularization or weighting parameter], [---],
    [$R^2$], [Coefficient of determination], [---],
  ),
  caption: [Summary of key notations and definitions],
) <tab:notations>

As shown in @tab:notations, all variables are defined with consistent physical units.

= Models

== Basic Model

=== Terms, Definitions and Symbols

The formulation follows standard mathematical modeling and statistical theory #link(<ref1>)[[1]].

=== Model Formulation

The regularized objective function can be written as:
$ min_B ||Y - X B||_F^2 + alpha ||B||_F^2 $ <eq:ridge>

From @eq:ridge, the analytical solution can be directly obtained.

=== Solution and Result

// Example of inserting a figure:
// #figure(
//   image("figures/workflow.png", width: 90%),
//   caption: [Overview of the proposed modeling pipeline],
// ) <fig:workflow>

=== Analysis of the Result

=== Strength and Weakness

- *Strength:* The proposed modeling framework balances interpretability, numerical stability, and predictive accuracy.
- *Weakness:* Out-of-sample generalization depends on sufficient coverage of boundary conditions.

= Conclusions

== Conclusions of the Problem

== Methods Used in Our Models

= Future Work

= References <sec:references>

// APMCM specification requires [ID] format and listing cited books/journals/online resources.
// You can either use #bibliography("refs.bib", style: "ieee") or maintain formatted entries directly:
#set par(first-line-indent: 0pt)
#enum(
  numbering: "[1]",
  [Author. *Title* [M]. Place of Publication: Press, Year, pp. xx--xx.],
  [Author. Paper name [J]. *Journal Name*, Year, Vol(No): pp. xx--xx.],
  [Author. Resource title. #link("https://example.com")[https://example.com], Visited YYYY-MM-DD.],
) <ref1>

#pagebreak()

= Appendix

All simulations and data analyses were implemented in Python (with NumPy, SciPy, and pandas).

#code-block(caption: [Example Python snippet in Appendix])[
```python
import numpy as np

def normalize(x: np.ndarray) -> np.ndarray:
    return (x - np.mean(x)) / np.std(x)
```
]
