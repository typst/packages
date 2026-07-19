# folio — Schema Map v0.0.1

> **This document is the contract.** Every schema path, its expected shape, severity, cross-references, and the component that renders it. If a path isn't here, folio doesn't support it. If a relationship isn't here, `refs.typ` doesn't link it.

---

## Assumptions / Decisions / Out of Scope

**Assumptions (from alignment):**
- Typst 0.14.2+ as the floor
- `gantty:0.5.1` is a hard dependency declared in `typst.toml`
- Cross-references use ID-based linking (v0.0.1) with automatic rollups deferred to v0.1.0
- No i18n — `format-money`, `format-date`, and `get-title` overrides handle locale
- No `project.sponsor`, `project.code`, `project.version` in scope
- Phase titles remain overridable via `get-title` data paths
- All existing examples must keep compiling after changes

**Decisions:**
- Feature-driven approach: folio gains components from PM standards, not from `01`'s bespoke implementation
- `01` reshapes its data to fit folio's schema
- Cover page remains external (`config: (cover: false)` + user's own cover)
- Pipeline is the single ordering mechanism — new sections slot into existing 4 phases + custom
- Every referenceable entity requires a stable `id` field

**Out of Scope:**
- Tailoring / methodology adaptation (PMBOK 7, PRINCE2)
- i18n / locale system
- PDF forms / interactive elements
- Presentation / slide generation
- Computed rollups (v0.1.0)
- `project.sponsor`, `project.code`, `project.version`

---

## Label Families (refs.typ)

Each referenceable entity type gets a label family. Labels are Typst labels created via `label("prefix-" + slugify(id))`. Cross-references resolve via `safe-link`.

| Prefix | Entity | Example |
|--------|--------|---------|
| `task-` | Gantt task | `task-t1` |
| `milestone-` | Schedule milestone | `milestone-m1` |
| `risk-` | Risk register entry | `risk-r1` |
| `issue-` | Issue log entry | `issue-i1` |
| `change-` | Change log entry | `change-c1` |
| `req-` | Requirement | `req-req-01` |
| `deliverable-` | Deliverables register entry | `deliverable-d1` |
| `assumption-` | Assumptions log entry | `assumption-a1` |
| `decision-` | Decision log entry | `decision-dec-1` |
| `stakeholder-` | Stakeholder register entry | `stakeholder-sh-1` |
| `objective-` | Objective | `objective-obj-1` |

---

## Schema Paths

### Cross-cutting — Project Metadata

#### `project.name`
- **Type:** `string`
- **Severity:** `critical`
- **Phase:** `meta`
- **Rendered by:** `cover()`, page headers
- **Cross-refs:** None
- **Shape:**
  ```
  project: (name: "string")
  ```

#### `project.description`
- **Type:** `string`
- **Severity:** `important`
- **Phase:** `meta`
- **Rendered by:** `cover()`
- **Cross-refs:** None
- **Shape:**
  ```
  project: (description: "string")
  ```

---

### Phase 1 — Initiation

#### `initiation.pitch`
- **Type:** `string`
- **Severity:** `critical`
- **Phase:** `initiation`
- **Pipeline ID:** `pitch`
- **Rendered by:** `pitch(data-path)` — card with elevator description
- **Cross-refs:** None
- **Shape:**
  ```
  initiation: (pitch: "string")
  ```

#### `initiation.business_case`
- **Type:** `string`
- **Severity:** `important`
- **Phase:** `initiation`
- **Pipeline ID:** `business_case`
- **Rendered by:** `business-case(data-path)` — card with business justification
- **Cross-refs:** None
- **Shape:**
  ```
  initiation: (business_case: "string")
  ```

#### `initiation.objectives`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `initiation`
- **Pipeline ID:** `objectives`
- **Rendered by:** `objectives(data-path)` — table with ID, description, priority badge
- **Cross-refs:**
  - → `closure.benefits_review` (original objectives vs. actual outcomes)
  - Each entry gets `objective-label(id)`
- **Shape:**
  ```
  initiation: (objectives: (
    (id: "OBJ-1", description: "string", priority: "high|neutral|low"),
    ...
  ))
  ```

#### `initiation.success_criteria`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `initiation`
- **Pipeline ID:** `success_criteria`
- **Rendered by:** `success-criteria(data-path)` — table with type, criterion, measurement, target
- **Cross-refs:**
  - → `initiation.objectives` via `objective_id` (which objective this criterion measures)
  - Links rendered via `link-to-objective`
- **Shape:**
  ```
  initiation: (success_criteria: (
    (
      id: "SC-1",
      type: "project|product|benefit",
      criterion: "string",
      measurement: "string",
      target: "string",
      objective_id: "OBJ-1",       // optional, links to objective
    ),
    ...
  ))
  ```

#### `initiation.stakeholders`
- **Type:** `array`
- **Severity:** `important`
- **Phase:** `initiation`
- **Pipeline ID:** `stakeholders`
- **Rendered by:** `stakeholders(data-path)` — table with name, role, organization, interest, influence
- **Cross-refs:**
  - → `closure.sign_off` (signers are stakeholders)
  - → `governance.team` (overlap detection in audit)
  - Each entry gets `stakeholder-label(id)`
- **Shape:**
  ```
  initiation: (stakeholders: (
    (
      id: "SH-1",
      name: "string",
      role: "string",
      organization: "string",       // optional
      interest: "high|medium|low",
      influence: "high|medium|low",
      engagement: "string",         // optional, strategy text
    ),
    ...
  ))
  ```

#### `initiation.assumptions_log`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `initiation`
- **Pipeline ID:** `assumptions_log`
- **Rendered by:** `assumptions-log(data-path)` — table with ID, assumption, status, linked risk
- **Cross-refs:**
  - → `registers.risk_register` via `risk_id` (invalidated assumption becomes a risk)
  - Each entry gets `assumption-label(id)`
- **Shape:**
  ```
  initiation: (assumptions_log: (
    (
      id: "A-1",
      description: "string",
      type: "assumption|constraint|dependency",
      status: "Open|Validated|Invalidated",
      risk_id: "R-1",              // optional, if invalidated → risk
    ),
    ...
  ))
  ```

---

### Phase 2 — Planning

#### `baselines.scope`
- **Type:** `dictionary`
- **Severity:** `important`
- **Phase:** `planning`
- **Pipeline ID:** `boundaries`
- **Rendered by:** `boundaries(data-path)` — two cards: in-scope, out-of-scope
- **Cross-refs:** None
- **Shape:**
  ```
  baselines: (scope: (
    in_scope: ("string", ...),
    out_of_scope: ("string", ...),
  ))
  ```

#### `baselines.requirements`
- **Type:** `array`
- **Severity:** `important`
- **Phase:** `planning`
- **Pipeline ID:** `requirements`
- **Rendered by:** `requirements(data-path)` — table grouped by category with ID, description, qty, unit, unit_cost, subtotal, priority badge. Category subtotals. Grand total row.
- **Cross-refs:**
  - → `baselines.financials.budget` (budget line items reference `req_id`)
  - → `registers.deliverables_register` (deliverables reference `req_id` for traceability)
  - ← `baselines.quality` (quality criteria reference `req_id`)
  - ← `baselines.compliance` (regulatory reqs reference `req_id`)
  - Each entry gets `req-label(id)`
- **Shape:**
  ```
  baselines: (requirements: (
    (
      id: "REQ-01",
      description: "string",
      category: "string",           // grouping key
      priority: "high|medium|low",
      qty: 1,                       // optional, default 1
      unit: "string",               // optional, e.g. "meters", "units"
      unit_cost: 0.0,               // optional, for costed requirements
    ),
    ...
  ))
  ```

#### `baselines.schedule.milestones`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `planning`
- **Pipeline ID:** `milestones`
- **Rendered by:** `milestones(data-path)` — table with date, title, status badge
- **Cross-refs:**
  - ← `registers.risk_register` via `blocks_milestone`
  - ← `registers.issue_log` via `blocks_milestone`
  - Each entry gets `milestone-label(id)`
- **Shape:**
  ```
  baselines: (schedule: (milestones: (
    (id: "M1", date: "YYYY-MM-DD", title: "string", status: "Done|Pending|Delayed"),
    ...
  )))
  ```

#### `baselines.schedule.gantt`
- **Type:** `array`
- **Severity:** `important`
- **Phase:** `planning`
- **Pipeline ID:** `gantt`
- **Rendered by:** `gantt(data-path)` — full visual Gantt chart with phase groupings, day headers, milestone markers. Themed via tokens.
- **Cross-refs:**
  - ← `registers.risk_register` via `affects_wbs`
  - Each task gets `task-label(id)`
- **Shape:**
  ```
  baselines: (schedule: (
    gantt: (
      start: "YYYY-MM-DD",          // project start
      end: "YYYY-MM-DD",            // project end (render boundary)
      tasks: (
        (
          name: "Phase Name",
          subtasks: (
            (name: "Task", start: "YYYY-MM-DD", end: "YYYY-MM-DD"),
            ...
          )
        ),
        ...
      ),
      milestones: (                  // optional, visual markers
        (name: "string", date: "YYYY-MM-DD", show-date: true),
        ...
      ),
    )
  ))
  ```
  **Note:** This shape matches `gantty`'s expected input. The `gantt` component passes it through with theming applied.

#### `baselines.financials.budget`
- **Type:** `array`
- **Severity:** `important`
- **Phase:** `planning`
- **Pipeline ID:** `budget`
- **Rendered by:** `budget(data-path)` — table grouped by category with subtotals, extra costs section, grand total summary box. Themed via tokens.
- **Cross-refs:**
  - ← `baselines.requirements` via `req_id` (cost of fulfilling a requirement)
  - → `closure.financial_closure` (final cost vs. baseline comparison)
- **Shape:**
  ```
  baselines: (financials: (budget: (
    line_items: (
      (
        id: "BUD-01",
        description: "string",
        category: "string",
        qty: 1,
        unit: "string",
        unit_cost: 0.0,
        req_id: "REQ-01",           // optional, links to requirement
      ),
      ...
    ),
    extra_costs: (                   // optional
      (
        description: "string",
        cost: 0.0,                   // absolute value
        percentage: none,            // or float, e.g. 0.10 for 10% of line_items subtotal
      ),
      ...
    ),
  )))
  ```
  **Backward compatibility:** If the consumer passes the old shape `(description, amount)` as a flat array, the component detects this and renders the simple table. New shape activates rich rendering.

#### `baselines.quality`
- **Type:** `dictionary`
- **Severity:** `recommended`
- **Phase:** `planning`
- **Pipeline ID:** `quality`
- **Rendered by:** `quality(data-path)` — cards for standards, acceptance procedures, testing strategy
- **Cross-refs:**
  - → `baselines.requirements` via `req_id` (quality criteria per requirement)
  - → `registers.deliverables_register` (acceptance procedure links)
- **Shape:**
  ```
  baselines: (quality: (
    standards: ("ISO 9001", "string", ...),        // optional
    acceptance_procedure: "string",                 // optional
    testing_strategy: "string",                     // optional
    criteria: (                                     // optional
      (req_id: "REQ-01", criterion: "string", method: "string"),
      ...
    ),
  ))
  ```

#### `baselines.communication`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `planning`
- **Pipeline ID:** `communication`
- **Rendered by:** `communication(data-path)` — table: what, audience, frequency, channel, owner
- **Cross-refs:**
  - → `governance.team` (audience members come from team)
- **Shape:**
  ```
  baselines: (communication: (
    (
      what: "string",
      audience: "string",
      frequency: "string",
      channel: "string",
      owner: "string",
    ),
    ...
  ))
  ```

#### `baselines.risk_strategy`
- **Type:** `dictionary`
- **Severity:** `recommended`
- **Phase:** `planning`
- **Pipeline ID:** `risk_strategy`
- **Rendered by:** `risk-strategy(data-path)` — cards describing approach, categories, scoring, tolerance
- **Cross-refs:**
  - → `registers.risk_register` (defines the framework the register uses)
- **Shape:**
  ```
  baselines: (risk_strategy: (
    approach: "string",
    categories: ("Technical", "Organizational", "External", ...),
    scoring: "string",              // e.g. "3x3 probability × impact"
    tolerance: "string",            // e.g. "No unmitigated High risks at milestone gates"
    escalation_threshold: "string", // optional
  ))
  ```

#### `baselines.compliance`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `planning`
- **Pipeline ID:** `compliance`
- **Rendered by:** `compliance(data-path)` — table: regulation, jurisdiction, req_id links, audit schedule
- **Cross-refs:**
  - → `baselines.requirements` via `req_id` (which requirements satisfy this regulation)
  - Each entry gets `compliance-label(id)` [ASSUMPTION: compliance entries are referenceable]
- **Shape:**
  ```
  baselines: (compliance: (
    (
      id: "COMP-1",
      regulation: "string",
      jurisdiction: "string",       // optional
      req_ids: ("REQ-01", ...),     // optional, which reqs satisfy this
      audit_date: "YYYY-MM-DD",     // optional
      status: "Compliant|Pending|Non-compliant",
    ),
    ...
  ))
  ```

#### `governance.team`
- **Type:** `array`
- **Severity:** `important`
- **Phase:** `meta`
- **Pipeline ID:** `team`
- **Rendered by:** `team(data-path)` — table with role, name, contact
- **Cross-refs:**
  - ← `baselines.communication` (audience)
  - ← `initiation.stakeholders` (overlap detection)
- **Shape:**
  ```
  governance: (team: (
    (role: "string", name: "string", email: "string"),
    ...
  ))
  ```

---

### Phase 3 — Execution

#### `execution.status`
- **Type:** `dictionary`
- **Severity:** `recommended`
- **Phase:** `execution`
- **Pipeline ID:** `status_report`
- **Rendered by:** `status-report(data-path)` — metrics (health, spend, variance) + executive summary card
- **Cross-refs:** None
- **Shape:**
  ```
  execution: (status: (
    health: "Good|Warning|Critical",
    spend: "string",
    variance: "string",
    summary: "string",
  ))
  ```

#### `registers.risk_register`
- **Type:** `array`
- **Severity:** `important`
- **Phase:** `execution`
- **Pipeline ID:** `risk_matrix`
- **Rendered by:** `risk-matrix(data-path)` — table with ID, risk, mitigation, probability, impact, status badge, cross-ref links
- **Cross-refs:**
  - → `baselines.schedule.gantt` via `affects_wbs` (links to tasks)
  - → `baselines.schedule.milestones` via `blocks_milestone`
  - ← `initiation.assumptions_log` via `risk_id` (source assumption)
  - Each entry gets `risk-label(id)`
- **Shape:**
  ```
  registers: (risk_register: (
    (
      id: "R1",
      description: "string",
      mitigation: "string",
      probability: "Low|Medium|High",
      impact: "Low|Medium|High",
      status: "Open|Monitoring|Closed",
      affects_wbs: ("T1", ...),         // optional
      blocks_milestone: ("M1", ...),    // optional
      source_assumption: "A-1",         // optional, NEW
    ),
    ...
  ))
  ```

#### `registers.issue_log`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `execution`
- **Pipeline ID:** `issue_log`
- **Rendered by:** `issue-log(data-path)` — table with ID, issue, owner, status badge, cross-ref links
- **Cross-refs:**
  - → `registers.risk_register` via `affects_risk`
  - → `baselines.schedule.milestones` via `blocks_milestone`
  - → `registers.deliverables_register` via `blocks_deliverable` (NEW)
  - Each entry gets `issue-label(id)`
- **Shape:**
  ```
  registers: (issue_log: (
    (
      id: "I1",
      description: "string",
      owner: "string",
      status: "Open|In-Progress|Resolved|Escalated",
      affects_risk: ("R1", ...),         // optional
      blocks_milestone: ("M1", ...),     // optional
      blocks_deliverable: ("D1", ...),   // optional, NEW
    ),
    ...
  ))
  ```

#### `registers.change_log`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `execution`
- **Pipeline ID:** `change_log`
- **Rendered by:** `change-log(data-path)` — table with ID, description, type, impact, status badge
- **Cross-refs:**
  - → baselines via `affects_baseline` (NEW — which baseline changed)
  - Each entry gets `change-label(id)`
- **Shape:**
  ```
  registers: (change_log: (
    (
      id: "C1",
      description: "string",
      status: "Pending|Approved|Rejected|Deferred",
      type: "scope|schedule|budget|quality",       // optional, NEW
      affects_baseline: "string",                   // optional, NEW, e.g. "baselines.scope"
    ),
    ...
  ))
  ```

#### `registers.decision_log`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `execution`
- **Pipeline ID:** `decision_log`
- **Rendered by:** `decision-log(data-path)` — table with ID, decision, date, maker, rationale
- **Cross-refs:**
  - → `registers.risk_register` via `prompted_by_risk` (optional)
  - → `registers.issue_log` via `prompted_by_issue` (optional)
  - Each entry gets `decision-label(id)`
- **Shape:**
  ```
  registers: (decision_log: (
    (
      id: "DEC-1",
      description: "string",
      date: "YYYY-MM-DD",
      decision_maker: "string",
      rationale: "string",
      reversibility: "Type-1|Type-2",              // optional
      prompted_by_risk: "R1",                       // optional
      prompted_by_issue: "I1",                      // optional
    ),
    ...
  ))
  ```

#### `registers.deliverables_register`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `execution`
- **Pipeline ID:** `deliverables_register`
- **Rendered by:** `deliverables-register(data-path)` — table with ID, description, owner, due date, status badge, req links
- **Cross-refs:**
  - → `baselines.requirements` via `req_ids` (which requirements this deliverable fulfills)
  - → `closure.acceptance` (acceptance record per deliverable)
  - ← `registers.issue_log` via `blocks_deliverable`
  - Each entry gets `deliverable-label(id)`
- **Shape:**
  ```
  registers: (deliverables_register: (
    (
      id: "D1",
      description: "string",
      owner: "string",
      due_date: "YYYY-MM-DD",
      status: "Planned|In-Progress|In-Review|Accepted|Rejected",
      req_ids: ("REQ-01", ...),         // optional, traceability
    ),
    ...
  ))
  ```

---

### Phase 4 — Closure

#### `closure.lessons_learned`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `closure`
- **Pipeline ID:** `lessons_learned`
- **Rendered by:** `lessons-learned(data-path)` — table with category, issue, recommendation
- **Cross-refs:** None
- **Shape:**
  ```
  closure: (lessons_learned: (
    (category: "string", issue: "string", recommendation: "string"),
    ...
  ))
  ```

#### `closure.sign_off`
- **Type:** `array`
- **Severity:** `important`
- **Phase:** `closure`
- **Pipeline ID:** `sign_off`
- **Rendered by:** `sign-off(data-path)` — table with stakeholder, role, signature line
- **Cross-refs:**
  - ← `initiation.stakeholders` (signers come from stakeholder register)
- **Shape:**
  ```
  closure: (sign_off: (
    (name: "string", role: "string"),
    ...
  ))
  ```

#### `closure.acceptance`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `closure`
- **Pipeline ID:** `acceptance`
- **Rendered by:** `acceptance(data-path)` — table with deliverable link, acceptance date, signer, outstanding issues
- **Cross-refs:**
  - → `registers.deliverables_register` via `deliverable_id` (which deliverable)
- **Shape:**
  ```
  closure: (acceptance: (
    (
      deliverable_id: "D1",
      accepted_by: "string",
      acceptance_date: "YYYY-MM-DD",
      outstanding_issues: "string",     // optional
    ),
    ...
  ))
  ```

#### `closure.benefits_review`
- **Type:** `array`
- **Severity:** `recommended`
- **Phase:** `closure`
- **Pipeline ID:** `benefits_review`
- **Rendered by:** `benefits-review(data-path)` — table with objective link, claimed benefit, actual outcome, variance
- **Cross-refs:**
  - → `initiation.objectives` via `objective_id` (original claims)
- **Shape:**
  ```
  closure: (benefits_review: (
    (
      objective_id: "OBJ-1",
      claimed: "string",
      actual: "string",
      variance: "string",
      root_cause: "string",            // optional
    ),
    ...
  ))
  ```

#### `closure.handover`
- **Type:** `dictionary`
- **Severity:** `recommended`
- **Phase:** `closure`
- **Pipeline ID:** `handover`
- **Rendered by:** `handover(data-path)` — cards for documentation, training, support arrangements
- **Cross-refs:** None (standalone)
- **Shape:**
  ```
  closure: (handover: (
    documentation: ("string", ...),     // optional, list of docs handed over
    training: "string",                 // optional
    support: "string",                  // optional, warranty/helpdesk
    transfer_date: "YYYY-MM-DD",        // optional
  ))
  ```

#### `closure.financial_closure`
- **Type:** `dictionary`
- **Severity:** `recommended`
- **Phase:** `closure`
- **Pipeline ID:** `financial_closure`
- **Rendered by:** `financial-closure(data-path)` — summary: final cost vs. budget baseline, variance, outstanding items
- **Cross-refs:**
  - → `baselines.financials.budget` (baseline comparison)
- **Shape:**
  ```
  closure: (financial_closure: (
    final_cost: 0.0,
    budget_baseline: 0.0,
    variance: 0.0,
    variance_explanation: "string",     // optional
    outstanding_invoices: "string",     // optional
  ))
  ```

---

## Cross-Reference Relationship Graph

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                    INITIATION                               │
                    │                                                             │
                    │  objectives ◄──────────────── success_criteria              │
                    │      │            (objective_id)                            │
                    │      │                                                      │
                    │      │  assumptions_log ───────────────────────┐            │
                    │      │      (risk_id)                         │            │
                    │      │                                        ▼            │
                    │  stakeholders ──────────────────┐      ┌───────────┐       │
                    │      │                          │      │           │       │
                    └──────│──────────────────────────│──────│───────────│───────┘
                           │                          │      │           │
                    ┌──────│──────────────────────────│──────│───────────│───────┐
                    │      │       PLANNING           │      │           │       │
                    │      │                          │      │           │       │
                    │  requirements ◄── quality       │      │           │       │
                    │      │    │    (req_id)         │      │           │       │
                    │      │    │                     │      │           │       │
                    │      │    ├── compliance        │      │           │       │
                    │      │    │    (req_ids)        │      │           │       │
                    │      │    │                     │      │           │       │
                    │      │    ├──► budget           │      │           │       │
                    │      │    │    (req_id)         │      │           │       │
                    │      │    │                     │      │           │       │
                    │      │    └──► deliverables     │      │           │       │
                    │      │         (req_ids)        │      │           │       │
                    │      │                          │      │           │       │
                    │  gantt ◄────────────────────────│──────│── risk_register   │
                    │    │     (affects_wbs)          │      │      │    │       │
                    │    │                            │      │      │    │       │
                    │  milestones ◄───────────────────│──────│──────┘    │       │
                    │    │     (blocks_milestone)     │      │    (blocks│       │
                    │    │                            │      │    _mile) │       │
                    │  communication ──► team         │      │          │       │
                    │  risk_strategy ──► risk_register│      │          │       │
                    │                                 │      │          │       │
                    └─────────────────────────────────│──────│──────────│───────┘
                                                      │      │          │
                    ┌─────────────────────────────────│──────│──────────│───────┐
                    │         EXECUTION               │      │          │       │
                    │                                 │      │          │       │
                    │  risk_register ◄────────────────┘      │          │       │
                    │      │  (source_assumption)            │          │       │
                    │      │                                  │          │       │
                    │  issue_log ──► risk_register            │          │       │
                    │      │     (affects_risk)               │          │       │
                    │      │──► milestones (blocks_milestone) │          │       │
                    │      │──► deliverables (blocks_deliv)   │          │       │
                    │      │                                  │          │       │
                    │  change_log ──► baselines               │          │       │
                    │      (affects_baseline)                 │          │       │
                    │                                         │          │       │
                    │  decision_log ──► risk_register         │          │       │
                    │      │        (prompted_by_risk)        │          │       │
                    │      └──► issue_log                     │          │       │
                    │           (prompted_by_issue)           │          │       │
                    │                                         │          │       │
                    │  deliverables_register ──► requirements  │          │       │
                    │      │                  (req_ids)        │          │       │
                    │      │                                   │          │       │
                    └──────│───────────────────────────────────│──────────│───────┘
                           │                                   │          │
                    ┌──────│───────────────────────────────────│──────────│───────┐
                    │      │          CLOSURE                  │          │       │
                    │      │                                   │          │       │
                    │  acceptance ──► deliverables_register    │          │       │
                    │      (deliverable_id)                    │          │       │
                    │                                          │          │       │
                    │  benefits_review ──► objectives ◄────────┘          │       │
                    │      (objective_id)                                 │       │
                    │                                                     │       │
                    │  financial_closure ──► budget                       │       │
                    │      (baseline comparison)                         │       │
                    │                                                     │       │
                    │  sign_off ◄── stakeholders ◄───────────────────────┘       │
                    │                                                            │
                    │  lessons_learned (standalone)                               │
                    │  handover (standalone)                                      │
                    │                                                            │
                    └────────────────────────────────────────────────────────────┘
```

---

## Pipeline Order (pmbok-pipeline)

```
 #  phase        section_id              data_path                           status
 1  initiation   pitch                   initiation.pitch                    existing
 2  initiation   business_case           initiation.business_case            existing
 3  initiation   objectives              initiation.objectives               existing
 4  initiation   success_criteria        initiation.success_criteria         NEW
 5  initiation   stakeholders            initiation.stakeholders             NEW
 6  initiation   assumptions_log         initiation.assumptions_log          NEW
 7  planning     boundaries              baselines.scope                     existing
 8  planning     requirements            baselines.requirements              NEW
 9  planning     milestones              baselines.schedule.milestones       existing
10  planning     budget                  baselines.financials.budget         enhanced
11  planning     gantt                   baselines.schedule.gantt            enhanced
12  planning     quality                 baselines.quality                   NEW
13  planning     communication           baselines.communication             NEW
14  planning     risk_strategy           baselines.risk_strategy             NEW
15  planning     compliance              baselines.compliance                NEW
16  planning     team                    governance.team                     existing
17  execution    status_report           execution.status                    existing
18  execution    risk_matrix             registers.risk_register             existing+
19  execution    issue_log               registers.issue_log                 existing+
20  execution    change_log              registers.change_log                existing+
21  execution    decision_log            registers.decision_log              NEW
22  execution    deliverables_register   registers.deliverables_register     NEW
23  closure      lessons_learned         closure.lessons_learned             existing
24  closure      acceptance              closure.acceptance                  NEW
25  closure      benefits_review         closure.benefits_review             NEW
26  closure      handover                closure.handover                    NEW
27  closure      financial_closure       closure.financial_closure           NEW
28  closure      sign_off                closure.sign_off                    existing
```

---

## Schema Registry (schema.typ)

All 30 paths with severity and kind for the audit system:

```
(path: "project.name",                        severity: "critical",    phase: "meta",       kind: "string"),
(path: "project.description",                  severity: "important",   phase: "meta",       kind: "string"),
(path: "initiation.pitch",                     severity: "critical",    phase: "initiation", kind: "string"),
(path: "initiation.business_case",             severity: "important",   phase: "initiation", kind: "string"),
(path: "initiation.objectives",                severity: "recommended", phase: "initiation", kind: "array"),
(path: "initiation.success_criteria",          severity: "recommended", phase: "initiation", kind: "array"),
(path: "initiation.stakeholders",              severity: "important",   phase: "initiation", kind: "array"),
(path: "initiation.assumptions_log",           severity: "recommended", phase: "initiation", kind: "array"),
(path: "baselines.scope",                      severity: "important",   phase: "planning",   kind: "dict"),
(path: "baselines.requirements",               severity: "important",   phase: "planning",   kind: "array"),
(path: "baselines.schedule.milestones",        severity: "recommended", phase: "planning",   kind: "array"),
(path: "baselines.schedule.gantt",             severity: "important",   phase: "planning",   kind: "dict"),
(path: "baselines.financials.budget",          severity: "important",   phase: "planning",   kind: "dict"),
(path: "baselines.quality",                    severity: "recommended", phase: "planning",   kind: "dict"),
(path: "baselines.communication",              severity: "recommended", phase: "planning",   kind: "array"),
(path: "baselines.risk_strategy",              severity: "recommended", phase: "planning",   kind: "dict"),
(path: "baselines.compliance",                 severity: "recommended", phase: "planning",   kind: "array"),
(path: "governance.team",                      severity: "important",   phase: "meta",       kind: "array"),
(path: "execution.status",                     severity: "recommended", phase: "execution",  kind: "dict"),
(path: "registers.risk_register",              severity: "important",   phase: "execution",  kind: "array"),
(path: "registers.issue_log",                  severity: "recommended", phase: "execution",  kind: "array"),
(path: "registers.change_log",                 severity: "recommended", phase: "execution",  kind: "array"),
(path: "registers.decision_log",               severity: "recommended", phase: "execution",  kind: "array"),
(path: "registers.deliverables_register",      severity: "recommended", phase: "execution",  kind: "array"),
(path: "closure.lessons_learned",              severity: "recommended", phase: "closure",    kind: "array"),
(path: "closure.acceptance",                   severity: "recommended", phase: "closure",    kind: "array"),
(path: "closure.benefits_review",              severity: "recommended", phase: "closure",    kind: "array"),
(path: "closure.handover",                     severity: "recommended", phase: "closure",    kind: "dict"),
(path: "closure.financial_closure",            severity: "recommended", phase: "closure",    kind: "dict"),
(path: "closure.sign_off",                     severity: "important",   phase: "closure",    kind: "array"),
```