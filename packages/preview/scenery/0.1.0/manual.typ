// scenery — showcase manual.
//
// Compile from inside the package directory with:
//   typst compile --root . manual.typ manual.pdf
//
// This file is NOT part of the published package (see typst.toml `exclude`); it
// is the library's documentation and, because every figure below is produced by
// eval'ing the very source string it displays, its compile also doubles as an
// end-to-end test of the public API.

#import "/lib.typ" as scn
#import "@preview/cetz:0.5.2"

#let pkg = toml("typst.toml").package
#let version = pkg.version

// --- document setup ---------------------------------------------------------

#set page(margin: 2cm, numbering: "1")
#set par(justify: true, leading: 0.62em)
#set text(font: "New Computer Modern", size: 10.5pt)
#set heading(numbering: "1.")
#show heading: set block(above: 1.4em, below: 0.7em)
#show link: set text(fill: rgb("#3060b0"))
#show raw.where(block: false): it => box(
  fill: luma(240), inset: (x: 3pt, y: 0pt), outset: (y: 3pt), radius: 2pt, it,
)

// Named accent colours drawn from the theme palette, reused in prose.
#let c-blue = scn.palette-color(scn.default-theme, 0)
#let c-orange = scn.palette-color(scn.default-theme, 1)
#let c-green = scn.palette-color(scn.default-theme, 2)
#let c-red = scn.palette-color(scn.default-theme, 3)

// --- the live-example engine ------------------------------------------------
//
// SCOPE is scenery's entire public surface, injected by name so that an example
// source string can call `sphere`, `camera`, `render-scene`, ... directly. `cetz`
// rides along for the composition chapter. Typst built-ins (grid, rgb, calc, ...)
// are always in scope inside `eval`, so only library names appear here.
#let SCOPE = (
  // linear algebra
  vadd: scn.vadd, vsub: scn.vsub, vscale: scn.vscale, vdot: scn.vdot,
  vcross: scn.vcross, vlen: scn.vlen, vnorm: scn.vnorm, mvec: scn.mvec, lerp: scn.lerp,
  // camera
  camera: scn.camera, camera-2d: scn.camera-2d, project: scn.project,
  // named coordinates
  anchor-ref: scn.anchor-ref, resolve-scene: scn.resolve-scene,
  anchor-of: scn.anchor-of, anchor-names: scn.anchor-names,
  // primitives + assembly
  sphere: scn.sphere, seg: scn.seg, edge: scn.edge, arrow: scn.arrow,
  face: scn.face, mesh: scn.mesh, label: scn.label, build-scene: scn.build-scene,
  // transforms
  affine: scn.affine, translate: scn.translate, scale: scn.scale, group: scn.group,
  // shapes
  hull-faces: scn.hull-faces, uv-sphere: scn.uv-sphere, cylinder: scn.cylinder,
  cone: scn.cone, prism: scn.prism,
  // styling
  default-theme: scn.default-theme, resolve-style: scn.resolve-style,
  palette-color: scn.palette-color,
  // rendering
  sort-prims: scn.sort-prims, scene-group: scn.scene-group, render-scene: scn.render-scene,
  // annotation
  axes-triad: scn.axes-triad, legend: scn.legend, colorbar: scn.colorbar,
  // for the composition chapter
  cetz: cetz,
)

/// Renders `src` twice: once as a syntax-highlighted code block, and once as the
/// live figure produced by evaluating that same string against scenery's public
/// scope. The code shown is therefore, by construction, the code executed — the
/// figure can never drift from its listing.
#let example(src, columns: (1.05fr, 1fr)) = block(
  breakable: false,
  width: 100%,
  radius: 4pt,
  stroke: 0.6pt + luma(200),
  clip: true,
  grid(
    columns: columns,
    grid.cell(
      fill: luma(247),
      inset: 9pt,
      align(left + horizon, raw(src, lang: "typ", block: true)),
    ),
    grid.vline(stroke: 0.6pt + luma(200)),
    grid.cell(
      inset: 10pt,
      align(center + horizon, eval(src, mode: "code", scope: SCOPE)),
    ),
  ),
)

// --- title-page hero: a live double helix -----------------------------------
//
// Adapted from examples/hero.typ: two coloured strands of shaded balls spiral up
// a shared axis, their rungs tinted by height through a shared colormap, wearing
// an axes triad, a legend and a colorbar — one `build-scene`, depth-sorted.
#let hero = {
  let strand-a = c-blue
  let strand-b = c-orange
  let heat = (rgb("#4c72b0"), rgb("#55a868"), rgb("#ccb974"), rgb("#c44e52"))
  let heat-grad = gradient.linear(..heat)
  let rungs = 13
  let dz = 0.62
  let step = 52deg
  let radius = 1.25
  let top = (rungs - 1) * dz
  let prims = ()
  let prev-a = none
  let prev-b = none
  for i in range(rungs) {
    let ang = i * step
    let z = i * dz
    let a = (radius * calc.cos(ang), radius * calc.sin(ang), z)
    let b = (radius * calc.cos(ang + 180deg), radius * calc.sin(ang + 180deg), z)
    if prev-a != none {
      prims.push(scn.seg(prev-a, a, color: strand-a, w: 0.08))
      prims.push(scn.seg(prev-b, b, color: strand-b, w: 0.08))
    }
    prims.push(scn.seg(a, b, color: heat-grad.sample(z / top * 100%), w: 0.09))
    prims.push(scn.sphere(a, 0.32, color: strand-a))
    prims.push(scn.sphere(b, 0.32, color: strand-b))
    prev-a = a
    prev-b = b
  }
  scn.render-scene(
    scn.build-scene(..prims),
    scn.camera(azimuth: 35deg, elevation: 12deg),
    width: 9cm,
    axes: (vectors: ((1, 0, 0), (0, 1, 0), (0, 0, 1)), names: ($x$, $y$, $z$)),
    legend: (([strand A], strand-a), ([strand B], strand-b)),
    colorbar: (colormap: heat, range: (0, top)),
  )
}

#page(numbering: none)[
  #align(center)[
    #v(1.2fr)
    #text(size: 40pt, weight: "bold")[scenery]
    #v(0.2em)
    #text(size: 14pt, fill: luma(70))[
      Programmatic 3D (and 2D) scenes for Typst --- the missing 3D layer
    ]
    #v(1.4em)
    #hero
    #v(1.6em)
    #text(size: 11pt)[
      Typed primitives $arrow$ depth-sorted #box[CeTZ] output, entirely inside the compiler
    ]
    #v(0.6em)
    #text(size: 10pt, fill: luma(90))[
      Version #version #h(0.6em) · #h(0.6em) #pkg.authors.join(", ")
    ]
    #v(0.4em)
    #link(pkg.repository)[#text(size: 10pt)[#pkg.repository]]
    #v(1.6fr)
  ]
]

#outline(indent: auto, depth: 2)

#pagebreak()

= Introduction

*scenery* is Typst's missing 3D layer. You describe a figure as a bag of _typed
primitives_ --- spheres, segments, wireframe edges, arrows, filled faces, indexed
meshes and text labels --- pick an orthographic or perspective camera, and scenery projects,
depth-sorts and paints the whole thing back-to-front with
#link("https://typst.app/universe/package/cetz")[CeTZ]. There is no external
tool, no raster step and no separate renderer: everything happens inside the
Typst compiler, so a 3D figure is just another value in your document.

The entire library is one short pipeline:

#align(center)[
  #box(inset: (y: 6pt))[
    `primitives` #sym.arrow.r `build-scene` #sym.arrow.r `camera` #sym.arrow.r `sort-prims` #sym.arrow.r `cetz`
  ]
]

You build primitives with plain constructors (`sphere(..)`, `seg(..)`, ...) and
collect them with `build-scene`, which returns pure data --- a flat array of
primitives plus a bounding box, with no CeTZ dependency whatsoever. At render
time a `camera` projects every primitive, `sort-prims` keys each
one by camera depth and orders them far-to-near, and the CeTZ backend draws them:
spheres as radial-gradient shaded balls, faces flat-shaded from a single world
light, and labels always last so they stay on top. Before sorting, line-like
primitives are split against opaque spheres and planar faces, while opaque meshes
cull rear faces.

Because the data model is pure, the same pipeline draws flat diagrams too:
`camera-2d()` passes `(x, y)` straight through, so 2D figures and 3D scenes share
one API (see @sec-cameras).

== When to use scenery, and when not to

Reach for scenery when your figure is fundamentally _3D geometry_ --- molecules
and bonds, crystal cells, lattices, polyhedra, vector fields, parametric solids,
anything where points live in space and occlusion matters. scenery gives you a
camera, depth sorting and shaded primitives for free.

Reach for plain CeTZ when your figure is fundamentally _2D drawing_ --- flowcharts,
plots, annotated diagrams, decorative graphics. scenery is built _on_ CeTZ and
composes with it (see @sec-compose), so the choice is never exclusive: you can
drop a depth-sorted 3D scene into the middle of an ordinary CeTZ canvas.

The deliberate limits are covered in @sec-limits: the default backend uses a
painter's algorithm, perspective points must stay in front of the camera, and
large or intersecting scenes may benefit from the optional WASM backend.

= Getting started

Install from Typst Universe by importing the published package. *Import the names
you use explicitly --- never `#import "@preview/scenery:` #version `": *`.* scenery
exports `scale`, `label` and `group`, which would shadow Typst built-ins (`scale`,
`label`) or clobber common variable names if wildcard-imported. Name exactly what
you need:

```typ
#import "@preview/scenery:0.1.0": build-scene, sphere, seg, camera, render-scene
```

If you want scenery's `scale` / `label` alongside the built-ins, rename them on
import:

```typ
#import "@preview/scenery:0.1.0": scale as sscale, label as slabel
```

A minimal complete document is just a scene, a camera and a render call:

#example(
  "let scene = build-scene(
  sphere((0, 0, 0), 0.6),
  sphere((2, 0, 0), 0.6, color: rgb(\"#dd8452\")),
  seg((0, 0, 0), (2, 0, 0)),
)

render-scene(
  scene,
  camera(azimuth: 30deg, elevation: 20deg),
  width: 5cm,
)",
)

#block(inset: (top: 4pt))[
  #text(size: 9pt, fill: luma(90))[
    Every boxed figure in this manual is generated by evaluating the source
    string shown beside it --- the listing on the left is _literally_ the code
    that produced the figure on the right, so nothing here can fall out of date.
  ]
]

= Primitives <sec-prims>

scenery has seven primitive kinds. Each is a plain constructor returning a tagged
dictionary. The optional `name:` and `depth-key:` are structural; other named
arguments (`color`, `w`, `head`, `fill-opacity`, ...) are styling hooks stored
verbatim on the primitive (see @sec-style).

#table(
  columns: (auto, 1fr),
  stroke: none,
  inset: (x: 0pt, y: 3pt),
  align: (left + top, left + top),
  [`sphere(center, r)`], [Shaded ball at `center` with radius `r`.],
  [`seg(a, b)`], [Thick round-capped segment (e.g. a bond); width `w` in scene units.],
  [`edge(a, b)`], [Thin wireframe edge; absolute stroke `width`.],
  [`arrow(from, to)`], [Arrow with a scaled head (`head`, `w`).],
  [`face(pts)`], [Filled planar polygon; `fill-opacity` for translucency.],
  [`mesh(vertices, faces)`], [Indexed polygon mesh; each face depth-sorts on its own.],
  [`label(at, body)`], [Text anchored at a 3D point, painted on top.],
)

The default `depth-key: "center"` sorts spheres by centre, lines by midpoint and
faces by centroid. For intersecting geometry, `"back"` and `"front"` instead use
the farthest or nearest support point. Exact shared support points still tie and
retain input order. A coordination face can combine `depth-key: "back"` with a
small backward offset, as Wyckoff does, so an atom paints over the corresponding
vertex without forcing every sphere into a global foreground layer.

One scene exercising all seven at once --- a translucent ground `face` with
wireframe `edge` rims, two shaded `sphere`s joined by a `seg`, an `arrow` normal
and three `label`s:

#example(
  "let scene = build-scene(
  face(
    ((-2,-2,0), (2,-2,0), (2,2,0), (-2,2,0)),
    color: palette-color(default-theme, 0),
    fill-opacity: 72%,
  ),
  edge((-2,-2,0), (2,-2,0)), edge((2,-2,0), (2,2,0)),
  edge((2,2,0), (-2,2,0)), edge((-2,2,0), (-2,-2,0)),
  sphere((-1,-1,1.2), 0.6, color: palette-color(default-theme, 1)),
  sphere((1.1,1,1.5), 0.5, color: palette-color(default-theme, 2)),
  seg((-1,-1,1.2), (1.1,1,1.5), color: luma(90)),
  arrow((0,0,0), (0,0,2.6), color: palette-color(default-theme, 3)),
  label((-1,-1,2.0), [A]), label((1.1,1,2.3), [B]), label((0.35,0,2.8), [n]),
)

render-scene(
  scene,
  camera(azimuth: 30deg, elevation: 20deg),
  width: 6cm,
  axes: (vectors: ((1,0,0), (0,1,0), (0,0,1)), names: ($x$, $y$, $z$)),
)",
)

Points may be written as 2- or 3-vectors: a 2-vector `(x, y)` is lifted to
`(x, y, 0)`, which is what lets the identical constructors serve `camera-2d()`
scenes (@sec-cameras).

= Named objects & anchors <sec-anchors>

Every primitive may have a unique `name:`. A string of the form
`"object.anchor"` can then be used in primitive coordinate parameters: sphere
centres, line endpoints, face/mesh vertices, and label attachment points.
References may point forward: `build-scene` records the complete registry, and
resolution occurs for the selected camera before projection. Sphere compass
anchors are on the visible, camera-relative silhouette. Shape-generator inputs
and affine transform parameters themselves remain concrete vectors.

#example(
  "let scene = build-scene(
  // The bond deliberately comes first: forward references are valid.
  seg(\"a\", \"b\", name: \"bond\", color: luma(85)),
  label(\"bond.mid\", box(fill: white, inset: 1pt, radius: 1pt)[d], text-anchor: \"south\"),
  sphere((0, 0, 0), 0.6, name: \"a\", color: rgb(\"#4477aa\")),
  sphere((2, 0, 0), 0.6, name: \"b\", color: rgb(\"#cc8963\")),
)

render-scene(scene, camera(azimuth: 30deg, elevation: 20deg), width: 5cm)",
)

#block(breakable: false, table(
    columns: (auto, auto, 1fr),
    stroke: none,
    inset: (x: 0pt, y: 3pt),
    align: (left + top, left + top, left + top),
    [*Primitive*], [*Default*], [*Named anchors*],
    [`sphere`], [`center`], [`center`; compass; `x±`/`y±`/`z±`; angle or 3-vector],
    [`seg`, `edge`, `arrow`], [`mid`], [`start`, `mid`, `end`],
    [`face`], [`centroid`], [`centroid`, `vertex-0`, `vertex-1`, ...],
    [`mesh`], [`center`], [`center`, `vertex-0`, `vertex-1`, ...],
    [`label`], [`center`], [its attachment-point `center`],
  ))

At line-like endpoints, a bare sphere name automatically attaches to the 3D
surface facing the other endpoint. Explicit `"a.center"` or `"a.z+"` references
override that behavior. Compass names and `anchor-ref("a", anchor: 30deg)` are
camera-relative; `x±`/`y±`/`z±` and
`anchor-ref("a", anchor: (1, 1, 1))` are world-space surface directions.
`anchor-of(scene, camera, "bond.mid")` returns a concrete 3D point, while
`anchor-names` lists named anchors. Affine groups defer reference transforms;
automatic attachment is limited to direct references, so transformed references
should use explicit anchors.

= Transforms & groups

A transform maps a point through a matrix and then adds an offset. `translate(v)`
and `scale(s)` are the two common shorthands; `affine(matrix:, offset:)` is the
general form. `group(transform, ..prims)` applies one transform to a whole bag of
primitives (and nested groups), returning a flat array that `build-scene` happily
absorbs. Groups nest and compose left-to-right. Concrete points transform
eagerly; named references defer the same transforms until resolution.

Here one "molecule" is built once, then `group`-translated into a row and
`group`-scaled to shrink the last copy. Note that `scale` moves _positions_ only:
sphere radii and segment widths are left untouched by design.

#example(
  "let unit = (
  sphere((0, 0, 0), 0.45, color: palette-color(default-theme, 0)),
  sphere((1, 0, 0), 0.30, color: palette-color(default-theme, 1)),
  seg((0, 0, 0), (1, 0, 0), color: luma(120)),
)

let scene = build-scene(
  group(translate((0, 0, 0)), ..unit),
  group(translate((0, 1.6, 0)), ..unit),
  group(translate((0, 3.2, 0)), ..unit),
  // scale shrinks positions, not radii:
  group(scale(0.6), group(translate((0, 4.6, 0)), ..unit)),
)

render-scene(
  scene,
  camera(azimuth: 25deg, elevation: 18deg),
  width: 5.5cm,
)",
)

= Shapes

Beyond the bare primitives, scenery ships geometry generators. Four parametric
_solids_ --- `uv-sphere`, `cylinder`, `cone`, `prism` --- each return a single
`mesh` primitive (indexed vertices + faces) that the renderer flat-shades with
adaptive back-face culling. Translucent meshes retain both sides but quiet their
rear strokes; `cull:` and `hidden-stroke:` override that policy. Separately,
`hull-faces(points)` computes the convex hull of a
point set as geometric face records `(plane, vertices)`; feed each record's
`vertices` to `face(..)` to draw a polyhedron with visible edges. It returns
`none` for degenerate (coplanar or collinear) input.

Adaptive culling assumes a closed, approximately convex mesh with its centre
inside, as produced by these generators. Use `cull: none` for open or strongly
concave custom meshes.

#example(
  "let col(i) = palette-color(default-theme, i)

// four parametric solids, drawn opaque (fill-opacity: 0%)
let solids = build-scene(
  uv-sphere((0,0,0), 1.1, segments: 24, rings: 12,
    color: col(0), fill-opacity: 0%),
  cylinder((2.6,0,-1.1), (2.6,0,1.1), 0.8, segments: 28,
    color: col(1), fill-opacity: 0%),
  cone((5.0,0,-1.1), (5.0,0,1.3), 0.9, segments: 28,
    color: col(2), fill-opacity: 0%),
  prism(
    ((6.6,-0.8,-1.1), (7.9,-0.8,-1.1), (7.25,0.5,-1.1)),
    (0,0,2.2), color: col(3), fill-opacity: 0%,
  ),
)

render-scene(
  solids,
  camera(azimuth: 28deg, elevation: 22deg),
  width: 7cm,
)",
)

The convex hull turns bare vertices into a polyhedron. Here an icosahedron from
the twelve cyclic permutations of `(0, ±1, ±φ)`, one stroked `face` per hull
plane:

#example(
  "let phi = (1 + calc.sqrt(5)) / 2
let verts = (
  (0,1,phi), (0,1,-phi), (0,-1,phi), (0,-1,-phi),
  (1,phi,0), (1,-phi,0), (-1,phi,0), (-1,-phi,0),
  (phi,0,1), (phi,0,-1), (-phi,0,1), (-phi,0,-1),
)

// one filled, stroked triangle per hull plane
let ico = hull-faces(verts).map(f => face(
  f.vertices, color: palette-color(default-theme, 4), fill-opacity: 0%,
))

render-scene(
  build-scene(ico),
  camera(azimuth: 28deg, elevation: 18deg),
  width: 4.5cm,
)",
)

= Cameras & views <sec-cameras>

A `camera(azimuth:, elevation:)` is orthographic by default: with both angles zero
it looks along $+y$ with $+x$ to the right and $+z$ up. Because rendering is a pure
function of the camera, viewing the _same scene_ from several angles is just a
loop over cameras. Here one molecule seen from four azimuth/elevation pairs:

#example(
  "let scene = build-scene(
  sphere((0,0,0), 0.7, color: palette-color(default-theme, 0)),
  sphere((1.6,0,0), 0.5, color: palette-color(default-theme, 1)),
  sphere((-0.9,1.3,0.4), 0.5, color: palette-color(default-theme, 2)),
  sphere((0,-0.4,1.4), 0.45, color: palette-color(default-theme, 3)),
  seg((0,0,0), (1.6,0,0)), seg((0,0,0), (-0.9,1.3,0.4)),
  seg((0,0,0), (0,-0.4,1.4)),
)

let shot(az, el) = {
  set align(center)
  stack(spacing: 3pt,
    render-scene(scene, camera(azimuth: az, elevation: el), width: 2.1cm),
    text(size: 6.5pt, fill: luma(90))[az #az, el #el],
  )
}

grid(columns: 4, column-gutter: 3pt, align: center + horizon,
  shot(0deg, 0deg), shot(30deg, 20deg),
  shot(60deg, 35deg), shot(90deg, 70deg),
)",
  columns: (0.62fr, 1fr),
)

Set `mode: "perspective"` and provide a positive `distance:` in scene units for
pinhole perspective. Smaller distances give stronger foreshortening; the distance
must exceed the greatest camera depth in the scene. For example,
`camera(azimuth: 30deg, elevation: 20deg, mode: "perspective", distance: 12)`.

The same call renders flat 2D diagrams: swap the camera for `camera-2d()`, the
identity camera. Coordinates pass straight through, spheres become shaded discs
and arrows become 2D connectors --- no projection, no foreshortening, the same
`build-scene` / `render-scene` loop:

#example(
  "let nodes = (
  ([input],  (0, 0),   palette-color(default-theme, 0)),
  ([encode], (2.4, 0), palette-color(default-theme, 1)),
  ([decode], (4.8, 0), palette-color(default-theme, 2)),
)

let discs = nodes.map(n => sphere(n.at(1), 0.5, color: n.at(2)))
let names = nodes.map(n => label(
  (n.at(1).at(0), n.at(1).at(1) + 0.95), n.at(0),
))
let links = (
  arrow((0.6, 0), (1.8, 0), color: luma(70)),
  arrow((3.0, 0), (4.2, 0), color: luma(70)),
)

render-scene(
  build-scene(..links, ..discs, ..names),
  camera-2d(),
  width: 7cm,
)",
)

= Styling & themes <sec-style>

Styling is a pure, three-layer dictionary merge, right-most winning:

#align(center)[
  `theme.defaults` #sym.arrow.l `theme.<kind>` #sym.arrow.l `the primitive's own hooks`
]

A _theme_ is plain data: a `palette` array for auto-colouring, a world-space
`light` direction for flat face shading, a `defaults` block, and one override
block per primitive kind. `default-theme` is the built-in; `resolve-style(theme,
prim)` computes a primitive's effective style, and `palette-color(theme, i)` picks
palette colour `i` (wrapping around). To restyle, you never touch the pipeline ---
you either pass hooks on a constructor or hand a modified theme to `render-scene`.

The ten-colour qualitative palette:

#align(center)[
  #grid(
    columns: 10,
    column-gutter: 4pt,
    ..range(10).map(i => {
      let c = scn.palette-color(scn.default-theme, i)
      stack(
        spacing: 2pt,
        box(width: 15pt, height: 15pt, radius: 2pt, fill: c),
        text(size: 6pt, fill: luma(110))[#i],
      )
    })
  )
]

Per-primitive hooks override the theme locally. The same three spheres, restyled
three ways --- theme default, an explicit `color`, and a hand-built radial
gradient fill flow straight through the `color` hook:

#example(
  "let scene = build-scene(
  // 1. theme default colour
  sphere((0, 0, 0), 0.6),
  // 2. explicit palette colour
  sphere((1.6, 0, 0), 0.6, color: palette-color(default-theme, 3)),
  // 3. any colour value works
  sphere((3.2, 0, 0), 0.6, color: rgb(\"#6a4fb0\")),
)

render-scene(
  scene,
  camera(azimuth: 20deg, elevation: 15deg),
  width: 6cm,
)",
)

To restyle globally, merge overrides into a copy of `default-theme` and pass it as
`theme:`. Here the whole scene is re-lit and the segment defaults thickened:

#example(
  "let dusk = default-theme
dusk.sphere = (color: rgb(\"#c05a7a\"), stroke-darken: 50%, stroke-width: 0.5pt)
dusk.seg = (color: rgb(\"#33507a\"), w: 0.2)
dusk.light = (0.6, -0.3, 0.7)

let scene = build-scene(
  sphere((0,0,0), 0.6), sphere((1.8,0,0), 0.6), sphere((0.9,1.4,0), 0.6),
  seg((0,0,0), (1.8,0,0)), seg((0,0,0), (0.9,1.4,0)),
  seg((1.8,0,0), (0.9,1.4,0)),
)

render-scene(
  scene,
  camera(azimuth: 30deg, elevation: 25deg),
  width: 5cm,
  theme: dusk,
)",
)

= Annotations

Three pieces of publication furniture ship as CeTZ draw commands: `axes-triad`
(a labelled orientation gizmo), `legend` (stacked shaded-ball swatches) and
`colorbar` (a vertical scalar bar with ticks). `render-scene` places all three for
you through its `axes:`, `legend:` and `colorbar:` options --- triad bottom-left,
legend and colorbar on the right --- derived from the scene's projected bounding
box:

#example(
  "let heat = (rgb(\"#4c72b0\"), rgb(\"#55a868\"),
            rgb(\"#ccb974\"), rgb(\"#c44e52\"))

let scene = build-scene(
  sphere((0,0,0), 0.6, color: palette-color(default-theme, 0)),
  sphere((1.6,0.4,1.0), 0.5, color: palette-color(default-theme, 1)),
  sphere((0.7,1.5,0.3), 0.5, color: palette-color(default-theme, 2)),
  seg((0,0,0), (1.6,0.4,1.0)), seg((0,0,0), (0.7,1.5,0.3)),
)

render-scene(
  scene,
  camera(azimuth: 32deg, elevation: 20deg),
  width: 5cm,
  axes: (vectors: ((1,0,0), (0,1,0), (0,0,1)), names: ($x$, $y$, $z$)),
  legend: (([core], palette-color(default-theme, 0)),
           ([ligand], palette-color(default-theme, 1))),
  colorbar: (colormap: heat, range: (0, 1)),
)",
  columns: (1fr, 0.8fr),
)

Each annotation is also usable on its own inside a CeTZ canvas --- the next
chapter shows how.

= Composing with CeTZ <sec-compose>

`render-scene` is the batteries-included entry point, but under it sits
`scene-group(scene, camera, ..)`, which emits _raw CeTZ draw commands_ instead of
a finished canvas. Drop it inside your own `cetz.canvas` and the depth-sorted 3D
scene coexists with ordinary CeTZ drawing --- annotations, callouts, plots,
anything. `unit:` sets canvas units per scene unit.

#example(
  "cetz.canvas(length: 1cm, {
  import cetz.draw: circle, line, content

  // an ordinary cetz backdrop
  circle((2, 1.4), radius: 1.9, fill: luma(245), stroke: none)

  // a depth-sorted scenery scene, embedded
  let scene = build-scene(
    sphere((0,0,0), 0.55, name: \"a\", color: palette-color(default-theme, 0)),
    sphere((2.2,0,0), 0.55, name: \"b\", color: palette-color(default-theme, 1)),
    seg(\"a\", \"b\", name: \"bond\"),
  )
  scene-group(
    scene, camera(azimuth: 30deg, elevation: 20deg), unit: 1,
  )

  // more cetz on top
  content(\"bond.mid\", box(fill: white, inset: 2pt, radius: 1pt,
    text(9pt)[named anchor]), anchor: \"south\")
  line((0, -1), (2.2, -1), mark: (end: \">\"), stroke: luma(120))
})",
  columns: (1.15fr, 1fr),
)

`scene-group` registers one anchor-only CeTZ group per logical named object, so
later CeTZ commands in the canvas can use `"a.east"` or `"bond.mid"`. The name
remains singular even if occlusion splits the rendered bond into several pieces.
For a large composed scene that needs no later references, pass
`register-anchors: false`; standalone `render-scene` skips this unused export
automatically.
Because `scene-group` is just CeTZ commands, the reverse also holds: scenery's own
`axes-triad`, `legend` and `colorbar` are callable directly inside any canvas when
you want finer placement than the `render-scene` options give.

= Performance & limitations <sec-limits>

scenery is deliberately scoped. Know these four boundaries:

/ Perspective near plane: Perspective projection does not clip at a near plane.
  Every point must stay in front of the camera; increase `distance` if rendering
  reports a point at or behind it.

/ Default painter's algorithm: With `engine: "typst"`, faces and other unsplit
  primitives use one depth key, so _intersecting_ translucent faces can layer in
  the wrong order. The optional `engine: "wasm"` backend BSP-splits those faces.
  Neither backend provides a z-buffer.

/ Pure-Typst size cap: Compile time grows with primitive count on the default
  backend. Use `engine: "wasm"` for larger scenes and for translucent BSP
  splitting. Prefer coarse `segments`/`rings` on solids, and reach for `edge`/`seg`
  wireframes over dense meshes where you can.

/ Adaptive mesh visibility: Opaque meshes cull rear faces by default;
  translucent meshes keep both sides with quieter rear strokes. Use `cull: none`,
  `cull: "back"`, `cull: "front"`, or `hidden-stroke:` to override the policy.

*Roadmap.* Further scene-core enhancements are tracked in
#link("https://github.com/GiggleLiu/scenery/issues/17")[issue #17].

= API reference

Every name below is exported from the package root. Import the ones you use by
name (@sec-prims explains why not `*`).

`scenery-version` is the package version as a Typst `version` value.

#let api(title, rows) = {
  block(above: 0.9em, below: 0.5em, text(weight: "bold")[#title])
  table(
    columns: (auto, 1fr),
    stroke: none,
    inset: (x: 0pt, y: 2.5pt),
    align: (left + top, left + top),
    ..rows,
  )
}

#api("Scene construction", (
  [`sphere(center, r, name:, ..style)`], [Shaded ball.],
  [`seg(a, b, name:, ..style)`], [Thick round-capped segment; width `w` in scene units.],
  [`edge(a, b, name:, ..style)`], [Thin wireframe edge; absolute stroke `width`.],
  [`arrow(from, to, name:, ..style)`], [Arrow with a scaled head (`head`, `w`).],
  [`face(pts, name:, ..style)`], [Planar polygon; `fill-opacity`, optional `cull`, and `depth-key`.],
  [`mesh(vertices, faces, name:, ..style)`], [Adaptive culling; `cull` and `hidden-stroke` hooks.],
  [`label(at, text, name:, ..style)`], [Text at a 3D point; `text-anchor` controls alignment.],
  [`build-scene(..prims)`], [Flattens primitives/groups and validates object names.],
))

#api("Named coordinates", (
  [`anchor-ref(name, anchor:)`], [Explicit name, screen angle, or world 3-vector direction.],
  [`resolve-scene(scene, camera)`], [Resolves references to concrete geometry.],
  [`anchor-of(scene, camera, reference)`], [Returns a concrete 3D anchor point.],
  [`anchor-names(scene, camera, name)`], [Lists an object's named anchors.],
))

#api("Transforms", (
  [`affine(matrix:, offset:)`], [Affine map: matrix times point, plus offset.],
  [`translate(v)`], [Pure translation by `v`.],
  [`scale(s)`], [Uniform scale about the origin (positions only, not radii).],
  [`group(transform, ..prims)`], [Applies a transform to a bag of primitives/subgroups.],
))

#api("Camera", (
  [`camera(azimuth:, elevation:, mode:, distance:)`], [Orthographic or perspective camera.],
  [`camera-2d()`], [Identity camera: `(x, y)` passes straight through.],
  [`project(cam, point)`], [Maps a 3-point to `(sx, sy, depth)`.],
  [`project-scale(cam, depth)`], [Screen-per-world scale at a projected depth.],
))

#api("Shape generators", (
  [`hull-faces(points)`], [Convex-hull face records `(plane, vertices)`; `none` if degenerate.],
  [`uv-sphere(center, r, segments:, rings:)`], [UV-sphere mesh.],
  [`cylinder(from, to, r, segments:, caps:)`], [Cylinder mesh along an axis.],
  [`cone(from, to, r, segments:, cap:)`], [Cone mesh, base at `from`, apex at `to`.],
  [`prism(base, extent, caps:)`], [Polygon `base` extruded by `extent`.],
))

#api("Rendering", (
  [`render-scene(scene, camera, ..)`],
  [Renders a scene at a target width; `engine:` selects `"typst"` or `"wasm"`.],
  [`scene-group(scene, camera, ..)`], [Raw CeTZ commands; controls anchors and geometry engine.],
  [`sort-prims(prims, camera)`], [Pure depth-sort (far-to-near); meshes exploded to faces.],
))

#api("Styling", (
  [`default-theme`], [Built-in theme: palette, light direction, per-kind defaults.],
  [`resolve-style(theme, prim)`], [Effective style (defaults #sym.arrow.l per-kind #sym.arrow.l hooks).],
  [`palette-color(theme, i)`], [Palette colour `i`, wrapping around.],
))

#api("Annotation", (
  [`axes-triad(camera, vectors, names:, ..)`], [Labelled orientation triad.],
  [`legend(entries, ..)`], [Stacked `(label, color)` swatches with shaded balls.],
  [`colorbar(colormap, range, ..)`], [Vertical scalar colorbar with min/mid/max ticks.],
))

#api("Linear algebra", (
  [`vadd vsub vscale vdot vcross`], [Component-wise vector arithmetic and products.],
  [`vlen vnorm`], [Length and normalisation.],
  [`mvec(m, v)` · `lerp(a, b, t)`], [Matrix·vector, and vector interpolation.],
))
