#let folio-schema = (
  // --- Meta ---
  (path: "project.name", severity: "critical", phase: "meta", kind: "string"),
  (
    path: "project.description",
    severity: "important",
    phase: "meta",
    kind: "string",
  ),
  (
    path: "governance.team",
    severity: "important",
    phase: "meta",
    kind: "array",
  ),
  // --- Initiation ---
  (
    path: "initiation.pitch",
    severity: "critical",
    phase: "initiation",
    kind: "string",
  ),
  (
    path: "initiation.business_case",
    severity: "important",
    phase: "initiation",
    kind: "string",
  ),
  (
    path: "initiation.objectives",
    severity: "recommended",
    phase: "initiation",
    kind: "array",
  ),
  (
    path: "initiation.success_criteria",
    severity: "recommended",
    phase: "initiation",
    kind: "array",
  ),
  (
    path: "initiation.stakeholders",
    severity: "important",
    phase: "initiation",
    kind: "array",
  ),
  (
    path: "initiation.assumptions_log",
    severity: "recommended",
    phase: "initiation",
    kind: "array",
  ),
  // --- Planning ---
  (
    path: "baselines.scope",
    severity: "important",
    phase: "planning",
    kind: "dict",
  ),
  (
    path: "baselines.requirements",
    severity: "important",
    phase: "planning",
    kind: "array",
  ),
  (
    path: "baselines.schedule.milestones",
    severity: "recommended",
    phase: "planning",
    kind: "array",
  ),
  (
    path: "baselines.schedule.gantt",
    severity: "important",
    phase: "planning",
    kind: "dict",
  ),
  (
    path: "baselines.financials.budget",
    severity: "important",
    phase: "planning",
    kind: "dict",
  ),
  (
    path: "baselines.quality",
    severity: "recommended",
    phase: "planning",
    kind: "dict",
  ),
  (
    path: "baselines.communication",
    severity: "recommended",
    phase: "planning",
    kind: "array",
  ),
  (
    path: "baselines.risk_strategy",
    severity: "recommended",
    phase: "planning",
    kind: "dict",
  ),
  (
    path: "baselines.compliance",
    severity: "recommended",
    phase: "planning",
    kind: "array",
  ),
  // --- Execution ---
  (
    path: "execution.status",
    severity: "recommended",
    phase: "execution",
    kind: "dict",
  ),
  (
    path: "registers.risk_register",
    severity: "important",
    phase: "execution",
    kind: "array",
  ),
  (
    path: "registers.issue_log",
    severity: "recommended",
    phase: "execution",
    kind: "array",
  ),
  (
    path: "registers.change_log",
    severity: "recommended",
    phase: "execution",
    kind: "array",
  ),
  (
    path: "registers.decision_log",
    severity: "recommended",
    phase: "execution",
    kind: "array",
  ),
  (
    path: "registers.deliverables_register",
    severity: "recommended",
    phase: "execution",
    kind: "array",
  ),
  // --- Closure ---
  (
    path: "closure.lessons_learned",
    severity: "recommended",
    phase: "closure",
    kind: "array",
  ),
  (
    path: "closure.acceptance",
    severity: "recommended",
    phase: "closure",
    kind: "array",
  ),
  (
    path: "closure.benefits_review",
    severity: "recommended",
    phase: "closure",
    kind: "array",
  ),
  (
    path: "closure.handover",
    severity: "recommended",
    phase: "closure",
    kind: "dict",
  ),
  (
    path: "closure.financial_closure",
    severity: "recommended",
    phase: "closure",
    kind: "dict",
  ),
  (
    path: "closure.sign_off",
    severity: "important",
    phase: "closure",
    kind: "array",
  ),
)
