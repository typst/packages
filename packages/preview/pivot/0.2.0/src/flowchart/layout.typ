// layout: a validated graph -> ranked structure. Pure, no cetz. A DFS first marks
// back-edges (those closing a cycle) so they can be reversed just for ranking,
// keeping the ranking graph acyclic. Then longest-path ranking and a barycenter
// sweep that orders each rank to cut crossings. Edges are classified, not split:
//   direct — one rank down; drawn straight/orthogonally between the two nodes.
//   long   — more than one rank down; routed down a side channel by the renderer.
//   back   — a reversed cycle edge; routed up a side channel.
// Only direct edges shape the ordering and (later) the coordinates — long and back
// edges keep clear of the body, so they don't distort the spine.
//
// Output: `cells` (one per node, with a `rank` and `order`) and `edges` (each with
// `from`, `to`, `label`, `kind`).

#let layout(graph) = {
  let nodes = graph.nodes
  let edges = graph.edges
  let ids = graph.ids
  let n = nodes.len()
  if n == 0 { return (cells: (), edges: (), ranks: 0) }

  // --- cycle removal: DFS, mark edges that close back onto the current stack ---
  let succ-e = (:)
  for (ei, e) in edges.enumerate() {
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
    let (fu, tv) = if reversed.at(str(ei), default: false) {
      (ids.at(e.to), ids.at(e.from))
    } else {
      (ids.at(e.from), ids.at(e.to))
    }
    succ.insert(str(fu), succ.at(str(fu), default: ()) + (tv,))
    indeg.insert(str(tv), indeg.at(str(tv)) + 1)
  }
  let rank = range(n).map(_ => 0)
  let queue = range(n).filter(i => indeg.at(str(i)) == 0)
  while queue.len() > 0 {
    let u = queue.remove(0)
    for v in succ.at(str(u), default: ()) {
      rank.at(v) = calc.max(rank.at(v), rank.at(u) + 1)
      indeg.insert(str(v), indeg.at(str(v)) - 1)
      if indeg.at(str(v)) == 0 { queue.push(v) }
    }
  }
  let ranks = calc.max(..rank) + 1

  // --- classify edges; only direct (one-rank) edges feed the ordering ---
  let up = (:)
  let down = (:)
  let epaths = ()
  for (ei, e) in edges.enumerate() {
    let u = ids.at(e.from)
    let v = ids.at(e.to)
    let kind = if reversed.at(str(ei), default: false) {
      "back"
    } else if rank.at(v) - rank.at(u) == 1 {
      down.insert(str(u), down.at(str(u), default: ()) + (v,))
      up.insert(str(v), up.at(str(v), default: ()) + (u,))
      "direct"
    } else {
      "long"
    }
    epaths.push((from: u, to: v, label: e.label, kind: kind))
  }

  // --- order within ranks: initial declaration order, then barycenter sweeps ---
  let order-in-rank = range(ranks).map(r => range(n).filter(i => (
    rank.at(i) == r
  )))
  let posx = (:)
  for r in range(ranks) {
    for (k, i) in order-in-rank.at(r).enumerate() { posx.insert(str(i), k) }
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
          } else {
            posx.at(str(i))
          }
          (i: i, bc: bc)
        })
      let sorted = scored.sorted(key: s => s.bc)
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
  ))

  (cells: out-cells, edges: epaths, ranks: ranks)
}
