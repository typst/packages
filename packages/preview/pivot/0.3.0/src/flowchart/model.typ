// model: mixed node/edge/group descriptors -> a validated graph. Pure, no cetz.
// Splits the argument list, checks each node id is unique, each edge references
// declared nodes, and each group forms a tree over already-declared members —
// naming the offender on bad input.
// Returns (nodes, edges, ids, groups, gpath) — `ids` maps a node id to its
// position in `nodes`; `groups` carries each group's style, member node
// indices (transitive) and nesting depth; `gpath` maps a node index (as str)
// to its chain of enclosing group ids, outermost first.

#let shapes = ("rounded", "rectangle", "diamond", "parallelogram", "cylinder")
#let group-strokes = ("solid", "dashed", "dotted")

#let model(items) = {
  let nodes = ()
  let edges = ()
  let ids = (:)
  let groups = ()
  let gids = (:) // group id -> index in `groups`
  let parent = (:) // member id (node or group) -> enclosing group id
  for (i, it) in items.enumerate() {
    assert(
      type(it) == dictionary
        and it.at("kind", default: none) in ("node", "edge", "group"),
      message: "flowchart: argument "
        + str(i)
        + " is not a node(), edge() or group()",
    )
    if it.kind == "group" {
      assert(
        it.id not in ids and it.id not in gids,
        message: "flowchart: duplicate id " + repr(it.id) + " (group)",
      )
      assert(
        type(it.stroke) != str or it.stroke in group-strokes,
        message: "group "
          + repr(it.id)
          + ": stroke must be one of "
          + group-strokes.join(", ")
          + ", or a Typst stroke",
      )
      let bc = it.at("border-color", default: none)
      assert(
        bc == none or type(bc) == color,
        message: "group " + repr(it.id) + ": border-color must be a colour",
      )
      // A full-stroke `stroke:` carries its own paint, so it can't also take a
      // separate border-color — use a keyword stroke, or fold the colour into
      // the full stroke.
      assert(
        bc == none or type(it.stroke) == str,
        message: "group "
          + repr(it.id)
          + ": set `border-color:` with a keyword `stroke:`, or a full "
          + "stroke — not both",
      )
      for m in it.members {
        // Members must already be declared — an inner group before the outer
        // that names it — which also makes membership cycles impossible.
        assert(
          m in ids or m in gids,
          message: "group "
            + repr(it.id)
            + ": member "
            + repr(m)
            + " is not a declared node or group",
        )
        assert(
          m not in parent,
          message: "group "
            + repr(it.id)
            + ": member "
            + repr(m)
            + " is already in group "
            + repr(parent.at(m, default: none)),
        )
        parent.insert(m, it.id)
      }
      gids.insert(it.id, groups.len())
      groups.push((
        id: it.id,
        title: it.title,
        stroke: it.stroke,
        border-color: bc,
        fill: it.fill,
        members: it.members,
      ))
      continue
    }
    if it.kind == "node" {
      assert(
        it.id not in ids,
        message: "flowchart: duplicate node id " + repr(it.id),
      )
      assert(
        shapes.contains(it.shape),
        message: "node "
          + repr(it.id)
          + ": shape must be one of "
          + shapes.join(", "),
      )
      // `outline` is the fill-less alternative to `fill`: a colour on the
      // border and the text, no fill. The two are mutually exclusive.
      let ol = it.at("outline", default: none)
      assert(
        ol == none or type(ol) == color,
        message: "node " + repr(it.id) + ": outline must be a colour",
      )
      assert(
        it.fill == none or ol == none,
        message: "node " + repr(it.id) + ": set fill: or outline:, not both",
      )
      ids.insert(it.id, nodes.len())
      nodes.push((
        index: nodes.len(),
        id: it.id,
        label: it.label,
        shape: it.shape,
        fill: it.fill,
        outline: ol,
      ))
    } else {
      assert(
        it.from in ids,
        message: "flowchart: edge references unknown node " + repr(it.from),
      )
      assert(
        it.to in ids,
        message: "flowchart: edge references unknown node " + repr(it.to),
      )
      let lo = it.at("label-offset", default: none)
      assert(
        lo == none
          or (
            type(lo) == array
              and lo.len() == 2
              and lo.all(v => type(v) == length)
          ),
        message: "flowchart: edge "
          + repr(it.from)
          + " -> "
          + repr(it.to)
          + ": label-offset must be an (x, y) pair of lengths",
      )
      edges.push((
        from: it.from,
        to: it.to,
        label: it.label,
        label-offset: lo,
      ))
    }
  }
  // Each group's chain of enclosing groups, outermost first (members were
  // declared before their group, so a parent is always later in `groups` and
  // the upward walk terminates).
  let chain = id => {
    let path = ()
    let cur = id
    while cur in parent {
      cur = parent.at(cur)
      path.insert(0, cur)
    }
    path
  }
  // Per-node enclosure path, then each group's transitive node members and
  // nesting depth — geometry (layout order, hull extents) reads these.
  let gpath = (:)
  for nd in nodes { gpath.insert(str(nd.index), chain(nd.id)) }
  for (gi, g) in groups.enumerate() {
    let path = chain(g.id)
    groups.at(gi).insert("depth", path.len())
    groups
      .at(gi)
      .insert(
        "nodes",
        nodes
          .filter(nd => gpath.at(str(nd.index)).contains(g.id))
          .map(nd => nd.index),
      )
  }
  (nodes: nodes, edges: edges, ids: ids, groups: groups, gpath: gpath)
}
