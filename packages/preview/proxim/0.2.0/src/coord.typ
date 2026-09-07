#import "@preview/cetz:0.5.2"
#import "util.typ" as util

/// Placement keys that position a node outside another named element.
#let outer-coords = (
  "east-of",
  "west-of",
  "north-of",
  "south-of",
  "north-east-of",
  "north-west-of",
  "south-east-of",
  "south-west-of",
)

/// Placement keys that position a node inside another named element.
#let inner-coords = (
  "in-north",
  "in-south",
  "in-west",
  "in-east",
  "in-north-west",
  "in-north-east",
  "in-south-west",
  "in-south-east",
  "in-center",
)

/// Normalize a placement value into `(element, distance, alignment)`.
///
/// Accepted forms are `name`, `(name, dist)`, or `(name, dist, align)`.
#let parse-placement-spec(spec) = {
  if type(spec) == array {
    if spec.len() == 2 {
      let (el, dist) = spec
      (el, dist, "center")
    } else {
      spec
    }
  } else {
    (spec, 0, "center")
  }
}

/// Resolve a node width and height into CeTZ scalar coordinates.
///
/// If `relative-to` is given, ratio values are interpreted relative to that
/// element's size.
#let resolve-node-size(ctx, width, height, relative-to: none) = {
  let (width, height) = if relative-to != none and (type(width) == ratio or type(height) == ratio) {
    let con-size = util.get-element-size(ctx, relative-to)
    let width = if type(width) == ratio { float(width * con-size.at(0)) } else { width }
    let height = if type(height) == ratio { float(height * con-size.at(1)) } else { height }
    (width, height)
  } else {
    (width, height)
  }

  (
    cetz.util.resolve-number(ctx, width),
    cetz.util.resolve-number(ctx, height),
  )
}

/// Resolve an outer placement like `north-of` or `south-east-of`.
///
/// Returns a CeTZ coordinate expression that places a rectangle of the given
/// `width` and `height` next to the referenced element.
#let resolve-outer(ctx, dir, el, dist, align, width, height) = {
  let edge = dir.slice(0, -3)
  let (target-el, target-anchor) = util.split-explicit-anchor-ref(el)
  assert(
    target-anchor == none or align == "center",
    message: "alignment is not supported when outer placement uses an explicit anchor reference",
  )
  let edge-pt = if target-anchor == none {
    util.resolve-element-anchor(ctx, el, edge)
  } else {
    util.resolve-element-anchor(ctx, target-el, target-anchor)
  }

  let (dist-x, dist-y) = if type(dist) == array {
    dist
  } else {
    (dist, dist)
  }

  let align-offset = (0, 0, 0)
  if align != "center" {
    let el-size = util.get-element-size(ctx, target-el)
    if edge == "north" or edge == "south" {
      let off = width / 2 - el-size.at(0) / 2
      if align == "left" {
        align-offset = (off, 0, 0)
      } else if align == "right" {
        align-offset = (-off, 0, 0)
      }
    } else {
      let off = height / 2 - el-size.at(1) / 2
      if align == "bottom" {
        align-offset = (0, off, 0)
      } else if align == "top" {
        align-offset = (0, -off, 0)
      }
    }
  }

  let normal = if edge == "north" { (0, 1, 0) } else if edge == "south" { (0, -1, 0) } else if edge == "east" {
    (1, 0, 0)
  } else if edge == "west" { (-1, 0, 0) } else if edge == "north-east" { (1, 1, 0) } else if edge == "north-west" {
    (-1, 1, 0)
  } else if edge == "south-east" { (1, -1, 0) } else if edge == "south-west" { (-1, -1, 0) }

  let nx = normal.at(0)
  let ny = normal.at(1)
  let halfproj = calc.abs(nx) * (width / 2) + calc.abs(ny) * (height / 2)
  
  let shift-x = if edge.contains("-") { dist-x } else { dist-x + halfproj }
  let shift-y = if edge.contains("-") { dist-y } else { dist-y + halfproj }

  let (ax, ay) = if edge == "south-west" { (-width, -height) } else if edge == "south-east" { (0, -height) } else if (
    edge == "north-west"
  ) { (-width, 0) } else if edge == "north-east" { (0, 0) } else { (-width / 2, -height / 2) }

  let offset = cetz.vector.add(
    cetz.vector.add(
      (nx * shift-x, ny * shift-y, 0),
      align-offset,
    ),
    (ax, ay, 0),
  )
  (rel: offset, to: edge-pt)
}

/// Resolve an inner placement like `in-north` or `in-south-west`.
///
/// Returns `(origin, size)` for a rectangle placed inside the referenced
/// element.
#let resolve-inner(pos, el, dist, width, height) = {
  let (dist-x, dist-y) = if type(dist) == array {
    dist
  } else {
    (dist, dist)
  }

  let y-start = if pos.starts-with("in-north") {
    -height - dist-y
  } else if pos.starts-with("in-south") {
    dist-y
  } else {
    -height / 2
  }

  let x-start = if pos.ends-with("west") {
    dist-x
  } else if pos.ends-with("east") {
    -width - dist-x
  } else {
    -width / 2
  }

  (
    (rel: (x-start, y-start), to: el + "." + pos.slice(3)),
    (rel: (width, height)),
  )
}

/// Resolve the midpoint between two coordinates or named anchors.
#let resolve-between(ctx, el-a, el-b) = {
  let pt-a = cetz.coordinate.resolve(ctx, el-a).at(1)
  let pt-b = cetz.coordinate.resolve(ctx, el-b).at(1)
  cetz.vector.scale(cetz.vector.add(pt-a, pt-b), .5)
}

/// Return whether `c` is a nodes placement dictionary understood by this package.
#let is-node-placement(c) = {
  (
    type(c) == dictionary
      and c.len() == 1
      and {
        let dir = c.keys().first()
        dir in outer-coords or dir in inner-coords or dir == "between"
      }
  )
}

/// Rewrite nested placement dictionaries into plain CeTZ coordinates.
///
/// This enables nested coordinate expressions such as relative coordinates that
/// themselves point to placement dictionaries.
#let rewrite-node-origin(ctx, c, width, height) = {
  if is-node-placement(c) {
    let (dir, spec) = c.pairs().first()

    if dir in outer-coords {
      let (el, dist, align) = parse-placement-spec(spec)
      let dist = cetz.util.resolve-number(ctx, dist)
      let (width, height) = resolve-node-size(ctx, width, height)
      resolve-outer(ctx, dir, el, dist, align, width, height)
    } else if dir in inner-coords {
      let (el, dist, _) = parse-placement-spec(spec)
      let dist = cetz.util.resolve-number(ctx, dist)
      let (width, height) = resolve-node-size(ctx, width, height, relative-to: el)
      resolve-inner(dir, el, dist, width, height).at(0)
    } else {
      let (el-a, el-b) = spec
      let (width, height) = resolve-node-size(ctx, width, height)
      let mid = resolve-between(ctx, el-a, el-b)
      cetz.vector.add(mid, (-width / 2, -height / 2, 0))
    }
  } else if type(c) == dictionary {
    let mapped = (:)
    for (k, v) in c.pairs() {
      mapped.insert(k, rewrite-node-origin(ctx, v, width, height))
    }
    mapped
  } else if type(c) == array {
    c.map(v => rewrite-node-origin(ctx, v, width, height))
  } else {
    c
  }
}

/// Coordinate resolver registered by `nodes.canvas(...)`.
///
/// It teaches CeTZ how to interpret placement dictionaries directly as
/// coordinates.
#let resolve-node-coordinate(ctx, c) = {
  if type(c) != dictionary or c.len() != 1 {
    return c
  }

  let (dir, spec) = c.pairs().first()
  if dir in outer-coords {
    let (el, dist, align) = parse-placement-spec(spec)
    let dist = if type(dist) == array {
      dist.map(d => cetz.util.resolve-number(ctx, d))
    } else {
      cetz.util.resolve-number(ctx, dist)
    }
    resolve-outer(ctx, dir, el, dist, align, 0, 0)
  } else if dir in inner-coords {
    let (el, dist, _) = parse-placement-spec(spec)
    let dist = if type(dist) == array {
      dist.map(d => cetz.util.resolve-number(ctx, d))
    } else {
      cetz.util.resolve-number(ctx, dist)
    }
    resolve-inner(dir, el, dist, 0, 0).at(0)
  } else if dir == "between" {
    let (el-a, el-b) = spec
    resolve-between(ctx, el-a, el-b)
  } else {
    c
  }
}
