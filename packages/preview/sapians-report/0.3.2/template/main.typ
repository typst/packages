#import "@preview/sapians-report:0.3.2": * // x-release-please-version

#show: sapians-report.with(
  title: "Report Title",
  subtitle: "One line saying what this document specifies or decides",
  author: "Author Name",
  version: "0.1",
  // Branding defaults are SAPIANS; override them for your organization:
  // kicker: "TECHNICAL REPORT",
  // org: "Your Organization",
  // lang: "pt", author-title: "Autor", date-title: "Data", version-title: "Versão",
)

= Executive Summary

Three to five sentences a busy reader can stop after: the situation, the
decision or finding, and what happens next.

1. *First key point:* one sentence.
2. *Second key point:* one sentence.
3. *Third key point:* one sentence.

= Background

The context someone new to the topic needs before the main content makes
sense. Keep it to what is load-bearing.

== Subsection

Use the accent card for the rule or constraint everything else depends on:

#accent-card(title: "Golden Rule")[
  Every page should carry *one dominant idea* with an unambiguous
  typographic hierarchy.
]

= Analysis

The body of the report. Tables use hairline strokes and a tinted header
row:

#align(center)[
  #table(
    columns: (1fr, 1.2fr, 1.2fr),
    stroke: stroke-light,
    fill: (_, row) => if row == 0 { sapians-code-bg } else { none },
    inset: 3mm,
    [*Dimension*], [*Option A*], [*Option B*],
    [Criterion one], [How A performs], [How B performs],
    [Criterion two], [How A performs], [How B performs],
    [Criterion three], [How A performs], [How B performs],
  )
]

= Recommendations

Numbered, each one actionable and owned:

#code-box(title: "Example: build commands", lang: "Bash")[
  ```bash
  # Compile this report
  typst compile main.typ report.pdf

  # Live-reload while writing
  typst watch main.typ
  ```
]

= Next Steps

Who does what by when.
