// The style follows cetz's model: generic keys at the root of `default-style`,
// one group per kind of element, and `auto` meaning "inherit the root key of
// the same name". Values combine with cetz's folding rules, so a partial stroke
// such as `(paint: red)` recolours a wire without changing its thickness.
// A style can be overridden at three levels:
//   - the whole diagram:  `string-diagram(d, style: (stroke: red))`
//   - a sub-diagram:      `styled(d, box: (fill: blue))`, or the `style:`
//                         argument of `serial` and `parallel`
//   - a single element:   `process("f", stroke: red)`, where `auto` inherits
//                         and `none` disables.
// Plain numbers are abstract units and scale with `unit`; typst lengths are
// absolute.

#import "@preview/cetz:0.5.2"

/// Default style.
#let default-style = (
  unit: 2em,             // length of one abstract unit
  padding: 0.1,          // canvas padding, so strokes are not clipped
  direction: "up",       // reading direction: "up", "down", "right" or "left"
  // Base stroke, inherited by every `auto` stroke below. Kept in dictionary
  // form: cetz folds a partial override into a dictionary field by field, but
  // over a stroke *value* it would fill the fields the override omits with
  // typst's defaults instead of these.
  stroke: (paint: black, thickness: 0.7pt),
  fill: white,           // base fill of solid shapes (boxes and triangles)
  inset: 0.1,            // padding around a label inside a box or triangle
  margin: 0.1,           // horizontal gap between a shape and its slot boundary
  stub: 0.2,             // wire stub above/below a box, so boxes never touch
  bend: 0.5,             // height of the S-bend band inserted by `serial`
  gap: 0.0,              // extra horizontal space between `parallel` factors
  wire: (
    stroke: auto,
    arm-angle: 0.1,      // sideways reach, in multiples of the rise, at which
                         // the arm of a fork starts leaving its dot at an angle
  ),
  box: (
    stroke: (thickness: 0.6pt),
    fill: auto,
    height: 0.75,        // minimum height of a process box
    inset: auto,
    margin: auto,
  ),
  triangle: (
    stroke: (thickness: 0.6pt),
    fill: auto,
    height: 0.75,        // minimum height of a state/effect triangle
    aspect: 2.5,         // width/height a triangle aims for before growing taller
    inset: auto,
    margin: auto,
  ),
  dot: (
    radius: 0.1,
    height: 0.2,         // height of the copy and discard dots above their
                         // junction, and of the branch point of unbundle/bundle
    fill: auto,          // `auto` follows the wire paint, not the root fill
  ),
  discard: (
    kind: "dot",         // "dot" or "ground"
  ),
  label: (
    size: 1em,
    sep: 0.1,            // distance of a wire label from its wire
  ),
)

#let directions = ("up", "down", "right", "left")

// Keys that describe the diagram as a whole and therefore cannot be
// overridden for a sub-diagram.
#let whole-diagram-keys = ("unit", "padding", "direction")

// The paint of a stroke given in any of the forms typst accepts.
#let paint-of(s) = {
  if s == none {
    none
  } else if type(s) == dictionary {
    s.at("paint", default: black)
  } else if type(s) == std.stroke {
    if s.paint == auto { black } else { s.paint }
  } else if type(s) in (color, gradient, tiling) {
    s
  } else {
    black
  }
}

#let resolve-dot-fill(raw, st) = {
  if raw.at("dot", default: (:)).at("fill", default: auto) == auto {
    st.dot.fill = paint-of(st.wire.stroke)
  }
  st
}

// A stroke of `none` cannot fold: cetz would let a later partial override
// restart from typst's stroke defaults, so a paintless partial over a
// disabled stroke would silently come back black. Disabled strokes are
// therefore carried as `(paint: none)`, which folds like any stroke — an
// override revives it only by naming a paint — and `use-stroke` turns
// whatever still has no paint back into `none` at the point of drawing.
#let no-stroke = (paint: none)

// Strokes that later overrides fold onto must be dictionaries: cetz merges a
// partial override into a dictionary field by field, but folds it over a
// stroke *value* by filling the omitted fields with typst's defaults, which
// would clobber the base. A full stroke value still replaces wholesale,
// because `resolve-stroke` expands every field explicitly.
#let normalize-stroke(v) = {
  if v == none { no-stroke } else if type(v) == std.stroke { cetz.util.resolve-stroke(v) } else { v }
}

#let normalize-style(over) = {
  // A group key that is `auto` inherits the root key at resolve time, but a
  // root-level `auto` has no ancestor to inherit from and would end up as a
  // literal `auto` stroke, i.e. cetz's defaults. At the root, `auto` therefore
  // means "no override": the key is dropped and the surrounding style shows
  // through.
  let over = over.pairs().filter(((_, v)) => v != auto).to-dict()
  if "stroke" in over { over.stroke = normalize-stroke(over.stroke) }
  for k in ("wire", "box", "triangle") {
    let g = over.at(k, default: auto)
    if type(g) == dictionary and "stroke" in g {
      g.stroke = normalize-stroke(g.stroke)
      over.insert(k, g)
    }
  }
  over
}

#let use-stroke(s) = if type(s) == dictionary and s.at("paint", default: auto) == none { none } else { s }

// Precomputed so that unstyled diagrams do not pay for style resolution at
// every element.
#let default-resolved = resolve-dot-fill(default-style, cetz.styles.resolve(default-style))

// Resolve a raw style: `auto` entries inherit the root key of the same name,
// and partial strokes fold with the stroke they inherit from.
#let resolve-style(style) = if style == default-style { default-resolved } else {
  resolve-dot-fill(style, cetz.styles.resolve(style))
}

// Fold inline element overrides into one group of a resolved style.
#let group-style(st, root, over) = cetz.styles.resolve(st, root: root, merge: over)

// Reject unknown style keys early, so that a typo fails with a clear message.
// Stroke values are checked against the stroke fields rather than the default
// dictionary's keys, which spell out only a paint and a thickness.
#let stroke-keys = ("paint", "thickness", "cap", "join", "miter-limit", "dash")

#let check-stroke(v, path) = if type(v) == dictionary {
  for k in v.keys() {
    assert(
      k in stroke-keys,
      message: "unknown stroke key `" + path + "." + k + "`; valid keys: " + stroke-keys.join(", "),
    )
  }
}

#let check-style(over) = {
  for (k, v) in over {
    assert(k in default-style, message: "unknown style key `" + k + "`; valid keys: " + default-style.keys().join(", "))
    let base = default-style.at(k)
    if k == "stroke" {
      check-stroke(v, k)
    } else if k == "direction" {
      assert(v in directions, message: "`direction` must be one of " + directions.map(repr).join(", "))
    } else if type(v) == dictionary and type(base) == dictionary {
      for (kk, vv) in v {
        assert(
          kk in base,
          message: "unknown style key `" + k + "." + kk + "`; valid keys: " + base.keys().join(", "),
        )
        if kk == "stroke" { check-stroke(vv, k + "." + kk) }
      }
    }
  }
}
