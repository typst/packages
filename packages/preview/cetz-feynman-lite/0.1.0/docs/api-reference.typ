#import "@preview/tidy:0.4.3"
#set text(lang: "en")
#show heading.where(level: 3): set heading(numbering: none)
#show heading.where(level: 4): set heading(numbering: none)
#show heading.where(level: 5): set heading(numbering: none)
= API reference

Import the public API from #raw("lib.typ"). Coordinates, radii, amplitudes, wavelengths
and offsets use canvas units. CeTZ's #raw("length") sets their physical scale.
Line widths use Typst lengths; labels accept Typst content.

#let params(..rows) = table(
  columns: (1.25fr, 1.1fr, 2.6fr), inset: 7pt,
  stroke: 0.4pt + luma(80%),
  fill: (x, y) => if y == 0 {luma(93%)} else {none},
  table.header([*Field*], [*Default / type*], [*Description*]),
  ..rows.pos().flatten(),
)

== Diagram functions
#tidy.show-module(tidy.parse-module(read("../lib.typ")), style: tidy.styles.default)
#pagebreak()
== Rendering and registration
#tidy.show-module(tidy.parse-module(read("../src/render.typ")), style: tidy.styles.default)
#pagebreak()
#tidy.show-module(tidy.parse-module(read("../src/styles.typ")), style: tidy.styles.default)

#pagebreak()
== Vertices

```typst
(id: "v", marker: "blob", size: 0.25,
  fill: blue.lighten(85%), stroke: 1pt + blue,
  label: $Gamma$, label-offset: (0, 0.45))
```

#params(
  ([id], [Required / str], [A unique, non-empty vertex ID.]),
  ([role], ["interaction"], [interaction, incoming or outgoing. Sets the default marker and layout role, not arrow direction.]),
  ([at], [auto], [A fixed (x, y) coordinate, or auto. Both coordinates must be finite numbers.]),
  ([marker], [By role / str], [none, dot, cross, circle or blob. Defaults to dot for interactions and none for external legs.]),
  ([size], [0.09 / positive number], [Circle radius, or the horizontal and vertical half-size of a cross.]),
  ([fill], [black], [Fill for dot and blob. A circle is always transparent.]),
  ([stroke], [0.9pt + black], [CeTZ stroke for circle, blob and cross. A dot has no outline.]),
  ([label], [none / content], [Vertex label, including mathematical or formatted content.]),
  ([label-offset], [(0, 0.3)], [Label displacement relative to the vertex center.]),
)

The dot, circle and blob markers are circular. Propagator centerlines are trimmed
to their boundaries, including both ends of a self-loop. A cross connects at its
center. The none marker hides the symbol while retaining its topology.
Custom marker callbacks and vertex registries are not available.

#pagebreak()
== Edges and paths

Both forms below are accepted and may be mixed in an edge array.

```typst
("a", "b", (particle: "fermion", label: $e^-$))
(id: "electron", from: "a", to: "b", particle: "fermion")
```

#params(
  ([id], [Generated / str], [A unique, non-empty ID. Explicit IDs stabilize parallel-edge allocation and crossing order.]),
  ([from / to], [Required / str], [Endpoint IDs. Equal IDs create a self-loop. Tuple options cannot override endpoints.]),
  ([particle], ["scalar" / str], [A preset name in registry. Names are drawing conventions, not physics validation.]),
  ([style], [(:) / dictionary], [Local overrides of the selected preset.]),
  ([arrow], [From style / str], [none, forward or backward relative to from → to. Overrides style.arrow.]),
  ([bend], [auto], [A number from −1 to 1. Zero is straight; ±1 is a semicircle. Positive bends to the left of from → to.]),
  ([controls], [none], [Two absolute control points for a cubic Bézier. Not for self-loops; cannot combine with explicit bend or route.]),
  ([route], [none / dictionary], [side: above or below (default above); level: positive integer (default 1). Uses absolute canvas directions.]),
  ([loop-size], [0.65 / positive number], [Self-loop half-axis in its facing direction. Self-loops only.]),
  ([loop-aspect], [1 / positive number], [Transverse half-axis divided by the facing half-axis. Self-loops only.]),
  ([loop-angle], [auto / angle], [Self-loop direction: 0deg right, 90deg up.]),
  ([label], [none / content], [Propagator label, independent of momentum.label.]),
  ([label-at], [0.5 / number], [Normalized arc-length position on the complete centerline, from 0 to 1.]),
  ([label-offset], [0.22 / number], [Offset along the left normal; negative values move to the right.]),
  ([momentum], [none / dictionary], [Independent momentum annotation; see Momentum.]),
)

A route requires horizontal separation and cannot be used on a self-loop.
Its midpoint is displaced by ±0.85 × level relative to the endpoint midpoint.
The level controls height, not crossing order. Explicit paths through unrelated
vertices produce an error rather than being silently rerouted.

#pagebreak()
== Styles

#params(
  ([line], ["solid" / str], [solid, dashed, dotted, wave, coil or double. Presets override this base default.]),
  ([arrow], ["none" / str], [none, forward or backward.]),
  ([paint], [black], [Color of the propagator and its arrows.]),
  ([thickness], [0.9pt / positive length], [Line width of the propagator and its arrows.]),
  ([amplitude], [0.085 / positive number], [Wave or coil amplitude; half-spacing for double. The gluon preset uses 0.168.]),
  ([wavelength], [0.42 / positive number], [Target wave or coil pitch, adjusted to fit the path.]),
  ([gluon-aspect], [1.1 / non-negative number], [Longitudinal coil excursion relative to amplitude. Applies to coil only.]),
)

#table(columns: (1fr, 1fr, 2fr), inset: 7pt, stroke: 0.4pt + luma(80%),
  table.header([*Preset*], [*Line*], [*Arrow*]),
  [scalar], [dashed], [none],
  [fermion], [solid], [forward],
  [photon], [wave], [none],
  [gluon], [coil], [none],
  [ghost], [dotted], [forward],
  [double], [double], [none],
)

Precedence: base defaults → registry preset → edge style → edge arrow.
All numerical style values must be finite. Waves taper at the endpoints;
coils fit whole turns plus a final half turn, scaling down for short edges.
Double lines converge at their endpoints.

```typst
#let custom = register-style(styles, "W", (
  line: "wave", paint: blue,
))
// Pass registry: custom to feynman.
// Use particle: "W" on an edge.
```

Registration combines existing line styles; it does not add a rendering algorithm.

#pagebreak()
== Momentum

```typst
momentum: (
  label: $p$, direction: "forward", side: "left",
  at: 0.5, span: 0.3, offset: 0.25, label-offset: 0.35,
)
```

#params(
  ([label], [none / content], [Momentum label. An empty dictionary draws an unlabeled arrow; momentum: none disables the annotation.]),
  ([direction], ["forward" / str], [forward or backward relative to from → to, independent of the propagator arrow.]),
  ([side], ["left" / str], [left or right relative to from → to. Reversing direction does not change the side.]),
  ([at], [0.5 / number], [Midpoint of the arrow interval, in normalized arc length of the complete centerline.]),
  ([span], [0.3 / positive number], [Fraction of the path covered by the arrow. Both at − span/2 and at + span/2 must lie between 0 and 1.]),
  ([offset], [0.25 / positive number], [Distance from the centerline to the momentum arrow in canvas units. The label moves with the arrow.]),
  ([label-offset], [0.20 / non-negative number], [Additional outward displacement of the label from the momentum arrow, in canvas units. Must be finite; zero places the label on the arrow path.]),
)

Use momentum.label-offset to move only the label, leaving the arrow unchanged.
The label is placed at at, outward on the side selected by momentum.side.
For example, label-offset: 0.35 gives more clearance than the default 0.20.
The edge's label-offset affects only the propagator label.

The fermion-flow arrow sits at the midpoint of the trimmed visible path.
Its position, head shape and dimensions are not exposed as options.
Both arrow types use the propagator color and line width.

#pagebreak()
== Layout and crossings

#params(
  ([main-lines], [() / array], [Under layout: arrays of vertex IDs. Each line runs left to right; lines run top to bottom. Each requires at least two adjacent connected vertices. No repeated or shared vertices.]),
  ([incoming-order], [() / array], [Under layout: top-to-bottom incoming order. If non-empty, list every incoming vertex exactly once.]),
  ([outgoing-order], [() / array], [Under layout: top-to-bottom outgoing order. If non-empty, list every outgoing vertex exactly once.]),
  ([external-gap], [2.4 / positive number], [Under layout: vertical spacing of automatically placed external legs. Fixed and main-line legs stay in place; spacing between fixed anchors may differ.]),
  ([crossing-gap], [0 / non-negative number], [Drawing option on feynman, draw-diagram and render. Gap half-length along the wave. Zero disables gaps. Only arrowless wave/wave crossings are handled.]),
)

On a main line, an incoming vertex may appear only first, and an outgoing vertex
only last. Fixed coordinates must satisfy horizontal alignment and ordering.
Candidate edges between adjacent main-line vertices are selected by ID for the
default straight path; explicit paths take precedence.

At a crossing, the lexicographically larger edge ID stays continuous.
Shared endpoints, regions near vertices and waves with flow arrows are excluded.

== Returned data

#params(
  ([vertices], [array], [Vertex dictionaries with defaults filled in.]),
  ([edges], [array], [Normalized edges with resolved style and arrow values.]),
  ([positions], [dictionary], [Vertex ID → final (x, y) position.]),
  ([routes], [array], [Edge properties plus path, table, start and end; pass the result to draw-diagram or render.]),
)

path describes the centerline. table stores sampled points, cumulative lengths
and total length. start and end delimit the trimmed visible arc-length interval.
Label positions and momentum intervals refer to the complete centerline.

Unknown fields, duplicate IDs, invalid values and unsatisfiable constraints are
rejected. Layout and collision checks use finite rules and sampling.
There is no automatic label or momentum avoidance, nor validation of charge,
momentum conservation or amplitudes.
