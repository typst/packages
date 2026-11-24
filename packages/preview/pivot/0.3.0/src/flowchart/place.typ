// place: measured cells -> coordinates. Pure, no cetz — the geometric half of the
// flowchart pipeline. `layout` fixes each node's rank and order; `place` turns
// measured sizes into positions — relaxing each rank toward a straight spine,
// widening a merge target to seat its inputs, choosing each long edge's corridor,
// and aligning an unanchored node (one with no direct edges) over its corridors —
// and `render` owns measurement and drawing, which need the document context.
//
// cells: one dict per node; reads index, rank, order, w, h, th, shape (extra keys
//        are the caller's and pass through untouched). Sizes are canvas units.
// edges: the classified edges from `layout` (from, to, kind).
// ranks: the rank count from `layout`.
// The token arguments are canvas-unit numbers from the theme; all are required.
//
// Returns dicts keyed by str(node index) — `x`, `y`, `w` (heights are the
// caller's) — plus `route` (per long-edge index: cx, side-ok, entry), `fanout`
// (direct children per node), `hulls` (per group id: the box rectangle and
// nesting depth), and `settled`: whether the widen loop reached its
// fixed point within the bound. If it didn't, widths may under-span their inputs;
// the renderer's shape-aware attach still lands every edge on an outline.

#import "crossing.typ": order-tracks, pair-cost

#let place(
  cells,
  edges,
  ranks,
  groups: (),
  // Per-edge label extent along the flow axis (dict str(edge index) ->
  // canvas units), measured by the renderer. Optional: a caller without
  // measurements gets today's gaps; with them, a gap grows to keep a
  // labelled line visible past its label.
  label-along: (:),
  node-gap: none,
  rank-gap: none,
  pad-x: none,
  back-margin: none,
  max-reach: none,
  widen-skew: none,
  edge-clearance: none,
  lane-gap: none,
  stub: none,
  margin-step: none,
  group-pad: none,
  title-room: none,
) = {
  for (name, v) in (
    ("node-gap", node-gap),
    ("rank-gap", rank-gap),
    ("pad-x", pad-x),
    ("back-margin", back-margin),
    ("max-reach", max-reach),
    ("widen-skew", widen-skew),
    ("edge-clearance", edge-clearance),
    ("lane-gap", lane-gap),
    ("stub", stub),
    ("margin-step", margin-step),
    ("group-pad", group-pad),
    ("title-room", title-room),
  ) {
    assert(v != none, message: "place: `" + name + "` is required")
  }
  if cells.len() == 0 {
    // The same contract as the main return: a caller reading any field must
    // never find it missing on the empty diagram.
    return (
      x: (:),
      y: (:),
      w: (:),
      route: (:),
      dseat: (:),
      dexit: (:),
      fanout: (:),
      hulls: (:),
      plan: (:),
      settled: true,
    )
  }
  // Groups with at least one (transitive) node member get geometry; an empty
  // group renders nothing. `gp` is each node's enclosure path.
  let live-groups = groups.filter(g => g.nodes.len() > 0)
  let gp = (:)
  for c in cells { gp.insert(str(c.index), c.at("gpath", default: ())) }
  let gspan = (:)
  for g in live-groups {
    let rs = g.nodes.map(a => cells.at(a).rank)
    gspan.insert(g.id, (calc.min(..rs), calc.max(..rs)))
  }
  // Whether input `s` sits in a box that excludes node `t` across t's own
  // rank — such a box's band is ground t may never occupy, so t must not
  // widen toward s (the arrow bends into a seat instead).
  let boxed-off = (t, s) => {
    let pt = gp.at(str(t), default: ())
    let tr = cells.at(t).rank
    gp
      .at(str(s), default: ())
      .any(gid => (
        not pt.contains(gid)
          and {
            let sp = gspan.at(gid, default: none)
            sp != none and tr >= sp.at(0) and tr <= sp.at(1)
          }
      ))
  }
  // A group's horizontal band under the current positions: member nodes and
  // child bands wrapped with `group-pad` — and never narrower than its
  // measured title (`tw`, supplied by the renderer), so a long name can't
  // overflow its box. This mirrors the hull computation exactly (children
  // recursively, then pad, then the title minimum), and one helper feeds the
  // push-out sweep and the corridor obstacles, so obstacle math and the drawn
  // border can never disagree.
  let live-by-id = (:)
  for g in live-groups { live-by-id.insert(g.id, g) }
  // A self-loop draws a small return loop off the node's cross-axis side —
  // `node-gap * 0.7` deep, matching the renderer's self-edge branch — so a
  // box around such a node must reserve that room too.
  let selfy = (:)
  for e in edges {
    if e.kind == "self" { selfy.insert(str(e.from), true) }
  }
  let loop-room = a => if str(a) in selfy { node-gap * 0.7 } else { 0 }
  // `chan` reserves internal routing channels: per group id, (l:, r:) counts
  // of corridor lanes running just inside that border — each widens the band
  // by a lane. Threaded explicitly (closures capture by value) so every
  // consumer sees the same reservations.
  let gband-rec = (self, g, x, w, chan) => {
    let lo = calc.min(..g.nodes.map(a => x.at(str(a)) - w.at(str(a)) / 2))
    let hi = calc.max(..g.nodes.map(a => (
      x.at(str(a)) + w.at(str(a)) / 2 + loop-room(a)
    )))
    for m in g.members {
      if m in live-by-id {
        let cb = self(self, live-by-id.at(m), x, w, chan)
        lo = calc.min(lo, cb.lo)
        hi = calc.max(hi, cb.hi)
      }
    }
    let ch = chan.at(g.id, default: (l: 0, r: 0))
    lo -= group-pad + ch.l * lane-gap
    hi += group-pad + ch.r * lane-gap
    let want = g.at("tw", default: 0) + group-pad
    if hi - lo < want {
      let c = (lo + hi) / 2
      (lo: c - want / 2, hi: c + want / 2)
    } else { (lo: lo, hi: hi) }
  }
  // Reservations are set by the segmented-corridor pass below; closures
  // capture by value, so `ch` rides along as an argument everywhere.
  let gband = (g, x, w, ch) => gband-rec(gband-rec, g, x, w, ch)
  // The innermost box both endpoints of an edge share ((none) if unboxed or
  // in disjoint boxes): the deepest common prefix of their enclosure paths.
  let shared-box = (u, v) => {
    let pu = gp.at(str(u), default: ())
    let pv = gp.at(str(v), default: ())
    let c = 0
    while c < calc.min(pu.len(), pv.len()) and pu.at(c) == pv.at(c) {
      c += 1
    }
    if c == 0 { none } else { pu.at(c - 1) }
  }
  // Group borders lying between two rank-mates: the groups their enclosure
  // paths diverge over. Each border needs `group-pad` of room — plus a lane
  // per routing channel reserved inside it.
  let crossed-groups = (a, b) => {
    let pa = gp.at(str(a), default: ())
    let pb = gp.at(str(b), default: ())
    let c = 0
    while c < calc.min(pa.len(), pb.len()) and pa.at(c) == pb.at(c) {
      c += 1
    }
    pa.slice(c) + pb.slice(c)
  }
  let border-room = (a, b, ch) => crossed-groups(a, b)
    .map(gid => {
      let cc = ch.at(gid, default: (l: 0, r: 0))
      group-pad + (cc.l + cc.r) * lane-gap
    })
    .sum(default: 0)

  let wof = (:)
  let hof = (:)
  for c in cells {
    wof.insert(str(c.index), c.w)
    hof.insert(str(c.index), c.h)
  }

  // Automatic breathing room: a node's packing footprint grows with its edge
  // count — a busy hub holds its rank-mates (and passing corridors) further
  // off than a chain link does. Placement-only: the drawn face keeps `w`.
  let mof = (:)
  for c in cells { mof.insert(str(c.index), 0) }
  for e in edges {
    for k in (e.from, e.to) {
      mof.insert(str(k), mof.at(str(k)) + 1)
    }
  }
  for (k, deg) in mof {
    mof.insert(k, margin-step * calc.max(0, deg - 2))
  }

  // Nodes of each rank, in order; rank height is its tallest node.
  let order-in-rank = range(ranks).map(r => cells
    .filter(c => c.rank == r)
    .sorted(key: c => c.order)
    .map(c => c.index))
  let rank-h = order-in-rank.map(row => if row.len() > 0 {
    calc.max(..row.map(a => hof.at(str(a))))
  } else { 0 })
  // (Vertical positions are assigned late: the gap between two ranks adapts to
  // the edge traffic that must fan through it, which is only known once seats
  // are allocated.)

  // Neighbours across ranks, from the *direct* edges only — long/back edges route
  // on the side and shouldn't tug spine nodes out of line. (A node absent from
  // this map has no spine to be tugged out of; the widen loop below aligns it
  // over its long edges' corridors instead.)
  let nbr = (:)
  for e in edges {
    if e.kind == "direct" {
      nbr.insert(str(e.from), nbr.at(str(e.from), default: ()) + (e.to,))
      nbr.insert(str(e.to), nbr.at(str(e.to), default: ()) + (e.from,))
    }
  }

  // Direct and long inputs of each node. A merge widens to seat its direct inputs
  // straight and to reach the entry column of each long (side-arriving) input.
  let din = (:)
  let lin = (:)
  for (ei, e) in edges.enumerate() {
    if e.kind == "direct" {
      din.insert(str(e.to), din.at(str(e.to), default: ()) + (e.from,))
    } else if e.kind == "long" {
      lin.insert(
        str(e.to),
        lin.at(str(e.to), default: ()) + ((ei: ei, from: e.from),),
      )
    }
  }
  let median = xs => {
    let s = xs.sorted()
    let k = s.len()
    if k == 0 { 0 } else if calc.rem(k, 2) == 1 {
      s.at(calc.quo(k, 2))
    } else {
      (s.at(calc.quo(k, 2) - 1) + s.at(calc.quo(k, 2))) / 2
    }
  }

  // How many long edges each *unanchored* node (no direct edges) touches. With
  // several, the node has no column a corridor should prefer — preferring the
  // source diverges: the target widens toward the source's column while that
  // very widening repacks the ranks and drifts the column further away. Those
  // edges prefer a corridor near their target instead (see `corridor`).
  let lcount = (:)
  for e in edges {
    if e.kind == "long" {
      for k in (e.from, e.to) {
        if str(k) not in nbr {
          lcount.insert(str(k), lcount.at(str(k), default: 0) + 1)
        }
      }
    }
  }

  // Coordinate assignment: start centred by order, then relax each node toward the
  // median of its neighbours (aligning chains) while a forward and a backward pass
  // hold each rank's separation. Both preserve the minimum gap, so their average
  // does too — the spine straightens without nodes ever overlapping.
  //
  // Long and back edges don't tug *spine* nodes out of line — but an unanchored
  // node (no direct edges at all, e.g. a feed that only supplies distant steps)
  // has no line to be tugged out of. `cwant` carries such a node's current
  // target: the median of its long edges' corridor columns; it chases that
  // instead of staying wherever rank packing dropped it.
  let relax = (widths, cwant, ch) => {
    // Packing and separation see each node's margined footprint; a group
    // border between two rank-mates costs `group-pad` more (plus any routing
    // channels reserved inside it), reserving the room the hull's edge will
    // occupy.
    let pw = a => widths.at(str(a)) + 2 * mof.at(str(a))
    let x = (:)
    for r in range(ranks) {
      let row = order-in-rank.at(r)
      let gaps-in-row = range(calc.max(row.len() - 1, 0)).map(i => (
        node-gap + border-room(row.at(i), row.at(i + 1), ch)
      ))
      let total = (
        row.map(a => pw(a)).sum(default: 0)
          + gaps-in-row.sum(
            default: 0,
          )
      )
      let cx = -total / 2
      for (k, a) in row.enumerate() {
        x.insert(str(a), cx + pw(a) / 2)
        cx += pw(a) + gaps-in-row.at(k, default: 0)
      }
    }
    for pass in range(12) {
      let seq = if calc.rem(pass, 2) == 0 {
        range(ranks)
      } else {
        range(ranks - 1, -1, step: -1)
      }
      for r in seq {
        let row = order-in-rank.at(r)
        let k = row.len()
        if k == 0 { continue }
        // A wanted column wins over the neighbour median: for the unanchored
        // nodes the settle loop pins there is no median anyway, and the
        // cohesion recovery uses the same door to pull a stray group member
        // home against its outside parents' tug.
        let want = row.map(a => {
          let ns = nbr.at(str(a), default: ())
          if str(a) in cwant {
            cwant.at(str(a))
          } else if ns.len() > 0 {
            median(ns.map(nn => x.at(str(nn))))
          } else {
            x.at(str(a))
          }
        })
        let sep = i => (
          pw(row.at(i)) / 2
            + node-gap
            + border-room(row.at(i), row.at(i + 1), ch)
            + pw(row.at(i + 1)) / 2
        )
        let xf = (want.at(0),)
        for i in range(1, k) {
          xf.push(calc.max(want.at(i), xf.at(i - 1) + sep(i - 1)))
        }
        let xb = range(k).map(_ => 0)
        xb.at(k - 1) = want.at(k - 1)
        for i in range(k - 2, -1, step: -1) {
          xb.at(i) = calc.min(want.at(i), xb.at(i + 1) - sep(i))
        }
        for i in range(k) {
          x.insert(str(row.at(i)), (xf.at(i) + xb.at(i)) / 2)
        }
      }
    }
    x
  }

  let shapeof = (:)
  let rankof = (:)
  for c in cells {
    shapeof.insert(str(c.index), c.shape)
    rankof.insert(str(c.index), c.rank)
  }

  // Every workable vertical corridor for a long edge u -> v under the current
  // widths, best first: the candidate x's that no node in the crossed ranks
  // blocks, ordered closest to the source's own column so the edge drops
  // straight when that column is clear (and only jogs when it isn't).
  // Candidates are the endpoints (or, for a side exit, the source's flanks),
  // the gaps just outside each crossed rank, and just outside the diagram.
  // The outside pair stands beyond every node's *margined* clearance band
  // (footprint + `mof` + stand-off), so no node can block it; only a group's
  // border can cover it, and the border-lane candidates below keep a column
  // findable there. Together the list always holds a workable column for a
  // plain drop. With `side-exit` (a decision leaving by a side vertex) the
  // corridor must sit outside the source, its run at u.y clear of u's
  // rank-mates; the list is empty if none does (caller falls back to a
  // bottom exit). The crossing sweep re-scores this same list later, so
  // anything it picks satisfies the same clearances.
  let corridor-cands = (ui, vi, side-exit, prefer-target, x, w, ch) => {
    let ur = rankof.at(str(ui))
    let vr = rankof.at(str(vi))
    let ux = x.at(str(ui))
    let uw = w.at(str(ui))
    let vx = x.at(str(vi))
    // A routed edge keeps `edge-clearance` from every node it passes, measured
    // from the node's margined footprint — busy hubs hold corridors further off.
    let hw = a => w.at(str(a)) / 2 + mof.at(str(a))
    // The diagram's extent for the outside fallback columns is the *margined*
    // footprint, and the stand-off never drops below `edge-clearance` — both
    // are needed for the outside pair to clear a busy boundary node's band
    // whatever the theme's back-margin is set to.
    let minx = calc.min(..cells.map(c => x.at(str(c.index)) - hw(c.index)))
    let maxx = calc.max(..cells.map(c => x.at(str(c.index)) + hw(c.index)))
    let out-margin = calc.max(back-margin, edge-clearance)
    let occupied = ()
    let cands = (vx, minx - out-margin, maxx + out-margin)
    cands += if side-exit {
      (ux - uw / 2 - edge-clearance, ux + uw / 2 + edge-clearance)
    } else { (ux,) }
    for r in range(calc.min(ur, vr) + 1, calc.max(ur, vr)) {
      let row = order-in-rank.at(r)
      for a in row {
        occupied.push((
          x.at(str(a)) - hw(a) - edge-clearance,
          x.at(str(a)) + hw(a) + edge-clearance,
        ))
      }
      if row.len() > 0 {
        cands.push(
          calc.min(..row.map(a => x.at(str(a)) - hw(a))) - edge-clearance,
        )
        cands.push(
          calc.max(..row.map(a => x.at(str(a)) + hw(a))) + edge-clearance,
        )
      }
      // A wide-enough gap *between* two row-mates is a corridor column too —
      // without these, a blocked source column sends the edge fleeing to the
      // row's far edge (or clean outside the diagram) when a clear channel
      // runs right next to it.
      for i in range(calc.max(row.len() - 1, 0)) {
        let lo = x.at(str(row.at(i))) + hw(row.at(i))
        let hi = x.at(str(row.at(i + 1))) - hw(row.at(i + 1))
        if hi - lo >= 2 * edge-clearance { cands.push((lo + hi) / 2) }
      }
    }
    // A group's box blocks corridors that have no business inside it: when
    // neither endpoint is a member and the box lies across the crossed ranks,
    // the hull's band joins the obstacles (an edge with an endpoint inside
    // must cross the border, and does so near that endpoint's own column). A
    // corridor that does belong inside may run through the box — but not
    // *along* its border line, so each border keeps a lane's width clear.
    for g in live-groups {
      let rs = g.nodes.map(a => rankof.at(str(a)))
      if (
        calc.max(..rs) < calc.min(ur, vr) or calc.min(..rs) > calc.max(ur, vr)
      ) { continue }
      let b = gband(g, x, w, ch)
      if (
        gp.at(str(ui), default: ()).contains(g.id)
          or gp.at(str(vi), default: ()).contains(g.id)
      ) {
        occupied.push((b.lo - lane-gap / 2, b.lo + lane-gap / 2))
        occupied.push((b.hi - lane-gap / 2, b.hi + lane-gap / 2))
        // Candidates just clear of the border lanes: when a box's interior is
        // fully tiled, these keep a corridor findable — a widened border can
        // otherwise swallow even the outside-the-diagram fallback columns,
        // leaving no candidate at all.
        cands.push(b.lo - lane-gap)
        cands.push(b.hi + lane-gap)
      } else {
        occupied.push((b.lo - edge-clearance, b.hi + edge-clearance))
        cands.push(b.lo - edge-clearance)
        cands.push(b.hi + edge-clearance)
      }
    }
    let clear = cx => occupied.all(iv => cx <= iv.at(0) or cx >= iv.at(1))
    let ok = cx => {
      if not clear(cx) { return false }
      if not side-exit { return true }
      if (
        cx > ux - uw / 2 - edge-clearance and cx < ux + uw / 2 + edge-clearance
      ) {
        return false
      }
      let vx2 = if cx < ux { ux - uw / 2 } else { ux + uw / 2 }
      order-in-rank
        .at(ur)
        .filter(a => a != ui)
        .all(a => (
          x.at(str(a)) + hw(a) <= calc.min(vx2, cx)
            or x.at(str(a)) - hw(a) >= calc.max(vx2, cx)
        ))
    }
    cands
      .filter(ok)
      // Prefer the source's own column (straight drop); break ties toward the
      // target. A several-feed unanchored source flips this: its column is
      // adrift, so stay near the target instead.
      .sorted(key: c => if prefer-target {
        (calc.abs(c - vx), calc.abs(ux - c))
      } else {
        (calc.abs(ux - c), calc.abs(c - vx))
      })
  }
  let corridor = (ui, vi, side-exit, prefer-target, x, w, ch) => (
    corridor-cands(ui, vi, side-exit, prefer-target, x, w, ch).at(
      0,
      default: none,
    )
  )

  // A long edge's entry steps just outside the target's direct-input columns
  // when its approach would crowd them, on whichever side it comes from.
  let step-entry = (entry, to, x) => {
    let din-xs = din.at(str(to), default: ()).map(s => x.at(str(s)))
    if din-xs.len() == 0 { return entry }
    let dmin = calc.min(..din-xs)
    let dmax = calc.max(..din-xs)
    if entry > dmin - node-gap and entry < dmax + node-gap {
      if entry <= x.at(str(to)) { dmin - node-gap } else { dmax + node-gap }
    } else { entry }
  }

  // A long edge's route under the current widths: the corridor x, whether a decision
  // takes a side exit, and where it enters the target's top. The entry sits on the
  // corridor (a straight drop) unless that would crowd the target's direct inputs, in
  // which case it steps just outside them.
  let route-long = (from, to, x, w, ch) => {
    let side = shapeof.at(str(from)) == "diamond"
    let pt = lcount.at(str(from), default: 0) >= 2
    let cx = if side { corridor(from, to, true, pt, x, w, ch) } else { none }
    let side-ok = cx != none
    if not side-ok { cx = corridor(from, to, false, pt, x, w, ch) }
    // Defensive only — the plain candidate list always holds a clear column
    // (see corridor-cands). Never crash regardless: degrade to a drop at the
    // target's own column and let the shape-aware attach land the arrow.
    if cx == none {
      cx = x.at(str(to))
      side-ok = false
    }
    (cx: cx, side-ok: side-ok, entry: step-entry(cx, to, x))
  }

  // Widths may grow: relax, then widen each node to span its merging direct inputs
  // and to reach every long edge's entry column, and re-relax so the wider node
  // still fits. Widths depend on positions and positions on widths, so iterate to
  // the fixed point: stop once no width moves more than `weps`. Convergence is
  // geometric — relax's forward/backward averaging roughly halves the residual
  // each round — so the bound covers log2(extent / weps) plus slack for a
  // widening to cascade down the ranks; the loop breaks well before it on
  // ordinary diagrams.
  let weps = 0.005 // width change below this (canvas units) counts as settled
  let aeps = 0.02 // an unanchored node within this of its corridor is aligned
  let w = wof
  let x = relax(w, (:), (:))
  // The settle loop's final alignment targets, kept for the channel-iteration
  // re-relax below (an unanchored node must not lose its corridor alignment).
  let cwant-last = (:)
  let settled = false
  // The last round's full routes: the seat pass below must see the same
  // corridors the widths settled against — recomputing them afterwards against
  // the settled (wider) extents drifts the outside-lane candidates outward and
  // bends drops the loop had already straightened.
  let lastr = (:)
  // Inputs the absolute reach cap has permanently dropped, per node (see the
  // sticky-exclusion note in the widen pass).
  let excl = (:)
  // Direct children per node, for the near-miss straightening below.
  let douts = (:)
  for e in edges {
    if e.kind == "direct" {
      douts.insert(str(e.from), douts.at(str(e.from), default: ()) + (e.to,))
    }
  }
  for round in range(calc.max(16, ranks + 12)) {
    let ent = (:)
    lastr = (:)
    for c in cells {
      for it in lin.at(str(c.index), default: ()) {
        let r = route-long(it.from, c.index, x, w, (:))
        lastr.insert(str(it.ei), r)
        ent.insert(str(it.ei), r.entry)
      }
    }
    // An unanchored node (absent from every direct edge) with exactly ONE long
    // edge wants that edge's corridor column — recomputed each round, since
    // corridors shift as widths settle. Strictly one: with several long edges
    // the node would sit between its targets, and the targets' widen-to-entry
    // rule then chases a column between them — each widening pushes the pair
    // apart and moves the goal, which never converges. A several-edged feed
    // instead relies on the ordering fallback (layout.typ) to sit among its
    // consumers, and its edges jog as usual.
    let cw = (:)
    for (ei, e) in edges.enumerate() {
      if e.kind == "long" {
        let unf = str(e.from) not in nbr
        let unt = str(e.to) not in nbr
        if unf or unt {
          let cx = route-long(e.from, e.to, x, w, (:)).cx
          if unf {
            cw.insert(str(e.from), cw.at(str(e.from), default: ()) + (cx,))
          }
          if unt {
            cw.insert(str(e.to), cw.at(str(e.to), default: ()) + (cx,))
          }
        }
      }
    }
    let cwant = (:)
    for (k, v) in cw {
      if v.len() == 1 { cwant.insert(k, v.at(0)) }
    }
    cwant-last = cwant
    // Alignment joins the settle test: exiting while a node is still mid-chase
    // would freeze it short of its corridor.
    let stable = cwant.pairs().all(((k, v)) => calc.abs(x.at(k) - v) <= aeps)
    for c in cells {
      let key = str(c.index)
      // An input living in a box that excludes this node at its own rank must
      // bend into a seat, never widen the node: stretching toward it would
      // push the face into (or across) that box's band, which the push-out
      // sweep would then have to undo — for a merge of two sibling boxes'
      // outputs, unresolvably.
      let d = din.at(key, default: ()).filter(s => not boxed-off(c.index, s))
      let l = lin
        .at(key, default: ())
        .filter(it => not boxed-off(c.index, it.from))
      let cxn = x.at(key)
      // A lone direct input fans in without widening; two or more merge, so the node
      // grows to span them; a long input pulls the node out to its entry. Both only
      // up to `max-reach`: widths are symmetric about the node's centre, so spanning
      // an input the packing has pushed far off-centre doubles into a page-wide
      // face. A further input must not inflate the node — its edge bends into an
      // allocated seat instead (see the route pass below). A decision never
      // widens at all: a diamond stretched to span its inputs loses its
      // pointed proportion, so it stays label-sized and every arrow bends
      // into a seat on its sloped faces or docks at a vertex — the input
      // side of the same rule its branches follow (see the near-miss pass).
      let cand = (
        if d.len() >= 2 and c.shape != "diamond" {
          d.map(s => (k: "d" + str(s), e: x.at(str(s))))
        } else { () }
      )
      let cand = (
        cand
          + if c.shape == "diamond" { () } else {
            l.map(it => (
              k: "l" + str(it.ei),
              e: ent.at(
                str(it.ei),
              ),
            ))
          }
      )
      // The absolute cap is *sticky*: an input it drops stays dropped. Settle
      // wobble otherwise flips borderline inputs in and out of the included
      // set, and the width limit-cycles instead of converging. The set only
      // shrinks, so exclusions are finite and the loop contracts in between.
      let ex = excl.at(key, default: (:))
      let inc = cand.filter(i => i.k not in ex)
      for i in inc {
        if calc.abs(i.e - cxn) > max-reach { ex.insert(i.k, true) }
      }
      excl.insert(key, ex)
      let xs = inc.filter(i => i.k not in ex).map(i => i.e)
      // Everything excluded: revert to the measured width (an earlier round may
      // have left a stale wider value).
      if xs.len() == 0 {
        if cand.len() > 0 {
          let nw = wof.at(key)
          if calc.abs(nw - w.at(key)) > weps { stable = false }
          w.insert(key, nw)
        }
        continue
      }
      let lo = calc.min(cxn, ..xs)
      let hi = calc.max(cxn, ..xs)
      // Widths are symmetric about the centre, so reaching an input the packing
      // has pushed off-centre costs double. Cap the imbalance: one side may
      // out-reach the other by at most `widen-skew` — a node that can't sit
      // near the middle of its inputs stays label-sized and the arrows bend to
      // seats on it instead (see the route pass).
      let lr = cxn - lo
      let rr = hi - cxn
      let reach = calc.min(
        calc.max(lr, rr),
        calc.min(lr, rr) + widen-skew,
        max-reach,
      )
      let nw = calc.max(wof.at(str(c.index)), 2 * reach + 2 * pad-x)
      if calc.abs(nw - w.at(str(c.index))) > weps { stable = false }
      w.insert(str(c.index), nw)
    }
    // On a stable round nothing moved beyond `weps` (and every unanchored node
    // sits on its corridor), so the current positions are the relaxation of the
    // final widths — consistent, stop here.
    if stable {
      settled = true
      break
    }
    x = relax(w, cwant, (:))
  }

  // Push-out: within a rank, ordering keeps a group's members contiguous and
  // the border-scaled separations hold rank-mates clear — but a group's box is
  // as wide as its widest rank, so a node in a rank where the group is narrow
  // (or absent) can still sit inside the band. Each such node escapes to the
  // nearest clear ground. The bands it must clear are *merged* first: sibling
  // boxes can abut, and escaping one band only to land in the next (and be
  // bounced back, forever) is exactly how a node got stranded inside a box —
  // against the merged interval the nearer edge is chosen once. Borders keep
  // `group-pad` of air outside (members sit a pad inside, so the line runs
  // centred in a clear channel); rank-mates that escaped first are stepped
  // past at `node-gap`. Best-effort: two passes, then whatever remains stays
  // (a box edge through a pathological nest beats refusing the diagram).
  // `refine` bundles the two passes so the channel iteration below can rerun
  // them against reserved-channel geometry. Returns the adjusted positions
  // and whether anything moved.
  let refine = (x0, ch) => {
    let x = x0
    let moved = false
    // Sibling boxes keep daylight between their borders. Rank packing spaces
    // same-rank pairs, but a box edge is a multi-rank maximum (plus any
    // title-width growth), so two side-by-side boxes can end up touching
    // even though every row is properly spaced. Where two unrelated groups
    // share a rank and their bands close within `group-pad`, everything
    // right of the midpoint shifts right by the deficit — a rigid shear that
    // opens the gap without disturbing either side's internal layout.
    for pass in range(if live-groups.len() > 1 { 2 } else { 0 }) {
      for i in range(live-groups.len()) {
        for j in range(i + 1, live-groups.len()) {
          let (ga, gb2) = (live-groups.at(i), live-groups.at(j))
          // Skip ancestor/descendant pairs (one contains the other) and pairs
          // whose rank spans don't overlap (stacked boxes may share columns).
          let related = (
            ga.nodes.all(a => gp.at(str(a), default: ()).contains(gb2.id))
              or gb2.nodes.all(a => gp.at(str(a), default: ()).contains(ga.id))
          )
          let (sa, sb) = (gspan.at(ga.id), gspan.at(gb2.id))
          if related or sa.at(1) < sb.at(0) or sb.at(1) < sa.at(0) {
            continue
          }
          let ba = gband(ga, x, w, ch)
          let bb = gband(gb2, x, w, ch)
          let (left, right) = if ba.lo <= bb.lo { (ba, bb) } else { (bb, ba) }
          let deficit = group-pad - (right.lo - left.hi)
          if deficit > 0.001 {
            let mid = (left.hi + right.lo) / 2
            for c in cells {
              if x.at(str(c.index)) > mid {
                x.insert(str(c.index), x.at(str(c.index)) + deficit)
              }
            }
            moved = true
          }
        }
      }
    }
    // Push-out (see the block comment above): non-members escape the merged
    // group bands to the nearest clear ground.
    for pass in range(if live-groups.len() > 0 { 2 } else { 0 }) {
      let bands = live-groups.map(g => {
        let rs = g.nodes.map(a => rankof.at(str(a)))
        let b = gband(g, x, w, ch)
        (
          id: g.id,
          gt: calc.min(..rs),
          gb: calc.max(..rs),
          f0: b.lo - group-pad,
          f1: b.hi + group-pad,
        )
      })
      let half = a => w.at(str(a)) / 2 + mof.at(str(a))
      for r in range(ranks) {
        // Every rank-mate is an obstacle — stationary neighbours as much as
        // earlier escapees (avoiding only the latter let an escapee land
        // squarely ON a neighbour that never moved). Keyed so a node ignores
        // its own entry while being placed; its landing updates the entry
        // for everyone after it.
        let occ = (:)
        for a in order-in-rank.at(r) {
          occ.insert(str(a), (c: x.at(str(a)), h: half(a)))
        }
        for a in order-in-rank.at(r) {
          let mine = bands
            .filter(b => (
              r >= b.gt
                and r <= b.gb
                and not gp.at(str(a), default: ()).contains(b.id)
            ))
            .map(b => (b.f0, b.f1))
            .sorted(key: b => b.at(0))
          if mine.len() == 0 { continue }
          // Bands whose clear gap is too narrow for this node merge into one
          // obstacle — a slot it can't occupy is no escape target (this also
          // absorbs float error where two abutting bands miss by an epsilon).
          let ha = half(a)
          let merged = ()
          for v in mine {
            if merged.len() > 0 and v.at(0) <= merged.last().at(1) + 2 * ha {
              let m = merged.pop()
              merged.push((m.at(0), calc.max(m.at(1), v.at(1))))
            } else { merged.push(v) }
          }
          for m in merged {
            if x.at(str(a)) + ha > m.at(0) and x.at(str(a)) - ha < m.at(1) {
              let dl = x.at(str(a)) - (m.at(0) - ha)
              let dr = (m.at(1) + ha) - x.at(str(a))
              let dir = if dl <= dr { -1 } else { 1 }
              let c = if dir < 0 { m.at(0) - ha } else { m.at(1) + ha }
              // Step past every rank-mate in the way — and past any further
              // hostile band a bump lands the node in (stepping past a
              // stationary member of the next box would otherwise strand the
              // node inside it). The collision tests leave an epsilon of
              // tolerance: a landing computed as exactly the separation can
              // round a hair short and re-collide with itself forever.
              // Bounded as a belt — every bump moves the landing further in
              // the escape direction, so the cap never binds on real input.
              let bumped = true
              let tries = 0
              while bumped and tries < 32 {
                bumped = false
                tries += 1
                for (k, p) in occ {
                  if (
                    k != str(a)
                      and calc.abs(c - p.c) < ha + p.h + node-gap - 0.001
                  ) {
                    c = p.c + dir * (p.h + ha + node-gap)
                    bumped = true
                  }
                }
                for m2 in merged {
                  if c + ha > m2.at(0) + 0.001 and c - ha < m2.at(1) - 0.001 {
                    c = if dir < 0 { m2.at(0) - ha } else { m2.at(1) + ha }
                    bumped = true
                  }
                }
              }
              x.insert(str(a), c)
              occ.insert(str(a), (c: c, h: ha))
              moved = true
              break
            }
          }
        }
      }
    }
    (x: x, moved: moved)
  }
  let reroute = (x, ch) => {
    let lr = (:)
    for c in cells {
      for it in lin.at(str(c.index), default: ()) {
        lr.insert(str(it.ei), route-long(it.from, c.index, x, w, ch))
      }
    }
    lr
  }
  let rf = refine(x, (:))
  x = rf.x
  // A shear or escape can stretch a box — corridors chosen against the
  // pre-move geometry may then land inside a border, so reroute.
  if rf.moved { lastr = reroute(x, (:)) }

  // Cohesion recovery. A group whose members sit on distant ranks with a
  // non-member step between them can defeat the push-out: the far member
  // chases its outside parent (the neighbour median), the band stretches
  // across the diagram, and every excluded node is herded into whatever
  // ground remains — sometimes none. When the dust settles wrong — an
  // overlap, or a non-member still inside a hostile band — pull the stray
  // members home instead: pin each member of an offending group whose
  // direct neighbours all lie outside it to the mean of the group's other
  // members, and relax once against the pins. The band collapses to a
  // column, the excluded nodes are naturally clear, and the member's edges
  // bend into the box like any other entry. One bounded pass, mirroring
  // the segmented and near-miss recoveries below.
  {
    let half2 = a => w.at(str(a)) / 2
    let offending = live-groups.filter(g => {
      let rs = g.nodes.map(a => rankof.at(str(a)))
      let (gt, gb) = (calc.min(..rs), calc.max(..rs))
      let b = gband(g, x, w, (:))
      cells.any(c => (
        c.rank >= gt
          and c.rank <= gb
          and not gp.at(str(c.index), default: ()).contains(g.id)
          and x.at(str(c.index)) + half2(c.index) > b.lo - group-pad + 0.01
          and x.at(str(c.index)) - half2(c.index) < b.hi + group-pad - 0.01
      ))
    })
    if offending.len() > 0 {
      let pins = (:)
      for g in offending {
        for m in g.nodes {
          let ns = nbr.at(str(m), default: ())
          if (
            ns.len() > 0
              and ns.all(n => not gp.at(str(n), default: ()).contains(g.id))
          ) {
            let others = g.nodes.filter(o => o != m)
            if others.len() > 0 {
              pins.insert(
                str(m),
                others.map(o => x.at(str(o))).sum() / others.len(),
              )
            }
          }
        }
      }
      if pins.len() > 0 {
        x = relax(w, cwant-last + pins, (:))
        // Phase two: a node fed ONLY by pinned members would follow the
        // box's column and drag its whole continuation sideways — and the
        // box sits wherever the rank order parked it, which is no place to
        // hang the rest of the flow. Hang such a node under its nearest
        // upstream feeder instead — the flow's own step; the box and the
        // other far-off context feeds reach it by edge, not by pull.
        // Anchors are read from the settled phase-one positions, then one
        // more relax places everything below along the same course.
        for c2 in cells {
          let k2 = str(c2.index)
          if k2 in pins { continue }
          if offending.any(g => gp.at(k2, default: ()).contains(g.id)) {
            continue
          }
          let dsrc = din.at(k2, default: ())
          let lsrc = lin.at(k2, default: ()).map(it => it.from)
          if (
            dsrc.len() > 0 and dsrc.all(s => str(s) in pins) and lsrc.len() > 0
          ) {
            let top2 = calc.max(..lsrc.map(s => rankof.at(str(s))))
            let near = lsrc.filter(s => rankof.at(str(s)) == top2)
            pins.insert(k2, median(near.map(s => x.at(str(s)))))
          }
        }
        x = relax(w, cwant-last + pins, (:))
        let rf2 = refine(x, (:))
        x = rf2.x
        lastr = reroute(x, (:))
      }
    }
  }

  // Near-miss straightening. The widen loop above never sees the spreads the
  // group machinery just created — sibling boxes are sheared apart only
  // here, and a fork's children can end up with their entry spans falling
  // *just* short of the source's exit face, forcing a small mid-air dogleg
  // on an otherwise straight drop. When the miss is no more than `node-gap`,
  // widen the source enough to meet the farther span (the same skew and
  // reach caps as input widening — a lopsided or distant child still bends),
  // then re-relax once against the new widths, mirroring the segmented
  // re-relax below. Decisions keep their pointed fork look, and a child
  // whose box excludes the source is off limits, as for inputs.
  {
    let grew = false
    for c in cells {
      if c.shape == "diamond" { continue }
      let key = str(c.index)
      let cxn = x.at(key)
      let sw = w.at(key)
      let sfh = sw / 2 - calc.min(pad-x, sw / 4)
      let outs = ()
      for t in douts.at(key, default: ()) {
        if boxed-off(c.index, t) { continue }
        let tk = str(t)
        let tw = w.at(tk)
        let tfh = tw / 2 - calc.min(pad-x, tw / 4)
        let gsep = calc.max(
          (x.at(tk) - tfh) - (cxn + sfh),
          (cxn - sfh) - (x.at(tk) + tfh),
          0,
        )
        if gsep > 0.001 and gsep <= node-gap {
          // Aim a hair inside the child's span, so the landing sits strictly
          // on the face rather than on its float boundary.
          outs.push(if x.at(tk) > cxn { x.at(tk) - tfh + 0.02 } else {
            x.at(tk) + tfh - 0.02
          })
        }
      }
      if outs.len() == 0 { continue }
      let lo = calc.min(cxn, ..outs)
      let hi = calc.max(cxn, ..outs)
      let reach = calc.min(
        calc.max(cxn - lo, hi - cxn),
        calc.min(cxn - lo, hi - cxn) + widen-skew,
        max-reach,
      )
      // The face must hold the exit (`pad-x` inset) AND the exit spread
      // clamp must reach it — exits sit within 0.7 of the half-width (the
      // projection factor shared with render's attach), so the width grows
      // to whichever bound is tighter.
      let nw = calc.max(sw, 2 * reach + 2 * pad-x, 2 * reach / 0.7)
      if nw - sw > 0.001 {
        w.insert(key, nw)
        grew = true
      }
    }
    if grew {
      x = relax(w, cwant-last, (:))
      let rf2 = refine(x, (:))
      x = rf2.x
      lastr = reroute(x, (:))
    }
  }

  // Segmented corridors: a long edge whose endpoints share a box must not
  // route outside it — but its straight corridor can be forced out when no
  // single column threads every crossed rank inside the band. Such an edge
  // re-routes rank by rank (a staircase): each crossed rank picks a clear
  // in-band column — an interior gap, a row edge, an endpoint column, or an
  // inside-border *channel* — minimising total sideways travel. A channel
  // column books a lane inside that border; if any were booked, the box
  // widens by the reserved lanes (`chan`), positions re-relax once against
  // the wider borders, and the routes are recomputed — one bounded iteration.
  let chan = (:)
  let seg-pass = (x, lr, ch) => {
    let segd = (:)
    let resv = (:)
    // Lane counters per box side: the k-th edge to book a side's channel gets
    // its own column, one lane further in — two edges sharing a side must
    // never draw on the same line.
    let ck = (:)
    let hwof = a => w.at(str(a)) / 2 + mof.at(str(a))
    for (ei, e) in edges.enumerate() {
      if e.kind != "long" { continue }
      let S = shared-box(e.from, e.to)
      if S == none or S not in live-by-id { continue }
      let band = gband(live-by-id.at(S), x, w, ch)
      let r0 = lr.at(str(ei))
      if r0.cx >= band.lo + 0.01 and r0.cx <= band.hi - 0.01 { continue }
      let ur = rankof.at(str(e.from))
      let vr = rankof.at(str(e.to))
      let span = range(calc.min(ur, vr) + 1, calc.max(ur, vr))
      if span.len() == 0 { continue }
      let ux = x.at(str(e.from))
      let vx = x.at(str(e.to))
      let chans = (
        band.lo + group-pad / 2 + ck.at(S + "|l", default: 0) * lane-gap,
        band.hi - group-pad / 2 - ck.at(S + "|r", default: 0) * lane-gap,
      )
      let states = span.map(r => {
        let row = order-in-rank.at(r)
        let occ = row.map(a => (
          x.at(str(a)) - hwof(a) - edge-clearance,
          x.at(str(a)) + hwof(a) + edge-clearance,
        ))
        // Other boxes keep their rules: a box with neither endpoint bans its
        // whole band at this rank, one with an endpoint only its border lines.
        for g in live-groups {
          if g.id == S { continue }
          let sp2 = gspan.at(g.id)
          if r < sp2.at(0) or r > sp2.at(1) { continue }
          let b = gband(g, x, w, ch)
          if (
            gp.at(str(e.from), default: ()).contains(g.id)
              or gp.at(str(e.to), default: ()).contains(g.id)
          ) {
            occ.push((b.lo - lane-gap / 2, b.lo + lane-gap / 2))
            occ.push((b.hi - lane-gap / 2, b.hi + lane-gap / 2))
          } else {
            occ.push((b.lo - edge-clearance, b.hi + edge-clearance))
          }
        }
        let clear = c => occ.all(iv => c <= iv.at(0) or c >= iv.at(1))
        let cands = (ux, vx)
        for i in range(calc.max(row.len() - 1, 0)) {
          let lo2 = x.at(str(row.at(i))) + hwof(row.at(i))
          let hi2 = x.at(str(row.at(i + 1))) - hwof(row.at(i + 1))
          if hi2 - lo2 >= 2 * edge-clearance { cands.push((lo2 + hi2) / 2) }
        }
        if row.len() > 0 {
          cands.push(
            calc.min(..row.map(a => x.at(str(a)) - hwof(a))) - edge-clearance,
          )
          cands.push(
            calc.max(..row.map(a => x.at(str(a)) + hwof(a))) + edge-clearance,
          )
        }
        (
          cands.filter(c => (
            c >= band.lo + 0.01 and c <= band.hi - 0.01 and clear(c)
          ))
            + chans
        )
      })
      // Shortest total sideways travel ux -> columns -> vx (tiny DP).
      let cost = states.at(0).map(c => calc.abs(c - ux))
      let back = ()
      for ri in range(1, states.len()) {
        let prev = states.at(ri - 1)
        let nc = ()
        let bk = ()
        for c in states.at(ri) {
          let best = 0
          let bv = cost.at(0) + calc.abs(c - prev.at(0))
          for (k, p) in prev.enumerate() {
            let v = cost.at(k) + calc.abs(c - p)
            if v < bv - 0.0001 {
              bv = v
              best = k
            }
          }
          nc.push(bv)
          bk.push(best)
        }
        cost = nc
        back.push(bk)
      }
      let besti = 0
      let bestv = cost.at(0) + calc.abs(states.last().at(0) - vx)
      for (k, c) in states.last().enumerate() {
        let v = cost.at(k) + calc.abs(c - vx)
        if v < bestv - 0.0001 {
          bestv = v
          besti = k
        }
      }
      let idxs = (besti,)
      for ri in range(back.len() - 1, -1, step: -1) {
        idxs.insert(0, back.at(ri).at(idxs.first()))
      }
      let cols = idxs.enumerate().map(((ri, k)) => states.at(ri).at(k))
      let used-l = cols.any(c => calc.abs(c - chans.at(0)) < 0.001)
      let used-r = cols.any(c => calc.abs(c - chans.at(1)) < 0.001)
      if used-l or used-r {
        let cur = resv.at(S, default: (l: 0, r: 0))
        resv.insert(S, (
          l: cur.l + if used-l { 1 } else { 0 },
          r: cur.r + if used-r { 1 } else { 0 },
        ))
        if used-l { ck.insert(S + "|l", ck.at(S + "|l", default: 0) + 1) }
        if used-r { ck.insert(S + "|r", ck.at(S + "|r", default: 0) + 1) }
      }
      // Entry steps off the target's direct-input columns, as route-long does.
      segd.insert(str(ei), (
        cols: cols,
        entry: step-entry(cols.last(), e.to, x),
      ))
    }
    (seg: segd, resv: resv)
  }
  let sp = seg-pass(x, lastr, (:))
  if sp.resv.len() > 0 {
    chan = sp.resv
    x = relax(w, cwant-last, chan)
    let rf2 = refine(x, chan)
    x = rf2.x
    lastr = reroute(x, chan)
    sp = seg-pass(x, lastr, chan)
  }

  // The invariant of last resort: whatever the passes above negotiated,
  // two nodes never overlap. Walk each rank in order and open any
  // overlapping pair to a full node-gap with a rigid rightward shift (the
  // shear's style — order preserved, internal layout intact). This never
  // fires on a layout the machinery resolved; when it does fire, band
  // purity may suffer there — a box edge through a crowd beats nodes drawn
  // on top of each other.
  {
    let pushed = false
    for r in range(ranks) {
      // Walk the rank in *current* x order, not the layout order — a
      // legitimate escape may have leapfrogged a neighbour, and treating
      // the stale order as geometry would "repair" a pair that never
      // overlapped.
      let row = order-in-rank.at(r).sorted(key: a => (x.at(str(a)), a))
      for i in range(calc.max(row.len() - 1, 0)) {
        let (a, b) = (row.at(i), row.at(i + 1))
        let minsep = w.at(str(a)) / 2 + w.at(str(b)) / 2
        let gap2 = x.at(str(b)) - x.at(str(a))
        if gap2 < minsep - 0.01 {
          x.insert(str(b), x.at(str(a)) + minsep + node-gap)
          pushed = true
        }
      }
    }
    if pushed {
      lastr = reroute(x, chan)
      sp = seg-pass(x, lastr, chan)
    }
  }
  for (ei, s) in sp.seg {
    lastr.insert(ei, (
      ..lastr.at(ei),
      cx: s.cols.first(),
      side-ok: false,
      entry: s.entry,
      cols: s.cols,
      last: s.cols.last(),
    ))
  }

  // How many *direct* children each node fans out to. A node with one direct child
  // drops that edge straight down; a genuine fork spreads toward each target. Long
  // and back edges route on the side, so they don't count as fan-out.
  let fanout = (:)
  for e in edges {
    if e.kind == "direct" {
      fanout.insert(str(e.from), fanout.at(str(e.from), default: 0) + 1)
    }
  }

  // Exit allocation — the mirror of the entry seats. A node with several
  // bottom-leaving edges gives each its own exit column on its flow face:
  // otherwise a lone direct edge and every long edge depart at the node's
  // centre (and spread exits saturate at the same flank for two far same-side
  // targets), drawing several edges as one line until they diverge. Natural
  // exits aim at each edge's outgoing direction; where they crowd, a
  // forward/backward min-pitch pass separates them in direction order, so
  // edges never cross at the node. Single-exit nodes keep today's behaviour.
  // A closure so the crossing sweep can re-run it after moving a corridor
  // (exit order follows corridor aims); routes are threaded, not captured.
  let exit-pass = (x, w, lr) => {
    let dexit = (:)
    // A re-run allocates from scratch: a stale exit on a route whose source
    // no longer has several departures must not survive it.
    for (k, r) in lr {
      if "exit" in r {
        let kept = (:)
        for (rk, rv) in r { if rk != "exit" { kept.insert(rk, rv) } }
        lr.insert(k, kept)
      }
    }
    for c in cells {
      let key = str(c.index)
      let outs = ()
      for (ei, e) in edges.enumerate() {
        if str(e.from) != key { continue }
        if e.kind == "direct" {
          outs.push((
            kind: "d",
            key: key + ">" + str(e.to),
            aim: x.at(str(e.to)),
          ))
        } else if e.kind == "long" {
          let r = lr.at(str(ei))
          if not r.side-ok {
            outs.push((
              kind: "l",
              ei: ei,
              aim: r.at("cols", default: (r.cx,)).first(),
            ))
          }
        }
      }
      if outs.len() < 2 { continue }
      let sx = x.at(key)
      let sw = w.at(key)
      let inset = calc.min(pad-x, sw / 4)
      let (lo, hi) = (sx - sw / 2 + inset, sx + sw / 2 - inset)
      let half = 0.7 * sw / 2
      let ordered = outs.sorted(key: o => o.aim)
      let n = ordered.len()
      let pitch = calc.min(node-gap / 2, (hi - lo) / (n + 1))
      // Natural spread exits, then enforce the pitch left-to-right and cap the
      // overflow back from the right face edge — order preserved, every pair
      // at least a pitch apart, all on the face.
      let exs = ordered.map(o => (
        calc.max(lo, calc.min(
          hi,
          sx + calc.max(calc.min(o.aim - sx, half), -half),
        ))
      ))
      for i in range(1, n) {
        exs.at(i) = calc.max(exs.at(i), exs.at(i - 1) + pitch)
      }
      for i in range(n - 1, -1, step: -1) {
        exs.at(i) = calc.min(exs.at(i), hi - (n - 1 - i) * pitch)
      }
      for (i, o) in ordered.enumerate() {
        if o.kind == "d" { dexit.insert(o.key, exs.at(i)) } else {
          lr.insert(str(o.ei), (..lr.at(str(o.ei)), exit: exs.at(i)))
        }
      }
    }
    (dexit: dexit, lastr: lr)
  }
  let ep = exit-pass(x, w, lastr)
  let dexit = ep.dexit
  lastr = ep.lastr

  // Per-target seat and route bookkeeping the per-edge router can't do. Direct
  // parents on the face own their columns; a direct parent the widen caps left
  // outside the face gets a *seat* allocated inward from its side's face edge
  // (returned in `dseat` for the renderer to aim at). Long edges follow: a
  // corridor that lands on the face with room of its own keeps its straight
  // drop, any other jogs into the next free seat, spaced `node-gap` from every
  // occupant. Phase 1 is x-only; the vertical gap each target's bent tails fan
  // through is sized to their number afterwards.
  // A closure would capture the occupancy list by value and never see later
  // pushes, so the check takes it explicitly. The pass as a whole is also a
  // closure, so the crossing sweep can re-run it after moving a corridor;
  // routes and exits are threaded, not captured.
  let seat-pass = (x, w, lr, dexit) => {
    let free = (sx, tk) => tk.all(t => calc.abs(sx - t) >= node-gap / 2)
    let allocs = ()
    for c in cells {
      let d = din.at(str(c.index), default: ())
      let ins = lin.at(str(c.index), default: ())
      if d.len() == 0 and ins.len() == 0 { continue }
      let tx = x.at(str(c.index))
      let tw = w.at(str(c.index))
      // `pad-x` keeps seats off the corners of a wide face — but a cross-narrow
      // node (any plain box in a horizontal flow, whose cross extent is its
      // measured height) can be barely wider than two pads, collapsing the face
      // to a point and piling every arrow onto it. Capping the inset at a
      // quarter of the extent keeps at least half of every face seatable; the
      // allocate/repair machinery below then spaces landings within it.
      let inset = calc.min(pad-x, tw / 4)
      let face-lo = tx - tw / 2 + inset
      let face-hi = tx + tw / 2 - inset
      // Each direct parent's *projected landing*: the renderer aims a parent's
      // entry at its spread exit (toward the target when the parent forks), not
      // at the parent's own column — modelling the column here let two forking
      // parents clamp onto the same face edge and double up their arrows. A
      // projection outside the face bends into an allocated seat like any other
      // far input.
      let px = d.map(s => {
        let sx = x.at(str(s))
        // A parent's arrow lands where its exit column meets this face: the
        // allocated exit when the source has several departures, else the
        // spread aim (the 0.7 matches render's `attach(s, .., 0.7)` — keep the
        // two in step, render.typ direct-edge branch).
        let land = dexit.at(str(s) + ">" + str(c.index), default: {
          let aim = if fanout.at(str(s), default: 0) == 1 { sx } else { tx }
          let half = 0.7 * w.at(str(s)) / 2
          sx + calc.max(calc.min(aim - sx, half), -half)
        })
        (s: s, x: land)
      })
      let taken = px
        .filter(p => p.x >= face-lo and p.x <= face-hi)
        .map(p => p.x)
      let allocate = (cx, tk) => {
        let side = if cx <= tx { -1 } else { 1 }
        let s = if side < 0 { face-lo } else { face-hi }
        let steps = 0
        while not free(s, tk) and steps < 32 {
          s = s - side * node-gap
          steps += 1
        }
        calc.max(face-lo, calc.min(face-hi, s))
      }
      // Everything that must *bend* into the face shares one allocation: parents
      // the skew cap left off the face, and long edges whose corridor can't take
      // a free straight drop. Long edges use the settle loop's own routes (see
      // the threaded routes), not a recomputation. Seated straight drops claim
      // their columns as they come.
      let seated-longs = ()
      let benders = ()
      for p in px.filter(p => p.x < face-lo or p.x > face-hi) {
        benders.push((kind: "direct", key: str(p.s), cx: p.x))
      }
      // A long edge arriving from beyond a decision's face may dock at the
      // diamond's side point instead of bending across the approach band —
      // the mirror of the diamond side exit. Eligible when the run at the
      // target's mid-height from corridor to vertex clears the target's
      // rank-mates, the flank's point is free (one entry per side, farthest
      // corridor first), and the target has no back edge — those dock at
      // the flanks too. A seated straight drop stays a top entry: it is
      // already the ideal line.
      let sides = ()
      let side-eis = (:)
      if (
        c.shape == "diamond"
          and not edges.any(e2 => (
            e2.kind == "back" and (e2.from == c.index or e2.to == c.index)
          ))
      ) {
        // A flank already spoken for stays spoken for: the diamond's own
        // side exits leave by these points, and a self-loop hangs off the
        // right one.
        let flank-used = (l: false, r: false)
        for (ei2, e2) in edges.enumerate() {
          if e2.kind == "self" and e2.from == c.index { flank-used.r = true }
          if (
            e2.kind == "long"
              and e2.from == c.index
              and str(ei2) in lr
              and lr.at(str(ei2)).side-ok
          ) {
            if lr.at(str(ei2)).cx > tx { flank-used.r = true } else {
              flank-used.l = true
            }
          }
        }
        for e in ins
          .map(it => (it: it, r: lr.at(str(it.ei))))
          .sorted(key: e => -calc.abs(e.r.at("last", default: e.r.cx) - tx)) {
          if "cols" in e.r { continue }
          let rcx = e.r.at("last", default: e.r.cx)
          if rcx >= face-lo and rcx <= face-hi { continue }
          let right = rcx > tx
          if (if right { flank-used.r } else { flank-used.l }) { continue }
          let vx = if right { tx + tw / 2 } else { tx - tw / 2 }
          let (lo2, hi2) = (calc.min(vx, rcx), calc.max(vx, rcx))
          let clear2 = order-in-rank
            .at(c.rank)
            .filter(a => a != c.index)
            .all(a => (
              x.at(str(a)) + w.at(str(a)) / 2 + mof.at(str(a)) <= lo2
                or x.at(str(a)) - w.at(str(a)) / 2 - mof.at(str(a)) >= hi2
            ))
          if not clear2 { continue }
          if right { flank-used.r = true } else { flank-used.l = true }
          sides.push((ei: e.it.ei, r: e.r, vx: vx))
          side-eis.insert(str(e.it.ei), true)
        }
      }
      // A segmented route approaches on its *last* column; a straight one on
      // its single corridor column (last == cx there).
      for e in ins
        .map(it => (it: it, r: lr.at(str(it.ei))))
        .sorted(key: e => -calc.abs(e.r.at("last", default: e.r.cx) - tx)) {
        if str(e.it.ei) in side-eis { continue }
        let rcx = e.r.at("last", default: e.r.cx)
        let seated = rcx >= face-lo and rcx <= face-hi and free(rcx, taken)
        if seated {
          taken.push(rcx)
          seated-longs.push((ei: e.it.ei, r: e.r))
        } else {
          benders.push((kind: "long", ei: e.it.ei, r: e.r, cx: rcx))
        }
      }
      // The straight landings — on-face parents and seated drops — are fixed;
      // bender seats must never coincide with them or with each other.
      let fixed = taken
      // Farthest source first, so it claims the outermost seat on its side.
      let ordered = benders.sorted(key: b => -calc.abs(b.cx - tx))
      let seated-benders = ()
      for b in ordered {
        let seat = allocate(b.cx, taken)
        taken.push(seat)
        seated-benders.push((..b, seat: seat))
      }
      // Capacity repair: when the face ran out of gap-spaced slots (the search
      // clamps and can land on an occupied column), respace the bender seats —
      // evenly across the face in their left-to-right order, nudged off every
      // fixed column, each strictly right of the last. Pitch may compress at
      // absurd fan-in, but every landing on the face stays distinct.
      let crowded = range(taken.len()).any(i => (
        range(i + 1, taken.len()).any(j => (
          calc.abs(taken.at(i) - taken.at(j)) < node-gap / 2 - 0.001
        ))
      ))
      if crowded and seated-benders.len() > 0 {
        let bysx = seated-benders.sorted(key: b => b.seat)
        let k = bysx.len()
        let pitch = calc.min(
          node-gap / 2,
          (face-hi - face-lo) / (k + fixed.len() + 1),
        )
        let repaired = ()
        let prev = face-lo - pitch
        for (i, b) in bysx.enumerate() {
          let s = calc.max(
            face-lo + (face-hi - face-lo) * (i + 1) / (k + 1),
            prev + pitch,
          )
          let tries = 0
          while tries < 8 and fixed.any(fc => calc.abs(s - fc) < pitch) {
            s = s + pitch
            tries += 1
          }
          s = calc.max(s, prev + 0.02)
          prev = s
          repaired.push((..b, seat: s))
        }
        seated-benders = repaired
      }
      allocs.push((
        key: str(c.index),
        rank: c.rank,
        tx: tx,
        seated: seated-longs,
        benders: seated-benders,
        sides: sides,
      ))
    }
    allocs
  }
  let allocs = seat-pass(x, w, lastr, dexit)

  // The planned-segment model: the sideways runs ("tracks") and
  // fully-spanning verticals each edge will draw, tagged by level — rank r's
  // row band is level 2r, the gap between ranks r-1 and r is level 2r-1.
  // Heights inside a gap are undecided at this point, but a vertical that
  // spans a whole level crosses any track there whose span contains its x at
  // *any* height — which is what makes those crossings forced. The crossing
  // sweep scores corridor candidates with it and the height allocator orders
  // each gap's tracks by it. A track carries its span (x0..x1) and the x of
  // the vertical rising above it (ux) and dropping below it (dx). Mirrors
  // render.typ's polyline assembly (direct and long branches) — keep the two
  // in step. Back edges and self loops draw outside the rank body and are
  // left out; the horizontal-orientation diamond fork is modelled as the
  // plain direct edge it is in flow space.
  let edge-plan = (x, w, lr, dexit, allocs) => {
    let dseat-x = (:)
    let lseat-x = (:)
    let lseated = (:)
    let lside = (:)
    for a in allocs {
      for s2 in a.seated { lseated.insert(str(s2.ei), true) }
      for s2 in a.at("sides", default: ()) {
        lside.insert(str(s2.ei), s2.vx)
      }
      for b in a.benders {
        if b.kind == "direct" {
          dseat-x.insert(b.key + ">" + a.key, b.seat)
        } else { lseat-x.insert(str(b.ei), b.seat) }
      }
    }
    let hs = ()
    let vs = ()
    for (ei, e) in edges.enumerate() {
      let (sk, tk) = (str(e.from), str(e.to))
      if e.kind == "direct" {
        let (sx, tx) = (x.at(sk), x.at(tk))
        let lvl = 2 * rankof.at(tk) - 1
        // The landing mirrors the seat pass's projection (and render's
        // attach aim): the allocated exit, else the spread aim.
        let land = dexit.at(sk + ">" + tk, default: {
          let aim = if fanout.at(sk, default: 0) == 1 { sx } else { tx }
          let half = 0.7 * w.at(sk) / 2
          sx + calc.max(calc.min(aim - sx, half), -half)
        })
        let seat = dseat-x.at(sk + ">" + tk, default: none)
        let entry = if seat != none { seat } else {
          let tw = w.at(tk)
          let inset = calc.min(pad-x, tw / 4)
          calc.max(tx - tw / 2 + inset, calc.min(tx + tw / 2 - inset, land))
        }
        if calc.abs(entry - land) < 0.01 {
          vs.push((edge: ei, x: land, level: lvl))
        } else {
          // Only a seated bend reaches here: an unseated landing is on the
          // face by construction, so entry == land above. (Render can still
          // z-bend an unseated edge into a shaped face — the clamp-to-face
          // approximation plans that as a straight drop.)
          hs.push((
            edge: ei,
            kind: "dseat",
            level: lvl,
            x0: calc.min(land, entry),
            x1: calc.max(land, entry),
            ux: land,
            dx: entry,
            fixed: false,
            src: sk,
            tgt: tk,
          ))
        }
      } else if e.kind == "long" {
        if str(ei) not in lr { continue }
        let r = lr.at(str(ei))
        let (ur, vr) = (rankof.at(sk), rankof.at(tk))
        if vr - ur < 2 { continue }
        let cols = r.at("cols", default: ())
        let colat = ri => if cols.len() == vr - ur - 1 {
          cols.at(ri - ur - 1)
        } else { r.cx }
        let c0 = colat(ur + 1)
        let clast = colat(vr - 1)
        let entry = if str(ei) in lseated { clast } else {
          lseat-x.at(str(ei), default: r.entry)
        }
        if r.side-ok {
          // A diamond's side exit runs across its own row at the node's own
          // height — fixed, never reordered, but corridors still cross it.
          hs.push((
            edge: ei,
            kind: "side",
            level: 2 * ur,
            x0: calc.min(x.at(sk), c0),
            x1: calc.max(x.at(sk), c0),
            ux: none,
            dx: c0,
            fixed: true,
            src: sk,
            tgt: tk,
          ))
          vs.push((edge: ei, x: c0, level: 2 * ur + 1))
        } else {
          let ex = r.at("exit", default: x.at(sk))
          if calc.abs(ex - c0) >= 0.01 {
            hs.push((
              edge: ei,
              kind: "head",
              level: 2 * ur + 1,
              x0: calc.min(ex, c0),
              x1: calc.max(ex, c0),
              ux: ex,
              dx: c0,
              fixed: false,
              src: sk,
              tgt: tk,
            ))
          } else {
            vs.push((edge: ei, x: c0, level: 2 * ur + 1))
          }
        }
        // The vertical run: every intermediate row band, and every
        // intermediate gap passed without changing column; a column change
        // is a jog track there instead.
        for ri in range(ur + 1, vr) {
          vs.push((edge: ei, x: colat(ri), level: 2 * ri))
          if ri + 1 < vr {
            let (ca, cb) = (colat(ri), colat(ri + 1))
            if calc.abs(ca - cb) < 0.01 {
              vs.push((edge: ei, x: ca, level: 2 * ri + 1))
            } else {
              hs.push((
                edge: ei,
                kind: "jog",
                level: 2 * ri + 1,
                x0: calc.min(ca, cb),
                x1: calc.max(ca, cb),
                ux: ca,
                dx: cb,
                fixed: false,
                src: sk,
                tgt: tk,
              ))
            }
          }
        }
        if str(ei) in lside {
          // A side entry runs across the target's own row at mid-height —
          // fixed, like the diamond side exit's run — and its corridor
          // passes the whole final gap on the way down.
          let vx = lside.at(str(ei))
          hs.push((
            edge: ei,
            kind: "side",
            level: 2 * vr,
            x0: calc.min(vx, clast),
            x1: calc.max(vx, clast),
            ux: none,
            dx: clast,
            fixed: true,
            src: sk,
            tgt: tk,
          ))
          vs.push((edge: ei, x: clast, level: 2 * vr - 1))
        } else if calc.abs(entry - clast) < 0.01 {
          vs.push((edge: ei, x: clast, level: 2 * vr - 1))
        } else {
          hs.push((
            edge: ei,
            kind: "tail",
            level: 2 * vr - 1,
            x0: calc.min(clast, entry),
            x1: calc.max(clast, entry),
            ux: clast,
            dx: entry,
            fixed: false,
            src: sk,
            tgt: tk,
          ))
        }
      }
    }
    (hs: hs, vs: vs)
  }

  // Corridor re-choice: route-long picks each corridor blind to every other
  // edge; with exits and seats known, each long edge's clear candidates are
  // re-scored by the crossings they *force* — the corridor vertical crosses
  // every sideways run whose span contains it on a level it fully spans (at
  // any height), and the edge's own head and tail runs cross every foreign
  // vertical spanning their gap. Same-gap run-vs-run meetings are left to
  // the height allocator, except the residual no stacking order can remove.
  // Candidates and clearance filters are corridor-cands' own, so a choice
  // here satisfies every landing and box invariant; a score tie keeps the
  // earlier (legacy-preferred) candidate, so a diagram that can't improve
  // doesn't move. Segmented routes (box-constrained), side exits, and
  // corridors an unanchored node aligned itself over are pinned — their
  // segments still count as everyone else's obstacles. Any change re-runs
  // the exit and seat passes (a moved corridor reorders both) and one more
  // sweep round reconciles — mirroring the segmented re-relax; bounded at
  // two rounds of strict-improvement choices.
  for sweep in range(2) {
    let inv = edge-plan(x, w, lastr, dexit, allocs)
    // Side entries are flank-anchored — the face-entry model below doesn't
    // apply to them, so they are pinned like side exits and segments.
    let side-in = (:)
    for a in allocs {
      for s2 in a.at("sides", default: ()) {
        side-in.insert(str(s2.ei), true)
      }
    }
    let changed = false
    for (ei, e) in edges.enumerate() {
      if e.kind != "long" or str(ei) not in lastr { continue }
      if str(ei) in side-in { continue }
      let r = lastr.at(str(ei))
      if r.side-ok or "cols" in r { continue }
      let (sk, tk) = (str(e.from), str(e.to))
      if sk in cwant-last or tk in cwant-last { continue }
      let (ur, vr) = (rankof.at(sk), rankof.at(tk))
      if vr - ur < 2 { continue }
      let ex = r.at("exit", default: x.at(sk))
      let fhs = inv.hs.filter(h => h.edge != ei)
      let fvs = inv.vs.filter(v => v.edge != ei)
      // A member edge must not trade its box for a crossing: a candidate
      // outside a band both endpoints share forfeits the containment the
      // group promises. A heavy penalty rather than a ban — when nothing
      // inside is clear the legacy route already sits outside, and the
      // sweep should still compare the outside candidates fairly.
      let shared-bands = live-groups
        .filter(g => (
          gp.at(sk, default: ()).contains(g.id)
            and gp.at(tk, default: ()).contains(g.id)
        ))
        .map(g => gband(g, x, w, chan))
      let score = c => {
        // The candidate's entry mirrors what the seat pass will do with it:
        // an on-face approach lands where step-entry says, an off-face one
        // is bent into a seat somewhere on the face — approximated as the
        // near face edge. Scoring the off-face case as a straight drop at
        // the corridor (step-entry's answer for a far column) hid the whole
        // width of the real bent tail and made far-outside corridors look
        // free.
        let ttx = x.at(tk)
        let ttw = w.at(tk)
        let tinset = calc.min(pad-x, ttw / 4)
        let (flo, fhi) = (ttx - ttw / 2 + tinset, ttx + ttw / 2 - tinset)
        let se = step-entry(c, e.to, x)
        let entry = if se >= flo and se <= fhi { se } else {
          calc.max(flo, calc.min(fhi, c))
        }
        let n = 0
        for b in shared-bands {
          if c < b.lo + 0.005 or c > b.hi - 0.005 { n += 100 }
        }
        // The levels the corridor vertical fully spans: every intermediate
        // row band and gap, plus the head/tail gap when its run degenerates
        // to a straight drop.
        let lvls = ()
        for ri in range(ur + 1, vr) {
          lvls.push(2 * ri)
          if ri + 1 < vr { lvls.push(2 * ri + 1) }
        }
        if calc.abs(ex - c) < 0.01 { lvls.push(2 * ur + 1) }
        if calc.abs(entry - c) < 0.01 { lvls.push(2 * vr - 1) }
        for h in fhs {
          if lvls.contains(h.level) and c > h.x0 + 0.005 and c < h.x1 - 0.005 {
            n += 1
          }
        }
        // The head and tail runs, when present.
        for (lvl, a, b) in ((2 * ur + 1, ex, c), (2 * vr - 1, c, entry)) {
          if calc.abs(a - b) < 0.01 { continue }
          let own = (
            x0: calc.min(a, b),
            x1: calc.max(a, b),
            ux: a,
            dx: b,
          )
          for v in fvs {
            if (
              v.level == lvl and v.x > own.x0 + 0.005 and v.x < own.x1 - 0.005
            ) {
              n += 1
            }
          }
          for h in fhs {
            if h.level == lvl and not h.fixed {
              n += calc.min(pair-cost(own, h), pair-cost(h, own))
            }
          }
        }
        n
      }
      let cands = corridor-cands(
        e.from,
        e.to,
        false,
        lcount.at(sk, default: 0) >= 2,
        x,
        w,
        chan,
      )
      if cands.len() == 0 { continue }
      let cur = score(r.cx)
      if cur == 0 { continue }
      let (best, bestn) = (r.cx, cur)
      for c in cands {
        let n = score(c)
        if n < bestn {
          best = c
          bestn = n
        }
      }
      if calc.abs(best - r.cx) > 0.005 {
        lastr.insert(str(ei), (
          cx: best,
          side-ok: false,
          entry: step-entry(best, e.to, x),
        ))
        changed = true
      }
    }
    if not changed { break }
    let ep2 = exit-pass(x, w, lastr)
    dexit = ep2.dexit
    lastr = ep2.lastr
    allocs = seat-pass(x, w, lastr, dexit)
  }

  // Jogging corridors must not share a lane: where two overlap in x and in
  // the ranks they cross, shift the later one outward by `lane-gap` until
  // clear. Seated corridors never move — theirs is the straight drop being
  // protected — and a segmented route was placed rank by rank against real
  // clearances, so its runs register as immovable. Runs before the height
  // passes so gap sizing and the height allocator see the final columns.
  let lane-seated = (:)
  for a in allocs {
    for s2 in a.seated { lane-seated.insert(str(s2.ei), true) }
  }
  let lanes = ()
  for (ei, e) in edges.enumerate() {
    if e.kind != "long" or str(ei) not in lastr { continue }
    let r = lastr.at(str(ei))
    let span = (
      calc.min(rankof.at(str(e.from)), rankof.at(str(e.to))),
      calc.max(rankof.at(str(e.from)), rankof.at(str(e.to))),
    )
    if "cols" in r {
      for c in r.cols.dedup() { lanes.push((cx: c, span: span)) }
      continue
    }
    if str(ei) in lane-seated {
      lanes.push((cx: r.cx, span: span))
      continue
    }
    let tx = x.at(str(e.to))
    let side = if r.cx <= tx { -1 } else { 1 }
    let cx = r.cx
    let steps = 0
    while (
      steps < 32
        and lanes.any(l => (
          calc.abs(l.cx - cx) < lane-gap
            and l.span.at(0) < span.at(1)
            and span.at(0) < l.span.at(1)
        ))
    ) {
      cx = cx + side * lane-gap
      steps += 1
    }
    lanes.push((cx: cx, span: span))
    if cx != r.cx { lastr.insert(str(ei), (..r, cx: cx)) }
  }

  // Vertical space adapts to traffic: each inter-rank gap grows to hold
  // every sideways run that will live in it — entry tails, exit heads and
  // jogs alike — stacked at `lane-gap` pitch with a `stub`-length
  // straight left at both faces. The planned-segment model knows each gap's
  // runs exactly, so the band is sized to the true count, not a per-node
  // fan estimate.
  let tracks-inv = edge-plan(x, w, lastr, dexit, allocs)
  // The width test matches edge-plan's own bend threshold (>= 0.01), so a
  // run counted as drawn is always counted for room.
  let gap-tracks = r => tracks-inv.hs.filter(h => (
    h.level == 2 * r - 1 and h.x1 - h.x0 >= 0.01
  ))
  let gaps = range(ranks).map(r => if r == 0 { 0 } else {
    calc.max(
      rank-gap,
      2 * stub + calc.max(0, gap-tracks(r).len() - 1) * lane-gap,
    )
  })
  // A labelled line must stay visible past its label: a tall label on a
  // short run otherwise swallows it, leaving just the arrowhead poking out
  // (the label solver's keep-outs can't conjure room that isn't there). The
  // gap a labelled direct edge crosses grows to hold the label plus a full
  // `stub` of shaft on the arrowhead side and half of one on the other.
  // Long edges' labels sit on their corridors, which are long by nature.
  for (ei, e) in edges.enumerate() {
    if e.kind == "direct" and str(ei) in label-along {
      let gr2 = calc.max(rankof.at(str(e.from)), rankof.at(str(e.to)))
      gaps.at(gr2) = calc.max(
        gaps.at(gr2),
        label-along.at(str(ei)) + 1.5 * stub,
      )
    }
  }
  // Group borders need vertical room too: the gap above a box's top rank
  // holds its title band and padding, the gap below its bottom rank its
  // padding. Nested boxes opening (or closing) at the same rank each add
  // their own, so their borders stack instead of coinciding. A box whose top
  // rank is the first extends the canvas upward instead.
  for g in live-groups {
    let rs = g.nodes.map(a => rankof.at(str(a)))
    let (gt, gb) = (calc.min(..rs), calc.max(..rs))
    if gt > 0 { gaps.at(gt) += title-room + group-pad }
    if gb + 1 < ranks { gaps.at(gb + 1) += group-pad }
  }
  let rank-y = (0,)
  for r in range(1, ranks) {
    rank-y.push(
      rank-y.at(r - 1) - (rank-h.at(r - 1) / 2 + gaps.at(r) + rank-h.at(r) / 2),
    )
  }
  let y = (:)
  for c in cells { y.insert(str(c.index), rank-y.at(c.rank)) }

  // Group hulls: each box wraps its member nodes and child boxes with
  // `group-pad` of breathing room and a `title-room` band along its top.
  // Members are declared before their group, so a child's hull always exists
  // when the parent wraps it — the parent's border sits a pad outside the
  // child's, and their title bands stack.
  let hulls = (:)
  for g in groups {
    let xs0 = g.nodes.map(a => x.at(str(a)) - w.at(str(a)) / 2)
    let xs1 = g.nodes.map(a => (
      x.at(str(a)) + w.at(str(a)) / 2 + loop-room(a)
    ))
    let ys0 = g.nodes.map(a => y.at(str(a)) - hof.at(str(a)) / 2)
    let ys1 = g.nodes.map(a => y.at(str(a)) + hof.at(str(a)) / 2)
    for m in g.members {
      if m in hulls {
        let h = hulls.at(m)
        xs0.push(h.x0)
        xs1.push(h.x1)
        ys0.push(h.y0)
        ys1.push(h.y1)
      }
    }
    if xs0.len() == 0 { continue }
    // Reserved routing channels widen the box, exactly as in `gband`.
    let cc = chan.at(g.id, default: (l: 0, r: 0))
    let x0 = calc.min(..xs0) - group-pad - cc.l * lane-gap
    let x1 = calc.max(..xs1) + group-pad + cc.r * lane-gap
    // A box is never narrower than its title (plus breathing room): a long
    // name on a small group widens the box instead of overflowing it.
    let want = g.at("tw", default: 0) + group-pad
    if x1 - x0 < want {
      let c = (x0 + x1) / 2
      x0 = c - want / 2
      x1 = c + want / 2
    }
    hulls.insert(g.id, (
      x0: x0,
      x1: x1,
      y0: calc.min(..ys0) - group-pad,
      y1: calc.max(..ys1) + group-pad + title-room,
      depth: g.depth,
    ))
  }

  // Heights. The legacy formulas first — a seated drop's run at the gap's
  // midpoint, bent tails fanned above the target (farthest lowest), exit
  // heads fanned below the source (farthest highest), jogs at gap
  // midpoints. They remain the values for runs the allocator below
  // doesn't touch and the starting order and fallback for those it does;
  // the fan orders become its hard constraints (each fan is internally
  // crossing-free by construction, and must stay so).
  let route = (:)
  let dseat = (:)
  let legacy = (:) // track id -> legacy y
  let fan-pairs = () // hard (above, below) track-id pairs
  for a in allocs {
    let top = y.at(a.key) + hof.at(a.key) / 2
    for s in a.seated {
      // Fresh routes, not the copies captured at seat time: the lane
      // deconfliction above may have shifted a column since.
      let fr = lastr.at(str(s.ei))
      route.insert(str(s.ei), (
        ..fr,
        entry: fr.at("last", default: fr.cx),
        ay: top + gaps.at(a.rank) / 2,
      ))
    }
    // A side entry docks at the diamond's vertex: the corridor drops to the
    // target's mid-height and runs straight into the point — render's
    // ordinary tail, fed a mid-height `ay` and the vertex as `entry`.
    for s in a.at("sides", default: ()) {
      route.insert(str(s.ei), (
        ..lastr.at(str(s.ei)),
        entry: s.vx,
        ay: y.at(a.key),
        side-in: true,
      ))
    }
    for side in (-1, 1) {
      let group = a
        .benders
        .filter(b => if side < 0 { b.cx <= a.tx } else { b.cx > a.tx })
        .sorted(key: b => -calc.abs(b.cx - a.tx))
      let tid = b => if b.kind == "direct" { "d:" + b.key + ">" + a.key } else {
        "t:" + str(b.ei)
      }
      for (i, b) in group.enumerate() {
        let ay = top + stub + i * lane-gap
        legacy.insert(tid(b), ay)
        if i + 1 < group.len() {
          // Farthest source lowest: the next (nearer) member stays above it.
          fan-pairs.push((above: tid(group.at(i + 1)), below: tid(b)))
        }
        if b.kind == "direct" {
          // Keyed by (from, to): a direct edge is unique per pair here.
          dseat.insert(b.key + ">" + a.key, (x: b.seat, ay: ay))
        } else {
          route.insert(str(b.ei), (
            ..lastr.at(str(b.ei)),
            entry: b.seat,
            ay: ay,
          ))
        }
      }
    }
  }
  // Exit heads: fanned when a node has several long departures (farthest
  // corridor jogging first, like the entry tails).
  let exit-rank = (:)
  for (ei, e) in edges.enumerate() {
    if e.kind == "long" and str(ei) in route and not route.at(str(ei)).side-ok {
      let r = route.at(str(ei))
      let ex = r.at("exit", default: x.at(str(e.from)))
      exit-rank.insert(
        str(e.from),
        exit-rank.at(str(e.from), default: ())
          + ((ei: ei, dist: calc.abs(r.cx - ex)),),
      )
    }
  }
  let hy-of = (:)
  for (k, fans) in exit-rank {
    if fans.len() < 2 { continue }
    let bottom = y.at(k) - hof.at(k) / 2
    let ordered = fans.sorted(key: f => -f.dist)
    for (i, f) in ordered.enumerate() {
      hy-of.insert(str(f.ei), bottom - stub - i * lane-gap)
      legacy.insert("h:" + str(f.ei), bottom - stub - i * lane-gap)
      if i + 1 < ordered.len() {
        // Farthest corridor highest: it must stay above the next one.
        fan-pairs.push((
          above: "h:" + str(f.ei),
          below: "h:" + str(ordered.at(i + 1).ei),
        ))
      }
    }
  }
  // The per-gap allocator: every sideways run sharing an inter-rank band is
  // one "track"; stacked in the wrong order, one track's riser or dropper
  // pierces another's span. Order each band's tracks to minimise those
  // crossings (fan pairs held fixed), then give each track its natural
  // height — an entry run hugging its target, an exit head hugging its
  // source — moved only as far as the order, the `lane-gap` pitch, and the
  // `stub` margins force (a centred stack put every bend at the band's
  // middle, the most conspicuous spot for a small dogleg). The gap was
  // sized above to hold the full set. An unsettled ordering (cap hit)
  // keeps every legacy height: degrade, never fail.
  let tid-of = h => if h.kind == "dseat" {
    "d:" + h.src + ">" + h.tgt
  } else if h.kind == "head" {
    "h:" + str(h.edge)
  } else if h.kind == "tail" { "t:" + str(h.edge) } else {
    "j:" + str(h.edge) + ":" + str(h.level)
  }
  let alloc-y = (:)
  for gr in range(1, ranks) {
    let btop = rank-y.at(gr - 1) - rank-h.at(gr - 1) / 2
    let bbot = rank-y.at(gr) + rank-h.at(gr) / 2
    let mid = (btop + bbot) / 2
    let ts = gap-tracks(gr).map(h => (
      id: tid-of(h),
      edge: h.edge,
      kind: h.kind,
      gap: gr,
      x0: h.x0,
      x1: h.x1,
      ux: h.ux,
      dx: h.dx,
      legacy-y: legacy.at(tid-of(h), default: mid),
    ))
    if ts.len() == 1 {
      alloc-y.insert(
        ts.first().id,
        calc.max(bbot + stub, calc.min(btop - stub, ts.first().legacy-y)),
      )
    } else if ts.len() >= 2 {
      let cons = fan-pairs.filter(c => (
        ts.any(t => t.id == c.above) and ts.any(t => t.id == c.below)
      ))
      let sorted-ts = ts.sorted(key: t => (-t.legacy-y, t.edge))
      let res = order-tracks(sorted-ts, cons)
      if res.settled {
        let by-id = (:)
        for t in ts { by-id.insert(t.id, t) }
        // Minimal-deviation placement: start each track at its clamped
        // natural height, then a downward sweep opens the pitch top-to-
        // bottom and an upward sweep lifts any overflow off the bottom
        // face — the same forward/backward repair the exit seats use. The
        // band always fits the full chain (sized above), so both sweeps
        // stay inside the faces.
        let want = res.order.map(id => (
          calc.max(bbot + stub, calc.min(btop - stub, by-id.at(id).legacy-y))
        ))
        let k = want.len()
        for i in range(1, k) {
          want.at(i) = calc.min(want.at(i), want.at(i - 1) - lane-gap)
        }
        want.at(k - 1) = calc.max(want.at(k - 1), bbot + stub)
        for i in range(k - 2, -1, step: -1) {
          want.at(i) = calc.max(want.at(i), want.at(i + 1) + lane-gap)
        }
        for (i, id) in res.order.enumerate() {
          alloc-y.insert(
            id,
            calc.max(bbot + stub, calc.min(btop - stub, want.at(i))),
          )
        }
      }
    }
  }
  // Write the allocated heights back over the legacy ones.
  for a in allocs {
    for b in a.benders {
      if b.kind == "direct" {
        let key = b.key + ">" + a.key
        if "d:" + key in alloc-y {
          dseat.insert(key, (..dseat.at(key), ay: alloc-y.at("d:" + key)))
        }
      } else if "t:" + str(b.ei) in alloc-y {
        route.insert(str(b.ei), (
          ..route.at(str(b.ei)),
          ay: alloc-y.at("t:" + str(b.ei)),
        ))
      }
    }
  }
  for (ei, e) in edges.enumerate() {
    if e.kind == "long" and str(ei) in route {
      let rs = rankof.at(str(e.from))
      // A long edge always descends, so its source is never the last rank and
      // `rs + 1` is in range; `default` degrades a mis-ranked edge to a plain
      // drop instead of crashing, rather than trusting that invariant blindly.
      let hy = alloc-y.at("h:" + str(ei), default: hy-of.at(
        str(ei),
        default: (
          y.at(str(e.from))
            - hof.at(str(e.from)) / 2
            - gaps.at(rs + 1, default: rank-gap) / 2
        ),
      ))
      route.insert(str(ei), (..route.at(str(ei)), hy: hy))
      // A segmented route changes column between ranks: each change becomes a
      // jog (y, next-column) in the inter-rank gap — at its allocated track
      // height, or halfway into the gap when the allocator left it alone —
      // and the renderer draws down to y, across to the next column, and on.
      let r = route.at(str(ei))
      if "cols" in r {
        let span = range(
          calc.min(rs, rankof.at(str(e.to))) + 1,
          calc.max(rs, rankof.at(str(e.to))),
        )
        let jogs = ()
        let prev = r.cols.first()
        for (i, rr) in span.enumerate() {
          if calc.abs(r.cols.at(i) - prev) > 0.001 {
            jogs.push((
              y: alloc-y.at(
                "j:" + str(ei) + ":" + str(2 * rr - 1),
                default: (
                  rank-y.at(rr - 1)
                    - rank-h.at(rr - 1) / 2
                    - gaps.at(rr, default: rank-gap) / 2
                ),
              ),
              x: r.cols.at(i),
            ))
            prev = r.cols.at(i)
          }
        }
        route.insert(str(ei), (..r, jogs: jogs))
      }
    }
  }
  // The final planned polylines, one per flow edge, in canvas space — the
  // pure mirror of render.typ's point assembly (direct and long branches),
  // close enough for crossing counts: endpoints land on face midlines rather
  // than shape outlines, and back edges / self loops are left out. Returned
  // as `plan` for tests and diagnostics; render still assembles its own.
  let plan = (:)
  for (ei, e) in edges.enumerate() {
    let (sk, tk) = (str(e.from), str(e.to))
    if e.kind == "direct" {
      let (sx, tx) = (x.at(sk), x.at(tk))
      let sbot = y.at(sk) - hof.at(sk) / 2
      let ttop = y.at(tk) + hof.at(tk) / 2
      let ex = dexit.at(sk + ">" + tk, default: {
        let aim = if fanout.at(sk, default: 0) == 1 { sx } else { tx }
        let half = 0.7 * w.at(sk) / 2
        sx + calc.max(calc.min(aim - sx, half), -half)
      })
      let ds = dseat.at(sk + ">" + tk, default: none)
      plan.insert(str(ei), if ds != none {
        ((ex, sbot), (ex, ds.ay), (ds.x, ds.ay), (ds.x, ttop))
      } else {
        let tw = w.at(tk)
        let inset = calc.min(pad-x, tw / 4)
        let entry = calc.max(
          tx - tw / 2 + inset,
          calc.min(tx + tw / 2 - inset, ex),
        )
        if calc.abs(ex - entry) < 0.01 { ((ex, sbot), (ex, ttop)) } else {
          let my = (sbot + ttop) / 2
          ((ex, sbot), (ex, my), (entry, my), (entry, ttop))
        }
      })
    } else if e.kind == "long" and str(ei) in route {
      let r = route.at(str(ei))
      let ttop = y.at(tk) + hof.at(tk) / 2
      let head = if r.side-ok {
        let flank = if r.cx < x.at(sk) { x.at(sk) - w.at(sk) / 2 } else {
          x.at(sk) + w.at(sk) / 2
        }
        ((flank, y.at(sk)), (r.cx, y.at(sk)))
      } else {
        let ex = r.at("exit", default: x.at(sk))
        ((ex, y.at(sk) - hof.at(sk) / 2), (ex, r.hy), (r.cx, r.hy))
      }
      let px2 = r.cx
      let mids = ()
      for j in r.at("jogs", default: ()) {
        mids += ((px2, j.y), (j.x, j.y))
        px2 = j.x
      }
      plan.insert(
        str(ei),
        head + mids + ((px2, r.ay), (r.entry, r.ay), (r.entry, ttop)),
      )
    }
  }

  (
    x: x,
    y: y,
    w: w,
    route: route,
    dseat: dseat,
    dexit: dexit,
    fanout: fanout,
    hulls: hulls,
    plan: plan,
    settled: settled,
  )
}

// label-spots: collision-free anchors for edge labels. Pure — the renderer
// measures each label and hands over final-space geometry; this walks every
// labelled edge in order and picks the first spot that overlaps no node box,
// no label already placed, and no other edge's line — a label is drawn over
// every line with a knockout behind it, so a spot on a foreign line would
// erase that line. Its own line is exempt: sitting on it (and breaking it up)
// is the point.
//
// items: per labelled edge — `segs`: its segments as (ax, ay, bx, by) tuples,
//        already sorted by the caller's preference (longest vertical run first,
//        so an uncontested label sits exactly where it always has); `hw`/`hh`:
//        the label box's half-extents; `edge`: the edge the label belongs to
//        (its segments in `lines` don't count as obstacles); `tip`: the path's
//        final point — the arrow tip; `off`: an optional (x, y) author nudge
//        (canvas units) added to the final anchor and its reserved rectangle.
// boxes: node rectangles as (cx, cy, hw, hh).
// lines: every edge's segments as (edge: index, box: (cx, cy, hw, hh)) — the
//        segment's bounding box, degenerate in one axis (paths are orthogonal,
//        so that box is the segment, exactly).
// head-room: how close a label may come to its own arrow tip. The renderer
//        passes the stub token: the final approach run sized to keep the
//        arrowhead clear stays visible in full.
//
// The own-line exemption has limits — the knockout breaking a long run in the
// middle is the interrupted-line look, but a label must not blanket its line:
// a candidate keeps `visible` of its segment showing past both ends of the
// box (a segment too short for that offers no spots), and stays `head-room`
// off its own tip (a label on the arrowhead reads as a floating head).
//
// Candidates walk each segment at fractions of its length, midpoint first. When
// every candidate collides, constraints shed in order of harm: first line
// cleanliness goes (a knockout gap in a foreign line stays legible; a label
// under a label does not), then, last, the label falls back to the best
// segment's midpoint (a rare overlap beats a missing label).
#let label-spots(items, boxes, lines, head-room: none) = {
  assert(head-room != none, message: "label-spots: `head-room` is required")
  let margin = 0.06 // breathing room between a label and anything else
  let visible = 0.12 // line that must stay showing past each end of a label
  let hits = (a, b) => (
    calc.abs(a.at(0) - b.at(0)) < a.at(2) + b.at(2)
      and calc.abs(a.at(1) - b.at(1)) < a.at(3) + b.at(3)
  )
  let placed = ()
  let out = ()
  for it in items {
    let anchor = none
    let own = it.at("edge", default: none)
    let tip = it.at("tip", default: none)
    // An author's explicit shift (canvas units, page space). Applied to the
    // chosen anchor and to the rectangle later labels dodge — so a nudged
    // label still reserves its real footprint.
    let off = it.at("off", default: (0, 0))
    // A crowded diagram may leave no spot satisfying everything. Degrade in
    // order of harm: a second pass gives up line cleanliness (a knockout gap
    // in a foreign line is legible) before a label may ever cover another
    // label, a node, or its own arrowhead.
    for relaxed in (false, true) {
      if anchor != none { break }
      for s in it.segs {
        if anchor != none { break }
        // Length and the label's half-extent along the segment's axis
        // (segments are orthogonal, so one of the two terms is zero).
        let l = calc.abs(s.at(2) - s.at(0)) + calc.abs(s.at(3) - s.at(1))
        let ext = if (
          calc.abs(s.at(3) - s.at(1)) >= calc.abs(s.at(2) - s.at(0))
        ) {
          it.hh
        } else {
          it.hw
        }
        // Coarse spots first — established placements stay put — then a finer
        // ring, reached only when all five fail, so a label threads a narrow
        // clean band (between two crossing lines, say) before giving up.
        for f in (
          0.5,
          0.35,
          0.65,
          0.2,
          0.8,
          0.12,
          0.28,
          0.42,
          0.58,
          0.72,
          0.88,
        ) {
          if f * l < ext + visible or (1 - f) * l < ext + visible { continue }
          let px = s.at(0) + (s.at(2) - s.at(0)) * f
          let py = s.at(1) + (s.at(3) - s.at(1)) * f
          let r = (px, py, it.hw + margin, it.hh + margin)
          if (
            (tip == none or not hits(r, (..tip, head-room, head-room)))
              and placed.all(q => not hits(r, q))
              and boxes.all(q => not hits(r, q))
              and (
                relaxed or lines.all(q => q.edge == own or not hits(r, q.box))
              )
          ) {
            anchor = (px + off.at(0), py + off.at(1))
            placed.push((anchor.at(0), anchor.at(1), r.at(2), r.at(3)))
            break
          }
        }
      }
    }
    if anchor == none {
      let s = it.segs.at(0)
      anchor = (
        (s.at(0) + s.at(2)) / 2 + off.at(0),
        (s.at(1) + s.at(3)) / 2 + off.at(1),
      )
      placed.push((anchor.at(0), anchor.at(1), it.hw + margin, it.hh + margin))
    }
    out.push(anchor)
  }
  out
}
