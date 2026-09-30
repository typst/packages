// Shared data dictionary for folio examples.
// Covers all 30 schema paths across all 28 pipeline sections.

#let project-data = (
  project: (
    name: "Chimera Urban Infrastructure",
    description: "Phase 2 Smart City implementation - Puebla District",
  ),
  // ─── Initiation ────────────────────────────────────────────────────────────
  initiation: (
    pitch: "Deploy a mesh network of acoustic sensors to detect and triangulate urban anomalies.",
    business_case: "Reduces emergency response time by 15% through automated incident detection.",
    objectives: (
      (id: "OBJ-1", description: "Deploy 500 sensor nodes", priority: "high"),
      (
        id: "OBJ-2",
        description: "Achieve <2s triangulation latency",
        priority: "high",
      ),
      (
        id: "OBJ-3",
        description: "Integrate with municipal dispatch",
        priority: "neutral",
      ),
    ),
    success_criteria: (
      (
        id: "SC-1",
        type: "project",
        criterion: "All 500 nodes operational",
        measurement: "Node count",
        target: "500",
        objective_id: "OBJ-1",
      ),
      (
        id: "SC-2",
        type: "product",
        criterion: "Latency below threshold",
        measurement: "P95 latency",
        target: "<2s",
        objective_id: "OBJ-2",
      ),
      (
        id: "SC-3",
        type: "benefit",
        criterion: "Dispatch response improved",
        measurement: "Response time delta",
        target: "-15%",
        objective_id: "OBJ-3",
      ),
    ),
    stakeholders: (
      (
        id: "SH-1",
        name: "Secretary of Urban Development",
        role: "Executive Sponsor",
        organization: "Puebla City Government",
        interest: "high",
        influence: "high",
        engagement: "Active steering committee member",
      ),
      (
        id: "SH-2",
        name: "Municipal Dispatch Center",
        role: "End-User Representative",
        organization: "Emergency Services",
        interest: "high",
        influence: "medium",
        engagement: "Participates in acceptance testing",
      ),
      (
        id: "SH-3",
        name: "Neighborhood Councils",
        role: "Community Representative",
        organization: "Civil Society",
        interest: "medium",
        influence: "low",
        engagement: "Informed via public meetings",
      ),
    ),
    assumptions_log: (
      (
        id: "A-1",
        type: "assumption",
        description: "5G coverage available in all deployment zones",
        status: "Validated",
      ),
      (
        id: "A-2",
        type: "constraint",
        description: "Budget cannot exceed $235,000 for Phase 2",
        status: "Open",
      ),
      (
        id: "A-3",
        type: "dependency",
        description: "Municipal API spec finalized before integration sprint",
        status: "Invalidated",
        risk_id: "R2",
      ),
    ),
  ),
  // ─── Baselines ─────────────────────────────────────────────────────────────
  baselines: (
    scope: (
      in_scope: (
        "Sensor hardware deployment",
        "Acoustic ML model training",
        "API integration",
      ),
      out_of_scope: ("Public-facing mobile app", "Camera surveillance"),
    ),
    requirements: (
      (
        id: "REQ-01",
        description: "Acoustic sensor node hardware",
        category: "Hardware",
        priority: "high",
        qty: 500,
        unit: "units",
        unit_cost: 240,
        compliance_ids: ("COMP-2",),
      ),
      (
        id: "REQ-02",
        description: "Tamper-proof enclosures",
        category: "Hardware",
        priority: "medium",
        qty: 500,
        unit: "units",
        unit_cost: 0,
      ),
      (
        id: "REQ-03",
        description: "Installation labor (on-site)",
        category: "Services",
        priority: "high",
        qty: 1,
        unit: "project",
        unit_cost: 85000,
      ),
      (
        id: "REQ-04",
        description: "Acoustic ML model license",
        category: "Software",
        priority: "high",
        qty: 1,
        unit: "license",
        unit_cost: 30000,
      ),
      (
        id: "REQ-05",
        description: "Municipal API integration layer",
        category: "Software",
        priority: "medium",
        qty: 1,
        unit: "module",
        unit_cost: 0,
      ),
    ),
    schedule: (
      milestones: (
        (id: "M1", date: "2026-05-01", title: "Pilot Complete", status: "Done"),
        (
          id: "M2",
          date: "2026-08-01",
          title: "District-Wide Rollout",
          status: "Pending",
        ),
      ),
      gantt: (
        start: "2026-04-01",
        end: "2026-09-01",
        tasks: (
          (
            name: "Phase 1 — Procurement",
            subtasks: (
              (
                id: "T1",
                name: "Hardware ordering",
                start: "2026-04-01",
                end: "2026-04-15",
              ),
              (
                id: "T2",
                name: "Vendor qualification",
                start: "2026-04-01",
                end: "2026-04-20",
              ),
            ),
          ),
          (
            name: "Phase 2 — Deployment",
            subtasks: (
              (
                id: "T3",
                name: "Pilot installation (Sector 1)",
                start: "2026-04-20",
                end: "2026-05-01",
              ),
              (
                id: "T4",
                name: "District-wide rollout",
                start: "2026-05-01",
                end: "2026-08-01",
              ),
            ),
          ),
          (
            name: "Phase 3 — Integration",
            subtasks: (
              (
                id: "T5",
                name: "API integration sprint",
                start: "2026-07-01",
                end: "2026-08-15",
              ),
              (
                id: "T6",
                name: "Acceptance testing",
                start: "2026-08-15",
                end: "2026-09-01",
              ),
            ),
          ),
        ),
        milestones: (
          (name: "Pilot complete", date: "2026-05-01", show-date: true),
          (name: "Full deployment", date: "2026-08-01", show-date: true),
        ),
      ),
    ),
    financials: (
      budget: (
        line_items: (
          (
            id: "BUD-01",
            description: "Acoustic sensor nodes (500 units)",
            category: "Hardware",
            qty: 500,
            unit: "units",
            unit_cost: 240,
            req_id: "REQ-01",
          ),
          (
            id: "BUD-02",
            description: "Installation labor",
            category: "Services",
            qty: 1,
            unit: "project",
            unit_cost: 85000,
            req_id: "REQ-03",
          ),
          (
            id: "BUD-03",
            description: "Acoustic ML software license",
            category: "Software",
            qty: 1,
            unit: "license",
            unit_cost: 30000,
            req_id: "REQ-04",
          ),
        ),
        extra_costs: (
          (description: "Project management overhead", percentage: 0.10),
          (description: "Contingency reserve", cost: 10000),
        ),
      ),
    ),
    quality: (
      standards: ("ISO 9001:2015", "IEC 61010 (sensor safety)"),
      acceptance_procedure: "Each node passes functional test before installation. District-level acceptance requires >98% node uptime over 72h.",
      testing_strategy: "Unit tests for ML model, integration tests for API, field acceptance tests post-deployment.",
      criteria: (
        (
          req_id: "REQ-01",
          criterion: "Node uptime ≥ 99% over 30 days",
          method: "Automated telemetry monitoring",
        ),
        (
          req_id: "REQ-04",
          criterion: "Model accuracy ≥ 95% on validation set",
          method: "Offline benchmark suite",
        ),
      ),
    ),
    communication: (
      (
        what: "Weekly status report",
        audience: "Executive Sponsor",
        frequency: "Weekly",
        channel: "Email",
        owner: "Program Manager",
      ),
      (
        what: "Sprint review",
        audience: "Technical team",
        frequency: "Bi-weekly",
        channel: "Video",
        owner: "Hardware Lead",
      ),
      (
        what: "Community update newsletter",
        audience: "Neighborhood Councils",
        frequency: "Monthly",
        channel: "Email",
        owner: "Program Manager",
      ),
      (
        what: "Incident notification",
        audience: "Dispatch Center",
        frequency: "As needed",
        channel: "SMS",
        owner: "On-call engineer",
      ),
    ),
    risk_strategy: (
      approach: "Identify, assess, and mitigate risks proactively. All High risks require mitigation plans before milestone gates.",
      categories: ("Technical", "Organizational", "External", "Environmental"),
      scoring: "3×3 matrix: probability (Low/Medium/High) × impact (Low/Medium/High)",
      tolerance: "No unmitigated High risks at any milestone gate.",
      escalation_threshold: "Any risk reaching High×High escalates to Executive Sponsor within 24h.",
    ),
    compliance: (
      (
        id: "COMP-1",
        regulation: "GDPR — Audio data privacy",
        jurisdiction: "EU / Mexico",
        req_ids: ("REQ-04", "REQ-05"),
        status: "Compliant",
        audit_date: "2026-03-01",
      ),
      (
        id: "COMP-2",
        regulation: "NOM-001-SCFI (electrical)",
        jurisdiction: "Mexico",
        req_ids: ("REQ-01",),
        status: "Compliant",
        audit_date: "2026-02-15",
      ),
      (
        id: "COMP-3",
        regulation: "Municipal Permit 2026-A",
        jurisdiction: "Puebla City",
        req_ids: (),
        status: "Pending",
      ),
    ),
  ),
  // ─── Governance ────────────────────────────────────────────────────────────
  governance: (
    team: (
      (
        role: "Program Manager",
        name: "Elena Rodriguez",
        email: "elena@chimera.city",
      ),
      (role: "Hardware Lead", name: "Marco Polo", email: "marco@chimera.city"),
    ),
  ),
  // ─── Execution ─────────────────────────────────────────────────────────────
  execution: (
    status: (
      health: "Good",
      spend: "45%",
      variance: "0d",
      summary: "Hardware procurement finished ahead of schedule. Installation phase underway.",
    ),
  ),
  registers: (
    risk_register: (
      (
        id: "R1",
        description: "Supply chain delays for chips",
        mitigation: "Bulk order placed in Phase 1",
        probability: "Low",
        impact: "High",
        status: "Closed",
        compliance_ids: ("COMP-1",),
      ),
      (
        id: "R2",
        description: "Municipal API spec not finalized",
        mitigation: "Escalated to city liaison",
        probability: "Medium",
        impact: "High",
        status: "Open",
        source_assumption: "A-3",
      ),
      (
        id: "R3",
        description: "Vandalism of sensor nodes",
        mitigation: "Tamper-proof enclosures",
        probability: "Medium",
        impact: "Low",
        status: "Open",
        affects_wbs: ("T4",),
        blocks_milestone: ("M2",),
      ),
    ),
    issue_log: (
      (
        id: "I1",
        description: "Frequency interference in Sector 4",
        owner: "Marco",
        status: "Resolved",
        blocks_milestone: ("M1",),
      ),
      (
        id: "I2",
        description: "API endpoint authentication error",
        owner: "Elena",
        status: "In-Progress",
        blocks_deliverable: ("D2",),
      ),
    ),
    change_log: (
      (
        id: "C1",
        description: "Add weather sensors to nodes",
        status: "Pending",
        type: "scope",
        affects_baseline: "baselines.scope",
      ),
      (
        id: "C2",
        description: "Extend rollout deadline by 2 weeks",
        status: "Approved",
        type: "schedule",
        affects_baseline: "baselines.schedule",
      ),
    ),
    decision_log: (
      (
        id: "DEC-1",
        description: "Use LoRaWAN for sensor backhaul in low-coverage zones",
        date: "2026-04-10",
        decision_maker: "Elena Rodriguez",
        rationale: "5G not available in 12% of zones; LoRaWAN covers gap at low cost.",
        reversibility: "Type-2",
        prompted_by_risk: "R1",
      ),
      (
        id: "DEC-2",
        description: "Defer mobile app to Phase 3",
        date: "2026-04-15",
        decision_maker: "Secretary of Urban Development",
        rationale: "Budget constraint prevents parallel track.",
        reversibility: "Type-1",
      ),
    ),
    deliverables_register: (
      (
        id: "D1",
        description: "500 sensor nodes installed & operational",
        owner: "Marco Polo",
        due_date: "2026-08-01",
        status: "In-Progress",
        req_ids: ("REQ-01", "REQ-02"),
      ),
      (
        id: "D2",
        description: "Municipal API integration layer",
        owner: "Elena Rodriguez",
        due_date: "2026-08-15",
        status: "Planned",
        req_ids: ("REQ-05",),
      ),
      (
        id: "D3",
        description: "ML model trained & validated",
        owner: "Data Science team",
        due_date: "2026-07-01",
        status: "Accepted",
        req_ids: ("REQ-04",),
      ),
    ),
  ),
  // ─── Closure ───────────────────────────────────────────────────────────────
  closure: (
    lessons_learned: (
      (
        category: "Hardware",
        issue: "Battery life lower in high-humidity areas",
        recommendation: "Use solar-augmentation for tropical sectors",
      ),
      (
        category: "Process",
        issue: "API spec ambiguity caused integration delay",
        recommendation: "Require signed spec before integration sprint",
      ),
    ),
    acceptance: (
      (
        deliverable_id: "D3",
        accepted_by: "Data Science Lead",
        acceptance_date: "2026-07-05",
        outstanding_issues: "None",
      ),
    ),
    benefits_review: (
      (
        objective_id: "OBJ-1",
        claimed: "500 nodes deployed",
        actual: "498 nodes operational (2 RMA)",
        variance: "-0.4%",
        root_cause: "Manufacturing defects on 2 units",
      ),
      (
        objective_id: "OBJ-2",
        claimed: "<2s triangulation latency",
        actual: "1.4s average",
        variance: "+30%",
        root_cause: "Algorithm optimization exceeded target",
      ),
    ),
    handover: (
      documentation: (
        "Sensor maintenance manual v1.2",
        "API integration guide v2.0",
        "ML model card & evaluation report",
      ),
      training: "3-day onboarding session for dispatch center operators (recorded).",
      support: "12-month warranty on hardware; helpdesk SLA 4h response for P1 incidents.",
      transfer_date: "2026-09-15",
    ),
    financial_closure: (
      final_cost: 231500.0,
      budget_baseline: 235000.0,
      variance: -3500.0,
      variance_explanation: "Hardware savings from bulk discount offset API integration overrun.",
      outstanding_invoices: "Final labor invoice (~$2,000) pending approval.",
    ),
    sign_off: (
      (name: "Secretary of Urban Development", role: "Executive Sponsor"),
      (name: "Elena Rodriguez", role: "Program Manager"),
    ),
  ),
)
