// Test: cross-reference links between sections
// Objectives → success-criteria, assumptions → risks, deliverables → requirements, etc.
#import "@preview/folio:0.0.1": project-doc

#show: project-doc(
  data: (
    project: (
      name: "Cross-Ref Test",
      description: "Verifying all label/link families",
    ),
    initiation: (
      pitch: "Testing that every cross-reference resolves to a real label in the document.",
      objectives: (
        (id: "OBJ-1", description: "Validate all cross-refs", priority: "high"),
      ),
      success_criteria: (
        (
          id: "SC-1",
          type: "project",
          criterion: "All links clickable, zero orphans",
          measurement: "Orphan count",
          target: "0",
          objective_id: "OBJ-1",
        ),
      ),
      stakeholders: (
        (
          id: "SH-1",
          name: "Test Runner",
          role: "QA",
          interest: "high",
          influence: "high",
        ),
      ),
      assumptions_log: (
        (
          id: "A-1",
          type: "assumption",
          description: "Typst compiler is deterministic",
          status: "Validated",
        ),
        (
          id: "A-2",
          type: "dependency",
          description: "Package installed locally",
          status: "Open",
          risk_id: "R1",
        ),
      ),
    ),
    baselines: (
      scope: (
        in_scope: ("Cross-reference validation",),
        out_of_scope: ("Visual regression testing",),
      ),
      requirements: (
        (
          id: "REQ-01",
          description: "Label emission for every entity",
          category: "Correctness",
          priority: "high",
          qty: 1,
          unit: "feature",
          unit_cost: 0,
        ),
      ),
      schedule: (
        milestones: (
          (
            id: "M1",
            date: "2026-05-01",
            title: "Cross-refs green",
            status: "Pending",
          ),
        ),
        gantt: (
          start: "2026-04-01",
          end: "2026-06-01",
          tasks: (
            (
              name: "Implementation",
              subtasks: (
                (
                  id: "T1",
                  name: "Add label families",
                  start: "2026-04-01",
                  end: "2026-04-15",
                ),
              ),
            ),
          ),
        ),
      ),
      financials: (
        budget: (
          (description: "CI compute", amount: 500),
        ),
      ),
      communication: (
        (
          what: "Test results",
          audience: "Dev team",
          frequency: "Per PR",
          channel: "CI report",
          owner: "CI",
        ),
      ),
    ),
    governance: (
      team: (
        (role: "Developer", name: "Test Author", email: "test@folio.dev"),
      ),
    ),
    execution: (
      status: (
        health: "Good",
        spend: "10%",
        variance: "0d",
        summary: "Cross-ref test in progress.",
      ),
    ),
    registers: (
      risk_register: (
        (
          id: "R1",
          description: "Package not installed locally",
          mitigation: "Run `just local` first",
          probability: "Low",
          impact: "High",
          status: "Open",
          source_assumption: "A-2",
        ),
      ),
      issue_log: (
        (
          id: "I1",
          description: "Orphan ref detected",
          owner: "CI",
          status: "Open",
          blocks_deliverable: ("D1",),
        ),
      ),
      change_log: (
        (
          id: "C1",
          description: "Added new label families",
          status: "Approved",
          type: "scope",
          affects_baseline: "baselines.scope",
        ),
      ),
      decision_log: (
        (
          id: "DEC-1",
          description: "Use slugify for label IDs",
          date: "2026-04-01",
          decision_maker: "Architect",
          rationale: "Avoids special-char collisions.",
          reversibility: "Type-2",
          prompted_by_risk: "R1",
        ),
      ),
      deliverables_register: (
        (
          id: "D1",
          description: "All label families green",
          owner: "Dev",
          due_date: "2026-05-01",
          status: "Planned",
          req_ids: ("REQ-01",),
        ),
      ),
    ),
    closure: (
      lessons_learned: (
        (
          category: "Architecture",
          issue: "Labels must be emitted before links resolve",
          recommendation: "Always emit labels in the same pass as the data table row",
        ),
      ),
      acceptance: (
        (
          deliverable_id: "D1",
          accepted_by: "QA Lead",
          acceptance_date: "2026-05-02",
          outstanding_issues: "None",
        ),
      ),
      benefits_review: (
        (
          objective_id: "OBJ-1",
          claimed: "Zero orphan references",
          actual: "Zero orphan references",
          variance: "0%",
        ),
      ),
      handover: (
        documentation: ("Cross-ref guide",),
        transfer_date: "2026-05-10",
      ),
      financial_closure: (
        final_cost: 450.0,
        budget_baseline: 500.0,
        variance: -50.0,
      ),
      sign_off: (
        (name: "QA Lead", role: "Acceptance authority"),
      ),
    ),
  ),
  config: (audit: true, toc: true),
)
