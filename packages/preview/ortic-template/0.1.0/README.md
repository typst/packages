# Ortic Solutions — Typst Templates

A Typst template for technical specifications, styled with the Ortic Solutions GmbH brand identity (blue `#008fff`, warm gray `#959283`, Open Sans).

## Files

| File | Purpose |
| --- | --- |
| `template.typ` | The reusable template (`ortic-spec` show-rule + `callout`, `req`, `kv-list` helpers). |
| `example.typ` | A sample technical specification demonstrating every feature. |
| `fonts/` | Bundled Open Sans (matches the brand). |
| `logo.png` | Ortic Solutions logo, used on the cover page. |
| `Makefile` | Convenience targets (`make build`, `make watch`). |

## Building

The template uses Open Sans, which is bundled under `fonts/`. **Pass `--font-path fonts` so Typst can find it**, otherwise it will fall back to Liberation Sans / DejaVu Sans and print a warning.

```bash
# Using the Makefile (recommended)
make build          # one-shot compile
make watch          # rebuild on change

# Or directly with Typst
typst compile --font-path fonts example.typ
typst watch   --font-path fonts example.typ
```

### Editor integration (Tinymist / VS Code)

The `.vscode/settings.json` in this repo points the Tinymist language server at the bundled fonts. If you use a different editor, configure its Typst extension with a font path of `./fonts` relative to the project root.

You can also export an env var so any `typst` invocation picks the fonts up automatically:

```bash
export TYPST_FONT_PATHS="$PWD/fonts"
typst compile example.typ   # no --font-path needed
```

## Usage

Once published to Typst Universe, import it directly — Typst downloads and
caches the package automatically, no clone needed:

```typst
#import "@preview/ortic-template:0.1.0": ortic-spec, callout, req, kv-list
```

> **Fonts:** Typst does not auto-load fonts bundled in a package, so the
> published package does not ship them. For the brand font, install Open Sans
> system-wide (e.g. into `~/.local/share/fonts/`) or pass `--font-path` to a
> folder containing it. Without it the template falls back to Liberation /
> DejaVu Sans.

You can also import the local file directly when working inside this repo
(`fonts/` is available here for that):

```typst
#import "template.typ": ortic-spec, callout, req, kv-list

#show: ortic-spec.with(
  title: "Your Document Title",
  subtitle: "Optional one-line description",
  project: "Project Name",
  client: "Client Name",
  document-id: "TSP-2026-014",
  version: "1.0",
  status: "Draft",
  date: datetime(year: 2026, month: 5, day: 20),
  classification: "Confidential",
  authors: (
    (name: "Jane Doe", role: "Lead Architect"),
  ),
  reviewers: (
    (name: "John Smith", role: "CTO"),
  ),
  abstract: [One paragraph summary of the document.],
  revisions: (
    (version: "1.0", date: "2026-05-20", description: "Initial release", author: "J. Doe"),
  ),
)

= First section

== Subsection

Body text...
```

### Helpers

```typst
// Requirement boxes with priority badge
#req("FR-01", priority: "MUST")[The system must …]
#req("FR-02", priority: "SHOULD")[The system should …]
#req("FR-03", priority: "MAY")[The system may …]

// Callouts: note / info / warning / important / success
#callout(kind: "warning", title: "Capacity")[Provision for 2× headroom.]

// Borderless key/value list
#kv-list(
  ("Metrics", "Prometheus"),
  ("Tracing", "OpenTelemetry"),
)
```

## Brand

- Primary accent: `#008fff` (Ortic blue)
- Secondary: `#959283` (warm gray)
- Typography: Open Sans (matches ortic.com)
- Imprint: Ortic Solutions GmbH · Riedmattweg 9 · CH-6052 Hergiswil
