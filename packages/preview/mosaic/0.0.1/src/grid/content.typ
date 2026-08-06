// Slide-content routing for canonical grid trees.
#import "../shared.typ": fail
#import "traversal.typ": resolve-cell-ids, fold-grid

// The IDs of every content-bearing cell (content == none), in the same
// depth-first declaration order that positional bodies fill. This is the
// single ordered destination list; named content is normalized against it.
#let body-cell-ids(node) = fold-grid(
  node,
  cell => if cell.content == none { (cell.id,) } else { () },
  (node, child) => child,
  (node, children) => children.flatten(),
)

// Resolve a slide's content into one id -> content map, the single internal
// representation the renderer consumes. Setup defaults are fallbacks for
// content-bearing cells that exist in this resolved grid. Named slide content
// overrides those defaults; `none` explicitly suppresses one. Positional bodies
// may either fill every cell (the full override form) or the leading cells not
// already satisfied by defaults. Any omitted content-bearing cell becomes [].
//
// `none` means "suppress", so suppressing a cell this layout does not have is
// already true and resolves to a no-op. That matches a setup-level default for
// an absent cell, which is likewise ignored, and it lets one slide say
// `footer: none` across layouts that do not all carry a footer. Any non-`none`
// value for an unknown id is still an error: there the author is supplying
// content that would silently vanish.
#let resolve-content(node, named, bodies, defaults: (:)) = {
  let body-ids = body-cell-ids(node)
  let inherited = (:)
  for id in body-ids {
    if id in defaults {
      let value = defaults.at(id)
      inherited.insert(id, if value == none { [] } else { value })
    }
  }
  if named.len() > 0 {
    let all-ids = resolve-cell-ids(node)
    let explicit = (:)
    for (id, value) in named {
      if id not in all-ids {
        if value == none { continue }
        fail("slide cells contains unknown cell id " + repr(id))
      }
      // A fixed-content cell is a different case: the cell does exist, so
      // `none` there reads as "blank it", which the layout cannot honor.
      // Keeping the error surfaces that rather than silently ignoring it.
      if id not in body-ids {
        fail("slide cells cannot supply fixed-content cell " + repr(id))
      }
      if value != none and type(value) != content {
        fail("slide cells for " + repr(id) + " must be content or none")
      }
      explicit.insert(id, if value == none { [] } else { value })
    }
    let resolved = inherited + explicit
    for id in body-ids {
      if id not in resolved {
        resolved.insert(id, [])
      }
    }
    resolved
  } else {
    let destination-ids = if bodies.len() == body-ids.len() {
      body-ids
    } else {
      body-ids.filter(id => id not in inherited)
    }
    if bodies.len() > destination-ids.len() {
      if inherited.len() == 0 {
        fail(
          "grid expects " + str(body-ids.len())
            + " bodies, received " + str(bodies.len()),
        )
      }
      fail(
        "grid expects " + str(destination-ids.len())
          + " bodies with setup defaults or " + str(body-ids.len())
          + " bodies to override them, received " + str(bodies.len()),
      )
    }
    let resolved = if destination-ids.len() == body-ids.len() { (:) } else { inherited }
    for (index, id) in destination-ids.enumerate() {
      resolved.insert(id, bodies.at(index, default: []))
    }
    resolved
  }
}
