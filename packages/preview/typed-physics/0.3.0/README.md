# typed-physics

A Typst drawing library that also understands physics.

![Block on an incline](assets/readme/incline.png)

```typst
#import "@preview/typed-physics:0.3.0": *

#let s = situation(
  ramp("incline", angle: 32deg, length: 8),
  block("A", mass: 25, on: "incline", at: 45%, size: 1.25, symbol: $m$),
  force(on: "A", magnitude: $F$, angle: 32deg),
)

#scene(s, labels: "both", angles: "both", annotations: (
  dimension(from: "incline.apex", to: "incline.base",
    orientation: "vertical", side: "right", label: $h$),
))
```

Nothing takes coordinates. A body says which surface it rests on and how far
along it sits, a connector says which two points it spans, and a circuit says
what is in series and what is in parallel. Change `angle:` from 32° to 40° and
the hatching, the block, its rotation, the angle arc, the height dimension, and
the answer all move together.

Built on [CeTZ](https://typst.app/universe/package/cetz).

> `block` is this package's body constructor, so importing with `*` shadows
> Typst's own `block`. Reach for it as `std.block`, or import only the names you
> use.

## Examples

<table>
<tr>
  <td><a href="https://github.com/GeronimoCastano/typed-physics/blob/5da63739055c180bca14c2ee188f9934b431d12b/assets/readme/examples/incline-friction-push.typ"><img src="assets/readme/examples/incline-friction-push.png" alt="Block pushed up an incline with friction and a free-body diagram" width="400"></a></td>
  <td><a href="https://github.com/GeronimoCastano/typed-physics/blob/5da63739055c180bca14c2ee188f9934b431d12b/assets/readme/examples/two-rope-sign.typ"><img src="assets/readme/examples/two-rope-sign.png" alt="Sign hung by two ropes with angles and a free-body diagram" width="400"></a></td>
</tr>
<tr>
  <td>A push on an incline: the solver decides the regime, the normal force, and the acceleration</td>
  <td>A sign hung from a ceiling and a wall by two ropes</td>
</tr>
<tr>
  <td><a href="https://github.com/GeronimoCastano/typed-physics/blob/5da63739055c180bca14c2ee188f9934b431d12b/assets/readme/examples/pendulum-release.typ"><img src="assets/readme/examples/pendulum-release.png" alt="Pendulum released from an angle with its rise and speed" width="400"></a></td>
  <td><a href="https://github.com/GeronimoCastano/typed-physics/blob/5da63739055c180bca14c2ee188f9934b431d12b/assets/readme/examples/series-parallel-circuit.typ"><img src="assets/readme/examples/series-parallel-circuit.png" alt="Series-parallel resistor circuit with currents" width="400"></a></td>
</tr>
<tr>
  <td>A released pendulum: the rise h and the speed at the bottom from energy conservation</td>
  <td>A series–parallel DC network: component values, the equivalent resistance, and the currents</td>
</tr>
</table>

*Click an example to see its source.*

## One declaration, four artifacts

The figure, the free-body diagram, the component decomposition, and the answer
are views of the same situation, so they cannot drift apart.

```typst
#let s = situation(
  ramp("incline", angle: 30deg, length: 7),
  block("A", mass: 4, on: "incline", at: 55%, mu: (s: 0.40, k: 0.30)),
)

#scene(s)
#fbd(s, "A")
#components(s, "A")
#solve(s)                    // a = 2.36 m/s², down the incline
#solve(s, find: "normal")    // N = 34.0 N
```

![Free-body diagram and component decomposition](assets/readme/derived.png)

Because it knows mechanics, it can disagree with you:

```typst
#block("A", mass: 4, on: "incline", at: 95%)
```

```text
error: assertion failed: typed-physics: block "A" hangs off the end of
       "incline" by 0.150 — move it back with `at:` or shrink it with `size:`
```

And it decides the friction regime rather than assuming it:

```typst
#let answer = results(s)
#answer.regime            // "sliding"
#answer.required.value    // 19.6 — the friction the situation needs
#answer.available.value   // 13.6 — the most this contact can supply
```

## Walkthroughs

### A spring, a moving block, and a gap

```typst
#let s = situation(
  ground("floor", length: 10),
  wall("wall", side: left, height: 2.4),
  block("A", on: "floor", at: 22%, size: 1.2),
  block("B", on: "floor", at: 62%, size: 1.5),
  spring("s", from: (on: "wall"), to: "A.left", coils: 7),
  velocity(on: "A", angle: 0deg, label: $v_0$),
)

#scene(s, annotations: (
  dimension(from: "A.right", to: "B.left",
    orientation: "horizontal", side: "above", label: $d$),
))
```

Because the wall attachment omits `at:`, the spring infers the height of the
body anchor and stays horizontal. Add an explicit wall ratio such as
`(on: "wall", at: 22%)` when the spring should use that exact point instead.

![Spring, blocks, and a labelled gap](assets/readme/spring.png)

### Annotating a figure

```typst
#let s = situation(
  ground("floor", length: 9),
  ramp("incline", angle: 32deg, length: 4.6, from: "floor.end"),
  block("A", mass: 2, on: "floor", at: 26%),
  pulley("P", at: (on: "floor", at: 58%, offset: (0, 2.4))),
  rope("cord", from: "A.top", to: "P.left"),
)

#scene(s, angles: "none", annotations: (
  angle-mark(from: "floor", to: "incline", label: $theta$, radius: 1.1),
  axis(at: (on: "floor", at: 8%, offset: (0, 2.4)), length: 0.7),
  dimension(from: "A.right", to: "incline.foot",
    orientation: "horizontal", label: $d$),
  brace(from: "incline.foot", to: "incline.apex", label: $ell$, offset: 0.3),
  callout(at: "P.center", label: [frictionless], direction: "north"),
  arrow(from: "A.left", to: (on: "A.left", offset: (-1.4, 0)),
    label: $v_0$, label-position: "center"),
))
```

Annotations belong to the figure rather than to the situation, and they attach
relationally: an angle mark names the two surfaces whose corner it measures, an
axis names the element whose direction it takes, and a callout names the point
it points at. None of them takes a coordinate.

![Six annotations on one scene](assets/readme/annotations.png)

### A simply supported beam

```typst
#let s = situation(
  rod("beam", length: 9, label: none),
  support("A", at: "beam.start", kind: "pin"),
  support("B", at: "beam.end", kind: "roller"),
  force(on: "beam", at: 30%, magnitude: $P_1$, angle: -90deg, label: $P_1$),
  force(on: "beam", at: 62%, magnitude: $P_2$, angle: -90deg, label: $P_2$),
  torque(on: "beam", at: 80%, direction: "clockwise", radius: 0.5, label: $M_0$),
)

#scene(s, annotations: (
  dimension(from: "beam.start", to: (on: "beam", at: 30%),
    side: "below", offset: 1.15, label: $a$),
  dimension(from: (on: "beam", at: 30%), to: (on: "beam", at: 62%),
    side: "below", offset: 1.15, label: $b$),
  dimension(from: "beam.start", to: "beam.end",
    side: "below", offset: 2.3, label: $L$),
))
```

![Simply supported beam](assets/readme/beam.png)

### A rope over a pulley

```typst
#let s = situation(
  ramp("incline", angle: 30deg, length: 7),
  pulley("P", at: "incline.apex", radius: 0.5),
  block("A", mass: 4, on: "incline", at: 55%, size: 1, mu: (s: 0.300, k: 0.220)),
  block("B", mass: 4, hanging: "P.right", drop: 2, size: 1),
  rope("cord", from: "A.uphill", to: "B.top", over: "P"),
)

#scene(s, labels: "both", frictions: true)
#fbd(s, "A")
#fbd(s, "B")
#solve(s, "A")                    // a = 1.52 m/s², B descends and A moves up the incline
#solve(s, "A", find: "tension")   // T = 33.2 N
```

![Modified Atwood machine with free-body diagrams](assets/readme/pulley.png)

The two bodies share one tension and one acceleration. The rope runs along the
incline and B hangs on a vertical rope, so the pair is solved in closed form: the
net pull is compared with the static friction the incline can supply, and kinetic
friction then opposes the motion that results. Friction on A points down the
slope because the regime says it does.

### A DC circuit

Components take no coordinates, wire paths, or rotations. `route:` says how a
branch of a `parallel` travels between the split and join nodes, which is how a
network takes a shape.

```typst
#import "@preview/typed-physics:0.3.0": electricity as e

#let circuit = e.dc-circuit(
  e.voltage-source("V", voltage: 18),
  e.series(
    e.resistor("R100", resistance: 100),
    e.parallel(
      e.resistor("R300", resistance: 300, route: "under"),
      e.resistor("R200", resistance: 200, route: "direct"),
      e.series(
        e.resistor("R50", resistance: 50),
        e.resistor("R250", resistance: 250),
        route: "over",
      ),
    ),
    e.resistor("R150", resistance: 150),
  ),
)

#e.diagram(circuit, labels: "value")
```

![DC resistor network](assets/readme/circuit.png)

A circuit is derived as well as drawn. Series resistances add, parallel
resistances add as reciprocals, and capacitances do the opposite. Your
declaration is already that tree, so every network `series` and `parallel` can
compose reduces:

```typst
#e.solve(circuit)                    // R_eq = 336 Ω
#e.solve(circuit, find: "current")   // I = 0.0536 A
#e.solve(circuit, "R200")            // V_R200 = 4.60 V
#e.component-table(circuit)
```

Quantities are the DC steady state, which is decided rather than assumed: a
capacitor carries no current, so one in series stops its whole branch, and the
voltage that branch does not drop across its resistors stands across its
capacitors instead, dividing as *Q/C*.

## Vocabulary

Wherever one element pins to another, the same spellings work:

```typst
"ceiling"                          // that element's default anchor
"incline.apex"                     // a named anchor of it
(on: "ceiling", at: 40%)           // that far along the element itself
(on: "A.top", at: 25%)             // that far along one of its anchors
(on: "B.left", offset: (0, 0.3))   // an anchor, displaced from where it sits
```

`at:` runs along an anchor that spans a line or an arc — a surface, a body's
side or face, a pulley rim, a rod, a pendulum string, a rope or spring.
`offset:` is an `(x, y)` displacement in world units or absolute lengths such
as `3pt`. A body carries `center`, `contact`, the sides and corners of the box
that encloses it (`top`, `bottom`, `left`, `right`, `top-left`, and the other
three), and its own faces in the frame it was placed in (`uphill`, `downhill`,
`outward`).

Surfaces and bodies:

```typst
#ground(length: 8, from: none, mu: none)
#wall(side: left, height: 4, from: none, mu: none)
#ceiling(length: 8, height: 4, from: none, mu: none)
#ramp("incline", angle: 30deg, length: 6, facing: right, symbol: auto)
#arc("loop", radius: 2, start-angle: -90deg, end-angle: 270deg, side: "outside")

#block("A", mass: none, on: none, at: 50%, touching: none, side: right,
  hanging: none, drop: 1.5, size: 1, mu: none, symbol: auto)
#ball("A", radius: 0.5)        // and every `block` argument
#point-mass("A", radius: 0.09)
#disk("A", radius: 0.6)
#ring("A", radius: 0.6)
```

Connectors, structures, loads, and motion:

```typst
#pulley("P", at: none, radius: 0.4)
#rope("r", from: none, to: none, over: none)
#spring("s", from: none, to: none, coils: 6, width: 0.28)

#rod("beam", from: none, to: none, length: 4, angle: 0deg, mass: none)
#pivot("O", at: none, radius: 0.12)
#support("A", at: none, kind: "pin", angle: 0deg, size: 0.5)
#pendulum("p", from: none, length: 3, angle: 20deg, mass: none)

#force(on: none, at: auto, magnitude: none, angle: 0deg, label: auto)
#torque(on: none, at: auto, magnitude: none, direction: "counterclockwise")
#velocity(on: none, magnitude: none, angle: 0deg, label: auto)
#angular-velocity(on: none, magnitude: none, direction: "counterclockwise")
```

Views, each taking the situation first:

```typst
#scene(s, labels: "name", angles: "value", loads: true, frictions: false,
  lengths: false, annotations: (), forces: none, components: none, style: (:))
#fbd(s, name, axes: auto, outline: true, solve: true, style: (:))
#components(s, name, of: "weight", style: (:))
#draw(s)                      // CeTZ elements, to compose with your own

#solve(s, ..name, find: auto, direction: true, assume: auto)
#force-table(s, ..name, assume: auto)
#results(s, ..name, assume: auto)
#forces(s, name)
#model-of(s, ..name)
#solved-models()
```

Annotations, which `scene(annotations:)` and `draw(annotations:)` take:

```text
#dimension(from:, to:, orientation: "aligned", side: auto, offset: 0.6, label: auto, ...)
#angle-mark(from:, to:, at: auto, radius: auto, label: auto, right-angle: auto, ...)
#axis(at:, along: auto, angle: 0deg, length: 1.2, x-label: auto, y-label: auto, ...)
#callout(at:, label:, direction: "north-east", distance: 1.2, dot: true, frame: true, ...)
#brace(from:, to:, label: none, side: "above", offset: 0.25, amplitude: 0.3, ...)
#arrow(from:, to:, via: (), label: none, arrows: "end", ...)
```

Electrical names live under the `electricity` namespace:

```typst
#e.dc-circuit(source, network, style: (:))
#e.voltage-source("V", voltage: none, unit: auto, label: auto)
#e.resistor("R1", resistance: none, unit: auto, label: auto, route: auto)
#e.capacitor("C1", capacitance: none, unit: auto, label: auto, route: auto)
#e.series(..branches, route: auto)
#e.parallel(..branches, route: auto)

#e.diagram(circuit, labels: "both", fold: auto, style: (:))
#e.solve(circuit, ..name, find: auto)
#e.results(circuit)
#e.component-table(circuit)
```

## Numbers as far as they reach

Every answer is carried as far towards a value as the numbers you declared
allow. All numeric gives a number; a symbolic coefficient among numbers folds
the numbers in and leaves the coefficient standing; nothing numeric gives the
closed form.

```typst
#let s = situation(
  ramp("incline", angle: 30deg, length: 6),
  block("A", mass: $m$, on: "incline", at: 50%, mu: (s: $mu_s$, k: $mu_k$)),
)
#solve(s, find: "normal")     // N = 8.50 m N
#solve(s, assume: "sliding")  // a = 4.90 - 8.50 mu_k m/s², down the incline
```

A declared angle always carries its number, so `sin θ` and `cos θ` fold even
when everything around them is symbolic. The untouched closed form is still in
the tree `results()` hands back, and `tests/test.typ` prints it for every model
beside the formula a textbook gives.

Whether a body slides is a question about numbers. When a coefficient is
symbolic the package says so instead of guessing, and `assume:` is how you
answer it yourself.

## What gets solved

There is no general solver here, and that is a choice. A situation reaches an
answer in closed form when its unknowns can be ordered so each is determined by
ones already found, which holds whenever a body shares no unknown force with
anything else that can move. Two bodies in contact share a pair of contact
forces; a body on a curved support carries a centripetal acceleration no
declaration states. Two bodies joined by a rope over a pulley share a tension,
and the pulley model solves exactly that pair.

So mechanics is a named, finite list of models, and the list is the promise:

| Model | What it is |
| --- | --- |
| `single-contact-body` | One body with a `mass:` on a `ground`, `ramp`, `wall`, or `ceiling`, carrying only the loads it declares. Gives the normal force, the friction force, the regime, and the acceleration. |
| `hanging-body` | One body with a `mass:` hanging from a fixed attachment, with nothing else on its rope. Gives the tension. |
| `two-bodies-over-pulley` | Two bodies with a `mass:` joined by one rope over one `pulley`: both hang (an Atwood machine), or one rests on a `ground` or `ramp` with its rope parallel to it while the other hangs on a vertical rope (a modified Atwood machine). Gives the common acceleration and its direction, the tension, and the normal force and friction on the body on the surface. |

Anything else is declined by name, with the shared unknown that was found:

```text
typed-physics: no solved model matches "A": body "B" rests against it, and
two bodies in contact share a pair of contact forces that has to be found
together with their motion.
```

A pulley pair whose rope leaves the surface at an angle, or whose body rests on a
wall, a ceiling, or a curve, is declined by name in the same way.

**No figure goes through a model.** A situation nothing solves still draws,
still shows its free-body diagram, and still lists the forces acting, with the
magnitudes a model would have supplied left blank.

Circuits are different: reduction is total over every network the grammar can
express, so a circuit is never declined. Only a quantity a circuit does not have
is, such as the resistance of a network no steady current passes through.

## Styling

A diagram style covers a whole figure. An element style covers one declared
thing and wins for that element alone.

```typst
#let s = situation(
  ramp("incline", angle: 30deg),
  block("A", mass: 4, on: "incline", at: 50%,
    style: block-style(fill: luma(230))),
  style: (body-fill: rgb("#DDE6F5"), scale: 0.9),
)
#scene(s, style: (force-colors: (applied: red)))
```

`block-style`, `surface-style`, `force-style`, and `connector-style` build the
sparse dictionaries a `style:` takes. `theme` is the exported dictionary of
every diagram-style default. An unknown key is an error, not a silent no-op.

## Documentation

The [user guide](https://github.com/GeronimoCastano/typed-physics/blob/5da6373/docs/documentation.pdf)
documents every element, view, argument, and style key, with a runnable example
for each.

## License

MIT
