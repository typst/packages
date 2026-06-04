/// Folio v0.0.1 — Public API
/// Import this module to use folio. Internal machinery is not exposed here.

// ── Entry point ──────────────────────────────────────────────────────────────
#import "core/orchestrator.typ": project-doc
// folio-init: public for custom pipeline / standalone component use
#import "core/state.typ": folio-init

// ── Phase-level functions (orchestrate a whole phase) ───────────────────────
#import "phases/initiation.typ": initiation
#import "phases/planning.typ": planning
#import "phases/execution.typ": execution
#import "phases/closure.typ": closure
#import "phases/custom.typ": custom

// ── Section-level functions (individual PMBOK sections) ─────────────────────
// Initiation
#import "components/initiation.typ": (
  assumptions-log, business-case, cover, objectives, pitch, stakeholders,
  success-criteria,
)
// Planning
#import "components/planning.typ": (
  boundaries, budget, communication, compliance, gantt, milestones, quality,
  requirements, risk-strategy, team,
)
// Execution
#import "components/execution.typ": (
  change-log, decision-log, deliverables-register, issue-log, risk-matrix,
  status-report,
)
// Closure
#import "components/closure.typ": (
  acceptance, benefits-review, financial-closure, handover, lessons-learned,
  sign-off,
)

// ── Themed UI primitives (token-resolved, use these in custom sections) ──────
#import "theme/ui.typ": badge, card, data-table, metric, progress-bar

// ── Raw primitives (explicit params, for power users) ───────────────────────
#import "primitives/card.typ": card as raw-card
#import "primitives/badge.typ": badge as raw-badge
#import "primitives/data-table.typ": data-table as raw-data-table
#import "primitives/metric.typ": metric as raw-metric
#import "primitives/progress-bar.typ": progress-bar as raw-progress-bar

// ── Formatters ───────────────────────────────────────────────────────────────
#import "utils/formatters.typ": format-date, format-money, format-percent

// ── Cross-reference utilities ────────────────────────────────────────────────
#import "core/refs.typ": (
  assumption-label, change-label, compliance-label, decision-label,
  deliverable-label, issue-label, link-to-assumption, link-to-change,
  link-to-compliance, link-to-decision, link-to-deliverable, link-to-issue,
  link-to-milestone, link-to-objective, link-to-req, link-to-risk,
  link-to-stakeholder, link-to-task, milestone-label, objective-label,
  req-label, risk-label, stakeholder-label, task-label,
)

// ── Compute layer (pure functions — data → values) ───────────────────────────
#import "compute.typ": (
  audit-missing, audit-summary, calc-budget, calc-requirements, compute-context,
  extras-total, find-orphans, grand-total, line-subtotal, sum-costs,
)

// ── Validator convenience wrappers (context-aware compute) ───────────────────
#import "utils/validators.typ": audit-builder, missing-fields, orphan-check
