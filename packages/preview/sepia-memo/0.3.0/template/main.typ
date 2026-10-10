// SPDX-License-Identifier: MIT-0
// Copyright (c) 2026 Chen Gao
#import "@preview/sepia-memo:0.3.0": memo, memo-note, memo-inset
#import "@preview/droplet:0.3.1": dropcap

#show: memo.with(
  title: [On repeated measurement],
  subtitle: [A short note on averages and variation],
  author: "A. Researcher",
  date: [22 September 2026],
)

// ponytail: One starter; optional fonts use the same memo settings.
#set math.equation(numbering: "(1)")

= Purpose

#dropcap(height: 3, gap: 4pt)[
  A measurement is easier to interpret when its units, repetition, and variation
  are recorded together. Five invented observations illustrate the arithmetic and
  layout of a short note. They are not evidence from an experiment.
]

= Calculation

#memo-inset(title: [Working assumption])[
  The observations share the same units and collection procedure. Their variation
  describes these measurements, not the uncertainty of every possible experiment.
]

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

#block(breakable: false)[
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
]

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
