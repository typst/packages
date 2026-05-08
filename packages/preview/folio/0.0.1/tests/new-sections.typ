// Test: all new sections render from populated data (Phases 2–6)
// Each section is exercised with a minimal but complete data payload.
#import "@preview/folio:0.0.1": (
  acceptance, assumptions-log, benefits-review, budget, communication, compliance, decision-log, deliverables-register,
  financial-closure, folio-init, gantt, handover, quality, requirements, risk-strategy, stakeholders, success-criteria,
)

#show: body => folio-init(
  data: (
    initiation: (
      objectives: (
        (id: "OBJ-1", description: "Deliver working product", priority: "high"),
      ),
      success_criteria: (
        (
          id: "SC-1",
          type: "project",
          criterion: "All features shipped",
          measurement: "Feature count",
          target: "10",
          objective_id: "OBJ-1",
        ),
        (
          id: "SC-2",
          type: "benefit",
          criterion: "Revenue uplift",
          measurement: "MoM growth",
          target: "+5%",
        ),
      ),
      stakeholders: (
        (
          id: "SH-1",
          name: "Alice",
          role: "Sponsor",
          interest: "high",
          influence: "high",
          engagement: "Weekly sync",
        ),
        (
          id: "SH-2",
          name: "Bob",
          role: "End User",
          interest: "medium",
          influence: "low",
          organization: "Ops Dept",
        ),
      ),
      assumptions_log: (
        (
          id: "A-1",
          type: "assumption",
          description: "Cloud infra available",
          status: "Validated",
        ),
        (
          id: "A-2",
          type: "dependency",
          description: "Legal sign-off by May",
          status: "Open",
        ),
        (
          id: "A-3",
          type: "constraint",
          description: "Budget capped at $50k",
          status: "Invalidated",
          risk_id: "R1",
        ),
      ),
    ),
    baselines: (
      requirements: (
        (
          id: "REQ-01",
          description: "Core API",
          category: "Backend",
          priority: "high",
          qty: 1,
          unit: "module",
          unit_cost: 15000,
        ),
        (
          id: "REQ-02",
          description: "Dashboard UI",
          category: "Frontend",
          priority: "medium",
          qty: 1,
          unit: "module",
          unit_cost: 8000,
        ),
        (
          id: "REQ-03",
          description: "Hosting (1 yr)",
          category: "Infra",
          priority: "high",
          qty: 12,
          unit: "months",
          unit_cost: 500,
        ),
      ),
      quality: (
        standards: ("ISO 9001", "OWASP Top 10"),
        acceptance_procedure: "All P0 bugs resolved before release.",
        testing_strategy: "CI pipeline with 80% coverage gate.",
        criteria: (
          (
            req_id: "REQ-01",
            criterion: "API response < 200ms",
            method: "Load test (k6)",
          ),
        ),
      ),
      communication: (
        (
          what: "Sprint review",
          audience: "All stakeholders",
          frequency: "Bi-weekly",
          channel: "Video call",
          owner: "PM",
        ),
        (
          what: "Status email",
          audience: "Sponsor",
          frequency: "Weekly",
          channel: "Email",
          owner: "PM",
        ),
      ),
      risk_strategy: (
        approach: "Risk-first planning. All High risks need mitigation before sprint start.",
        categories: ("Technical", "Commercial", "Regulatory"),
        scoring: "3×3 probability × impact",
        tolerance: "No High×High risks unmitigated.",
        escalation_threshold: "High×High within 24h to Sponsor",
      ),
      compliance: (
        (
          id: "COMP-1",
          regulation: "GDPR",
          jurisdiction: "EU",
          req_ids: ("REQ-01",),
          status: "Compliant",
          audit_date: "2026-01-15",
        ),
        (
          id: "COMP-2",
          regulation: "SOC 2 Type I",
          jurisdiction: "US",
          req_ids: (),
          status: "Pending",
        ),
      ),
      financials: (
        budget: (
          line_items: (
            (
              id: "BUD-01",
              description: "Core API dev",
              category: "Backend",
              qty: 1,
              unit: "module",
              unit_cost: 15000,
              req_id: "REQ-01",
            ),
            (
              id: "BUD-02",
              description: "Dashboard dev",
              category: "Frontend",
              qty: 1,
              unit: "module",
              unit_cost: 8000,
              req_id: "REQ-02",
            ),
            (
              id: "BUD-03",
              description: "Cloud hosting",
              category: "Infra",
              qty: 12,
              unit: "months",
              unit_cost: 500,
              req_id: "REQ-03",
            ),
          ),
          extra_costs: (
            (description: "Contingency (10%)", percentage: 0.10),
          ),
        ),
      ),
      schedule: (
        gantt: (
          start: "2026-05-01",
          end: "2026-10-01",
          tasks: (
            (
              name: "Backend",
              subtasks: (
                (
                  id: "T1",
                  name: "API design",
                  start: "2026-05-01",
                  end: "2026-05-15",
                ),
                (
                  id: "T2",
                  name: "API build",
                  start: "2026-05-15",
                  end: "2026-07-01",
                ),
              ),
            ),
            (
              name: "Frontend",
              subtasks: (
                (
                  id: "T3",
                  name: "UI wireframes",
                  start: "2026-06-01",
                  end: "2026-06-15",
                ),
                (
                  id: "T4",
                  name: "UI build",
                  start: "2026-06-15",
                  end: "2026-08-01",
                ),
              ),
            ),
          ),
          milestones: (
            (name: "Beta release", date: "2026-08-01", show-date: true),
          ),
        ),
      ),
    ),
    registers: (
      risk_register: (
        (
          id: "R1",
          description: "Budget overrun",
          mitigation: "Weekly burn tracking",
          probability: "Medium",
          impact: "High",
          status: "Open",
          source_assumption: "A-3",
        ),
      ),
      deliverables_register: (
        (
          id: "D1",
          description: "Core API v1.0",
          owner: "Backend team",
          due_date: "2026-07-01",
          status: "In-Progress",
          req_ids: ("REQ-01",),
        ),
        (
          id: "D2",
          description: "Dashboard v1.0",
          owner: "Frontend team",
          due_date: "2026-08-01",
          status: "Planned",
          req_ids: ("REQ-02",),
        ),
      ),
      decision_log: (
        (
          id: "DEC-1",
          description: "Use PostgreSQL over MongoDB",
          date: "2026-05-05",
          decision_maker: "Tech Lead",
          rationale: "Team expertise and ACID compliance.",
          reversibility: "Type-2",
          prompted_by_risk: "R1",
        ),
        (
          id: "DEC-2",
          description: "Skip mobile app for v1",
          date: "2026-05-10",
          decision_maker: "Alice",
          rationale: "Out of scope per budget cap.",
        ),
      ),
    ),
    closure: (
      acceptance: (
        (
          deliverable_id: "D1",
          accepted_by: "Alice",
          acceptance_date: "2026-07-03",
          outstanding_issues: "None",
        ),
      ),
      benefits_review: (
        (
          objective_id: "OBJ-1",
          claimed: "10 features shipped",
          actual: "11 features shipped",
          variance: "+10%",
          root_cause: "Team velocity higher than estimated",
        ),
      ),
      handover: (
        documentation: (
          "API reference v1.0",
          "Deployment runbook",
          "User guide v1.0",
        ),
        training: "1-day onboarding workshop for Ops team.",
        support: "90-day hypercare with 4h SLA.",
        transfer_date: "2026-10-01",
      ),
      financial_closure: (
        final_cost: 48200.0,
        budget_baseline: 50000.0,
        variance: -1800.0,
        variance_explanation: "Frontend delivered under budget.",
        outstanding_invoices: "None.",
      ),
    ),
  ),
  body,
)

= New Sections — Render Test

== Initiation Additions

=== Success Criteria
#success-criteria("initiation.success_criteria")

=== Stakeholder Register
#stakeholders("initiation.stakeholders")

=== Assumptions Log
#assumptions-log("initiation.assumptions_log")

== Planning Additions

=== Requirements Register
#requirements("baselines.requirements")

=== Quality Plan
#quality("baselines.quality")

=== Communication Plan
#communication("baselines.communication")

=== Risk Management Strategy
#risk-strategy("baselines.risk_strategy")

=== Compliance Register
#compliance("baselines.compliance")

=== Budget (rich shape with req cross-refs)
#budget("baselines.financials.budget")

=== Gantt (nested shape)
#gantt("baselines.schedule.gantt")

== Execution Additions

=== Decision Log
#decision-log("registers.decision_log")

=== Deliverables Register
#deliverables-register("registers.deliverables_register")

== Closure Additions

=== Acceptance Records
#acceptance("closure.acceptance")

=== Benefits Review
#benefits-review("closure.benefits_review")

=== Handover
#handover("closure.handover")

=== Financial Closure
#financial-closure("closure.financial_closure")
