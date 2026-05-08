// Full project data dict for fixture testing.
// Covers all 30 schema paths. All cross-references are internally consistent.
// This dict is the single source of truth for the comprehensive test.

#let full-project-data = (
  project: (
    name: "Fixture Test — Full Data",
    description: "Complete PMBOK project data covering all 30 schema paths.",
  ),
  // ─── Initiation ──────────────────────────────────────────────────────
  initiation: (
    pitch: "Validate that every folio section renders correctly with complete data.",
    business_case: "Ensures reliability of the rendering pipeline before v0.0.1 release.",
    objectives: (
      (
        id: "OBJ-1",
        description: "All 30 schema paths render",
        priority: "high",
      ),
      (
        id: "OBJ-2",
        description: "Zero orphan cross-references",
        priority: "high",
      ),
      (
        id: "OBJ-3",
        description: "Audit dashboard is accurate",
        priority: "neutral",
      ),
    ),
    success_criteria: (
      (
        id: "SC-1",
        type: "project",
        criterion: "All sections render without crash",
        measurement: "Compilation result",
        target: "Success",
        objective_id: "OBJ-1",
      ),
      (
        id: "SC-2",
        type: "product",
        criterion: "Zero orphan count",
        measurement: "Orphan count",
        target: "0",
        objective_id: "OBJ-2",
      ),
      (
        id: "SC-3",
        type: "benefit",
        criterion: "Audit matches schema",
        measurement: "Field count",
        target: "30",
        objective_id: "OBJ-3",
      ),
    ),
    stakeholders: (
      (
        id: "SH-1",
        name: "Lead Developer",
        role: "Package Author",
        organization: "folio",
        interest: "high",
        influence: "high",
        engagement: "Daily development",
      ),
      (
        id: "SH-2",
        name: "QA Reviewer",
        role: "Tester",
        organization: "folio",
        interest: "high",
        influence: "medium",
        engagement: "Fixture review",
      ),
    ),
    assumptions_log: (
      (
        id: "A-1",
        type: "assumption",
        description: "Typst 0.14.2+ is the floor",
        status: "Validated",
      ),
      (
        id: "A-2",
        type: "constraint",
        description: "No runtime dependencies beyond gantty",
        status: "Open",
      ),
      (
        id: "A-3",
        type: "dependency",
        description: "Brand presets ship before sections",
        status: "Invalidated",
        risk_id: "R1",
      ),
    ),
  ),
  // ─── Baselines ───────────────────────────────────────────────────────
  baselines: (
    scope: (
      in_scope: (
        "Schema validation",
        "Cost computation",
        "Cross-ref detection",
        "Audit dashboard",
      ),
      out_of_scope: ("Visual regression", "Multi-language support"),
    ),
    requirements: (
      (
        id: "REQ-01",
        description: "Schema field inventory",
        category: "Core",
        priority: "high",
        qty: 1,
        unit: "module",
        unit_cost: 5000,
        compliance_ids: ("COMP-1",),
      ),
      (
        id: "REQ-02",
        description: "Cost aggregation engine",
        category: "Core",
        priority: "high",
        qty: 1,
        unit: "module",
        unit_cost: 3000,
      ),
      (
        id: "REQ-03",
        description: "Orphan detection",
        category: "Validation",
        priority: "medium",
        qty: 1,
        unit: "feature",
        unit_cost: 2000,
      ),
      (
        id: "REQ-04",
        description: "Test fixtures",
        category: "Testing",
        priority: "high",
        qty: 4,
        unit: "files",
        unit_cost: 500,
      ),
    ),
    schedule: (
      milestones: (
        (
          id: "M1",
          date: "2026-05-01",
          title: "Phase 1 Complete",
          status: "Done",
        ),
        (
          id: "M2",
          date: "2026-05-15",
          title: "Phase 2 Complete",
          status: "Pending",
        ),
        (
          id: "M3",
          date: "2026-06-01",
          title: "v0.0.1 Release",
          status: "Pending",
        ),
      ),
      gantt: (
        start: "2026-04-15",
        end: "2026-06-15",
        tasks: (
          (
            name: "Foundation",
            subtasks: (
              (
                id: "T1",
                name: "Schema refactor",
                start: "2026-04-15",
                end: "2026-04-25",
              ),
              (
                id: "T2",
                name: "Compute layer",
                start: "2026-04-20",
                end: "2026-05-01",
              ),
            ),
          ),
          (
            name: "Rendering",
            subtasks: (
              (
                id: "T3",
                name: "Section components",
                start: "2026-05-01",
                end: "2026-05-15",
              ),
              (
                id: "T4",
                name: "Brand presets",
                start: "2026-05-10",
                end: "2026-05-20",
              ),
            ),
          ),
          (
            name: "Integration",
            subtasks: (
              (
                id: "T5",
                name: "Examples & fixtures",
                start: "2026-05-15",
                end: "2026-05-25",
              ),
              (
                id: "T6",
                name: "Documentation",
                start: "2026-05-20",
                end: "2026-06-01",
              ),
            ),
          ),
        ),
        milestones: (
          (name: "Phase 1 done", date: "2026-05-01", show-date: true),
          (name: "v0.0.1 release", date: "2026-06-01", show-date: true),
        ),
      ),
    ),
    financials: (
      budget: (
        line_items: (
          (
            id: "BUD-01",
            description: "Schema & compute development",
            category: "Core",
            qty: 1,
            unit: "module",
            unit_cost: 8000,
            req_id: "REQ-01",
          ),
          (
            id: "BUD-02",
            description: "Validation engine",
            category: "Core",
            qty: 1,
            unit: "module",
            unit_cost: 2000,
            req_id: "REQ-03",
          ),
          (
            id: "BUD-03",
            description: "Test infrastructure",
            category: "Testing",
            qty: 4,
            unit: "fixtures",
            unit_cost: 500,
            req_id: "REQ-04",
          ),
        ),
        extra_costs: (
          (description: "Contingency (10%)", percentage: 0.10),
          (description: "Documentation overhead", cost: 1000),
        ),
      ),
    ),
    quality: (
      standards: ("Typst 0.14.2+ compatibility", "Zero-crash guarantee"),
      acceptance_procedure: "All fixtures compile without errors. Audit-style passes.",
      testing_strategy: "Compile-based: just test runs typst compile on all examples and fixtures.",
      criteria: (
        (
          req_id: "REQ-01",
          criterion: "Schema covers all 30 paths",
          method: "Field count in audit",
        ),
        (
          req_id: "REQ-03",
          criterion: "No false-positive orphans",
          method: "Cross-ref fixture test",
        ),
      ),
    ),
    communication: (
      (
        what: "Progress update",
        audience: "Self",
        frequency: "Daily",
        channel: "Commit log",
        owner: "Developer",
      ),
      (
        what: "Release announcement",
        audience: "Users",
        frequency: "Per release",
        channel: "GitHub",
        owner: "Maintainer",
      ),
    ),
    risk_strategy: (
      approach: "Identify risks early. Mitigate before implementing dependent features.",
      categories: ("Technical", "Scope", "Dependency"),
      scoring: "3×3 probability × impact",
      tolerance: "No High×High unmitigated.",
      escalation_threshold: "Any blocking risk pauses the sprint.",
    ),
    compliance: (
      (
        id: "COMP-1",
        regulation: "Typst Package Guidelines",
        jurisdiction: "Typst Universe",
        req_ids: ("REQ-01",),
        status: "Compliant",
        audit_date: "2026-04-20",
      ),
      (
        id: "COMP-2",
        regulation: "MIT License compliance",
        jurisdiction: "Global",
        req_ids: (),
        status: "Compliant",
      ),
    ),
  ),
  // ─── Governance ──────────────────────────────────────────────────────
  governance: (
    team: (
      (role: "Developer", name: "folio Author", email: "dev@folio.dev"),
      (role: "Reviewer", name: "QA Bot", email: "qa@folio.dev"),
    ),
  ),
  // ─── Execution ───────────────────────────────────────────────────────
  execution: (
    status: (
      health: "Good",
      spend: "40%",
      variance: "0d",
      summary: "Phase 1 foundation complete. Compute layer validated.",
    ),
  ),
  registers: (
    risk_register: (
      (
        id: "R1",
        description: "Brand presets delay sections",
        mitigation: "Parallelize phases 2 & 3",
        probability: "Low",
        impact: "Medium",
        status: "Monitoring",
        source_assumption: "A-3",
      ),
      (
        id: "R2",
        description: "Typst breaking change in 0.15",
        mitigation: "Pin compiler version",
        probability: "Low",
        impact: "High",
        status: "Open",
        affects_wbs: ("T3",),
        blocks_milestone: ("M3",),
      ),
    ),
    issue_log: (
      (
        id: "I1",
        description: "Audit double-counts nested fields",
        owner: "Developer",
        status: "Resolved",
        blocks_milestone: ("M1",),
      ),
      (
        id: "I2",
        description: "Budget extra_costs edge case",
        owner: "Developer",
        status: "In-Progress",
        blocks_deliverable: ("D1",),
      ),
    ),
    change_log: (
      (
        id: "C1",
        description: "Added compute.typ to architecture",
        status: "Approved",
        type: "scope",
        affects_baseline: "baselines.scope",
      ),
      (
        id: "C2",
        description: "Deferred visual regression to v0.1.0",
        status: "Approved",
        type: "scope",
        affects_baseline: "baselines.scope",
      ),
    ),
    decision_log: (
      (
        id: "DEC-1",
        description: "Use separate compute layer instead of inline functions",
        date: "2026-04-25",
        decision_maker: "Developer",
        rationale: "Centralizes all cost and validation logic. Pure functions enable testing.",
        reversibility: "Type-2",
        prompted_by_risk: "R1",
      ),
      (
        id: "DEC-2",
        description: "Keep existing schema paths instead of unified items array",
        date: "2026-04-28",
        decision_maker: "Developer",
        rationale: "Existing architecture is more evolved and already works.",
        reversibility: "Type-1",
      ),
    ),
    deliverables_register: (
      (
        id: "D1",
        description: "compute.typ module",
        owner: "Developer",
        due_date: "2026-05-01",
        status: "Accepted",
        req_ids: ("REQ-02",),
      ),
      (
        id: "D2",
        description: "Test fixture suite",
        owner: "Developer",
        due_date: "2026-05-05",
        status: "In-Progress",
        req_ids: ("REQ-04",),
      ),
      (
        id: "D3",
        description: "SCHEMA.md documentation",
        owner: "Developer",
        due_date: "2026-05-07",
        status: "Planned",
        req_ids: ("REQ-01",),
      ),
    ),
  ),
  // ─── Closure ─────────────────────────────────────────────────────────
  closure: (
    lessons_learned: (
      (
        category: "Architecture",
        issue: "Inline compute logic was scattered across components",
        recommendation: "Centralize all compute in a single module",
      ),
      (
        category: "Testing",
        issue: "No fixture for empty data existed",
        recommendation: "Always create boundary-condition fixtures first",
      ),
    ),
    acceptance: (
      (
        deliverable_id: "D1",
        accepted_by: "Developer",
        acceptance_date: "2026-05-01",
        outstanding_issues: "None",
      ),
    ),
    benefits_review: (
      (
        objective_id: "OBJ-1",
        claimed: "All 30 paths render",
        actual: "All 30 paths render successfully",
        variance: "0%",
        root_cause: "Schema was already complete",
      ),
      (
        objective_id: "OBJ-2",
        claimed: "Zero orphans",
        actual: "Zero orphans detected",
        variance: "0%",
      ),
    ),
    handover: (
      documentation: (
        "SCHEMA.md — field reference",
        "MANIFEST.md — design philosophy",
        "README.md — quick start",
      ),
      training: "Self-documented via examples and fixtures.",
      support: "GitHub Issues for bug reports.",
      transfer_date: "2026-06-01",
    ),
    financial_closure: (
      final_cost: 12500.0,
      budget_baseline: 13100.0,
      variance: -600.0,
      variance_explanation: "Test fixture development was faster than estimated.",
      outstanding_invoices: "None.",
    ),
    sign_off: (
      (name: "folio Author", role: "Developer"),
      (name: "QA Bot", role: "Automated Reviewer"),
    ),
  ),
)
