#import "@preview/chalks:0.1.0" as lib
#set page(width: 460pt, margin: 24pt, height: auto)
#set text(size: 10pt)

#let scope = dictionary(lib) // module -> dict of its exports (Typst >= 0.12)
#let example(src) = grid(
  columns: (1fr, auto),
  gutter: 12pt,
  align: horizon,
  raw(src, lang: "typst", block: true),
  eval(src, mode: "markup", scope: scope),
)

= chalks — manual (v#lib.chalks-version)

Hand-drawn pencil/chalk figures for scientific documents. Engine:
`chalks-engine` (Rust → WASM) generating variable-width filled outlines.

== Strokes

#example("#sketch(180pt, 60pt,\n  line((10, 30), (170, 30), roughness: 1.5),\n)")

== Paths

`path` passes through its points in order. `width` is the full stroke
thickness; `smoothness` controls how roundly the curve flows through the
points. There is no fixed-radius corner-rounding parameter.

#example("#sketch(180pt, 75pt,\n  path(((10, 60), (55, 15), (105, 55), (170, 20)),\n    width: 2.4, smoothness: 0.8),\n)")

== Shapes and fills

#example("#sketch(180pt, 90pt,\n  rect((10, 10), (70, 50), fill: \"hachure\"),\n  circle((130, 35), 28, fill: \"shade\"),\n)")

== Annotations

`annotate` places its mark in page coordinates (so an arrow can span pins far
from the `annotate` call itself), so — unlike the self-contained `sketch`
examples above — it must not be nested inside a grid/stack cell here; shown
stacked instead of side-by-side.

#let annotate-src = "The key #pin(\"idea\")[idea].\n#annotate(circle: \"idea\")"
#raw(annotate-src, lang: "typst", block: true)
#eval(annotate-src, mode: "markup", scope: scope)

== Themes

#example("#chalks-theme(ink)\n#sketch(180pt, 50pt, line((10, 25), (170, 25)))")
