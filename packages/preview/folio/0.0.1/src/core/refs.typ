#let slugify(text) = {
  lower(str(text)).replace(regex("[^a-z0-9]+"), "-").trim("-")
}

// --- Existing label families ---
#let task-label(id) = label("task-" + slugify(id))
#let milestone-label(id) = label("milestone-" + slugify(id))
#let risk-label(id) = label("risk-" + slugify(id))
#let issue-label(id) = label("issue-" + slugify(id))
#let change-label(id) = label("change-" + slugify(id))

// --- New label families (Phase 1 expansion) ---
#let req-label(id) = label("req-" + slugify(id))
#let deliverable-label(id) = label("deliverable-" + slugify(id))
#let assumption-label(id) = label("assumption-" + slugify(id))
#let decision-label(id) = label("decision-" + slugify(id))
#let stakeholder-label(id) = label("stakeholder-" + slugify(id))
#let objective-label(id) = label("objective-" + slugify(id))
#let compliance-label(id) = label("compliance-" + slugify(id))

#let folio-orphans = state("folio-orphans", ())

#let safe-link(lbl, fallback-text) = context {
  if query(lbl).len() > 0 {
    link(lbl)[#fallback-text]
  } else {
    folio-orphans.update(prev => (
      prev + ((target: lbl, fallback: fallback-text),)
    ))
    [#fallback-text?]
  }
}

// --- Existing link functions ---
#let link-to-task(id) = safe-link(task-label(id), id)
#let link-to-milestone(id) = safe-link(milestone-label(id), id)
#let link-to-risk(id) = safe-link(risk-label(id), id)
#let link-to-issue(id) = safe-link(issue-label(id), id)
#let link-to-change(id) = safe-link(change-label(id), id)

// --- New link functions ---
#let link-to-req(id) = safe-link(req-label(id), id)
#let link-to-deliverable(id) = safe-link(deliverable-label(id), id)
#let link-to-assumption(id) = safe-link(assumption-label(id), id)
#let link-to-decision(id) = safe-link(decision-label(id), id)
#let link-to-stakeholder(id) = safe-link(stakeholder-label(id), id)
#let link-to-objective(id) = safe-link(objective-label(id), id)
#let link-to-compliance(id) = safe-link(compliance-label(id), id)
