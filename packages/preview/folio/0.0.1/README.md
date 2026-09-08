# folio

**folio** is a Typst package that turns project data into publication-grade documents. You write the data; folio writes the document.

## Quickstart

```typst
#import "@preview/folio:0.0.1": project-doc

#let project = (
  project: (name: "My Project", description: "A folio demonstration"),
  initiation: (pitch: "This project will change everything.")
)

#show: project-doc(
  data: project,
  config: (audit: true, toc: true),
  brand: (palette: (primary: rgb("#003e7e"))),
)
```

## What's in v0.0.1

Folio v0.0.1 covers 14 PMBOK-aligned sections across 4 phases:

- **Phase 1: Initiation**: Business Case, Project Objectives, Project Pitch.
- **Phase 2: Planning**: Project Boundaries, Budget, Gantt, Milestones, Team.
- **Phase 3: Execution**: Change Log, Issue Log, Risk Matrix, Status Report.
- **Phase 4: Closure**: Lessons Learned, Sign-off.

Plus support for **Custom Sections** at any insertion point.

## Features

- **The Data is the Document**: All content lives in a single dictionary.
- **Graceful Failure**: Missing fields show as red placeholders, not build errors.
<!-- todo: Add the syling guide! :) -->
<!-- - **Branding**: Multiple visual presets (`corporate`, `academic`) and deep token overrides. See [Styling Guide](docs/styling.md). -->
- **Audit System**: Diagnostic dashboard for data completeness and orphan references.
- **Extensible**: Inject custom sections at named insertion points.

## Branding

folio supports a multi-layered branding system. You can use built-in presets or create your own brand packs.

```typst
#show: project-doc(
  data: project,
  brand: (preset: "academic")
)
```

<!-- See [docs/styling.md](docs/styling.md) for the full reference on presets and available tokens. -->

## Audit System

Folio includes a diagnostic audit system. To enable it, set `audit: true` in the config.

Note: **Orphan Reference detection** requires a second compile pass for full accuracy, as it depends on Typst's layout query system.


## Documentation

See [`docs/manual.pdf`](docs/manual.pdf) for full API reference and schema details.

## Examples

Browse [`examples`](examples) for runnable templates that show folio end-to-end:

- [`minimal`](examples/minimal.pdf) — smallest viable document, ideal starting point
- [`full-standards`](examples/full-standards.pdf) — every PMBOK section populated
- [`branding-demo`](examples/branding-demo.pdf) — brand presets and token overrides
- [`thesis`](examples/thesis.pdf) — academic preset adaptation
- [`rfp`](examples/rfp.pdf) — request-for-proposal format
- [`hardware`](examples/hardware.pdf) — hardware-project variant

> Each section also ships a standalone showcase in [`examples/components`](examples/components) — one minimal `.typ` per component, designed as drop-in snippets you can paste straight into your own document. Source-only by design: the top-level examples above already render these components in context.