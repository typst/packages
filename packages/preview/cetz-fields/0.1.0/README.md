> **AI disclosure:** This package and its documentation were developed with AI assistance.

# cetz-fields

`cetz-fields` is a pure-Typst library for drawing two-dimensional diagrams of the
three-dimensional Coulomb field with [CeTZ](https://typst.app/universe/package/cetz).
It provides field-line and vector-field renderings, accepts CeTZ coordinates,
and uses bounded deterministic integration.

```typst
#import "@preview/cetz-fields:0.1.0": charge-diagram

#charge-diagram(
  (
    (position: (-1, 0), charge: 1),
    (position: (1, 0), charge: -1),
  ),
  mode: "field-lines",
  domain: ((-3, 3), (-2, 2)),
)
```

## API

### `charge-diagram(charges, ...)`

Creates a self-sizing CeTZ canvas. Important options:

- `mode`: `"field-lines"` (default) or `"vectors"`.
- `domain`: `((x-min, x-max), (y-min, y-max))`; required by the numerical
  methods and used as the exact canvas extent.
- `lines-per-charge`: constant number seeded uniformly around every nonzero
  source. It does not vary with charge magnitude.
- `charge-thickness-factor`: field-line thickness is
  `line-stroke × (1 + factor × abs(charge))`.
- `step`, `max-steps`: RK4 field-line resolution and hard work bound.
- `softening`: Plummer softening length. The mathematically exact field is the
  default (`0`); a small positive value can smooth crowded diagrams.
- `marker-radius` (default `0.22`) sets the global minimum particle radius. A
  charge's `radius` sets its local minimum. Visible labels are measured and the
  circle grows when needed to contain them. `label-padding` (default `0.06`)
  controls the space between a label and its circle. `hit-radius`,
  `line-stroke`, `line-color`, `arrow-position`, and `arrow-scale` provide
  further presentation controls. `line-color` defaults to Typst `black`, which
  Typst Mate maps to the active Obsidian text color.
- `vector-samples` controls vector-grid density. `vector-length-mode` selects
  `"saturating"`, `"linear"`, `"sqrt"`, `"log"`, or `"normalized"` magnitude
  scaling. `vector-scale`, `vector-min-length`, and `vector-max-length` tune and
  clamp the result; `vector-min-field` omits near-zero vectors.
- `vector-arrowhead` defaults to CeTZ's filled stealth arrow (`">>"`), and
  `vector-arrow-scale` controls its size independently of field-line arrows.
- `vector-gradient` accepts a Typst gradient, normally `gradient.linear(...)`.
  `vector-color-min` and `vector-color-max` map the corresponding $abs(F)$
  values to the gradient endpoints and clamp values outside that interval.
  Either endpoint may be `auto` to use the sampled field extrema.
- `show-charges`, `labels`, `positive-color`, `negative-color`.

Each charge is a dictionary:

```typst
(name: "source", position: (0, 0), charge: 1, label: [$q_1$],
 color: red, opacity: 28%, radius: 0.18, line-color: black)
```

`q` is accepted as an alias for `charge`. Labels may be arbitrary Typst
content. Positive particles use red and negative particles blue, following the
usual charge-diagram convention. Their fills are translucent (`particle-opacity:
28%` globally or `opacity` per charge), while labels and borders use
`line-color`. This keeps them legible with both light and dark theme text.
A named charge exposes the standard CeTZ circle anchors, such as
`"source.center"`, `"source.north"`, or `(name: "source", anchor: 30deg)`.
Named charges retain invisible circle anchors when `show-charges: false`.

### Field-line anchors

Request named anchors for selected field lines with `anchors`. The nearest
uniformly seeded line to `field-line` is assigned the requested CeTZ path name:

```typst
draw-charge-diagram(
  (
    (name: "positive", position: (-1, 0), charge: 1),
    (name: "negative", position: (1, 0), charge: -1),
  ),
  domain: ((-3, 3), (-2, 2)),
  anchors: (
    (particle: "positive", field-line: 42deg, name: "selected-line"),
  ),
)

// Available after draw-charge-diagram in the same canvas:
content("selected-line.mid", [midpoint])
content((name: "selected-line", anchor: 25%), [quarter point])
```

The named path provides CeTZ's standard `start`, `mid`, `end`, and percentage
anchors. Selection uses the field line's seed angle around the named particle.
Path direction follows the electric field, so a negative source lies at the
path's `end`, not its `start`.

### CeTZ coordinates and anchors

`draw-charge-diagram` draws into an existing canvas and supports every position
resolved by `cetz.coordinate.resolve`, including named anchors created earlier:

```typst
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-fields:0.1.0": draw-charge-diagram

#cetz.canvas({
  import cetz.draw: *
  rect((-2, -1), (2, 1), name: "frame")
  draw-charge-diagram(
    ((position: "frame.west", charge: 1),
     (position: "frame.east", charge: -1)),
    domain: ((-3, 3), (-2, 2)),
  )
})
```

The standalone `charge-diagram` also accepts a `setup:` block for defining
anchors before the field is processed.

### `electric-field(point, charges, softening: 0)`

Returns the numerical field

`E(r) = sum_i q_i (r-r_i) / |r-r_i|^3`.

This helper requires numeric positions because no CeTZ canvas context exists.
The omitted physical constant only changes the choice of units.

A magnitude-colored vector plot can be configured as follows:

```typst
#charge-diagram(
  charges,
  mode: "vectors",
  domain: ((-3, 3), (-2, 2)),
  vector-length-mode: "sqrt",
  vector-scale: 0.18,
  vector-min-length: 0.04,
  vector-max-length: 0.32,
  vector-arrowhead: ">>",
  vector-arrow-scale: 0.62,
  vector-gradient: gradient.linear(
    rgb("440154"), rgb("21918c"), rgb("fde725"),
  ),
  vector-color-min: 0.05,
  vector-color-max: 2.5,
)
```

The scaling formulas before min/max clamping are: `scale × |F|` for linear,
`scale × sqrt(|F|)` for square-root, `scale × ln(1 + |F|)` for logarithmic,
and `max-length × (1 − exp(−scale × |F|))` for saturating mode. Normalized mode
uses `vector-max-length` for every vector.

## Numerical method

Field lines solve the normalized ODE `dr/ds = ±E/|E|` using classical RK4.
Positive sources integrate with the field and negative sources against it;
negative paths are reversed before drawing so arrows always indicate the
physical field direction. Traces stop at the domain, a different charge, a
field null, or `max-steps`. Exact rectangle intersection avoids overshooting
plot boundaries.

## Development

The environment tracks unstable nixpkgs so `pkgs.typst` is the newest packaged
Typst release.

```sh
devenv shell
check
```

Dependencies use Typst's package imports (`@preview/cetz:0.5.2`); no vendored
runtime or non-Typst implementation code is used.
