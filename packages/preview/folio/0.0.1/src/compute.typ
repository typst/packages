/// folio v0.0.1 — Compute Layer
/// Pure functions: cost aggregation, cross-ref validation, orphan detection.
/// No side effects, no rendering, no state access.

#import "core/resolve.typ": _walk, nonempty
#import "core/schema.typ": folio-schema

// ─── Budget helpers (used by planning.typ/budget component) ──────────────────

/// Compute line-items subtotal. items: array of (qty, unit_cost, ...)
#let line-subtotal(items) = {
  if type(items) != array { return 0.0 }
  items.fold(0.0, (acc, i) => (
    acc + float(i.at("qty", default: 1)) * float(i.at("unit_cost", default: 0))
  ))
}

/// Compute extra costs total.
/// extra-costs: array of (description, cost|percentage, ...)
/// subtotal: float — the line-items subtotal (used to resolve percentages)
#let extras-total(extra-costs, subtotal) = {
  if type(extra-costs) != array { return 0.0 }
  extra-costs.fold(0.0, (acc, e) => {
    if e.at("percentage", default: none) != none {
      acc + subtotal * float(e.at("percentage", default: 0))
    } else {
      acc + float(e.at("cost", default: 0))
    }
  })
}

/// Compute grand total from line_items and extra_costs arrays.
#let grand-total(items, extra-costs) = {
  let sub = line-subtotal(items)
  sub + extras-total(extra-costs, sub)
}

// ─── Higher-level cost aggregation ──────────────────────────────────────────

/// Sum qty × unit_cost for a generic array of items (requirements, etc.)
#let sum-costs(items) = line-subtotal(items)

/// Full budget summary from the budget dict (dict shape only).
/// Returns: (line-subtotal: float, extra-total: float, grand-total: float)
#let calc-budget(data) = {
  let financials = data
    .at("baselines", default: (:))
    .at("financials", default: (:))
  let budget = financials.at("budget", default: (:))

  if type(budget) != dictionary {
    return (line-subtotal: 0.0, extra-total: 0.0, grand-total: 0.0)
  }

  let items = budget.at("line_items", default: ())
  let extra = budget.at("extra_costs", default: ())
  let sub = line-subtotal(items)
  let ext = extras-total(extra, sub)
  (line-subtotal: sub, extra-total: ext, grand-total: sub + ext)
}

/// Requirements cost summary grouped by category.
/// Returns: (categories: dict(name -> subtotal), grand-total: float)
#let calc-requirements(data) = {
  let reqs = data.at("baselines", default: (:)).at("requirements", default: ())
  if type(reqs) != array { return (categories: (:), grand-total: 0.0) }

  let cats = (:)
  let grand = 0.0
  for r in reqs {
    let cat = r.at("category", default: "General")
    let cost = (
      float(r.at("qty", default: 1)) * float(r.at("unit_cost", default: 0))
    )
    cats.insert(cat, cats.at(cat, default: 0.0) + cost)
    grand += cost
  }
  (categories: cats, grand-total: grand)
}

// ─── Cross-Reference Validation ─────────────────────────────────────────────

/// Collect all IDs from a nested array at the given dot-path.
#let _collect-ids(data, path) = {
  let r = _walk(data, path)
  if not r.found or type(r.value) != array { return () }
  r.value.map(item => item.at("id", default: none)).filter(id => id != none)
}

/// Find orphaned cross-references across all entity relationships.
/// Returns: array of (source, field, ref-id, target) records.
#let find-orphans(data) = {
  let orphans = ()
  let objective-ids = _collect-ids(data, "initiation.objectives")
  let req-ids = _collect-ids(data, "baselines.requirements")
  let risk-ids = _collect-ids(data, "registers.risk_register")
  let issue-ids = _collect-ids(data, "registers.issue_log")
  let milestone-ids = _collect-ids(data, "baselines.schedule.milestones")
  let deliverable-ids = _collect-ids(data, "registers.deliverables_register")
  let compliance-ids = _collect-ids(data, "baselines.compliance")
  let assumption-ids = _collect-ids(data, "initiation.assumptions_log")

  // Gantt task IDs (nested subtasks)
  let task-ids = {
    let gantt = data
      .at("baselines", default: (:))
      .at("schedule", default: (:))
      .at("gantt", default: (:))
    let tasks = gantt.at("tasks", default: ())
    if type(tasks) != array { () } else {
      tasks
        .map(phase => {
          let subs = phase.at("subtasks", default: ())
          if type(subs) != array { () } else {
            subs.map(s => s.at("id", default: none)).filter(id => id != none)
          }
        })
        .flatten()
    }
  }

  let push-orphan(source, field, ref-id, target) = {
    orphans.push((source: source, field: field, ref-id: ref-id, target: target))
  }

  // success_criteria → objectives
  let sc = data
    .at("initiation", default: (:))
    .at("success_criteria", default: ())
  if type(sc) == array {
    for c in sc {
      let oid = c.at("objective_id", default: none)
      if oid != none and oid not in objective-ids {
        push-orphan(
          "success_criteria." + c.at("id", default: "?"),
          "objective_id",
          oid,
          "initiation.objectives",
        )
      }
    }
  }

  // assumptions_log → risk_register
  let assumptions = data
    .at("initiation", default: (:))
    .at("assumptions_log", default: ())
  if type(assumptions) == array {
    for a in assumptions {
      let rid = a.at("risk_id", default: none)
      if rid != none and rid not in risk-ids {
        push-orphan(
          "assumptions_log." + a.at("id", default: "?"),
          "risk_id",
          rid,
          "registers.risk_register",
        )
      }
    }
  }

  // risk_register → tasks, milestones, assumptions
  let risks = data
    .at("registers", default: (:))
    .at("risk_register", default: ())
  if type(risks) == array {
    for r in risks {
      for tid in (
        if type(r.at("affects_wbs", default: ())) == str {
          (r.at("affects_wbs", default: ()),)
        } else { r.at("affects_wbs", default: ()) }
      ) {
        if tid not in task-ids {
          push-orphan(
            "risk_register." + r.at("id", default: "?"),
            "affects_wbs",
            tid,
            "baselines.schedule.gantt",
          )
        }
      }
      for mid in (
        if type(r.at("blocks_milestone", default: ())) == str {
          (r.at("blocks_milestone", default: ()),)
        } else { r.at("blocks_milestone", default: ()) }
      ) {
        if mid not in milestone-ids {
          push-orphan(
            "risk_register." + r.at("id", default: "?"),
            "blocks_milestone",
            mid,
            "baselines.schedule.milestones",
          )
        }
      }
      let sa = r.at("source_assumption", default: none)
      if sa != none and sa not in assumption-ids {
        push-orphan(
          "risk_register." + r.at("id", default: "?"),
          "source_assumption",
          sa,
          "initiation.assumptions_log",
        )
      }
    }
  }

  // issue_log → milestones, deliverables
  let issues = data.at("registers", default: (:)).at("issue_log", default: ())
  if type(issues) == array {
    for i in issues {
      for mid in (
        if type(i.at("blocks_milestone", default: ())) == str {
          (i.at("blocks_milestone", default: ()),)
        } else { i.at("blocks_milestone", default: ()) }
      ) {
        if mid not in milestone-ids {
          push-orphan(
            "issue_log." + i.at("id", default: "?"),
            "blocks_milestone",
            mid,
            "baselines.schedule.milestones",
          )
        }
      }
      for did in (
        if type(i.at("blocks_deliverable", default: ())) == str {
          (i.at("blocks_deliverable", default: ()),)
        } else { i.at("blocks_deliverable", default: ()) }
      ) {
        if did not in deliverable-ids {
          push-orphan(
            "issue_log." + i.at("id", default: "?"),
            "blocks_deliverable",
            did,
            "registers.deliverables_register",
          )
        }
      }
    }
  }

  // decision_log → risks, issues
  let decisions = data
    .at("registers", default: (:))
    .at("decision_log", default: ())
  if type(decisions) == array {
    for d in decisions {
      let pr = d.at("prompted_by_risk", default: none)
      if pr != none and pr not in risk-ids {
        push-orphan(
          "decision_log." + d.at("id", default: "?"),
          "prompted_by_risk",
          pr,
          "registers.risk_register",
        )
      }
      let pi = d.at("prompted_by_issue", default: none)
      if pi != none and pi not in issue-ids {
        push-orphan(
          "decision_log." + d.at("id", default: "?"),
          "prompted_by_issue",
          pi,
          "registers.issue_log",
        )
      }
    }
  }

  // budget line_items → requirements
  let budget = data
    .at("baselines", default: (:))
    .at("financials", default: (:))
    .at("budget", default: (:))
  if type(budget) == dictionary {
    for item in budget.at("line_items", default: ()) {
      let rid = item.at("req_id", default: none)
      if rid != none and rid not in req-ids {
        push-orphan(
          "budget." + item.at("id", default: "?"),
          "req_id",
          rid,
          "baselines.requirements",
        )
      }
    }
  }

  // deliverables → requirements
  for d in data
    .at("registers", default: (:))
    .at("deliverables_register", default: ()) {
    for rid in (
      if type(d.at("req_ids", default: ())) == str {
        (d.at("req_ids", default: ()),)
      } else { d.at("req_ids", default: ()) }
    ) {
      if rid not in req-ids {
        push-orphan(
          "deliverables_register." + d.at("id", default: "?"),
          "req_ids",
          rid,
          "baselines.requirements",
        )
      }
    }
  }

  // acceptance → deliverables
  for a in data.at("closure", default: (:)).at("acceptance", default: ()) {
    let did = a.at("deliverable_id", default: none)
    if did != none and did not in deliverable-ids {
      push-orphan(
        "acceptance",
        "deliverable_id",
        did,
        "registers.deliverables_register",
      )
    }
  }

  // benefits_review → objectives
  for b in data.at("closure", default: (:)).at("benefits_review", default: ()) {
    let oid = b.at("objective_id", default: none)
    if oid != none and oid not in objective-ids {
      push-orphan(
        "benefits_review",
        "objective_id",
        oid,
        "initiation.objectives",
      )
    }
  }

  // quality.criteria → requirements
  let quality = data.at("baselines", default: (:)).at("quality", default: (:))
  if type(quality) == dictionary {
    for c in quality.at("criteria", default: ()) {
      let rid = c.at("req_id", default: none)
      if rid != none and rid not in req-ids {
        push-orphan("quality.criteria", "req_id", rid, "baselines.requirements")
      }
    }
  }

  // compliance → requirements, requirements → compliance
  for c in data.at("baselines", default: (:)).at("compliance", default: ()) {
    for rid in (
      if type(c.at("req_ids", default: ())) == str {
        (c.at("req_ids", default: ()),)
      } else { c.at("req_ids", default: ()) }
    ) {
      if rid not in req-ids {
        push-orphan(
          "compliance." + c.at("id", default: "?"),
          "req_ids",
          rid,
          "baselines.requirements",
        )
      }
    }
  }
  for r in data.at("baselines", default: (:)).at("requirements", default: ()) {
    for cid in (
      if type(r.at("compliance_ids", default: ())) == str {
        (r.at("compliance_ids", default: ()),)
      } else { r.at("compliance_ids", default: ()) }
    ) {
      if cid not in compliance-ids {
        push-orphan(
          "requirements." + r.at("id", default: "?"),
          "compliance_ids",
          cid,
          "baselines.compliance",
        )
      }
    }
  }

  orphans
}

// ─── Schema Audit ────────────────────────────────────────────────────────────

/// Audit all schema fields against data. Returns array of status records.
#let audit-missing(data, extra-checks: ()) = {
  let full-schema = folio-schema + extra-checks
  full-schema.map(entry => {
    let r = _walk(data, entry.path)
    let status = if not r.found { "Missing" } else if not nonempty(
      data,
      entry.path,
    ) { "Empty" } else { "Present" }
    (
      path: entry.path,
      severity: entry.severity,
      phase: entry.at("phase", default: "custom"),
      kind: entry.at("kind", default: "unknown"),
      status: status,
    )
  })
}

/// Count field statuses by severity.
#let audit-summary(audit-results) = {
  let count(sev, status) = audit-results
    .filter(r => r.severity == sev and r.status == status)
    .len()
  (
    critical: (
      present: count("critical", "Present"),
      empty: count("critical", "Empty"),
      missing: count("critical", "Missing"),
    ),
    important: (
      present: count("important", "Present"),
      empty: count("important", "Empty"),
      missing: count("important", "Missing"),
    ),
    recommended: (
      present: count("recommended", "Present"),
      empty: count("recommended", "Empty"),
      missing: count("recommended", "Missing"),
    ),
  )
}

/// Compute the full context dict from raw project data.
#let compute-context(data, config: (:)) = {
  let extra-checks = config.at("extra-checks", default: ())
  let budget = calc-budget(data)
  let requirements = calc-requirements(data)
  let orphans = find-orphans(data)
  let audit = audit-missing(data, extra-checks: extra-checks)
  let summary = audit-summary(audit)
  (
    budget: budget,
    requirements: requirements,
    orphans: orphans,
    audit: audit,
    summary: summary,
    orphan-count: orphans.len(),
    is-clean: orphans.len() == 0 and summary.critical.missing == 0,
  )
}


