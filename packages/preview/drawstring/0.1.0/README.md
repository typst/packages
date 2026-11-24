# drawstring: Draw String Diagrams in Typst

String diagrams for Markov categories, and more generally for monoidal categories with copying and discarding, as a [Typst](https://typst.app) package.
You write a diagram as a term, such as `serial(copy, parallel(discard, wire()))`, and drawstring lays it out in the style of Fritz (2020) and Cho–Jacobs (2019), drawing with [CeTZ](https://typst.app/universe/package/cetz).

![Three diagrams drawn with drawstring: a camera whose photo is kept and also described in text, the law that copying and then discarding one copy is the identity, and copying a product wire](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/overview.svg)

- **Terms, not coordinates.** Wires, boxes, states and effects are composed in series and in parallel; drawstring places every element and routes the wires between them.
- **Made for equations.** A diagram is content whose centre sits on the math axis, so `$ #string-diagram(a) = #string-diagram(b) $` reads as an equation.
- **Styling at three levels:** the whole diagram, a sub-diagram, or a single element.
- **Four reading directions:** bottom to top by default, or top to bottom, left to right and right to left.
- **Extensible:** any CeTZ drawing can become an element.

## Quick start

```typst
#import "@preview/drawstring:0.1.0": *

$ #string-diagram(serial(
    state("Camera"),
    wire("photo"),
    process("Describe"),
    wire("text"),
  )) $

$ #string-diagram(serial(
    copy,
    parallel(discard, wire()),
  )) = #string-diagram(wire()) $
```

![A camera producing a photo that is described in text, and the equation copy-then-discard equals identity](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/quick-start.svg)

The first diagram is read from the bottom up: a camera produces a photo, which is then described in text.
The second says that copying something and discarding one of the copies is the same as doing nothing.

## Building blocks

| Element | Wires | Drawing | Description |
|---|---|---|---|
| `wire(label, length: 1, side: "right")` | 1 → 1 | ![a vertical wire labelled X](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/wire.svg) | A wire of `length` units, with an optional label beside it. `wire()` is the identity. |
| `process(label, inputs: 1, outputs: 1)` | n → m | ![a box labelled f with a wire entering below and leaving above](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/process.svg) | A step with inputs and outputs: a box with the label inside. |
| `state(label, outputs: 1)` | 0 → m | ![a downward-pointing triangle labelled p with a wire leaving its top edge](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/state.svg) | A source, with outputs only; in a Markov category, a distribution. A triangle pointing down. |
| `effect(label, inputs: 1)` | n → 0 | ![an upward-pointing triangle labelled e with a wire entering its bottom edge](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/effect.svg) | A sink, with inputs only: the mirror image of `state`. |
| `copy` | 1 → 2 | ![a wire rising to a dot from which two arms curve up and outwards](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/copy.svg) | A dot with two arms. |
| `discard` | 1 → 0 | ![a short wire ending in a dot](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/discard.svg) | A wire ending in a dot, or in a ground symbol with the style `discard: (kind: "ground")`. |
| `swap` | 2 → 2 | ![two wires crossing in an X](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/swap.svg) | Two wires crossing. |
| `unbundle` | 1 → 2 | ![one wire forking into two without a dot](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/unbundle.svg) | A fork without a dot, to draw a product wire X × Y as two wires. |
| `bundle` | 2 → 1 | ![two wires merging into one without a dot](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/bundle.svg) | The mirror image of `unbundle`. |

- `copy`, `discard`, `swap`, `unbundle` and `bundle` are values, not functions: write `copy`, not `copy()`.
- Labels are ordinary content: a string is typeset upright, `$X$` gives math.
  `wire` also accepts its label as `label: $X$`.
- Boxes, triangles and wires grow to fit their labels.
- Sizes are measured in abstract units.
  Neighbouring wires are one unit apart, and the style key `unit` (`2em` by default) sets how long a unit is on the page.
- `process`, `state` and `effect` also take `stroke:` and `fill:`, and `wire` a `stroke:`, to restyle that one element; see [Styling](#styling).

Some variants:

| Code | Drawing |
|---|---|
| `wire($X$, length: 2, side: "left")` | ![a wire of length 2 with its label on the left](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/wire-long.svg) |
| `process($f$, inputs: 2, outputs: 3)` | ![a box with two inputs and three outputs](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/process-2-3.svg) |
| `state($p$, outputs: 2)` | ![a state with two outputs](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/state-2.svg) |
| `effect($e$, inputs: 2)` | ![an effect with two inputs](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/effect-2.svg) |
| `process("Describe")` | ![a box that has grown to fit the label Describe](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/process-wide.svg) |

A note on names:
- `state` shadows Typst's builtin, which stays reachable as `std.state`; to keep the builtin, import selectively and rename, as in `#import "@preview/drawstring:0.1.0": serial, parallel, wire, state as dist`.
- The renderer is called `string-diagram` rather than `diagram`, which fletcher and lilaq already export; alias it with `#let sd = string-diagram` if you prefer the short name.

## Composing diagrams

`serial(a, b, ...)` stacks diagrams from bottom to top and connects each one's outputs to the inputs of the next.
`parallel(a, b, ...)` places diagrams side by side, from left to right.

| Code | Drawing |
|---|---|
| `serial(process($f$), process($g$))` | ![f below g](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/serial-fg.svg) |
| `parallel(process($f$), process($g$))` | ![f beside g](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/parallel-fg.svg) |
| `serial(wire($X$), process($f$), wire($Y$), process($g$), wire($Z$))` | ![a labelled chain X, f, Y, g, Z](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/chain.svg) |

Both nest freely:

```typst
serial(
  copy,
  parallel(process($f$), process($g$)),
)
```

![a copy feeding f and g](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/copy-fg.svg)

- By default, diagrams read **bottom to top**: inputs enter at the bottom edge and outputs leave at the top edge, and the first argument of `serial` is the bottom one.
  See [Reading direction](#reading-direction) for the other three.
- In `serial`, each diagram must have as many outputs as the next one has inputs.
  `serial(copy, wire())` is an error, since `copy` has two outputs and `wire()` one input.
- Every diagram has an `inputs` and an `outputs` field with its wire counts.
- `parallel` centres shorter diagrams vertically and extends their wires to the common edges.
  A diagram with no outputs, such as `discard`, sits at the bottom edge instead, and one with no inputs, such as a `state`, at the top edge.
- With a single argument, both combinators return it unchanged; with none, they return the empty diagram.

### How wires are routed

Boxes, triangles and custom elements hold the ends of their wires in place; plain wires and the arms of `copy`, `unbundle` and `bundle` are flexible.
This is what gives the drawings their hand-drawn look.

A wire follows the element it stands on, so a narrow layer of wires over a wide box stays straight rather than kinked:

```typst
serial(process("Describe"), wire("text"))
```

![a labelled wire standing straight on a wide box](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/routing-straight.svg)

A fork arm runs from its dot straight to wherever the next layer needs it:

```typst
serial(
  copy,
  parallel(process("Describe"), wire()),
)
```

![a copy whose left arm reaches sideways to a wide box](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/routing-arm.svg)

A wire whose two ends are held at different positions becomes an S-curve over its own length:

```typst
serial(
  parallel(process("Crop"), process("Describe")),
  parallel(wire(), wire()),
  parallel(process("Describe"), process("Crop")),
)
```

![two boxes over two boxes of different widths, connected by S-curved wires](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/routing-sbend.svg)

Only where two rigid elements meet and disagree does `serial` insert a connector band of `bend` units between the layers:

```typst
serial(
  parallel(process("Crop"), process("Describe")),
  parallel(process("Describe"), process("Crop")),
)
```

![the same boxes without wires in between, with a short connector band inserted](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/routing-band.svg)

## Labels

| Code | Drawing |
|---|---|
| `wire("photo")` | ![a wire labelled with the upright word photo](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/label-string.svg) |
| `wire($X times Y$)` | ![a wire labelled with the math X times Y](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/label-math.svg) |
| `parallel(wire("photo"), process("Describe"))` | ![a labelled wire beside a box, with room kept for the label](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/label-beside.svg) |
| `parallel(wire("photo", side: "left"), process("Describe"))` | ![the same with the label on the left, outside the diagram](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/label-left.svg) |

- A string label is set upright, and math is math.
- A wire label sits to the right of its wire, and the wire keeps room for it, so a neighbour in a `parallel` is placed after the label.
  `side: "left"` puts the label on the other side, for instance to keep it outside the diagram.
- Read sideways, a wire is at least as long as its label.
- Label size follows the surrounding text, not the diagram's `unit`.
  Change it with the style key `label.size`.

## Styling

A style is a dictionary of overrides on `default-style`.
Most documents fix one once, `#let sd = string-diagram.with(style: (unit: 1.5em))`, but a style can be applied at three levels.
The examples use this program, which keeps a photo and also describes it in text:

```typst
#let program = serial(
  state("Camera"),
  copy,
  parallel(wire("photo", side: "left"), process("Describe")),
  parallel(wire(), wire("text")),
)
```

The whole diagram, through the `style:` argument of `string-diagram`:

```typst
#string-diagram(program, style: (stroke: (paint: blue), box: (fill: blue.transparentize(85%))))
```

![the program drawn in blue, with a tinted box](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/style-whole.svg)

A sub-diagram, through `styled`:

```typst
#string-diagram(serial(
  state("Camera"),
  styled(serial(copy, parallel(wire(), discard)), stroke: (paint: red)),
  wire("photo"),
))
```

![a diagram whose copy-and-discard part is red](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/style-sub.svg)

A single element, through its own `stroke:` and `fill:` arguments:

```typst
#string-diagram(serial(
  wire($X$),
  process($f$, stroke: (paint: blue), fill: blue.transparentize(85%)),
  wire($Y$, stroke: (dash: "dashed")),
))
```

![a blue, tinted box between a plain wire and a dashed one](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/style-element.svg)

`serial` and `parallel` also take a `style:` argument, which restyles the diagram they build: `serial(copy, parallel(wire(), discard), style: (discard: (kind: "ground")))`.

### Style keys

The same diagram, `serial(copy, parallel(discard, process($f$)))`, under a few overrides:

| Style | Drawing |
|---|---|
| *(default)* | ![the diagram with the default style](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/keys-default.svg) |
| `(discard: (kind: "ground"))` | ![with a ground symbol for discard](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/keys-ground.svg) |
| `(gap: 0.5)` | ![with a wider gap between the factors](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/keys-gap.svg) |
| `(stroke: (thickness: 1.4pt))` | ![with thicker strokes](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/keys-thickness.svg) |
| `(dot: (radius: 0.15, height: 0.4))` | ![with larger dots placed higher](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/keys-dot.svg) |
| `(unit: 1.4em)` | ![at a smaller unit](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/keys-unit.svg) |

Root keys:

| Key | Default | Meaning |
|---|---|---|
| `unit` | `2em` | length of one unit on the page; an `em` value scales with the text |
| `direction` | `"up"` | reading direction: `"up"`, `"down"`, `"right"` or `"left"` |
| `stroke` | `black + 0.7pt` | base stroke, inherited by every element stroke that is `auto` |
| `fill` | `white` | fill of boxes and triangles |
| `inset` | `0.1` | space between a label and the border of its box or triangle |
| `margin` | `0.1` | space kept free beside a box, a triangle or a wire label, so that neighbours do not touch |
| `stub` | `0.2` | length of the short wire stubs attached to boxes and triangles |
| `bend` | `0.5` | height of the connector band that `serial` inserts between rigid elements |
| `gap` | `0` | extra space between the factors of a `parallel` |
| `padding` | `0.1` | padding around the canvas, so that strokes are not clipped |

Element groups:

| Key | Default | Meaning |
|---|---|---|
| `wire.stroke` | `auto` | stroke of all wires |
| `wire.arm-angle` | `0.1` | sideways reach of a fork arm, relative to its rise, up to which the arm leaves the dot vertically; beyond it the arm leaves at an angle, and `0` makes every arm do so |
| `box.stroke`, `box.fill` | `(thickness: 0.6pt)`, `auto` | stroke and fill of process boxes |
| `box.height` | `0.75` | minimum height of a box |
| `box.inset`, `box.margin` | `auto` | as the root keys, for boxes |
| `triangle.stroke`, `triangle.fill` | `(thickness: 0.6pt)`, `auto` | stroke and fill of `state` and `effect` triangles |
| `triangle.height` | `0.75` | minimum height of a triangle |
| `triangle.aspect` | `2.5` | width-to-height ratio a triangle aims for; a long label first widens it and then, past this ratio, makes it taller too |
| `triangle.inset`, `triangle.margin` | `auto` | as the root keys, for triangles |
| `dot.radius` | `0.1` | radius of the `copy` and `discard` dots |
| `dot.height` | `0.2` | distance of a dot, or of the branch point of `unbundle` and `bundle`, from the end of its single wire |
| `dot.fill` | `auto` | fill of the dots; `auto` follows the wire paint |
| `discard.kind` | `"dot"` | `"dot"` or `"ground"` |
| `label.size` | `1em` | text size of all labels |
| `label.sep` | `0.1` | distance between a wire and its label |

Plain numbers are in units and scale with `unit`; `unit`, `label.size` and stroke thicknesses are Typst lengths.

### How styles combine

- `auto` in an element group means "use the root key of the same name".
- Strokes fold as in CeTZ: a partial stroke such as `(paint: red)` or `(dash: "dashed")` changes only what it names, while a full stroke such as `red + 1pt` replaces the inherited one.
- `stroke: none` at the root hides everything, since boxes, triangles and dots take their paint from it.
  An element comes back only when its own stroke names a paint, for example `box: (stroke: (paint: black))`.
- `unit`, `padding` and `direction` describe the diagram as a whole, so only `string-diagram` accepts them, not `styled`.
- Unknown keys are an error, so a typo does not pass silently.

## Reading direction

The `direction` style key turns the finished drawing.
Labels stay upright; boxes, triangles and labelled wires make room for them along the new flow.

| Style | Drawing |
|---|---|
| `(direction: "up")` | ![the program read bottom to top](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/direction-up.svg) |
| `(direction: "down")` | ![the program read top to bottom](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/direction-down.svg) |
| `(direction: "right")` | ![the program read left to right](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/direction-right.svg) |
| `(direction: "left")` | ![the program read right to left](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/direction-left.svg) |

- `"down"` is the vertical mirror image of `"up"`.
- In `"right"` and `"left"`, the first factor of a `parallel` is on top, and boxes are long along the flow, as such diagrams are usually drawn.
- Read sideways, a wire label with `side: "right"` sits below its wire and one with `side: "left"` above it.

## Diagrams in running text

The default unit is sized for display math.
Inline, pass a smaller one, and a smaller label size if the diagram carries labels:

```typst
#let small = string-diagram.with(style: (unit: 1.2em))
The copy map #small(copy) and the discard map #small(discard) satisfy
#small(serial(copy, parallel(wire(), discard))) $=$ #small(wire()), so every object is a comonoid.
At the default size the same diagram, #string-diagram(serial(copy, parallel(wire(), discard))), is too tall for a line of text.
A labelled diagram also wants smaller labels: #string-diagram(serial(wire($X$), process($f$), wire($Y$)), style: (unit: 1.3em, label: (size: 0.8em))).
```

![a paragraph with small diagrams set inline, one diagram at the default size that is too tall for the line, and a labelled diagram with reduced label size](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/inline.svg)

`string-diagram` returns a box whose baseline is shifted so that the diagram's vertical centre lands on the math axis.
Pass `baseline:` to change that.

## Custom primitives

`primitive` turns a CeTZ drawing into an element that composes like the built-in ones.

```typst
#import "@preview/cetz:0.5.2": draw

#let cup = primitive(inputs: 0, outputs: 2, width: 2, height: 1, draw: (style, geometry) => {
  draw.bezier((0.5, 1), (1.5, 1), (0.5, 0.2), (1.5, 0.2), stroke: style.wire.stroke)
})

#let cap = primitive(inputs: 2, outputs: 0, width: 2, height: 1, draw: (style, geometry) => {
  draw.bezier((0.5, 0), (1.5, 0), (0.5, 0.8), (1.5, 0.8), stroke: style.wire.stroke)
})

#let spider(n, m) = primitive(inputs: n, outputs: m, draw: (style, geometry) => {
  let c = (geometry.width / 2, geometry.height / 2)
  for x in geometry.input-positions { draw.line((x, 0), c, stroke: style.wire.stroke) }
  for x in geometry.output-positions { draw.line(c, (x, geometry.height), stroke: style.wire.stroke) }
  draw.circle(c, radius: style.dot.radius, fill: style.dot.fill, stroke: none)
})
```

| Element | Drawing |
|---|---|
| `cup` | ![a cup](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/cup.svg) |
| `cap` | ![a cap](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/cap.svg) |
| `spider(3, 2)` | ![a spider with three inputs and two outputs](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/spider.svg) |
| `trapezoid("Describe")`, defined in [docs/figures/custom.typ](https://github.com/fzaiser/drawstring/blob/v0.1.0/docs/figures/custom.typ) | ![a trapezoid sized to its label](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/trapezoid.svg) |

The snake equation of a compact closed category:

```typst
$ #string-diagram(serial(
    parallel(wire($X$), cup),
    parallel(cap, wire($X$)),
  )) = #string-diagram(wire($X$, length: 2)) $
```

![a wire that runs up, loops back down through a cup and a cap, and continues up, equal to a straight wire](https://raw.githubusercontent.com/fzaiser/drawstring/v0.1.0/docs/images/snake.svg)

- `draw(style, geometry)` returns CeTZ elements.
  It draws in units, with the origin at the bottom-left corner of the element.
- `style` is the fully resolved style, so `style.wire.stroke`, `style.box.fill` or `style.dot.radius` can be handed to CeTZ as they are.
  Import the same CeTZ version as drawstring does.
- `geometry` holds the element's `width`, `height`, `input-positions` and `output-positions`, and a `measure` function.
- The element is `width` × `height` units; by default it is one unit tall and as wide as its larger wire count.
  Its wire ends are spread evenly along its edges unless `input-positions` and `output-positions` say otherwise.
- To size an element to its label, pass `width` or `height` (or the positions) as a function `(style, measure) => ...`.
  `measure(label)` returns the label's `width` and `height` in units, along the element's own axes, so that the element fits its label in every reading direction.
  The trapezoid above is drawn this way.
- Custom elements are rigid: their wire ends stay put, and the neighbouring wires bend to meet them.
- The declared size counts towards the canvas even where the drawing is smaller.

## Further information

- **Gallery**: [docs/gallery.typ](https://github.com/fzaiser/drawstring/blob/v0.1.0/docs/gallery.typ) shows the whole repertoire in one document, with examples from probability theory; [docs/gallery.pdf](https://github.com/fzaiser/drawstring/blob/v0.1.0/docs/gallery.pdf) is its output.
- **Requirements**: Typst 0.14 or newer.
- **Contributing**: [CONTRIBUTING.md](https://github.com/fzaiser/drawstring/blob/v0.1.0/CONTRIBUTING.md) explains how to run the tests and regenerate the figures, and [ARCHITECTURE.md](https://github.com/fzaiser/drawstring/blob/v0.1.0/ARCHITECTURE.md) how the layout works.
- **AI assistance**: drawstring was developed with the help of AI coding assistants (Claude Code and OpenAI Codex) under close human review.
- **License**: MIT, see [LICENSE](LICENSE).
