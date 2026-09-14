#import "utility.typ": is-node, is-edge, is-content, is-coord, split-direction

/// Places arbitrary content at diagram coordinates `(x, y)` — e.g. a label,
/// a "⋯" leg-count marker, or a caption. Exported as `typ.place` by the
/// package facade.
#let place-item(x, y, body, align: center + horizon) = {
  assert(type(x) in (int, float) and type(y) in (int, float), message: "place coordinates must be numbers")
  assert(type(align) == alignment, message: "place align must be an alignment")
  assert(
    align.x in (none, left, center, right)
      and align.y in (none, top, horizon, bottom),
    message: "place align must use physical left/center/right and top/horizon/bottom; start/end depend on text direction",
  )
  (
    (type: "content", x: x, y: y, body: body, align: align),
  )
}

/// Repositions (and optionally resizes/reorients) a fragment of
/// already-built items (nodes/edges/content) — the tool for reusing a motif
/// across a document.
///
/// A fragment is just a value, so you can name one and re-place it as often
/// as you like; `group()` accepts fragments as well as raw blocks, and
/// composes with itself:
///
/// ```typc
/// #import "@preview/typograph:0.2.1" as typ
/// let motif = {                     // define once...
///   let a = typ.box(0, 0, [A])
///   let b = typ.box(0, 1, [B])
///   typ.edge(a, b)
/// }
/// typ.diagram({
///   typ.group(motif)                        // ...place as-is
///   typ.group(dx: 2, scale: 0.6, motif)     // ...or moved and shrunk
/// })
/// ```
///
/// `scale` resizes node shapes and their label text (about `pivot`) as
/// well as repositioning everything — a motif built at a comfortable
/// working size still looks right when stamped down smaller. `rotate`
/// turns positions, edge geometry, and deferred port directions about
/// `pivot`, but leaves node
/// shapes/labels and `place()` content upright so they stay readable; give
/// affected nodes a `style: (rotate: ..)` if their shapes should follow too.
#let group(dx: 0, dy: 0, scale: 1, rotate: 0deg, pivot: (0, 0), ..items) = {
  assert(items.named().len() == 0, message: "unexpected named argument(s): " + repr(items.named()))
  assert(type(dx) in (int, float) and type(dy) in (int, float), message: "group dx/dy must be numbers")
  assert(is-coord(pivot), message: "group pivot must be a numeric (x, y) coordinate")
  assert(type(scale) in (int, float) and scale > 0, message: "group scale must be a positive number")
  assert(type(rotate) == angle, message: "group rotate must be an angle")
  let items = items.pos().flatten()
  if dx == 0 and dy == 0 and scale == 1 and rotate == 0deg { return items }

  // One affine transform per group. Computing sin/cos inside every point
  // transformation was measurable for large rotated fragments.
  let cosine = calc.cos(rotate)
  let sine = calc.sin(rotate)
  let a = scale * cosine
  let b = -scale * sine
  let c = scale * sine
  let d = scale * cosine
  let (pivot-x, pivot-y) = pivot
  let translate-x = pivot-x - a * pivot-x - b * pivot-y + dx
  let translate-y = pivot-y - c * pivot-x - d * pivot-y + dy
  let transform(point) = (
    a * point.at(0) + b * point.at(1) + translate-x,
    c * point.at(0) + d * point.at(1) + translate-y,
  )
  let transform-vector(vector) = (
    a * vector.at(0) + b * vector.at(1),
    c * vector.at(0) + d * vector.at(1),
  )
  let transform-direction(direction) = {
    if direction == auto { return auto }
    let (angle, strength) = split-direction(direction)
    (angle + rotate, strength * scale)
  }
  let transform-node(node) = {
    let point = transform((node.x, node.y))
    node.x = point.at(0)
    node.y = point.at(1)
    node.size-scale *= scale
    node
  }

  items.map(it => {
    if is-node(it) {
      // Gate ports need nothing here: they are derived from the rendered box
      // at layout time, so scaling `size-scale` already carries them along.
      transform-node(it)
    } else if is-content(it) {
      let p = transform((it.x, it.y))
      it.x = p.at(0)
      it.y = p.at(1)
      it
    } else if is-edge(it) {
      it.size-scale = it.size-scale * scale
      // These curve controls are resolved after grouping, so carry the affine
      // transform in their compact parameters just as explicit control points
      // below carry it in their coordinates.
      it.bend *= scale
      it.from = transform-direction(it.from)
      it.to = transform-direction(it.to)
      it.waypoints = it.waypoints.map(wp => {
        // Any node the waypoint carries has to move with the group, so that
        // layout-time lookups against the emitted copies — a port's box
        // outline, a boundary clip — still find it.
        let source-node = wp.node
        let source-clip = wp.clip-to
        if source-node != none {
          wp.node = transform-node(source-node)
        }
        if source-clip != none {
          wp.clip-to = if source-node != none and source-clip == source-node {
            wp.node
          } else {
            transform-node(source-clip)
          }
        }
        if wp.defer != none {
          // Controls are absolute geometry even when the segment endpoint is
          // deferred. Transform them before the deferred branch returns.
          if wp.ctrl != none and wp.ctrl != auto {
            wp.ctrl = wp.ctrl.map(transform)
          }
          if wp.defer.type == "rel" {
            // An offset is a direction and a length: it scales and rotates,
            // but must not be translated.
            let vector = transform-vector((wp.defer.dx, wp.defer.dy))
            wp.defer.dx = vector.at(0)
            wp.defer.dy = vector.at(1)
          } else if wp.defer.type == "port" {
            // The port holds its own handle on the gate; keep it in step.
            wp.defer.node = wp.node
            wp.defer.rotate = wp.defer.at("rotate", default: 0deg) + rotate
          }
          // `ref` needs nothing: it resolves by name, and the node it names
          // is transformed as an item in its own right.
          return wp
        }
        wp.end = transform(wp.end)
        if wp.ctrl != none and wp.ctrl != auto { wp.ctrl = wp.ctrl.map(transform) }
        wp
      })
      it
    } else {
      it
    }
  })
}
