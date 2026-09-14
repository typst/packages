# diagramgrid Architecture Model

## Core Concepts

### Shapes
Shapes are the atomic visual elements. Each shape wraps content with styling.

```
dg-block (base)
├── dg-rect    → rectangle with optional rounded corners
├── dg-circle  → circle that auto-sizes to content
└── dg-ellipse → ellipse that auto-sizes to content
```

**Key parameters:**
- `content` — what goes inside
- `width`, `height` — dimensions (default: `auto`)
- `fill` — background color
- `stroke` — border
- `inset` — internal padding
- `radius` — corner radius (rect only)

### Layouts
Layouts arrange children using CSS flexbox semantics mapped to Typst's `grid()`.

```
dg-flex (main layout)
├── dg-row    → shorthand for direction: "row"
├── dg-col    → shorthand for direction: "column"
└── dg-layers → shorthand for vertical stacking
```

**dg-flex parameters:**
- `direction` — `"row"` or `"column"`
- `justify` — main axis: `"start"`, `"center"`, `"end"`, `"space-between"`, `"space-around"`
- `align-items` — cross axis: `"stretch"`, `"start"`, `"center"`, `"end"`
- `gap` — spacing between items

### Flexbox-to-Grid Mapping

```
CSS Flexbox          →  Typst Grid
─────────────────────────────────────
direction: row       →  columns: (auto,) * n
direction: column    →  rows: (auto,) * n
justify: center      →  align: center (horizontal)
justify: space-between → insert 1fr spacer columns
align-items: stretch →  rows/cols: (1fr,)
gap                  →  column-gutter / row-gutter
```

## Composition Pattern

The key design principle: **shapes contain content, layouts arrange children**.

```typst
// BAD: dg-layers auto-wrapping (removed)
dg-layers(
  [Text gets auto-wrapped],  // creates unwanted large boxes
  dg-flex(...),              // also gets wrapped!
)

// GOOD: explicit control
dg-layers(
  dg-rect([Label], fill: gray, width: 200pt),  // explicit box
  dg-flex(                                      // no wrapper
    dg-rect([A]),
    dg-rect([B]),
  ),
)
```

## Nesting Model

```
dg-layers (vertical stack)
└── dg-rect (labeled header)
└── dg-flex (horizontal row)
    └── dg-rect (container with nested content)
        └── dg-layers (nested vertical stack)
            └── dg-rect (inner label)
            └── dg-flex (inner row)
                └── dg-circle (leaf node)
```

Nesting depth is unlimited. Each level adds:
- Layout structure (flex/layers)
- Optional visual container (rect with fill/stroke)
- Content (text, shapes, or more layouts)

## File Structure

```
diagramgrid/
├── lib.typ      # Entry point, re-exports all public functions
├── shapes.typ   # dg-block, dg-rect, dg-circle, dg-ellipse
├── layouts.typ  # dg-flex, dg-layers, dg-group, dg-row, dg-col
├── themes.typ   # dg-theme, preset themes, themed-* helpers
├── typst.toml   # Package manifest
├── README.md    # User documentation
├── MODEL.md     # This file
└── manual.typ   # Examples document
```

## Default Values

| Function | Parameter | Default |
|----------|-----------|---------|
| dg-rect | inset | `(x: 8pt, y: 6pt)` |
| dg-rect | radius | `5pt` |
| dg-rect | stroke | `0.8pt + luma(120)` |
| dg-flex | gap | `0.8em` |
| dg-flex | direction | `"row"` |
| dg-flex | justify | `"start"` |
| dg-flex | align-items | `"stretch"` |
| dg-layers | gap | `0.5em` |
| dg-layers | align-items | `"center"` |

## Theming

Themes are dictionaries of style values:

```typst
#let my-theme = dg-theme(
  fill: color,
  stroke: stroke,
  radius: length,
  inset: length or dict,
  gap: length,
  layer-fill: color,
  layer-stroke: stroke,
  layer-radius: length,
  layer-inset: length,
)
```

Apply with helpers:
- `themed-rect(theme, content)` — single rect with theme styles
- `themed-layers(theme, ..children)` — wraps each child in themed rect
