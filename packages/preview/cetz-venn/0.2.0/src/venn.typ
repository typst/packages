#import "@preview/cetz:0.5.2"

#let default-venn2-style = (
  stroke: auto,
  fill: white,
  padding: 2em,
  distance: 1.25,
  radius: 1,
  anchor-outset: -0.25,
)

#let default-venn3-style = (
  ..default-venn2-style,
  distance: 0.75,
  anchor-outset: 0.4,
)

#let venn-prepare-args(ctx, num-sets, args, style) = {
  assert(2 <= num-sets and num-sets <= 3,
    message: "Number of sets must be 2 or 3")

  let set-combinations = if num-sets == 2 {
    ("a", "b", "ab", "not-ab")
  } else {
    ("a", "b", "c", "ab", "ac", "bc", "abc", "not-abc")
  }

  let keys = (
    "fill": style.fill,
    "stroke": style.stroke,
    "layer": 0,
    "ab-layer": -1,
    "ac-layer": -1,
    "bc-layer": -1,
    "abc-layer": -1,
    "ab-stroke": none,
    "ac-stroke": none,
    "bc-stroke": none,
    "not-ab-layer": -2,
    "not-abc-layer": -2,
    "radius": style.radius,
    "distance": style.distance,
    "anchor-outset": style.anchor-outset,
  )

  let wants-resolve(key) = {
    key in ("distance", "radius", "anchor-outset")
  }

  let new = (:)
  for combo in set-combinations {
    for (suffix, def) in keys {
      let key = combo + "-" + suffix
      let value = args.at(key, default: keys.at(key, default: def))
      if wants-resolve(suffix) {
        value = cetz.util.resolve-number(ctx, value)
      }
      new.insert(key, value)
    }
  }

  return new
}

/// Draw a venn diagram with two sets a and b
///
/// *Set attributes:* \
/// The `venn2` function has two sets `a` and `b`, each of them having the following attributes:
///   - `*-fill`: Fill color
///   - `*-stroke`: Stroke style
///   - `*-layer`: CeTZ layer index
///   - `*-distance`: Distance of the center of the set to the center
///   - `*-anchor-outset`: Distance offset for the named anchor
///   - `*-radius`: Radius of the set circle
/// To set a set-attribute, combine the set name (`a`) and the attribute key (`fill`) with a dash: `a-fill`.
///
/// ```example
/// cetz.canvas({
///   cetz-venn.venn2(a-fill: red, b-fill: green)
/// })
/// ```
///
/// The following set names exist and also act as anchors (for labels):
///   - `a`
///   - `b`
///   - `ab`
///   - `not-ab`
///
#let venn2(
  /// Set and style attributes -> any
  ..args,
  /// Element name -> none | string
  name: none) = {
  import cetz.draw: *

  assert-version(std.version(0, 5, 0), max: std.version(0, 6, 0), hint: "tests/version/assert-version")

  group(name: name, ctx => {
    let style = cetz.styles.resolve(ctx.style, base: default-venn2-style, root: "venn", merge: args.named())
    let padding = cetz.util.as-padding-dict(style.padding)
    for (k, v) in padding {
      padding.insert(k, cetz.util.resolve-number(ctx, v))
    }

    let args = venn-prepare-args(ctx, 2, args.named(), style)
    let distance = cetz.util.resolve-number(ctx, style.distance)

    let pos-a = (-args.a-distance / 2,0)
    let pos-b = (+args.b-distance / 2,0)

    let a = circle(pos-a, radius: args.a-radius)
    let b = circle(pos-b, radius: args.b-radius)

    on-layer(args.not-ab-layer,
      rect((rel: (-1 - padding.left, -1 - padding.bottom), to: pos-a),
           (rel: (+1 + padding.right, +1 + padding.top), to: pos-b),
           fill: args.not-ab-fill, stroke: args.not-ab-stroke, name: "frame"))

    on-layer(args.a-layer,
      boolean(a, b, op: "difference", name: "a", ignore-hidden: false,
        fill: args.a-fill, stroke: args.a-stroke))
    on-layer(args.b-layer,
      boolean(b, a, op: "difference", name: "b", ignore-hidden: false,
        fill: args.b-fill, stroke: args.b-stroke))
    on-layer(args.ab-layer,
      boolean(a, b, op: "intersection", name: "ab", ignore-hidden: false,
        fill: args.ab-fill, stroke: args.ab-stroke))

    anchor("a", ((0, 0), args.a-distance + args.a-anchor-outset, pos-a))
    anchor("b", ((0, 0), args.b-distance + args.b-anchor-outset, pos-b))
    anchor("ab", ("a", 50%, "b"))
    anchor("not-ab", (rel: (padding.left / 2, padding.bottom / 2), to: "frame.south-west"))
  })
}

/// Draw a venn diagram with three sets a, b and c
///
/// See `venn2` for the attribute documentation.
///
/// ```example
/// cetz.canvas({
///   cetz-venn.venn3(not-abc-fill: red)
/// })
/// ```
///
/// The following set names exist and also act as anchors (for labels):
///   - `a`
///   - `b`
///   - `c`
///   - `ab`
///   - `bc`
///   - `ac`
///   - `abc`
///   - `not-abc`
///
#let venn3(
  /// Set attributes -> any
  ..args,
  /// Element name -> none | string
  name: none) = {
  import cetz.draw: *

  assert-version(std.version(0, 5, 0), max: std.version(0, 6, 0), hint: "tests/version/assert-version")

  group(name: name, ctx => {
    let style = cetz.styles.resolve(ctx.style, base: default-venn3-style, root: "venn", merge: args.named())
    let padding = cetz.util.as-padding-dict(style.padding)
    for (k, v) in padding {
      padding.insert(k, cetz.util.resolve-number(ctx, v))
    }

    let args = venn-prepare-args(ctx, 3, args.named(), style)
    let distance = cetz.util.resolve-number(ctx, style.distance)

    let pos-a = (-90deg + 2 * 360deg / 3, args.a-distance)
    let pos-b = (-90deg + 360deg / 3, args.b-distance)
    let pos-c = (-90deg + 360deg, args.c-distance)

    let a = circle(pos-a, radius: args.a-radius)
    let b = circle(pos-b, radius: args.b-radius)
    let c = circle(pos-c, radius: args.c-radius)

    on-layer(args.a-layer,
      boolean(a, { b; c }, op: "difference", name: "a", fill: args.a-fill, stroke: args.a-stroke))
    on-layer(args.b-layer,
      boolean(b, { a; c }, op: "difference", name: "b", fill: args.b-fill, stroke: args.b-stroke))
    on-layer(args.c-layer,
      boolean(c, { a; b }, op: "difference", name: "c", fill: args.c-fill, stroke: args.c-stroke))
    on-layer(args.ab-layer,
      boolean({ a; b }, c, op: "difference", name: "ab", fill: args.ab-fill, stroke: args.ab-stroke))
    on-layer(args.bc-layer,
      boolean({ b; c }, a, op: "difference", name: "bc", fill: args.bc-fill, stroke: args.bc-stroke))
    on-layer(args.ac-layer,
      boolean({ a; c }, b, op: "difference", name: "ac", fill: args.ac-fill, stroke: args.ac-stroke))
    on-layer(args.abc-layer,
      boolean(boolean(a, b, op: "intersection"), c, op: "intersection", name: "abc", fill: args.abc-fill, stroke: args.abc-stroke))
    on-layer(args.not-abc-layer,
      rect-around("a", "b", "c", fill: args.not-abc-fill, stroke: args.not-abc-stroke, padding: padding, name: "frame"))

    anchor("a", ((0, 0), args.a-distance + args.a-anchor-outset, pos-a))
    anchor("b", ((0, 0), args.b-distance + args.b-anchor-outset, pos-b))
    anchor("c", ((0, 0), args.c-distance + args.c-anchor-outset, pos-c))
    anchor("ab", ("a", 50%, "b"))
    anchor("bc", ("b", 50%, "c"))
    anchor("ac", ("c", 50%, "a"))
    anchor("abc", (0,0))
    anchor("not-abc", (rel: (padding.left / 2, padding.bottom / 2), to: "frame.south-west"))
  })
}
