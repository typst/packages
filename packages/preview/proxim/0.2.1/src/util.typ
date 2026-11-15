#import "@preview/cetz:0.5.2"

#let explicit-anchors = (
  "north",
  "south",
  "west",
  "east",
  "north-west",
  "north-east",
  "south-west",
  "south-east",
)

/// Debug helper that materializes `body` as a label containing its `repr(...)`.
///
/// This is mainly useful while developing the package itself.
#let warn(body) = {
  let my-message = [#(label(repr(body)))]
}

#let nodes-canvas-key = "__nodes_canvas__"

#let _with-anchor(name, anchor) = {
  if type(name) != str or not name.contains(".") {
    return (name: name, anchor: anchor)
  }

  let (root, ..nested) = name.split(".")
  let anchor = if type(anchor) == array {
    nested + anchor
  } else {
    nested + (anchor,)
  }
  (name: root, anchor: anchor)
}

/// Split a `"name.anchor"` reference into `(name, anchor)`.
///
/// If `name` does not end in a recognized anchor suffix, return `(name, none)`.
#let split-explicit-anchor-ref(name) = {
  if type(name) != str {
    return (name, none)
  }

  for anchor in explicit-anchors {
    let suffix = "." + anchor
    if name.ends-with(suffix) {
      return (name.slice(0, -suffix.len()), anchor)
    }
  }

  (name, none)
}

#let has-explicit-anchor-ref(name) = split-explicit-anchor-ref(name).at(1) != none

/// Assert that the current CeTZ context was created by `nodes.canvas(...)`.
///
/// Shared helpers that depend on the nodes coordinate resolver call this to
/// fail early with a clearer error message.
#let assert-nodes-canvas(ctx) = {
  assert(
    ctx.shared-state.at(nodes-canvas-key, default: false),
    message: "nodes.node and nodes.edge must be used inside nodes.canvas(...)",
  )
}

/// Resolve an anchor on a named element, including elements inside CeTZ groups.
#let resolve-element-anchor(ctx, name, anchor) = {
  cetz.coordinate.resolve(ctx, _with-anchor(name, anchor)).at(1)
}

/// Resolve the center point of a named element, including group-qualified names.
#let resolve-element-center(ctx, name) = {
  resolve-element-anchor(ctx, name, "center")
}

/// Resolve the border point of a named element in the direction of `toward`.
///
/// For plain top-level elements, preserve CeTZ's drawable-intersection behavior.
/// For group-qualified names like `group.el`, fall back to border-anchor
/// resolution because CeTZ does not expose the child element object directly.
#let resolve-element-border(ctx, name, toward) = {
  let center = resolve-element-center(ctx, name)

  if type(name) == str and not name.contains(".") {
    import cetz: intersection

    let elem = ctx.nodes.at(name, default: none)
    if elem != none {
      let (ta, tb) = cetz.util.apply-transform(ctx.transform, center, toward)

      let pts = ()
      for d in elem.at("drawables", default: ()).filter(d => d.type == "path") {
        pts += intersection.line-path(ta, tb, d)
      }

      if pts != () {
        let pt = cetz.util.sort-points-by-distance(tb, pts).first()
        return cetz.util.revert-transform(ctx.transform, pt)
      }
    }
  }

  let angle = calc.atan2(toward.at(0) - center.at(0), toward.at(1) - center.at(1))
  resolve-element-anchor(ctx, name, angle)
}

/// Return the axis-aligned size `(width, height, depth)` of a named CeTZ node.
///
/// The size is computed from the element's drawable bounds and is used by the
/// coordinate helpers when placing nodes relative to other elements.
#let get-element-size(ctx, name) = {
  let west = resolve-element-anchor(ctx, name, "west")
  let east = resolve-element-anchor(ctx, name, "east")
  let north = resolve-element-anchor(ctx, name, "north")
  let south = resolve-element-anchor(ctx, name, "south")

  (
    calc.abs(east.at(0) - west.at(0)),
    calc.abs(north.at(1) - south.at(1)),
    0,
  )
}
