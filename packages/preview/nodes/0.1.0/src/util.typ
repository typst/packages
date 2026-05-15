#import "@preview/cetz:0.4.2"

/// Debug helper that materializes `body` as a label containing its `repr(...)`.
///
/// This is mainly useful while developing the package itself.
#let warn(body) = {
  let my-message = [#(label(repr(body)))]
}

#let nodes-canvas-key = "__nodes_canvas__"

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

/// Return the axis-aligned size `(width, height, depth)` of a named CeTZ node.
///
/// The size is computed from the element's drawable bounds and is used by the
/// coordinate helpers when placing nodes relative to other elements.
#let get-element-size(ctx, name) = {
  import cetz: drawable, path-util

  let element = ctx.nodes.at(name)
  let min-pt = (calc.inf, calc.inf, calc.inf)
  let max-pt = (-calc.inf, -calc.inf, -calc.inf)

  for drawable in drawable.filter-tagged(element.drawables, drawable.TAG.no-bounds) {
    if drawable.type == "path" {
      for pt in path-util.bounds(drawable.segments) {
        min-pt = (
          calc.min(min-pt.at(0), pt.at(0)),
          calc.min(min-pt.at(1), pt.at(1)),
          calc.min(min-pt.at(2), pt.at(2)),
        )
        max-pt = (
          calc.max(max-pt.at(0), pt.at(0)),
          calc.max(max-pt.at(1), pt.at(1)),
          calc.max(max-pt.at(2), pt.at(2)),
        )
      }
    } else if drawable.type == "content" {
      let (x, y, _, w, h) = drawable.pos + (drawable.width, drawable.height)
      let corners = (
        (x + w / 2, y - h / 2, 0.0),
        (x - w / 2, y + h / 2, 0.0),
      )
      for pt in corners {
        min-pt = (
          calc.min(min-pt.at(0), pt.at(0)),
          calc.min(min-pt.at(1), pt.at(1)),
          calc.min(min-pt.at(2), pt.at(2)),
        )
        max-pt = (
          calc.max(max-pt.at(0), pt.at(0)),
          calc.max(max-pt.at(1), pt.at(1)),
          calc.max(max-pt.at(2), pt.at(2)),
        )
      }
    }
  }

  (
    calc.abs(max-pt.at(0) - min-pt.at(0)),
    calc.abs(max-pt.at(1) - min-pt.at(1)),
    calc.abs(max-pt.at(2) - min-pt.at(2)),
  )
}
