# figchild — Typst

A faithful port of the LaTeX package
[`figchild`](https://ctan.org/pkg/figchild) (*Figures for Creating
Children's Activities*, Fernando de Souza Bastos, UFV, v3.1.2) : **561
colourful line drawings** (animals, vehicles, food, letters, numbers, …)
for teachers who create activities for children.

Two rendering backends:

- **CeTZ** — exact reproduction of the original TikZ drawings
  (`#canvas(...)`);
- **Scrawl** — a hand-drawn variant with a wobbly stroke (`#scrawl(...)`).

```typst
#import "@preview/figchild:0.1.0": *

#canvas(fc-owl-a())                          // exact CeTZ rendering
#canvas(fc-dino(scale: 0.5, rotate: 10deg))  // TikZ-like options
#scrawl(fc-pumpkin(), seed: 3)               // hand-drawn style
```

Module style also works:

```typst
#import "@preview/figchild:0.1.0"
#figchild.canvas(figchild.fc-bee())
```

## The 561 figures

Every macro `\fc…` of the original package maps 1:1 to a function `fc-…`
(kebab-case): `\fcOwlA` → `fc-owl-a`, `\fcIceCreamA` → `fc-ice-cream-a`,
`\fcAlligator` → `fc-alligator`, …

- `#figure-names` returns the full list of original macro names, in the
  order of the original `.sty`.
- `#all-figures` (from `figures.typ`) is the index of every figure
  function.
- The generated definitions live in `figures.typ` (do not edit by hand;
  see `tools/convert.py` in the repository for regeneration).

## Options

`canvas` and `scrawl` accept the usual figure options, applied like the
optional argument of the original macros:

- `scale` (number), `rotate` (angle), `shift` (coordinate)
- `fill` (color) — overrides the drawing's own fill colour
- `stroke` (color) — overrides the stroke colour

```typst
#canvas(fc-apple(fill: red))
#canvas(fc-crown(rotate: 25deg, scale: 0.8))
```

`scrawl` additionally takes `seed`, `roughness`, `margin` and `hand`
(see `#scrawl` docs).

## Combining figures

`render` returns CeTZ elements, so figures can be combined freely inside a
single canvas:

```typst
#import "@preview/cetz:0.5.2"
#cetz.canvas({
  render(fc-bee()) + render(fc-flower-a(shift: (3, 0)))
})
```

## Fidelity

The port is a mechanical conversion of the TikZ code: every `\draw` of the
original package becomes a list of drawing operations with its styles,
nodes and edges. The exact PGF semantics are reproduced (parabola and
smooth-plot Bézier coefficients, arc kappa `4/3·tan(Δ/4)`, clockwise
`arc(270:190:…)`, TikZ 3D points, `cm={…}`, …). See the repository's
verification tooling (`tools/geocheck.py`, `tools/compare.py`).

## Atlas et démo

- `atlas.typ` / `atlas.pdf` : toutes les 561 figures sur des pages A4,
  chacune mise à l'échelle automatiquement pour tenir dans sa cellule (les
  tailles naturelles vont de ~1.7 cm à ~31 cm) et étiquetée avec son nom
  `fc-…`. Compilez `atlas.typ` pour régénérer le PDF.
- `demo.typ` / `demo.pdf` : démonstration (rendu exact, variante Scrawl,
  options à la TikZ), 2 pages A4.

## Notes

- The original package's `\includegraphics` traces are commented out in
  the source and are not part of the port.
- The Scrawl backend samples curves, so it is visually faithful but not
  geometric (CeTZ is).
- Fonts: figures use only strokes/fills, no text — no font dependency.

## License

This port is derived from `figchild` (LPPL 1.3c), Copyright 2021–2026
Fernando de Souza Bastos <fernando.bastos@ufv.br> and contributors
(UFV). Distributed under the same license, LPPL-1.3c (see `LICENSE`).
This is an independent port, not affiliated with the original authors.

FERGOUS Abdelhak. 
