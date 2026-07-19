# folio — Rendering Pipeline

> **The pipeline is data, not code.** The 28 PMBOK-aligned sections render in standard order. Users opt out per-section, reorder via config, and inject custom sections at named insertion points — all without patching code.

---

## Quick Reference

```typst
#show: project-doc(
  data: project,
  config: (
    sections: (budget: false, risk_matrix: false),        // disable sections
    extra-sections: (                                      // inject custom sections
      (id: "pricing", phase: "custom", data-path: "custom.pricing",
       render: my-pricing-fn, after: "budget"),
    ),
  ),
)
```

---

## Pipeline Phases

The pipeline groups 28 sections into 4 PMBOK phases plus a custom phase. Each phase renders as a level-1 heading followed by its sections.

| # | Phase | Heading | Sections |
|---|---|---|---|
| 1 | **Initiation** | `Initiation` | 6 sections |
| 2 | **Planning** | `Planning` | 10 sections |
| 3 | **Execution** | `Execution` | 6 sections |
| 4 | **Closure** | `Closure` | 6 sections |
| 5 | **Custom** | `Custom Sections` | User-injected |

Phase headings are overridable via `get-title` data paths (e.g., `phases.initiation.title`).

A phase is **skipped entirely** (no heading, no pagebreak) if zero of its sections have renderable data.

---

## Section Registry

### Phase 1 — Initiation

| Pipeline ID | Data Path | Component | Description |
|---|---|---|---|
| `pitch` | `initiation.pitch` | `pitch()` | Elevator pitch card |
| `business_case` | `initiation.business_case` | `business-case()` | Business justification card |
| `objectives` | `initiation.objectives` | `objectives()` | Goals table with priority badges |
| `success_criteria` | `initiation.success_criteria` | `success-criteria()` | Criteria table linked to objectives |
| `stakeholders` | `initiation.stakeholders` | `stakeholders()` | Stakeholder register with interest/influence |
| `assumptions_log` | `initiation.assumptions_log` | `assumptions-log()` | Assumptions/constraints/dependencies table |

### Phase 2 — Planning

| Pipeline ID | Data Path | Component | Description |
|---|---|---|---|
| `boundaries` | `baselines.scope` | `boundaries()` | In-scope / out-of-scope cards |
| `requirements` | `baselines.requirements` | `requirements()` | Requirements grouped by category with costs |
| `milestones` | `baselines.schedule.milestones` | `milestones()` | Milestone table with status badges |
| `budget` | `baselines.financials.budget` | `budget()` | Budget by category + extra costs + grand total |
| `gantt` | `baselines.schedule.gantt` | `gantt()` | Visual Gantt chart via `gantty` |
| `quality` | `baselines.quality` | `quality()` | Standards, acceptance procedure, quality criteria |
| `communication` | `baselines.communication` | `communication()` | Communication plan table |
| `risk_strategy` | `baselines.risk_strategy` | `risk-strategy()` | Risk management approach, scoring, tolerance |
| `compliance` | `baselines.compliance` | `compliance()` | Regulatory compliance register |
| `team` | `governance.team` | `team()` | Team roster with roles and contact |

### Phase 3 — Execution

| Pipeline ID | Data Path | Component | Description |
|---|---|---|---|
| `status_report` | `execution.status` | `status-report()` | Health/spend/variance metrics + summary |
| `risk_matrix` | `registers.risk_register` | `risk-matrix()` | Risk register with cross-ref links |
| `issue_log` | `registers.issue_log` | `issue-log()` | Issue tracker with blocking refs |
| `change_log` | `registers.change_log` | `change-log()` | Change log with baseline impact |
| `decision_log` | `registers.decision_log` | `decision-log()` | Decision record with rationale |
| `deliverables_register` | `registers.deliverables_register` | `deliverables-register()` | Deliverables with requirement traceability |

### Phase 4 — Closure

| Pipeline ID | Data Path | Component | Description |
|---|---|---|---|
| `lessons_learned` | `closure.lessons_learned` | `lessons-learned()` | Retrospective: issue → recommendation |
| `acceptance` | `closure.acceptance` | `acceptance()` | Formal acceptance records per deliverable |
| `benefits_review` | `closure.benefits_review` | `benefits-review()` | Claimed vs. actual outcomes |
| `handover` | `closure.handover` | `handover()` | Documentation, training, support cards |
| `financial_closure` | `closure.financial_closure` | `financial-closure()` | Final cost vs. budget variance |
| `sign_off` | `closure.sign_off` | `sign-off()` | Signature lines for stakeholders |

---

## Section Guard Logic

Before rendering each section, the pipeline checks `config.sections[section_id]`:

| Toggle Value | Behavior |
|---|---|
| `true` | Always render, even if data is missing (shows `_missing()` placeholders) |
| `false` | Never render (skip entirely) |
| `auto` (default) | Render only if data is present and non-empty |

```typst
config: (
  sections: (
    budget: true,          // force-render even if no budget data
    risk_matrix: false,    // never render
    // everything else defaults to auto
  ),
)
```

### Missing Data Handling

When data is absent for a section set to `auto`, the section is silently skipped — no heading, no placeholder.

When data is absent for a section set to `true`, the section renders its heading and inline `_missing()` placeholders for each missing field:

```
┌─────────────────────────────────┐
│ Missing: baselines.financials.budget │
└─────────────────────────────────┘
```

This uses the `missing()` function from `core/fallback.typ`, which renders a red-bordered box with the field path.

---

## Custom Section Injection

Custom sections are declared in `config.extra-sections` and injected into the pipeline at named positions.

### Schema

```typst
extra-sections: (
  (
    id: "my-section",             // unique section_id (must not collide)
    phase: "planning",            // which phase to render in
    data-path: "custom.my-data",  // data path for section-guard
    render: my-render-fn,         // function(data-path) -> content
    before: "budget",             // optional: insert before this section_id
    after: "requirements",        // optional: insert after this section_id
  ),
)
```

### Positioning

| Argument | Behavior |
|---|---|
| `before: "section_id"` | Insert immediately before the named section |
| `after: "section_id"` | Insert immediately after the named section |
| Neither | Append to the end of the specified phase |

### Example: Pricing Annex

```typst
#let pricing-annex(data-path) = context {
  heading(level: 2)[Pricing Annex]
  card[Detailed pricing goes here.]
}

#show: project-doc(
  data: (
    // ...standard data...
    custom: (pricing: (tier: "Enterprise")),
  ),
  config: (
    extra-sections: (
      (
        id: "pricing-annex",
        phase: "custom",
        data-path: "custom.pricing",
        render: pricing-annex,
        after: "budget",
      ),
    ),
  ),
)
```

### Collision Detection

If an `extra-sections` entry has an `id` that collides with an existing pipeline section, folio panics with a clear error message. This prevents accidental overrides.

---

## Pipeline Rendering Order

The full rendering sequence within `project-doc()`:

```
1. Audit dashboard      (if config.audit == true)
2. Cover page           (if config.cover == true or auto + project.name exists)
3. Table of Contents    (if config.toc == true)
4. Initiation phase     (6 sections)
5. Planning phase       (10 sections)
6. Execution phase      (6 sections)
7. Closure phase        (6 sections)
8. Custom phase         (user-injected sections)
9. Orphan report        (if config.audit == true)
10. User body content   (anything after #show: project-doc(...))
```

### Config Reference

| Key | Type | Default | Description |
|---|---|---|---|
| `audit` | `bool` | `false` | Show audit dashboard + orphan report |
| `cover` | `bool \| auto` | `auto` | Render cover page |
| `toc` | `bool` | `true` | Render table of contents |
| `sections` | `dict` | `(:)` | Per-section toggle overrides |
| `extra-sections` | `array` | `()` | Custom section injection |
| `extra-checks` | `array` | `()` | Additional schema paths for audit |

---

## Phase Title Overrides

Phase headings default to English ("Initiation", "Planning", etc.) but can be overridden via data paths:

```typst
data: (
  phases: (
    initiation: (title: "Inicio"),
    planning: (title: "Planificación"),
    execution: (title: "Ejecución"),
    closure: (title: "Cierre"),
  ),
  // ...rest of data...
)
```

Each phase renderer calls `get-title(data, "phases.<phase>.title", "Default")` before rendering.

---

## Architecture

### Module Structure

```
src/core/orchestrator.typ     project-doc() — top-level entry
  ├── src/core/pipeline.typ   pmbok-pipeline array (section registry)
  ├── src/core/guard.typ      section-guard() — toggle + data check
  ├── src/core/audit.typ      data-audit-header(), data-audit-orphans()
  ├── src/phases/*.typ         Phase renderers (filter + render sections)
  └── src/components/*.typ     Section components (actual rendering logic)
```

### Data Flow

```
project-doc(data, config, brand)
  → folio-init(data, config, brand)     [sets folio-state]
  → resolve config                       [merge defaults]
  → inject extra-sections into pipeline  [collision check]
  → audit dashboard                      [optional]
  → cover                               [optional]
  → TOC                                  [optional]
  → for each phase:
      filter renderable sections         [toggle + data check]
      if any renderable: pagebreak + heading
      for each section: section-guard → render_fn(data_path)
  → orphan report                        [optional]
  → user body                            [passthrough]
```

### Section Function Signature

All section components follow the same pattern:

```typst
#let my-section(data-path) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  heading(level: 2)[Section Title]

  let raw = resolve(data, data-path)
  if type(raw) == array {
    // render table/cards from array data
  } else {
    [#raw]  // fallback: render the _missing() placeholder or raw value
  }
}
```

Key contracts:
- Takes a single `data-path` argument
- Reads from `folio-state` (never takes data as a parameter)
- Uses `resolve()` for safe data access (returns `_missing()` on failure)
- Never mutates state
- Never depends on other sections' rendered output
