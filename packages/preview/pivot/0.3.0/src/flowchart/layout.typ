// layout: a validated graph -> ranked structure. Pure, no cetz. A DFS first marks
// back-edges (those closing a cycle) so they can be reversed just for ranking,
// keeping the ranking graph acyclic. Then longest-path ranking and a barycenter
// sweep that orders each rank to cut crossings. Edges are classified, not split:
//   direct — one rank down; drawn straight/orthogonally between the two nodes.
//   long   — more than one rank down; routed down a side channel by the renderer.
//   back   — a reversed cycle edge; routed up a side channel.
//   self   — a node onto itself; drawn as a small loop, outside the ranking graph.
// Only direct edges shape the ordering and (later) the coordinates — long and back
// edges keep clear of the body, so they don't distort the spine. One exception: a
// node with no direct edges at all (an unanchored feed) has no spine to distort,
// so it takes its ordering hint from its long-edge partners — placement will then
// align it over its corridor.
//
// Output: `cells` (one per node, with a `rank` and `order`) and `edges` (each with
// `from`, `to`, `label`, `kind`).

#let layout(graph) = {
  let nodes = graph.nodes
  let edges = graph.edges
  let ids = graph.ids
  let gpath = graph.at("gpath", default: (:))
  let n = nodes.len()
  if n == 0 { return (cells: (), edges: (), ranks: 0, groups: ()) }

  // --- cycle removal: DFS, mark edges that close back onto the current stack ---
  // Self-loops (a node onto itself — a retry/poll-in-place step) never enter the
  // ranking graph: they don't order or rank anything, and feeding one in stalls
  // the topological sort (a node can't lower its own in-degree). They are kept in
  // the edge list and drawn as a small self-return loop (kind "self", below).
  let succ-e = (:)
  for (ei, e) in edges.enumerate() {
    if e.from == e.to { continue }
    let u = str(ids.at(e.from))
    succ-e.insert(u, succ-e.at(u, default: ()) + ((v: ids.at(e.to), ei: ei),))
  }
  let color = range(n).map(_ => 0) // 0 white, 1 on-stack, 2 done
  let reversed = (:)
  for start in range(n) {
    if color.at(start) != 0 { continue }
    color.at(start) = 1
    let stack = ((node: start, si: 0),)
    while stack.len() > 0 {
      let ti = stack.len() - 1
      let top = stack.at(ti)
      let outs = succ-e.at(str(top.node), default: ())
      if top.si < outs.len() {
        stack.at(ti) = (node: top.node, si: top.si + 1)
        let nx = outs.at(top.si)
        if color.at(nx.v) == 1 {
          reversed.insert(str(nx.ei), true)
        } else if color.at(nx.v) == 0 {
          color.at(nx.v) = 1
          stack.push((node: nx.v, si: 0))
        }
      } else {
        color.at(top.node) = 2
        let _ = stack.pop()
      }
    }
  }

  // --- longest-path ranking on the DAG (back-edges reversed) ---
  let succ = (:)
  let indeg = (:)
  for i in range(n) { indeg.insert(str(i), 0) }
  for (ei, e) in edges.enumerate() {
    if e.from == e.to { continue }
    let (fu, tv) = if reversed.at(str(ei), default: false) {
      (ids.at(e.to), ids.at(e.from))
    } else {
      (ids.at(e.from), ids.at(e.to))
    }
    succ.insert(str(fu), succ.at(str(fu), default: ()) + (tv,))
    indeg.insert(str(tv), indeg.at(str(tv)) + 1)
  }
  let rank = range(n).map(_ => 0)
  let roots = range(n).filter(i => indeg.at(str(i)) == 0)
  let queue = roots
  while queue.len() > 0 {
    let u = queue.remove(0)
    for v in succ.at(str(u), default: ()) {
      rank.at(v) = calc.max(rank.at(v), rank.at(u) + 1)
      indeg.insert(str(v), indeg.at(str(v)) - 1)
      if indeg.at(str(v)) == 0 { queue.push(v) }
    }
  }
  // Take up the slack: longest-path ranking pins every source to the top,
  // even one whose first consumer sits layers below — its edge then runs the
  // whole height of the chart. A source holds nothing up, so it sinks to one
  // layer above its nearest consumer (min over children), the way dot and
  // dagre minimise edge length. Nothing else has slack — every ranked
  // non-source sits tight against its deepest parent — so one pass over the
  // sources settles it, and no edge can invert (a source's children keep
  // their ranks). The top layer never empties: some node has only source
  // parents, and that node's parents stay put.
  for i in roots {
    let cs = succ.at(str(i), default: ())
    if cs.len() > 0 {
      rank.at(i) = calc.min(..cs.map(v => rank.at(v))) - 1
    }
  }
  let ranks = calc.max(..rank) + 1

  // --- classify edges; only direct (one-rank) edges feed the ordering ---
  let up = (:)
  let down = (:)
  let lpart = (:) // long-edge partners, the ordering fallback for unanchored nodes
  let epaths = ()
  for (ei, e) in edges.enumerate() {
    let u = ids.at(e.from)
    let v = ids.at(e.to)
    let kind = if e.from == e.to {
      // A self-loop: no rank relation, drawn as a small loop on the node.
      "self"
    } else if reversed.at(str(ei), default: false) {
      "back"
    } else if rank.at(v) - rank.at(u) == 1 {
      down.insert(str(u), down.at(str(u), default: ()) + (v,))
      up.insert(str(v), up.at(str(v), default: ()) + (u,))
      "direct"
    } else {
      lpart.insert(str(u), lpart.at(str(u), default: ()) + (v,))
      lpart.insert(str(v), lpart.at(str(v), default: ()) + (u,))
      "long"
    }
    epaths.push((
      from: u,
      to: v,
      label: e.label,
      label-offset: e.at("label-offset", default: none),
      kind: kind,
    ))
  }

  // --- order within ranks: initial declaration order, then barycenter sweeps ---
  // Grouped nodes start clustered (stable within a cluster), so the sweeps
  // begin from contiguous blocks; an ungrouped diagram is untouched.
  let gkey = i => ("",) + gpath.at(str(i), default: ())
  let order-in-rank = range(ranks).map(r => range(n)
    .filter(i => rank.at(i) == r)
    .sorted(key: i => gkey(i).join("/")))
  let posx = (:)
  for r in range(ranks) {
    for (k, i) in order-in-rank.at(r).enumerate() { posx.insert(str(i), k) }
  }
  // Group-aware ordering: a rank's units are its loose nodes and the groups
  // present in it; a group moves as one block keyed by its members' mean
  // barycenter, recursively for nested groups. A loose node's key is its own
  // barycenter and a block's members all share the block key, so an outsider
  // can never interleave a group — same-group nodes stay contiguous in every
  // rank. With no groups every unit is a lone node and this is exactly the
  // old flat stable sort.
  let hsort = (self, its, level) => {
    let units = ()
    let bygroup = (:)
    let gorder = ()
    for it in its {
      let p = gpath.at(str(it.i), default: ())
      if p.len() > level {
        let gid = p.at(level)
        if gid not in bygroup { gorder.push(gid) }
        bygroup.insert(gid, bygroup.at(gid, default: ()) + (it,))
      } else {
        units.push((key: it.bc, group: none, items: (it,)))
      }
    }
    for gid in gorder {
      let gits = bygroup.at(gid)
      units.push((
        key: gits.map(x => x.bc).sum() / gits.len(),
        group: gid,
        items: gits,
      ))
    }
    let out = ()
    for u in units.sorted(key: u => u.key) {
      out += if u.group == none { u.items } else {
        self(self, u.items, level + 1)
      }
    }
    out
  }
  for iter in range(6) {
    let downward = calc.rem(iter, 2) == 0
    let rseq = if downward {
      range(1, ranks)
    } else {
      range(ranks - 2, -1, step: -1)
    }
    for r in rseq {
      let adj = if downward { up } else { down }
      let scored = order-in-rank
        .at(r)
        .map(i => {
          let nb = adj.at(str(i), default: ())
          let bc = if nb.len() > 0 {
            nb.map(j => posx.at(str(j))).sum() / nb.len()
          } else if (
            str(i) not in up
              and str(i) not in down
              and lpart.at(str(i), default: ()).len() == 1
          ) {
            // No direct edges and exactly one long edge: order this unanchored
            // node by that partner, so it starts on the side placement will
            // align it to. Strictly one — seating a several-edged feed between
            // its targets puts its corridor between them too, and the targets'
            // widen-to-entry rule then fights across it without settling.
            posx.at(str(lpart.at(str(i)).at(0)))
          } else {
            posx.at(str(i))
          }
          (i: i, bc: bc)
        })
      let sorted = hsort(hsort, scored, 0)
      order-in-rank.at(r) = sorted.map(s => s.i)
      for (k, s) in sorted.enumerate() { posx.insert(str(s.i), k) }
    }
  }

  let order = (:)
  for r in range(ranks) {
    for (k, i) in order-in-rank.at(r).enumerate() { order.insert(str(i), k) }
  }
  let out-cells = nodes.map(nd => (
    index: nd.index,
    rank: rank.at(nd.index),
    order: order.at(str(nd.index)),
    id: nd.id,
    label: nd.label,
    shape: nd.shape,
    fill: nd.fill,
    outline: nd.outline,
    gpath: gpath.at(str(nd.index), default: ()),
  ))

  (
    cells: out-cells,
    edges: epaths,
    ranks: ranks,
    groups: graph.at("groups", default: ()),
  )
}
