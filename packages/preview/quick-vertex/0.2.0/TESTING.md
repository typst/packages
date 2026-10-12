# TESTING — quick-vertex

Run all automated checks from the repository root:

```sh
python3 tests/check.py
```

Requires Python 3 (standard library only), Typst and `pdftotext` from Poppler.
The script keeps compiler outputs in memory. Set `TYPST_BIN` to check another
compiler version. It compiles the math assertions and the gallery/render
battery, checks invalid inputs and rendered diagnostics, inspects SVG geometry,
and compares 100 deterministic systems against an independent exact rational
Fourier–Motzkin projection (including strict inequalities and boundedness).

The pure assertions in `tests/analysis.typ` check known optimal values, narrow
cones, oblique rays, strict feasibility and unattained bounds, scale invariance,
vertex-free regions, the zero objective and degenerate regions. They can also
be run without CeTZ by compiling that file directly.
The render check also compiles all linked example sources:
`gallery/examples.typ`, `gallery/g2-es.typ` and `gallery/additional.typ`.

**Compilation alone is not a mathematical correctness test.** Keep explicit
assertions for mathematical changes; visually inspect rendering changes too.

Render the battery with:

```sh
typst compile --root . tests/regression.typ tests/regression.pdf
```

Then check, page by page:

- [ ] **Bounded, unique optimum** — region filled + hatched; optimum highlighted
  at `C(3,1)`; table shows `Z = 13` in the marked row.
- [ ] **Unbounded, finite minimum** — open sides carry outward arrows; "unbounded
  region" note appears; optimum `Z = 8` at `A(4,0)`; the arrow points toward
  **decreasing** `Z` and is labeled `min Z` for `sense: "min"`.
- [ ] **Unbounded objective** — no vertex is marked optimal; message "No finite
  max: Z increases without bound…".
- [ ] **Multiple optima (segment)** — thick segment `C(3,1)–D(0,4)`; message
  "Multiple solution: Z = 4 on the feasible part of the segment …".
- [ ] **Multiple optima (ray)** — thick ray from the optimal vertex with an
  arrowhead; message mentions "on the feasible part of the ray starting at …".
- [ ] **Any quadrant** (`first-quadrant: false`) — axes cross inside the frame;
  ticks show negatives; the direction arrow is perpendicular to the level lines.
- [ ] **Strict inequality** — boundary drawn **dashed**, with no solid underlay;
  excluded vertices are hollow and rows carry `○`.
- [ ] **Infeasible system** — no table; message "Infeasible region".
- [ ] **Localization** — the same call with `lang: "es"` renders every label in
  Spanish (Vértice / Coordenadas / Óptimo / Solución múltiple / Región no factible).
- [ ] **Optimization direction** — the arrow (`max Z` or `min Z`) is
  perpendicular to the optimal level line and points toward the requested bound.
- [ ] **`equal-aspect: false`** — on a case with a non-square data range (e.g.
  case 1 or 2 above), pass `equal-aspect: false`: the figure stretches to fill
  `size` exactly, each axis picks its own tick step again, and the arrow is still
  visually perpendicular to the level line.
- [ ] **Vertex label placement** — on a many-vertex region (e.g. the "many
  constraints" case), letters lean away from the polygon (exterior bisector)
  instead of a fixed corner offset; check none sits on top of an edge.

## Gallery

- [ ] `gallery/g1.png … g4.png` match the current output after any code change:
  `typst compile --root . --format png --ppi 150 gallery/examples.typ gallery/g{p}.png`
- [ ] Spanish preview shows "Rectas de nivel: Z = k" and the arrow "min Z":
  `typst compile --root . --format png --ppi 150 gallery/g2-es.typ gallery/g2-es.png`

## Additional render cases

The final 13 pages cover narrow cones, oblique rays, unattained suprema,
empty strict systems, distant half-planes, open optimal edges, the zero
objective, a strict boundary through a frame corner, hidden tables,
coefficient scaling, a localized open strip, anisotropic gradients and a
zero objective on a degenerate segment.

- [ ] Continuation arrows appear on the open ends of optimal rays/lines.
- [ ] An unattained optimal face is dashed and no table row is marked optimal.
- [ ] An attained open segment has hollow excluded endpoints and a solid interior.
- [ ] A zero objective highlights the whole region, including a segment.
- [ ] The distant half-plane is visible and has a finite optimum on a line.
- [ ] Turning off the table preserves all objective diagnostics.
