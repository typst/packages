///! Laying primitives out into a guide.
///!
///! A primitive draws from its own edge outward and knows nothing about its
///! neighbours. A composition is what gives each one an edge to draw from: it
///! measures the children in order, stacks them away from the panel, and hands
///! each a context whose `place` is pushed out past everything before it.
///!
///! Measuring and drawing read the same layout record, so the room a guide
///! reserves and the ink it puts down cannot drift apart. That is the failure
///! the legend renderer guards against today with paired comments, and the
///! record makes it structural instead.
///!
///! Entries flow down. A composition resolves its own table once and passes it
///! to every child that did not bring one, which is what lets a stack of ticks
///! and labels share a single set of breaks.

#import "../utils/errors.typ": check, fail-enum, fail-type
#import "entry.typ": resolve-entries
#import "primitive/common.typ": PRIMITIVE, measured
#import "primitive/registry.typ" as registry

// Tag a composition carries, so a parent can tell one from a primitive.
#let COMPOSITION = "composition"

// Children stack away from the panel, in the order given: the first sits
// against the panel edge and each later one clears those before it.
//
// `spacing` is the gap between neighbours, in centimetres; `auto` takes the
// context's tick gap, which is what separates a tick row from its labels today.
#let compose-stack(..children, entries: auto, spacing: auto) = {
  let kids = children.pos()
  check(
    kids.len() > 0,
    "guide-compose",
    "a stack needs at least one child",
    hint: "Pass the primitives to stack as positional arguments.",
  )
  for (i, c) in kids.enumerate() {
    if (
      type(c) != dictionary
        or c.at("kind", default: none)
          not in (
            PRIMITIVE,
            COMPOSITION,
          )
    ) {
      fail-type(
        "guide-compose",
        "child " + str(i),
        c,
        "a primitive or a composition",
      )
    }
  }
  (
    kind: COMPOSITION,
    name: "stack",
    children: kids,
    entries: entries,
    spacing: spacing,
  )
}

// Push a resolved entry table down to every child that did not bring one.
// Mirrors the rule that a shared table reaches only children whose own table is
// still `auto`, so a child can always override its parent.
#let train(node, inherited: auto) = {
  if type(node) != dictionary { return node }
  if node.at("kind", default: none) != COMPOSITION {
    let own = node.at("entries", default: auto)
    // A leaf resolves its own spec here too, so a closure is as legal on a
    // primitive as it is on the composition above it.
    if own != auto {
      return (..node, entries: resolve-entries(own, scope: "guide-compose"))
    }
    if inherited != auto { return (..node, entries: inherited) }
    return node
  }
  let own = node.at("entries", default: auto)
  let table = if own != auto {
    resolve-entries(own, scope: "guide-compose")
  } else {
    inherited
  }
  (
    ..node,
    entries: table,
    children: node.children.map(c => train(c, inherited: table)),
  )
}

// Room one child needs, whether it is a primitive or a nested composition, and
// the nested layout when there is one. The nested record is kept so the draw
// pass reads it back rather than measuring the subtree a second time.
//
// `layout-of` arrives as an argument because it is defined below this helper
// and Typst resolves a binding only after it is bound.
#let _measure-child(child, gctx, layout-of) = {
  if child.at("kind", default: none) == COMPOSITION {
    let inner = layout-of(child, gctx)
    (
      measure: measured(
        across: inner.across,
        along: inner.along,
        fills: inner.fills,
        near: inner.reach.near,
        far: inner.reach.far,
      ),
      layout: inner,
    )
  } else {
    (
      measure: registry.measure(
        child,
        gctx,
        entries: child.at("entries", default: auto),
      ),
      layout: none,
    )
  }
}

// The gap a stack puts between neighbours.
#let _spacing-of(node, gctx) = {
  let given = node.at("spacing", default: auto)
  if given != auto { return given }
  gctx.at("tick-gap", default: 0.0)
}

// Whether a child is a spacer that is owed only when the stack takes room.
#let _is-owed(child) = (
  child.at("kind", default: none) == PRIMITIVE
    and child.at("name", default: none) == "spacer"
    and child.at("owed", default: false)
)

// Measure the whole tree into one record.
//
// `cells` carries one entry per child, in draw order, each with the depth it
// occupies and the offset it starts at. The draw pass reads these back rather
// than recomputing them, so the two agree by construction.
//
// A child that reserves nothing takes no offset and no gap: an axis with its
// ticks blanked puts its labels where the ticks would have started, which is
// how a stripped axis keeps the room today.
#let layout-of(node, gctx) = {
  if type(node) != dictionary or node.at("kind", default: none) != COMPOSITION {
    fail-type("guide-compose", "node", node, "a composition")
  }
  if node.name != "stack" {
    fail-enum("guide-compose", "composition", node.name, ("stack",))
  }
  let gap = _spacing-of(node, gctx)
  // An owed spacer belongs to the band rather than to a neighbour, so it is
  // decided from what the rest of the stack reserved rather than from what sits
  // beside it. That is the gap an axis holds its labels off the panel edge by.
  //
  // Deciding it costs a pass over the children, so a stack without one, which is
  // every legend, never pays for it.
  let owes = node.children.any(_is-owed)
  let band = (
    owes
      and node.children.any(child => (
        not _is-owed(child)
          and _measure-child(child, gctx, layout-of).measure.across > 0.0
      ))
  )
  let cells = ()
  let offset = 0.0
  let along = 0.0
  let fills = false
  let near = 0.0
  let far = 0.0
  for child in node.children {
    let (measure: m, layout: inner) = _measure-child(child, gctx, layout-of)
    if _is-owed(child) and not band { m = measured() }
    let empty = m.across == 0.0 and not m.fills and m.along == 0.0
    if empty {
      cells.push((
        child: child,
        measure: m,
        layout: inner,
        off-across: offset,
        drawn: false,
      ))
      continue
    }
    // The gap separates depth from depth, so it is owed only when something
    // before this child reserved some and this child reserves some too. A spine
    // draws on the panel edge without any thickness of its own, so the ticks
    // after it still start on that edge rather than floating a gap out.
    let start = if offset > 0.0 and m.across > 0.0 { offset + gap } else {
      offset
    }
    cells.push((
      child: child,
      measure: m,
      layout: inner,
      off-across: start,
      drawn: true,
    ))
    offset = start + m.across
    along = calc.max(along, m.along)
    fills = fills or m.fills
    near = calc.max(near, m.reach.near)
    far = calc.max(far, m.reach.far)
  }
  (
    across: offset,
    along: along,
    fills: fills,
    reach: (near: near, far: far),
    cells: cells,
  )
}

// Whether a guide is built from a part of this name, at any depth.
//
// A stage outside the guide layer asks this when the ink a part puts down costs
// room of its own: the chrome stage reserves the `legend-bar` outset for a
// guide that paints a bar. Asking the tree is what keeps that reservation on
// the same footing as the rest, which all reads the record rather than the kind
// of guide it came from.
#let has-part(node, name) = {
  if type(node) != dictionary { return false }
  if node.at("kind", default: none) != COMPOSITION {
    return node.at("name", default: none) == name
  }
  node.children.any(child => has-part(child, name))
}

// The room one named part of a laid-out guide takes.
//
// A guide that reserves its band whole reads `across` and never needs this. A
// radial one does: its circle gives up radius for the tick weights alone,
// because the labels that ring it are solved per angle rather than as one band.
#let part-across(layout, name) = {
  for cell in layout.cells {
    if cell.child.at("name", default: none) == name {
      return cell.measure.across
    }
  }
  0.0
}

// Draw the tree, each child from the edge the layout gave it.
//
// `layout` is the record `layout-of` returned for this same node and context.
// Passing it in rather than recomputing is what keeps the ink inside the room
// that was reserved for it.
#let draw(node, gctx, layout) = {
  // The record has to be the one this node produced, or the ink lands outside
  // the room that was reserved for it.
  check(
    layout.cells.len() == node.children.len(),
    "guide-compose",
    "the layout has "
      + str(layout.cells.len())
      + " cells for "
      + str(node.children.len())
      + " children",
    hint: "Pass the record `layout-of` returned for this same node.",
  )
  let place = gctx.at("place", default: none)
  if place == none { return }
  for cell in layout.cells {
    if not cell.drawn { continue }
    let lead = cell.off-across
    let shifted = (
      ..gctx,
      place: (frac, across) => place(frac, across + lead),
    )
    let child = cell.child
    if child.at("kind", default: none) == COMPOSITION {
      draw(child, shifted, cell.layout)
    } else {
      registry.draw(child, shifted, entries: child.at("entries", default: auto))
    }
  }
}
