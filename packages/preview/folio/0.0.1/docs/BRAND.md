# folio — Brand System

> **Branding is an overlay, not a fork.** A brand is a dictionary of token overrides layered on top of a preset. Anything not overridden falls back to the preset's default.

---

## Quick Start

```typst
#show: project-doc(
  data: project,
  brand: (
    preset: "corporate",                        // pick a preset
    palette: (primary: rgb("#003e7e")),          // override any token
  ),
)
```

That's it. The entire document reflects the new primary color. Everything else falls back to the corporate preset.

---

## How It Works

The brand system resolves tokens in a three-level chain:

```
User brand dict → Preset tokens → Default tokens (corporate)
```

1. **User brand:** Anything passed in the `brand:` parameter of `project-doc()` or `folio-init()`.
2. **Preset tokens:** The complete token dict from the selected preset (`minimal`, `corporate`, `academic`).
3. **Default tokens:** The corporate preset serves as the ultimate fallback.

Missing tokens at any level cascade to the next. Every primitive and component reads tokens through `resolve-token()`, which walks this chain.

---

## Presets

### `minimal` — Typst defaults

No flourish. Serif fonts (Linux Libertine), zero border-radius, muted grayscale palette. Designed as the plainest output and a neutral base for customization.

| Token | Value |
|---|---|
| Font (body) | Linux Libertine, Liberation Serif |
| Primary | `#333333` (dark gray) |
| Card radius | `0pt` |
| Badge radius | `2pt` |
| Page margin | `2.5cm` |

**Best for:** Thesis projects, academic submissions, users who want minimal styling.

### `corporate` — Professional default

The default folio aesthetic. Clean sans-serif (Liberation Sans), blue primary, rounded cards, subtle surface tones. The baseline all other presets are compared against.

| Token | Value |
|---|---|
| Font (body) | Liberation Sans, DejaVu Sans |
| Primary | `#2563eb` (blue) |
| Card radius | `8pt` |
| Badge radius | `4pt` |
| Page margin | `2.5cm` |

**Best for:** RFP responses, project plans, professional teams, startup MVPs.

### `academic` — 01-inspired classic

Serif typography (New Computer Modern), deep blue primary, rounded badges, formal spacing. Derived from the original `01` project aesthetic.

| Token | Value |
|---|---|
| Font (body) | New Computer Modern, Libertinus Serif |
| Primary | `#0d47a1` (deep blue) |
| Card radius | `6pt` |
| Badge radius | `10pt` (heavily rounded) |
| Page margin | `2cm` |

**Best for:** Academic project briefs, thesis proposals, formal documentation.

---

## Token Groups

### `typography`

| Path | Type | Description |
|---|---|---|
| `typography.font.body` | array of strings | Body text font stack |
| `typography.font.heading` | array of strings | Heading font stack |
| `typography.size.body` | length | Base body text size |
| `typography.size.sm` | length | Small text (badges, labels) |
| `typography.size.md` | length | Medium text (default) |
| `typography.size.lg` | length | Large text (card titles) |
| `typography.size.xl` | length | Extra-large text (metrics, hero values) |

### `palette`

| Path | Type | Description |
|---|---|---|
| `palette.primary` | color | Brand primary color (links, headings, accents) |
| `palette.text` | color | Main body text color |
| `palette.intent.success` | color | Success indicators (green) |
| `palette.intent.danger` | color | Error/danger indicators (red) |
| `palette.intent.warning` | color | Warning indicators (amber/orange) |
| `palette.intent.neutral` | color | Neutral/muted indicators (gray) |
| `palette.surface.background` | color | Page background |
| `palette.surface.card` | color | Card fill color |
| `palette.surface.border` | color | Border/stroke color |
| `palette.surface.alt` | color | Alternating row background |

### `geometry`

| Path | Type | Description |
|---|---|---|
| `geometry.radius.sm` | length | Small border radius |
| `geometry.radius.md` | length | Medium border radius |
| `geometry.radius.lg` | length | Large border radius |
| `geometry.radius.none` | length | Zero radius (always `0pt`) |
| `geometry.radius.card` | length | Card component radius |
| `geometry.radius.table` | length | Table container radius |
| `geometry.radius.badge` | length | Badge radius |
| `geometry.radius.progress` | length | Progress bar radius |
| `geometry.stroke-width.thin` | length | Thin stroke (table borders) |
| `geometry.stroke-width.normal` | length | Normal stroke (cards) |
| `geometry.stroke-width.thick` | length | Thick stroke (emphasis) |
| `geometry.gantt.bar-height` | length | Gantt phase bar height |
| `geometry.gantt.subtask-bar-height` | length | Gantt subtask bar height |
| `geometry.gantt.sidebar-padding` | length | Gantt sidebar padding |
| `geometry.gantt.sidebar-spacing` | length | Gantt sidebar spacing |
| `geometry.table.cell-padding` | length | Table cell inset |
| `geometry.page-margin` | length | Page margin |
| `geometry.paper` | string | Paper size (`"a4"`, `"us-letter"`, etc.) |

### `spacing`

| Path | Type | Description |
|---|---|---|
| `spacing.base` | length | Base spacing unit (all spacing derives from this) |
| `spacing.density-multiplier.compact` | float | Multiplier for compact density |
| `spacing.density-multiplier.comfortable` | float | Multiplier for comfortable density (default) |
| `spacing.density-multiplier.spacious` | float | Multiplier for spacious density |

---

## Customization Guide

### Override a single token

```typst
brand: (
  preset: "corporate",
  palette: (primary: rgb("#003e7e")),
)
```

The entire document uses `#003e7e` as the primary color. All other tokens remain corporate defaults.

### Override multiple token groups

```typst
brand: (
  preset: "academic",
  palette: (
    primary: rgb("#1b5e20"),
    intent: (success: rgb("#2e7d32")),
  ),
  typography: (
    font: (body: ("Fira Sans",)),
  ),
)
```

### Change density

```typst
brand: (
  preset: "corporate",
  density: "compact",     // tighter tables and spacing
)
```

Valid density values: `"compact"`, `"comfortable"` (default), `"spacious"`.

### No preset (bare defaults)

If no `preset` key is provided, the corporate preset is used as the default fallback. To build a fully custom brand:

```typst
brand: (
  palette: (primary: rgb("#6200ea")),
  typography: (font: (body: ("Inter",), heading: ("Inter",))),
  geometry: (radius: (card: 12pt, badge: 6pt)),
)
```

Any tokens not specified fall back to corporate defaults.

---

## Architecture

### Token Resolution (`resolve-token`)

```typst
#let resolve-token(st, path) = {
  // 1. User brand dict (highest priority)
  // 2. Preset tokens
  // 3. Default tokens (corporate — always complete)
  // Falls back to magenta rgb("#ff00ff") if nothing found (visual debug aid)
}
```

### Spacing Resolution (`resolve-spacing`)

```typst
#let resolve-spacing(st, multiplier: 1.0) = {
  // base spacing × density multiplier × caller multiplier
}
```

### UI Adapters (`theme/ui.typ`)

Each primitive has a themed wrapper in `ui.typ` that resolves tokens before passing them to the raw primitive:

```typst
// Themed wrapper (what sections use)
#let card(body, title: none) = context {
  let st = folio-state.get()
  p-card(body, title: title,
    bg: resolve-token(st, "palette.surface.card"),
    border-color: resolve-token(st, "palette.surface.border"),
    // ...
  )
}
```

Raw primitives (`primitives/card.typ`, etc.) accept explicit parameters and fall back to token resolution — they're usable both with and without the brand system.

---

## Audit

The `audit-style` task in the justfile searches for hardcoded color literals (`rgb()`, `luma()`, named colors) in `components/` and `primitives/`. Any hardcoded literal is a style audit failure. All colors must derive from brand tokens.

```bash
just audit-style
```

---

## Creating a New Preset

1. Copy `src/theme/brand-packs/corporate.typ` as a starting point.
2. Rename to `your-preset.typ`.
3. Modify all token values. Every token must be defined (presets are complete).
4. Add a loader branch in `src/core/state.typ`:
   ```typst
   } else if brand-preset == "your-preset" {
     import "../theme/brand-packs/your-preset.typ": brand
     brand
   }
   ```
5. Test with `examples/branding-demo.typ`.

Preset registration is manual in v0.0.1. A discovery mechanism is planned for v0.1.0.
