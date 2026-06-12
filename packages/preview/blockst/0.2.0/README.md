# Blockst - Scratch Blocks in Typst

<p align="left">
  <a href="https://typst.app/universe/package/blockst"><img src="https://img.shields.io/badge/typst-preview%20package-239dad?style=flat" alt="Typst package blockst" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-brightgreen?style=flat" alt="License MIT" /></a>
</p>

![Blockst header](examples/header.svg)

Blockst renders Scratch-style programming blocks directly in Typst documents.
It is made for worksheets, tutorials, teaching material, and visual programming explanations.

The current renderer is text-based: Typst passes Scratch text to a bundled WASM plugin, the plugin parses and renders SVG, and Typst embeds the SVG output.

> ⚠️ **BREAKING CHANGE (since `0.2.0`)**
>
> ❌ The old pre-`0.2.0` syntax is **removed** and no longer available.
>
> ✅ From `0.2.0` onward, Blockst supports **only** the text-to-WASM pipeline.
>
> 🔧 Documents that still rely on the previous native Typst renderer syntax **must be migrated**.

Starting with version 0.2.0, Blockst uses only the WASM-based text parser and renderer. The earlier native Typst rendering approach was dropped because it ran into Typst's limits on more complex Scratch layouts.

## Contents

- [Highlights](#highlights)
- [Install and Import](#install-and-import)
- [Quick Start](#quick-start)
- [Example Gallery](#example-gallery)
- [SB3 Import via Typst Plugin WASM](#sb3-import-via-typst-plugin-wasm)
- [Catalog](#catalog)
- [Contributing](#contributing)

## Highlights

- Scratchblocks-style syntax for scripts, reporters, booleans, inputs, dropdowns, and nested control blocks
- Themes: normal, high-contrast, print
- Localized text rendering through the WASM locale data
- **experimental:** SB3 import helpers for scripts, lists, variables, images, and static screen previews

## Install and Import

```typst
#import "@preview/blockst:0.2.0": blockst, scratch, raw-scratch, sb3
```

> Font requirement: Blockst is designed for Helvetica Neue (Scratch-like look).
> On Linux/Windows install a compatible font, for example Nimbus Sans,
> or override globally with `set-blockst(font: "...")`.

## Quick Start

![Quick Start example](examples/example-quickstart.svg)

<details>
<summary><strong>Show code</strong></summary>

```typst
#scratch("
when green flag clicked
move (10) steps
turn cw (15) degrees
")
```

</details>

Source: [examples/example-quickstart.typ](examples/example-quickstart.typ)

## Example Gallery

All long snippets below use the same pattern: result first, code in a collapsible block.

### Localized Text

![German localization example](examples/example-de.svg)

<details>
<summary><strong>Show code</strong></summary>

```typst
#set-blockst(scale: 67.5%)

#scratch("Wenn die grüne Flagge angeklickt
wiederhole (4) mal 
  gehe (30) er Schritt
  drehe dich nach rechts um (90) Grad
end", language: "de")
```

</details>

Source: [examples/example-de.typ](examples/example-de.typ)

### Inline Usage Without blockst Container

![Inline usage example](examples/example-inline.svg)

<details>
<summary><strong>Show code</strong></summary>

```typst
#grid(
  columns: (1fr, auto),
  gutter: 6mm,
  [*Step 1*\
  Trigger the script and walk forward.],
  [#scratch("when green flag clicked\nmove (20) steps")],
  [*Step 2*\
  Repeat a square movement.],
  [#scratch("repeat (4)\nmove (40) steps\nturn cw (90) degrees\nend")],
)
```

</details>

Source: [examples/example-inline.typ](examples/example-inline.typ)

### Markdown Code Blocks with raw-scratch

![raw-scratch example](examples/example-raw-scratch.svg)

<details>
<summary><strong>Show code</strong></summary>

````typst
#show: raw-scratch()

```scratch
when green flag clicked
repeat (4)
  move (30) steps
  turn cw (90) degrees
end
```
````

</details>

Source: [examples/example-raw-scratch.typ](examples/example-raw-scratch.typ)

### Theme and Scale

![Theme example (normal, high-contrast, print)](examples/example-theme.svg)

<details>
<summary><strong>Show code</strong></summary>

```typst
#let script = "when green flag clicked
go to (random position v)
turn cw (30) degrees"

#blockst[
  #scratch(script)
]

#v(5mm)

#blockst(theme: "high-contrast")[
  #scratch(script)
]

#v(5mm)

#blockst(theme: "print")[
  #scratch(script)
]
```

</details>

Source: [examples/example-theme.typ](examples/example-theme.typ)

### Executable Preview (scratch-run)

![Executable square example](examples/example-executable.svg)

<details>
<summary><strong>Show code</strong></summary>

```typst
#let square-program = "
go to x: (-45) y: (-45)
pen down
set pen [color v] to (0)
set pen size to (45)
repeat (4)
  move (90) steps
  turn cw (90) degrees
  change pen [color v] by (25)
end"

#let star-rosette-program = "
go to x: (0) y: (0)
point in direction (90)
pen down
set pen size to (3)
repeat (9)
  repeat (5)
    move (90) steps
    turn cw (144) degrees
  end
  turn cw (40) degrees
  change pen [color v] by (18)
end"

#let spiral-program = "
go to x: (-95) y: (-10)
point in direction (90)
pen down
set pen size to (50)
repeat (60)
  move (10) steps
  turn cw (6) degrees
  change pen [color v] by (8)
  change pen size by (-0.5)
end"

#let custom-block-program = "
define triangle (var [size]) (color)
set pen [color v] to (var [color])
pen down
repeat (3)
  move (var [size]) steps
  turn cw (120) degrees
end
pen up

when green flag clicked
set pen size to (8)
go to x: (-50) y: (-50)
call triangle (100) (200)
go to x: (50) y: (50)
call triangle (50) (60)
"

#set-scratch-run(
  width: 300,
  height: 240,
  start-x: 0,
  start-y: 0,
  start-angle: 90,
  show-grid: 10,
  show-axes: false,
  show-cursor: true,
)

#stack(
  spacing: 6mm,

  [*1) Hue Square*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(square-program)],
    [#scratch-run(..scratch-execute(square-program), unit: 2)],
  ),

  [*2) Star Rosette (Nested repeat)*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(star-rosette-program)],
    [#scratch-run(..scratch-execute(star-rosette-program), unit: 2)],
  ),

  [*3) Colored Spiral (Hue + pen size)*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(spiral-program)],
    [#scratch-run(..scratch-execute(spiral-program), unit: 2)],
  ),

  [*4) Custom Block: Triangle Pattern*],
  grid(
    columns: (auto, auto),
    gutter: 6mm,
    [#scratch(custom-block-program)],
    [#scratch-run(..scratch-execute(custom-block-program), unit: 2, show-cursor: false)],
  ),
)

```

</details>

Source: [examples/example-executable.typ](examples/example-executable.typ)

## Experimental: SB3 Import via Typst Plugin WASM

Recommended workflow:

1. Read `.sb3` as bytes via `read(..., encoding: none)`.
2. Use the `sb3` helpers to extract scripts, monitors, images, or screen previews.
3. Render imported scripts through the same text-to-WASM pipeline as `scratch(...)`.

### SB3 Scripts and Screen Preview

![SB3 import example](examples/example-sb3-import.svg)

<details>
<summary><strong>Show code</strong></summary>

```typst
#let project = read("Mampf-Matze Lösung.sb3", encoding: none)

#blockst[
  #sb3.sb3-screen-preview(project, unit: 1.5)

  #v(4mm)

  #sb3.render-sb3-scripts(
    project,
    language: "en",
    target: "Pacman",
    target-script-number: 2,
    show-headers: true,
  )
]
```

</details>

Source: [examples/example-sb3-import.typ](examples/example-sb3-import.typ)

### Variable and List Monitors

![SB3 variable and list monitors](examples/example-monitors.svg)

<details>
<summary><strong>Show code</strong></summary>

```typst
#let project = read("Mampf-Matze Lösung.sb3", encoding: none)

#stack(
  spacing: 4mm,
  sb3.render-sb3-variables(project, language: "en", show-target-headers: false),
  sb3.render-sb3-lists(project, language: "en", show-target-headers: false),
)
```

</details>

Source: [examples/example-monitors.typ](examples/example-monitors.typ)

### SB3 API at a Glance

- Scripts: `sb3.render-sb3-scripts(...)` with target and script filters
- Lists: `sb3.render-sb3-lists(...)` by target, name, or local index
- Variables: `sb3.render-sb3-variables(...)` by target, name, or local index
- Images: `sb3.sb3-images-catalog(...)`, `sb3.sb3-image(...)`
- Screen: `sb3.sb3-screen-preview(...)`
- Catalogs: `sb3.sb3-scripts-catalog(...)`, `sb3.sb3-state-catalog(...)`

## Catalog

The catalog is split by Scratch 3 category so each file stays readable and can be regenerated independently.

<details>
<summary><strong>Motion</strong></summary>

![Motion blocks](examples/catalog/motion.svg)

Source: [examples/catalog/motion.typ](examples/catalog/motion.typ)

</details>

<details>
<summary><strong>Looks</strong></summary>

![Looks blocks](examples/catalog/looks.svg)

Source: [examples/catalog/looks.typ](examples/catalog/looks.typ)

</details>

<details>
<summary><strong>Sound</strong></summary>

![Sound blocks](examples/catalog/sound.svg)

Source: [examples/catalog/sound.typ](examples/catalog/sound.typ)

</details>

<details>
<summary><strong>Pen</strong></summary>

![Pen blocks](examples/catalog/pen.svg)

Source: [examples/catalog/pen.typ](examples/catalog/pen.typ)

</details>

<details>
<summary><strong>Variables</strong></summary>

![Variable blocks](examples/catalog/variables.svg)

Source: [examples/catalog/variables.typ](examples/catalog/variables.typ)

</details>

<details>
<summary><strong>Lists</strong></summary>

![List blocks](examples/catalog/lists.svg)

Source: [examples/catalog/lists.typ](examples/catalog/lists.typ)

</details>

<details>
<summary><strong>Events</strong></summary>

![Event blocks](examples/catalog/events.svg)

Source: [examples/catalog/events.typ](examples/catalog/events.typ)

</details>

<details>
<summary><strong>Control</strong></summary>

![Control blocks](examples/catalog/control.svg)

Source: [examples/catalog/control.typ](examples/catalog/control.typ)

</details>

<details>
<summary><strong>Sensing</strong></summary>

![Sensing blocks](examples/catalog/sensing.svg)

Source: [examples/catalog/sensing.typ](examples/catalog/sensing.typ)

</details>

<details>
<summary><strong>Operators</strong></summary>

![Operator blocks](examples/catalog/operators.svg)

Source: [examples/catalog/operators.typ](examples/catalog/operators.typ)

</details>

## Contributing

Contributions are welcome: bug reports, missing blocks, parser improvements, rendering polish, docs, and new localizations.
