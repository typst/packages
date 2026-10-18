#import "../core/resolve.typ": get-title, resolve
#import "../core/state.typ": folio-state
#import "../theme/ui.typ": badge, card, data-table, metric
#import "../utils/formatters.typ": format-date, format-money
#import "../core/refs.typ": link-to-deliverable, link-to-objective

#let lessons-learned(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Lessons Learned")]

  let lessons = resolve(data, data-path)
  if type(lessons) == array {
    data-table(
      columns: (auto, 1fr, 1fr),
      headers: ("Category", "What went wrong", "Recommendation"),
      rows: lessons
        .map(l => (
          l.at("category", default: "-"),
          l.at("issue", default: "-"),
          l.at("recommendation", default: "-"),
        ))
        .flatten(),
    )
  } else {
    [#lessons]
  }
}

#let sign-off(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Formal Sign-Off")]

  let stakeholders = resolve(data, data-path)
  if type(stakeholders) == array {
    data-table(
      columns: (1fr, 1fr, 1fr),
      headers: ("Stakeholder", "Role", "Date/Signature"),
      rows: stakeholders
        .map(s => (
          s.at("name", default: "-"),
          s.at("role", default: "-"),
          "___________________",
        ))
        .flatten(),
    )
  } else {
    [#stakeholders]
  }
}

#let acceptance(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Acceptance Records")]

  let records = resolve(data, data-path)
  if type(records) == array {
    data-table(
      columns: (auto, auto, auto, 1fr),
      headers: (
        "Deliverable",
        "Accepted By",
        "Acceptance Date",
        "Outstanding Issues",
      ),
      rows: records
        .map(r => (
          link-to-deliverable(r.at("deliverable_id", default: "-")),
          r.at("accepted_by", default: "-"),
          format-date(r.at("acceptance_date", default: "")),
          r.at("outstanding_issues", default: "None"),
        ))
        .flatten(),
    )
  } else {
    [#records]
  }
}

#let benefits-review(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Benefits Review")]

  let reviews = resolve(data, data-path)
  if type(reviews) == array {
    data-table(
      columns: (auto, 1fr, 1fr, auto, auto),
      headers: (
        "Objective",
        "Claimed Benefit",
        "Actual Outcome",
        "Variance",
        "Root Cause",
      ),
      rows: reviews
        .map(r => (
          link-to-objective(r.at("objective_id", default: "-")),
          r.at("claimed", default: "-"),
          r.at("actual", default: "-"),
          r.at("variance", default: "-"),
          r.at("root_cause", default: "—"),
        ))
        .flatten(),
    )
  } else {
    [#reviews]
  }
}

#let handover(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Project Handover")]

  let h = resolve(data, data-path)
  if type(h) != dictionary {
    [#h]
    return
  }

  let docs = h.at("documentation", default: ())
  if docs.len() > 0 {
    card(title: "Documentation Handed Over")[
      #list(..docs)
    ]
  }

  let training = h.at("training", default: none)
  if training != none { card(title: "Training")[#training] }

  let support = h.at("support", default: none)
  if support != none { card(title: "Support / Warranty")[#support] }

  let transfer-date = h.at("transfer_date", default: none)
  if transfer-date != none {
    card[*Transfer date:* #format-date(transfer-date)]
  }
}

#let financial-closure(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[#get-title(data, data-path, "Financial Closure")]

  let fc = resolve(data, data-path)
  if type(fc) != dictionary {
    [#fc]
    return
  }

  let final-cost = float(fc.at("final_cost", default: 0))
  let baseline = float(fc.at("budget_baseline", default: 0))
  let variance = float(fc.at("variance", default: final-cost - baseline))

  card[
    #stack(
      dir: ltr,
      spacing: 3em,
      metric("Budget Baseline", format-money(baseline)),
      metric("Final Cost", format-money(final-cost)),
      metric("Variance", format-money(variance), intent: if variance <= 0 {
        "success"
      } else { "danger" }),
    )
  ]

  let explanation = fc.at("variance_explanation", default: none)
  if explanation != none { card(title: "Variance Explanation")[#explanation] }

  let outstanding = fc.at("outstanding_invoices", default: none)
  if outstanding != none { card(title: "Outstanding Invoices")[#outstanding] }
}
