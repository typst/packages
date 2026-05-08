// Test: compute layer functions (cost aggregation, orphan detection, audit)
// Verifies compute.typ works correctly in isolation from the rendering pipeline.
#import "@preview/folio:0.0.1": (
  audit-missing, audit-summary, badge, calc-budget, calc-requirements, card, compute-context, data-table, find-orphans,
  folio-init, line-subtotal, metric, sum-costs,
)
#import "fixtures/full-data-dict.typ": full-project-data

#show: body => folio-init(
  data: full-project-data,
  config: (:),
  body,
)

= Compute Layer — Validation Test

== Cost Aggregation

#let budget-result = calc-budget(full-project-data)
#let req-result = calc-requirements(full-project-data)

#card(title: "Budget Computation")[
  - *Line items subtotal:* #budget-result.line-subtotal
  - *Extra costs total:* #budget-result.extra-total
  - *Grand total:* #budget-result.grand-total
]

#card(title: "Requirements Cost by Category")[
  #for (cat, total) in req-result.categories [
    - *#cat:* #total
  ]
  - *Grand total:* #req-result.grand-total
]

== Orphan Detection

#let orphans = find-orphans(full-project-data)

#if orphans.len() == 0 {
  card(title: "✓ Orphan Check Passed")[
    No orphan cross-references detected. All IDs resolve correctly.
  ]
} else {
  card(title: "✗ Orphan Check Failed")[
    Found #orphans.len() orphan reference(s):

    #data-table(
      columns: (auto, auto, auto, auto),
      headers: ("Source", "Field", "Ref ID", "Expected In"),
      rows: orphans
        .map(o => (
          o.source,
          o.field,
          o.ref-id,
          o.target,
        ))
        .flatten(),
    )
  ]
}

== Schema Audit

#let audit = audit-missing(full-project-data)
#let summary = audit-summary(audit)

#card(title: "Audit Summary")[
  #stack(
    dir: ltr,
    spacing: 2em,
    metric(
      "Critical",
      [#summary.critical.present P / #summary.critical.empty E / #summary.critical.missing M],
    ),
    metric(
      "Important",
      [#summary.important.present P / #summary.important.empty E / #summary.important.missing M],
    ),
    metric(
      "Recommended",
      [#summary.recommended.present P / #summary.recommended.empty E / #summary.recommended.missing M],
    ),
  )
]

#card(title: "Field Status Detail")[
  #data-table(
    columns: (1fr, auto, auto, auto),
    headers: ("Path", "Severity", "Status", "Phase"),
    rows: audit
      .map(r => (
        r.path,
        badge(r.severity, intent: if r.severity == "critical" {
          "danger"
        } else if r.severity == "important" {
          "warning"
        } else { "neutral" }),
        badge(r.status, intent: if r.status == "Present" {
          "success"
        } else if r.status == "Empty" { "warning" } else {
          "danger"
        }),
        r.phase,
      ))
      .flatten(),
  )
]

== Full Context

#let ctx = compute-context(full-project-data)

#card(title: "Compute Context Summary")[
  - *Orphan count:* #ctx.orphan-count
  - *Is clean:* #ctx.is-clean
  - *Budget grand total:* #ctx.budget.grand-total
  - *Requirements grand total:* #ctx.requirements.grand-total
]
