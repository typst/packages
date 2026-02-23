<h1 align="center">
  <img src="https://avatars.githubusercontent.com/u/67595261" alt="Folio Icon" width="128" height="128">
  <div align="center">Folio</div>
</h1>

<div align="center">

[![Typst Universe](https://img.shields.io/badge/typst--universe-folio-239DAD?&logo=typst)](https://typst.app/universe/package/folio)
[![GitHub](https://img.shields.io/badge/GitHub-Yrrrrrf%2Ffolio-blue)](https://github.com/Yrrrrrf/folio)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://choosealicense.com/licenses/mit/)

</div>

**Folio** is a universal project management document generator for **Typst**.
Define your entire project once in a single data file and generate a complete,
professionally styled suite of PM documents — charter, Gantt chart, risk matrix,
budget, stakeholder map, and more — all from one source of truth.

See the [Overview](docs/overview.md) for a comprehensive guide, feature list,
and data structure documentation, or check out the [Manual](docs/manual.typ) for
full details.

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
  // ... risks, budget, stakeholders, phases, milestones, etc.
)
```

**`main.typ` — pick the documents you need:**

```typ
#import "@preview/folio:0.0.1": *
#import "dt.typ": project

#charter(project)
#gantt(project)
```

Then compile:

```bash
typst compile main.typ
```

For the full list of available documents and project data structure, see
[docs/overview.md](docs/overview.md).

## License

MIT License — See [LICENSE](LICENSE) for details.
