#import "@preview/cetz:0.4.0"

#let default-style = (
  stroke: auto,
  fill: white,
  padding: 2em,
)

#let venn-prepare-args(num-sets, args, style) = {
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
    "ab-stroke": none,
    "ac-stroke": none,
    "bc-stroke": none,
  )

  let new = (:)
  for combo in set-combinations {
    for (key, def) in keys {
      key = combo + "-" + key
      new.insert(key, args.at(key, default: keys.at(key, default: def)))
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

  let distance = 1.25

  group(name: name, ctx => {
    let style = cetz.styles.resolve(ctx.style, base: default-style, root: "venn", merge: args.named())
    let padding = cetz.util.as-padding-dict(style.padding)
    for (k, v) in padding {
      padding.insert(k, cetz.util.resolve-number(ctx, v))
    }

    let args = venn-prepare-args(2, args.named(), style)

    let pos-a = (-distance / 2,0)
    let pos-b = (+distance / 2,0)

    let a = circle(pos-a, radius: 1)
    let b = circle(pos-b, radius: 1)

    intersections("ab", {
      hide(a);
      hide(b);
    })

    on-layer(args.not-ab-layer,
      rect((rel: (-1 - padding.left, -1 - padding.bottom), to: pos-a),
          (rel: (+1 + padding.right, +1 + padding.top), to: pos-b),
          fill: args.not-ab-fill, stroke: args.not-ab-stroke, name: "frame"))

    on-layer(args.ab-layer,
      merge-path(name: "ab-shape", {
        arc-through("ab.0", (rel: (-1, 0), to: pos-b), "ab.1")
        arc-through("ab.1", (rel: (+1, 0), to: pos-a), "ab.0")
      }, fill: args.ab-fill, stroke: args.ab-stroke, close: true))

    on-layer(args.a-layer,
      merge-path(name: "a-shape", {
        arc-through("ab.0", (rel: (-1, 0), to: pos-a), "ab.1")
        arc-through("ab.1", (rel: (-1, 0), to: pos-b), "ab.0")
      }, fill: args.a-fill, stroke: args.a-stroke, close: true))

    on-layer(args.b-layer,
      merge-path(name: "b-shape", {
        arc-through("ab.0", (rel: (+1, 0), to: pos-b), "ab.1")
        arc-through("ab.1", (rel: (+1, 0), to: pos-a), "ab.0")
      }, fill: args.b-fill, stroke: args.b-stroke, close: true))

    anchor("a", (rel: (-1 + distance / 2, 0), to: pos-a))
    anchor("b", (rel: (+1 - distance / 2, 0), to: pos-b))
    anchor("ab", (pos-a, 50%, pos-b))
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

  let distance = .75

  group(name: name, ctx => {
    let style = cetz.styles.resolve(ctx.style, base: default-style, root: "venn", merge: args.named())
    let padding = cetz.util.as-padding-dict(style.padding)
    for (k, v) in padding {
      padding.insert(k, cetz.util.resolve-number(ctx, v))
    }

    let args = venn-prepare-args(3, args.named(), style)

    let pos-a = cetz.vector.rotate-z((distance,0), -90deg + 2 * 360deg / 3)
    let pos-b = cetz.vector.rotate-z((distance,0), -90deg + 360deg / 3)
    let pos-c = cetz.vector.rotate-z((distance,0), -90deg)

    let angle-ab = cetz.vector.angle2(pos-a, pos-b)
    let angle-ac = cetz.vector.angle2(pos-a, pos-c)
    let angle-bc = cetz.vector.angle2(pos-b, pos-c)

    // Distance between set center points
    let d-ab = cetz.vector.dist(pos-a, pos-b)
    let d-ac = cetz.vector.dist(pos-a, pos-c)
    let d-bc = cetz.vector.dist(pos-b, pos-c)

    // Midpoints between set center points
    let m-ab = cetz.vector.lerp(pos-a, pos-b, .5)
    let m-ac = cetz.vector.lerp(pos-a, pos-c, .5)
    let m-bc = cetz.vector.lerp(pos-b, pos-c, .5)

    // Intersections (0 = outer, 1 = inner)
    let i-ab-0 = cetz.vector.add(m-ab, cetz.vector.rotate-z((+calc.sqrt(1 - calc.pow(d-ab / 2, 2)), 0), angle-ab + 90deg))
    let i-ab-1 = cetz.vector.add(m-ab, cetz.vector.rotate-z((-calc.sqrt(1 - calc.pow(d-ab / 2, 2)), 0), angle-ab + 90deg))
    let i-ac-0 = cetz.vector.add(m-ac, cetz.vector.rotate-z((-calc.sqrt(1 - calc.pow(d-ac / 2, 2)), 0), angle-ac + 90deg))
    let i-ac-1 = cetz.vector.add(m-ac, cetz.vector.rotate-z((+calc.sqrt(1 - calc.pow(d-ac / 2, 2)), 0), angle-ac + 90deg))
    let i-bc-0 = cetz.vector.add(m-bc, cetz.vector.rotate-z((+calc.sqrt(1 - calc.pow(d-bc / 2, 2)), 0), angle-bc + 90deg))
    let i-bc-1 = cetz.vector.add(m-bc, cetz.vector.rotate-z((-calc.sqrt(1 - calc.pow(d-bc / 2, 2)), 0), angle-bc + 90deg))

    on-layer(args.not-abc-layer,
      rect((rel: (-1 - padding.left, +1 + padding.top), to: pos-a),
          (rel: (+1 + padding.right, -1 - padding.bottom), to: (pos-b.at(0), pos-c.at(1))),
          fill: args.not-abc-fill, stroke: args.not-abc-stroke, name: "frame"))

    for (name, angle) in (("ab", 0deg), ("ac", 360deg / 3), ("bc", 2 * 360deg / 3)) {
      on-layer(args.at(name + "-layer"), scope({
        merge-path(name: name + "-shape", {
          rotate(angle)
          arc-through(i-bc-1, (rel: (-1, 0), to: pos-b), i-ab-0)
          arc-through((),     (rel: (+1, 0), to: pos-a), i-ac-1)
          arc-through((),     (rel: (0, +1), to: pos-c), i-bc-1)
        }, fill: args.at(name + "-fill"), stroke: args.at(name + "-stroke"), close: true)}))
    }
    on-layer(args.abc-layer, scope({
      merge-path(name: "abc-shape", {
        arc-through(i-ab-1, (rel: cetz.vector.rotate-z((+1,0), (angle-ab + angle-ac) / 2), to: pos-a), i-ac-1)
        arc-through((),     (rel: cetz.vector.rotate-z((-1,0), (angle-ac + angle-bc) / 2), to: pos-c), i-bc-1)
        arc-through((),     (rel: cetz.vector.rotate-z((-1,0), (180deg + angle-ab + angle-bc) / 2), to: pos-b), i-ab-1)
      }, fill: args.abc-fill, stroke: args.abc-stroke, close: true)}))

    for (name, angle) in (("a", 0deg), ("c", 360deg / 3), ("b", 2 * 360deg / 3)) {
      on-layer(args.at(name + "-layer"),
        scope({
          merge-path(name: "a-shape", {
            rotate(angle)
            arc-through(i-ab-0, (rel: (-1, 0), to: pos-a), i-ac-0)
            arc-through((),     (rel: cetz.vector.rotate-z((-1,0), angle-ac), to: pos-c), i-bc-1)
            arc-through((),     (rel: (-1, 0), to: pos-b), i-ab-0)
          }, fill: args.at(name + "-fill"), stroke: args.at(name + "-stroke"), close: true)
        }))
    }

    let a-a = cetz.vector.lerp(i-bc-0, i-bc-1, 1.5)
    let a-b = cetz.vector.lerp(i-ac-0, i-ac-1, 1.5)
    let a-c = cetz.vector.lerp(i-ab-0, i-ab-1, 1.5)

    anchor("a", a-a)
    anchor("b", a-b)
    anchor("c", a-c)
    anchor("ab", cetz.vector.lerp(a-a, a-b, .5))
    anchor("bc", cetz.vector.lerp(a-b, a-c, .5))
    anchor("ac", cetz.vector.lerp(a-a, a-c, .5))
    anchor("abc", (0,0))
    anchor("not-abc", (rel: (padding.left / 2, padding.bottom / 2), to: "frame.south-west"))
  })
}
