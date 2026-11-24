> **AI disclosure:** This package and its documentation were developed with AI assistance.

# cetz-fields

Pure-Typst numerical vector fields and CeTZ diagrams of streamlines, trajectories, and Coulomb charges. The diagram plots a 2D slice of the 3D Coulomb force law. Requires Typst 0.14+ and CeTZ 0.5.2.

```typst
#import "@preview/cetz-fields:0.2.0": vectorfield, graph, coulomb
#coulomb.charge-diagram(
  ((position: (-1, 0), charge: 1), (position: (1, 0), charge: -1)),
  domain: ((-3, -2), (3, 2)),
  vectors: (samples: (13, 9)), // optional: draw vectors behind streamlines
)
```

## Numerical kernel (no CeTZ)

The `vectorfield` module contains the constructor and operations. Its native module functions take the field explicitly:

```typst
#import "@preview/cetz-fields:0.2.0": vectorfield
#let field = vectorfield.new((x, y) => (1, -y))
#let value = vectorfield.sample(field, 0, 1)
#let trace = vectorfield.streamline(field, 0, 0, step: 0.07, max-steps: 900)
#let flight = vectorfield.trajectory(field, 0, 0, vx: 0, vy: 1)
```

Streamlines use fixed-step RK4 on `±F/|F|`, with `reverse: true` tracing against the field. Their `(vx, vy)` values are *raw field samples*, not tangent velocities. Trajectories use fixed-step RK4 on `position' = velocity`, `velocity' = F(position)` (unit mass and coupling); `(vx, vy)` set initial velocity. Both use `step: 0.07`, `max-steps: 900`, optional numeric `domain: ((xmin, ymin), (xmax, ymax))` and `terminate:`. Results are `(points: ((x, y, vx, vy), ...), reason: "boundary" | "terminated" | "null" | "max-steps", hit: none | name)`. The last point is the endpoint; there is no separate end state. The `"null"` reason applies only to streamlines.

`vectorfield.circle-terminator((x, y), radius, name: "target")` snaps to the first segment/circle intersection. `vectorfield.combine-terminators(..terms)` picks the earliest crossing. A custom terminator receives `(previous-state, next-state)` and returns `none` or `(at: t, state: (x, y, vx, vy), name: "target")` with `t` in `[0, 1]`. Domain and terminator hits are compared along the same step; the earliest wins, and the domain wins ties. A named terminator puts its name in `result.hit`.

## Generic CeTZ renderer

`graph.draw-field-graph(field, domain: ..., vectors: none, trajectories: none, lines: none)` draws inside an existing `cetz.canvas`. `graph.field-graph` wraps it in a standalone canvas and accepts `setup`, `length: 1cm`, `padding: 0.15`, and `background`. Domains use **bottom-left/top-right CeTZ corners**, with the field origin at the centre and no scaling. CeTZ named anchors created before the call are supported; explicit 3D coordinate tuples and nonzero-z anchors are rejected.

Omitted options take their defaults. `none` **disables** a drawing layer; an empty dictionary `(:)` enables it with defaults. `vectors: (grid: ((position: (0, 0), name: "arrow"), ...))` draws named arrows. An absent grid uses a `(17, 13)` cell-centre grid. `graph.vector-grid(domain, samples: (17, 13), exclude: ((position: ..., radius: ...),))` is a lazy grid descriptor for skipping circular obstacles. Vectors default to black centred filled-stealth arrows, `stroke: 0.65pt`, `arrow-scale: 0.62`, saturating lengths clamped to `0..0.32`, and omit magnitudes below `min-field: 1e-8`. Optional `gradient: gradient.linear(...)` colours by magnitude; `color-min` and `color-max` default to retained sample extrema (equal extrema use the gradient midpoint). Length modes: `"saturating"`, `"linear"`, `"sqrt"`, `"log"`, `"normalized"`.

`lines: (origins: ((position: (-1, 0), name: "stream", reverse: false),))` draws streamlines. `trajectories: (origins: ((position: (-1, 1), vx: 1, vy: 0, name: "flight"),))` draws trajectories. Both offer `step`, `max-steps`, `stroke`, `color`, `arrow-position`, and `arrow-scale` at layer level and overrides on individual origins. `arrows: false` hides an origin's arrow. `graph.line-origins(sources, count: 12, radius: 0.22)` produces lazy uniformly spaced seeds. `graph.cetz-circle-terminator("target.center", 0.25, name: "target")` resolves its centre during drawing; `graph.cetz-combine-terminators(..terms)` combines lazy CeTZ terminators. Kernel terminators instead require numeric field-space centres.

Named vector arrows, streamlines, trajectories, and charge circles have CeTZ anchors (e.g. `"flight.mid"`, `"arrow.end"`, `"source.north"`). Names must be unique across all layers. Rendering order is frame, vectors, trajectories, streamlines, markers.

## Coulomb convenience layer

`coulomb.draw-charge-diagram(charges, ...)` draws inside an existing canvas; `coulomb.charge-diagram(charges, setup: none, length: 1cm, padding: 0.15, background: none, ...)` makes one. Both accept the generic `vectors`, `lines`, and `trajectories` dictionaries. The default is charge streamlines only (`lines: (:)`, `vectors: none`, `trajectories: none`); pass `lines: none` to hide them. Default domain is `((-4, -3), (4, 3))`. `setup` can create CeTZ anchors before charge positions are resolved.

A charge is `(position: (x, y), charge: number, content: [+], name: "source", lines: 12, color: red, radius: 0.22, opacity: 28%, line-color: black)`. `content` can be any Typst content and defaults to the sign. With no per-charge `lines`, the count is `max(1, round(lines-per-charge * abs(charge)))` for nonzero charges, zero for neutral charges. `lines-per-charge: 12` by default; `lines-per-charge: 0` disables automatic seeding. An explicit per-charge integer is literal, including zero. Charge magnitude also scales line thickness. Marker fills are translucent red `rgb("d94b45")` for positive and blue `rgb("3977c3")` for negative charges; neutral is gray. Labels grow the marker to fit. Named marker circle anchors remain available when `show-charges: false`.

Charge paths snap to other charge markers and stop at the domain edge, a field null, or 900 steps. A negative source traces against the field, then reverses the drawn path to keep arrows pointing with the field. `anchors: ((particle: "source", field-line: 42deg, name: "selected"),)` names the closest uniformly seeded path, exposing CeTZ's standard path anchors. `coulomb.electric-field((x, y), charges, softening: 0)` computes a numerical sample; `coulomb.coulomb-field(charges, softening: 0)` constructs a generic numerical field. Both require numeric charge coordinates outside a canvas. Softening is optional and defaults to the exact inverse-square Coulomb law.

## Migration from 0.1.0

This is a breaking API revision:

| Previously | Now |
|---|---|
| `domain: ((xmin, xmax), (ymin, ymax))` | `domain: ((xmin, ymin), (xmax, ymax))` |
| `mode: "vectors"` | `vectors: (:)`, `lines: none` |
| `mode: "field-lines"` | Default, or `lines: (:)` |
| `vector-gradient`, `vector-samples`, other `vector-*` | `vectors: (gradient: ..., samples: ..., ...)` |
| Charge `label` / `q` | `content` / `charge` |
| `charge-diagram(...)`, `electric-field(...)` | `coulomb.charge-diagram(...)`, `coulomb.electric-field(...)` |
| `electric-field` returns a CeTZ-style 3-tuple | Returns a numeric 2-tuple |

See the [gallery](examples/gallery.typ) and [smoke test](tests/smoke.typ) for runnable usage. Compile locally with `typst compile --root . tests/smoke.typ`.
