// SPDX-License-Identifier: MIT-0
// Copyright (c) 2026 Chen Gao
// Original illustrative prose and invented measurements; not research results.

#let sample(memo-note) = [
  #set math.equation(numbering: "(1)")

  = Purpose

  A measurement is easier to interpret when its units, repetition, and variation
  are recorded together. This note uses five invented observations to show how a
  short calculation can be reported alongside the information needed to check it.
  The values illustrate the layout; they are not evidence from an experiment.

  = Calculation

  Let $x_i$ denote observation $i$ and let $n$ be the number of observations. The
  sample mean and the sample standard deviation are

  $
    overline(x) = 1/n sum_(i=1)^n x_i,
    quad s = sqrt(1/(n - 1) sum_(i=1)^n (x_i - overline(x))^2).
  $ <eq-summary>

  For the values below, $n = 5$, $overline(x) = 10.0$, and $s approx 0.16$ units.
  The standard deviation is rounded to two decimal places; the calculation uses
  the observations as shown.#footnote[The divisor $n - 1$ defines the usual sample
    variance. Here it equals four.]

  #figure(
    table(
      columns: (1fr, 1fr, 1fr),
      align: (left, right, right),
      table.hline(stroke: 0.6pt),
      table.header([*Observation*], [*Value*], [*Deviation*]),
      table.hline(stroke: 0.3pt),
      [1], [9.8], [$-0.2$],
      [2], [10.1], [$0.1$],
      [3], [10.0], [$0.0$],
      [4], [9.9], [$-0.1$],
      [5], [10.2], [$0.2$],
      table.hline(stroke: 0.6pt),
    ),
    caption: [Invented observations, in arbitrary units. Deviations are measured
      from the sample mean.],
  ) <tab-observations>

  = Interpretation

  #memo-note[
    *Keep units visible.* A precise number can still describe an uncertain
    measurement.
  ][
    @tab-observations makes the arithmetic in @eq-summary easy to inspect. The
    deviations sum to zero, while their squares sum to $0.10$. These checks can
    catch a transcription error before a rounded result is reported.
  ]

  Repeated measurements describe variation under the conditions of collection.
  They do not, by themselves, establish that the instrument is calibrated or
  that a different setting would produce the same distribution. Those claims
  need their own observations and reasoning.
]
