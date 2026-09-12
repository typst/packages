#import "@preview/cetz:0.5.2"
#import "coord.typ" as coord
#import "util.typ" as util

#let _resolve-body-size(ctx, body, width, height, body-angle) = {
  if width != auto and height != auto {
    return (width, height)
  }

  let (cw, ch) = cetz.util.measure(ctx, body)
  if body-angle != 0deg {
    let cos-a = calc.abs(calc.cos(body-angle))
    let sin-a = calc.abs(calc.sin(body-angle))
    let rw = cw * cos-a + ch * sin-a
    let rh = cw * sin-a + ch * cos-a
    (cw, ch) = (rw, rh)
  }

  (
    if width == auto { cw } else { width },
    if height == auto { ch } else { height },
  )
}

#let _resolve-dict-origin(ctx, origin, width, height, style) = {
  let (dir, spec) = origin.pairs().first()

  if dir == "between" {
    let (el-a, el-b) = spec
    let (width, height) = coord.resolve-node-size(ctx, width, height)
    let mid = coord.resolve-between(ctx, el-a, el-b)
    let loc = cetz.vector.add(mid, (-width / 2, -height / 2, 0))
    return ("center", loc, (rel: (width, height)))
  }

  let (el, dist, align) = coord.parse-placement-spec(spec)
  let dist = if type(dist) == array {
    dist.map(d => cetz.util.resolve-number(ctx, d))
  } else {
    cetz.util.resolve-number(ctx, dist)
  }

  if dir in coord.outer-coords {
    let (width, height) = coord.resolve-node-size(ctx, width, height)
    (
      "center",
      coord.resolve-outer(ctx, dir, el, dist, align, width, height),
      (rel: (width, height)),
    )
  } else if dir in coord.inner-coords {
    let (width, height) = coord.resolve-node-size(ctx, width, height, relative-to: el)
    let (loc, size) = coord.resolve-inner(dir, el, dist, width, height)
    ("center", loc, size)
  } else {
    (style.at("anchor", default: "center"), origin, (rel: (width, height)))
  }
}

#let _resolve-rect(ctx, origin, width, height, style) = {
  let origin = if coord.is-node-placement(origin) {
    origin
  } else {
    coord.rewrite-node-origin(ctx, origin, width, height)
  }

  if type(origin) == dictionary {
    _resolve-dict-origin(ctx, origin, width, height, style)
  } else {
    (style.at("anchor", default: "center"), origin, (rel: (width, height)))
  }
}

#let _resolve-body-placement(name, body-pos, body-dist) = {
  let body-anc = name + "." + body-pos
  let (dist-x, dist-y) = if type(body-dist) == array {
    body-dist
  } else {
    (body-dist, body-dist)
  }

  if body-pos == "north" {
    ((rel: (0, -dist-y), to: body-anc), "north")
  } else if body-pos == "south" {
    ((rel: (0, dist-y), to: body-anc), "south")
  } else if body-pos == "west" {
    ((rel: (dist-x, 0), to: body-anc), "west")
  } else if body-pos == "east" {
    ((rel: (-dist-x, 0), to: body-anc), "east")
  } else if body-pos == "north-west" {
    ((rel: (dist-x, -dist-y), to: body-anc), "north-west")
  } else if body-pos == "north-east" {
    ((rel: (-dist-x, -dist-y), to: body-anc), "north-east")
  } else if body-pos == "south-west" {
    ((rel: (dist-x, dist-y), to: body-anc), "south-west")
  } else if body-pos == "south-east" {
    ((rel: (-dist-x, dist-y), to: body-anc), "south-east")
  } else {
    (name, "center")
  }
}

/// Draw a rectangular node (box) with a label on a CeTZ canvas.
///
/// The node's position and size are controlled by `origin`, which can be:
/// - A plain CeTZ coordinate: places the node at that coordinate. The anchor
///   used to attach the node to the coordinate defaults to `"center"` but can
///   be overridden via the `anchor` named style argument.
/// - A dictionary with one of the following keys:
///   - `"north-of"`, `"south-of"`, `"east-of"`, `"west-of"`,
///     `"north-east-of"`, `"north-west-of"`, `"south-east-of"`, `"south-west-of"`:
///     places the node adjacent to an existing named element. The value may be
///     just the element name (string), a two-element array `(name, dist)`,
///     a three-element array `(name, dist, align)`, or a distance that is itself
///     a two-element array `(dx, dy)` to specify horizontal and vertical distance
///     differently. The `align` is `"left"`, `"right"`,
///     `"top"`, or `"bottom"` and specifies the alignment of the new element relative
///     to the element `name`. For example, with `"north-of"` and `"left"` the new
///     element is placed north of the `name` and its left border is aligned the
///     left border of `name`. To place relative to a specific anchor point instead,
///     pass `"name.anchor"` such as `"node-name.north-west"`. When using an
///     explicit anchor reference, `align` must remain `"center"`.
///   - `"in-north"`, `"in-south"`, `"in-east"`, `"in-west"`,
///     `"in-north-east"`, `"in-north-west"`, `"in-south-east"`, `"in-south-west"`,
///     `"in-center"`:
///     places the node *inside* an existing named element, anchored to the
///     given inner edge/corner/centre. The value follows the same conventions
///     as the outer-placement keys above. `width` and `height` may be given as
///     ratios (e.g. `50%`) to size the child relative to the container.
///   - `"between"`: centres the node between two existing coordinates. The
///     value must be a two-element array `(coord-a, coord-b)` and may include
///     node anchors like `("foo.north", "bar.south")`.
///
/// The remaining arguments are:
/// - `body` (`content`) -- Content rendered inside the node.
/// - `body-pos` (`string`) -- Anchor of the node's rectangle used to attach
///   the body. One of `"center"`, `"north"`, `"south"`, `"east"`, `"west"`.
///   Defaults to `"center"`.
/// - `body-dist` (`length` or `array`) -- Additional offset between the body and the
///   `body-pos` anchor. Can be a single `length` or an array `(dx, dy)`.
///   Defaults to `0pt`.
/// - `body-align` (`alignment`) -- Typst alignment applied to the body
///   content. Defaults to `center`.
/// - `body-angle` (`angle`) -- Rotation applied to the body content before
///   measuring and drawing. Defaults to `0deg`.
/// - `width` (`auto` or `length` or `ratio`) -- Width of the node. `auto`
///   sizes to fit the body. A `ratio` is resolved relative to the container
///   when using an inner-placement `origin`. Defaults to `auto`.
/// - `height` (`auto` or `length` or `ratio`) -- Height of the node. Same
///   semantics as `width`. Defaults to `auto`.
/// - `inset` (`length`) -- Inset applied around the body inside the node box.
///   Defaults to `0.3em`.
/// - `..style` -- Additional named CeTZ `rect` style arguments (e.g. `name`,
///   `fill`, `stroke`, `anchor`, `radius`, ...).
#let node(
  origin,
  body,
  body-pos: "center",
  body-dist: 0pt,
  body-align: center,
  body-angle: 0deg,
  width: auto,
  height: auto,
  inset: .3em,
  ..style,
) = {
  cetz.draw.get-ctx(ctx => {
    let body = box(inset: inset, rotate(body-angle)[#body])
    let (width, height) = _resolve-body-size(ctx, body, width, height, body-angle)

    util.assert-nodes-canvas(ctx)
    let (anchor, loc, size) = _resolve-rect(ctx, origin, width, height, style)

    let name = style.at("name", default: "__r__")
    cetz.draw.rect(
      loc,
      size,
      anchor: anchor,
      name: name,
      ..style,
    )

    let (pos, anc) = _resolve-body-placement(name, body-pos, body-dist)
    cetz.draw.content(pos, anchor: anc, align(body-align)[#body])
  })
}
