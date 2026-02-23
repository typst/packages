<h1 align="center">
  <img src="https://avatars.githubusercontent.com/u/67595261" alt="Folio Icon" width="128" height="128">
  <div align="center">Folio</div>
</h1>

<div align="center">

[![Typst Universe](https://img.shields.io/badge/typst--universe-folio-239DAD?&logo=typst)](https://typst.app/universe/package/folio)
[![GitHub](https://img.shields.io/badge/GitHub-Yrrrrrf%2Ffolio-blue)](https://github.com/Yrrrrrf/folio)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://choosealicense.com/licenses/mit/)

</div>

## Overview

**Folio** is a universal project management document generator for **Typst**. Define your entire project once in a single data file and generate a complete, professionally styled suite of PM documents — charter, Gantt chart, risk matrix, budget, stakeholder map, and more — all from one source of truth.

## Key Features

- **📋 Single Source of Truth:** Define your project once in `dt.typ` and every document stays in sync automatically.
- **📄 Full PM Document Suite:** Covers the complete project lifecycle — from charter and feasibility all the way through to closure.
- **📊 Built-in Gantt Charts:** Auto-generated timeline visualizations from your phase and milestone data.
- **🎨 Consistent Branding:** A unified design system (colors, typography, page layout) across every generated document.
- **⚡ Zero Boilerplate:** Import the package, point it at your data, call the function — done.
- **🔧 Flexible & Composable:** Generate all documents or just the ones you need, in any order.

## Installation

### Via [Typst Universe](https://typst.app/universe/package/folio)

```typ
#import "@preview/folio:0.0.1": *
```

## Quick Start

Get a full project management document suite running in two files.

**`dt.typ` — your project data (the single source of truth):**

```typ
#let project = (
  name: "My Project",
  version: "1.0.0",
  status: "En Progreso",
  description: "A high-level description of the project's objective and context.",
  start_date: "2026-03-01",
  end_date: "2026-06-30",
  owner: "Project Lead",
  team: (
    (name: "Alice", role: "Tech Lead", responsibilities: "Architecture and review."),
    (name: "Bob",   role: "Backend Engineer", responsibilities: "API implementation."),
  ),
  objectives: (
    "Deliver phase 1 before Q3.",
    "Reduce processing time by 40%.",
  ),
  // ... risks, budget, stakeholders, phases, milestones, etc.
)
```

**`main.typ` — pick the documents you need:**

```typ
#import "@preview/folio:0.1.0": *
#import "dt.typ": project

#charter(project)
#pagebreak()
#plan(project)
#pagebreak()
#gantt(project)
#pagebreak()
#budget(project)
#pagebreak()
#risks(project)
#pagebreak()
#closure(project)
```

Then compile:

```bash
typst compile main.typ
```

You now have a complete, consistently branded project management PDF ready to share.

## Available Documents

| Function | Document |
|---|---|
| `charter(project)` | Project Charter — identity, objectives, scope |
| `feasibility(project)` | Feasibility Study — technical, economic, operative analysis |
| `executive-brief(project)` | Executive Brief — high-level summary for stakeholders |
| `plan(project)` | Project Plan — team, quality criteria, communication plan |
| `requirements(project)` | Requirements / BOM — categorized material and service list |
| `budget(project)` | Budget — cost breakdown with totals and contingency |
| `gantt(project)` | Gantt Chart — phases and milestones on a timeline |
| `risks(project)` | Risk Register — probability/impact matrix with mitigations |
| `stakeholders(project)` | Stakeholder Map — influence, interest, and communication channels |
| `closure(project)` | Project Closure — deliverables sign-off and acceptance |

## Project Data Structure

All document content is driven by fields on the `project` dictionary. Every field is optional unless the document that uses it is called — Folio simply renders what you provide.

```typ
#let project = (
  // Identity
  name: "",  version: "",  status: "",  description: "",
  start_date: "",  end_date: "",  gantt_render_end: "",

  // People
  owner: "",
  team: ((name: "", role: "", responsibilities: ""),),
  stakeholders: ((name: "", organization: "", power: "", interest: "", channel: "", attitude: ""),),

  // Scope & Goals
  objectives: (),  benefits: (),
  scope: (included: (), excluded: ()),

  // Resources
  requirements: ((id: "", description: "", unit: "", qty: 0, unit_cost: 0, category: ""),),
  budget_extras: ((description: "", cost: 0),),

  // Risk
  risks: ((id: "", description: "", probability: "", impact: "", mitigation: ""),),

  // Schedule
  phases: ((name: "", subtasks: ((name: "", start: "", end: ""),)),),
  milestones: ((name: "", date: "", show-date: true),),

  // Quality & Comms
  quality_criteria: (),
  communication_plan: ((audience: "", frequency: "", channel: "", owner: ""),),
  notes: (),

  // Closure
  acceptance_date: "",  client_signature: "",
  completed_deliverables: (),
)
```

## License

MIT License — See [LICENSE](LICENSE) for details.