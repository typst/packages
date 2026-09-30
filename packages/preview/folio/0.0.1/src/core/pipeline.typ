#import "../components/initiation.typ": (
  assumptions-log, business-case, objectives, pitch, stakeholders,
  success-criteria,
)
#import "../components/planning.typ": (
  boundaries, budget, communication, compliance, gantt, milestones, quality,
  requirements, risk-strategy, team,
)
#import "../components/execution.typ": (
  change-log, decision-log, deliverables-register, issue-log, risk-matrix,
  status-report,
)
#import "../components/closure.typ": (
  acceptance, benefits-review, financial-closure, handover, lessons-learned,
  sign-off,
)

#let pmbok-pipeline = (
  // --- Initiation (6 sections) ---
  (
    phase: "initiation",
    section_id: "pitch",
    data_path: "initiation.pitch",
    render_fn: pitch,
  ),
  (
    phase: "initiation",
    section_id: "business_case",
    data_path: "initiation.business_case",
    render_fn: business-case,
  ),
  (
    phase: "initiation",
    section_id: "objectives",
    data_path: "initiation.objectives",
    render_fn: objectives,
  ),
  (
    phase: "initiation",
    section_id: "success_criteria",
    data_path: "initiation.success_criteria",
    render_fn: success-criteria,
  ),
  (
    phase: "initiation",
    section_id: "stakeholders",
    data_path: "initiation.stakeholders",
    render_fn: stakeholders,
  ),
  (
    phase: "initiation",
    section_id: "assumptions_log",
    data_path: "initiation.assumptions_log",
    render_fn: assumptions-log,
  ),
  // --- Planning (10 sections) ---
  (
    phase: "planning",
    section_id: "boundaries",
    data_path: "baselines.scope",
    render_fn: boundaries,
  ),
  (
    phase: "planning",
    section_id: "requirements",
    data_path: "baselines.requirements",
    render_fn: requirements,
  ),
  (
    phase: "planning",
    section_id: "milestones",
    data_path: "baselines.schedule.milestones",
    render_fn: milestones,
  ),
  (
    phase: "planning",
    section_id: "budget",
    data_path: "baselines.financials.budget",
    render_fn: budget,
  ),
  (
    phase: "planning",
    section_id: "gantt",
    data_path: "baselines.schedule.gantt",
    render_fn: gantt,
  ),
  (
    phase: "planning",
    section_id: "quality",
    data_path: "baselines.quality",
    render_fn: quality,
  ),
  (
    phase: "planning",
    section_id: "communication",
    data_path: "baselines.communication",
    render_fn: communication,
  ),
  (
    phase: "planning",
    section_id: "risk_strategy",
    data_path: "baselines.risk_strategy",
    render_fn: risk-strategy,
  ),
  (
    phase: "planning",
    section_id: "compliance",
    data_path: "baselines.compliance",
    render_fn: compliance,
  ),
  (
    phase: "planning",
    section_id: "team",
    data_path: "governance.team",
    render_fn: team,
  ),
  // --- Execution (6 sections) ---
  (
    phase: "execution",
    section_id: "status_report",
    data_path: "execution.status",
    render_fn: status-report,
  ),
  (
    phase: "execution",
    section_id: "risk_matrix",
    data_path: "registers.risk_register",
    render_fn: risk-matrix,
  ),
  (
    phase: "execution",
    section_id: "issue_log",
    data_path: "registers.issue_log",
    render_fn: issue-log,
  ),
  (
    phase: "execution",
    section_id: "change_log",
    data_path: "registers.change_log",
    render_fn: change-log,
  ),
  (
    phase: "execution",
    section_id: "decision_log",
    data_path: "registers.decision_log",
    render_fn: decision-log,
  ),
  (
    phase: "execution",
    section_id: "deliverables_register",
    data_path: "registers.deliverables_register",
    render_fn: deliverables-register,
  ),
  // --- Closure (6 sections) ---
  (
    phase: "closure",
    section_id: "lessons_learned",
    data_path: "closure.lessons_learned",
    render_fn: lessons-learned,
  ),
  (
    phase: "closure",
    section_id: "acceptance",
    data_path: "closure.acceptance",
    render_fn: acceptance,
  ),
  (
    phase: "closure",
    section_id: "benefits_review",
    data_path: "closure.benefits_review",
    render_fn: benefits-review,
  ),
  (
    phase: "closure",
    section_id: "handover",
    data_path: "closure.handover",
    render_fn: handover,
  ),
  (
    phase: "closure",
    section_id: "financial_closure",
    data_path: "closure.financial_closure",
    render_fn: financial-closure,
  ),
  (
    phase: "closure",
    section_id: "sign_off",
    data_path: "closure.sign_off",
    render_fn: sign-off,
  ),
)
