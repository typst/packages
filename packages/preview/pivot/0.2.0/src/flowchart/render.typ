#import "@preview/cetz:0.5.2" as cetz
#import "../theme.typ" as theme-mod
#import "model.typ": model
#import "layout.typ": layout

// flowchart: nodes joined by directed edges, laid out in ranked layers. `layout`
// fixes each node's rank and order; here we measure the labels, align a node with its
// neighbours (a straight spine), then route: a direct (one-rank) edge runs straight
// into a single-input target or fans into a shared one; a long or back edge takes a
// side channel clear of the body. The engine works in a canonical vertical (top to
// bottom) flow; `orientation: "horizontal"` is the same picture transposed at the draw
// step. Node colour is opt-in (`fill:`). Returns content.
#let flowchart(
  ..items,
  orientation: "vertical",
  theme: theme-mod.default,
) = context {
  assert(
    orientation in ("vertical", "horizontal"),
    message: "flowchart: orientation must be \"vertical\" or \"horizontal\", got "
      + repr(orientation),
  )
  let g = layout(model(items.pos()))
  // An empty diagram has no nodes to place and no extent to measure — draw nothing.
  if g.cells.len() == 0 { return none }

  // Capture tokens before `import cetz.draw: *` shadows names like `line`/`fill`.
  let pad-x = theme.flowchart-node-pad-x / 1cm
  let pad-y = theme.flowchart-node-pad-y / 1cm
  let min-w = theme.flowchart-node-min-width / 1cm
  let node-gap = theme.flowchart-node-gap / 1cm
  let rank-gap = theme.flowchart-rank-gap / 1cm
  let back-margin = theme.flowchart-back-margin / 1cm
  let back-gap = theme.flowchart-back-gap / 1cm
  let edge-width = theme.flowchart-node-edge-width
  let edge-darken = theme.flowchart-node-edge-darken
  let node-outline = theme.flowchart-node-outline
  let node-fill = theme.flowchart-node-fill
  let label-size = theme.flowchart-label-size
  let label-color = theme.flowchart-label-color
  let dscale = theme.flowchart-decision-scale
  let io-slant = theme.flowchart-io-slant / 1cm
  let edge-stroke = theme.flowchart-edge-width + theme.flowchart-edge-color
  let arrow-fill = theme.flowchart-edge-color
  let arrow-scale = theme.flowchart-arrow-scale
  let elabel-size = theme.flowchart-edge-label-size
  let elabel-color = theme.flowchart-edge-label-color
  let elabel-fill = theme.flowchart-edge-label-fill
  let elabel-inset = theme.flowchart-edge-label-inset

  // Measure each label and give the node a box per shape (a diamond grows to hold
  // the label, a rounded rectangle rounds its corners, a parallelogram leans off vertical).
  let sized = g.cells.map(c => {
    let lbl = text(size: label-size, fill: label-color, c.label)
    let m = measure(lbl)
    let iw = calc.max(m.width / 1cm + 2 * pad-x, min-w)
    let ih = m.height / 1cm + 2 * pad-y
    // The router works in a canonical (cross, flow) space: `w` is the cross-axis
    // extent (growable by a merge), `h` the flow-axis extent. Most shapes are a plain
    // box that just swaps axes with the flow orientation; the parallelogram is
    // special — its slant always runs along the cross axis (so its flow-entry/exit
    // faces stay flat and edges attach flush), so the slant room is reserved in
    // whichever extent is the cross one.
    let (w, h) = if c.shape == "parallelogram" {
      if orientation == "horizontal" { (ih + io-slant, iw) } else {
        (iw + io-slant, ih)
      }
    } else {
      let (bw, bh) = if c.shape == "diamond" {
        (iw * dscale, ih * dscale)
      } else if c.shape == "rounded" {
        (iw + ih, ih)
      } else {
        (iw, ih)
      }
      if orientation == "horizontal" { (bh, bw) } else { (bw, bh) }
    }
    // `th` is the label-height thickness — the rounded rectangle's corner radius, so a
    // merge target that grows keeps flat faces (rounded corners, not a bulging capsule).
    (..c, lbl: lbl, w: w, h: h, th: ih)
  })
  let wof = (:)
  let hof = (:)
  for c in sized {
    wof.insert(str(c.index), c.w)
    hof.insert(str(c.index), c.h)
  }

  // Nodes of each rank, in order; rank height is its tallest node.
  let order-in-rank = range(g.ranks).map(r => sized
    .filter(c => c.rank == r)
    .sorted(key: c => c.order)
    .map(c => c.index))
  let rank-h = order-in-rank.map(row => if row.len() > 0 {
    calc.max(..row.map(a => hof.at(str(a))))
  } else { 0 })
  let rank-y = if g.ranks > 0 { (0,) } else { () }
  for r in range(1, g.ranks) {
    rank-y.push(
      rank-y.at(r - 1) - (rank-h.at(r - 1) / 2 + rank-gap + rank-h.at(r) / 2),
    )
  }

  // Neighbours across ranks, from the *direct* edges only (long/back edges route on
  // the side and shouldn't tug nodes out of line).
  let nbr = (:)
  for e in g.edges {
    if e.kind == "direct" {
      nbr.insert(str(e.from), nbr.at(str(e.from), default: ()) + (e.to,))
      nbr.insert(str(e.to), nbr.at(str(e.to), default: ()) + (e.from,))
    }
  }

  // Direct and long inputs of each node. A merge widens to seat its direct inputs
  // straight and to reach the entry column of each long (side-arriving) input.
  let din = (:)
  let lin = (:)
  for (ei, e) in g.edges.enumerate() {
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

  // Coordinate assignment: start centred by order, then relax each node toward the
  // median of its neighbours (aligning chains) while a forward and a backward pass
  // hold each rank's separation. Both preserve the minimum gap, so their average
  // does too — the spine straightens without nodes ever overlapping.
  let relax = widths => {
    let x = (:)
    for r in range(g.ranks) {
      let row = order-in-rank.at(r)
      let total = (
        row.map(a => widths.at(str(a))).sum(default: 0)
          + calc.max(row.len() - 1, 0) * node-gap
      )
      let cx = -total / 2
      for a in row {
        x.insert(str(a), cx + widths.at(str(a)) / 2)
        cx += widths.at(str(a)) + node-gap
      }
    }
    for pass in range(12) {
      let seq = if calc.rem(pass, 2) == 0 {
        range(g.ranks)
      } else {
        range(g.ranks - 1, -1, step: -1)
      }
      for r in seq {
        let row = order-in-rank.at(r)
        let k = row.len()
        if k == 0 { continue }
        let want = row.map(a => {
          let ns = nbr.at(str(a), default: ())
          if ns.len() > 0 { median(ns.map(nn => x.at(str(nn)))) } else {
            x.at(str(a))
          }
        })
        let sep = i => (
          widths.at(str(row.at(i))) / 2
            + node-gap
            + widths.at(str(row.at(i + 1))) / 2
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
  for c in sized {
    shapeof.insert(str(c.index), c.shape)
    rankof.insert(str(c.index), c.rank)
  }

  // The clearest vertical corridor for a long edge u -> v under the current widths:
  // the candidate x that no node in the crossed ranks blocks, chosen closest to the
  // source's own column so the edge drops straight when that column is clear (and
  // only jogs when it isn't). Candidates are the endpoints (or, for a side exit, the
  // source's flanks), the gaps just outside each crossed rank, and just outside the
  // diagram — the last is always clear, so a corridor always exists. With `side-exit`
  // (a decision leaving by a side vertex) the corridor must sit outside the source,
  // its run at u.y clear of u's rank-mates; returns none if none does (caller falls
  // back to a bottom exit).
  let corridor = (ui, vi, side-exit, x, w) => {
    let ur = rankof.at(str(ui))
    let vr = rankof.at(str(vi))
    let ux = x.at(str(ui))
    let uw = w.at(str(ui))
    let vx = x.at(str(vi))
    let m = node-gap / 2
    let minx = calc.min(..sized.map(c => (
      x.at(str(c.index)) - w.at(str(c.index)) / 2
    )))
    let maxx = calc.max(..sized.map(c => (
      x.at(str(c.index)) + w.at(str(c.index)) / 2
    )))
    let occupied = ()
    let cands = (vx, minx - back-margin, maxx + back-margin)
    cands += if side-exit { (ux - uw / 2 - m, ux + uw / 2 + m) } else { (ux,) }
    for r in range(calc.min(ur, vr) + 1, calc.max(ur, vr)) {
      let row = order-in-rank.at(r)
      for a in row {
        occupied.push((
          x.at(str(a)) - w.at(str(a)) / 2 - m,
          x.at(str(a)) + w.at(str(a)) / 2 + m,
        ))
      }
      if row.len() > 0 {
        cands.push(
          calc.min(..row.map(a => x.at(str(a)) - w.at(str(a)) / 2)) - m,
        )
        cands.push(
          calc.max(..row.map(a => x.at(str(a)) + w.at(str(a)) / 2)) + m,
        )
      }
    }
    let clear = cx => occupied.all(iv => cx <= iv.at(0) or cx >= iv.at(1))
    let ok = cx => {
      if not clear(cx) { return false }
      if not side-exit { return true }
      if cx > ux - uw / 2 - m and cx < ux + uw / 2 + m { return false }
      let vx2 = if cx < ux { ux - uw / 2 } else { ux + uw / 2 }
      order-in-rank
        .at(ur)
        .filter(a => a != ui)
        .all(a => (
          x.at(str(a)) + w.at(str(a)) / 2 <= calc.min(vx2, cx)
            or x.at(str(a)) - w.at(str(a)) / 2 >= calc.max(vx2, cx)
        ))
    }
    cands
      .filter(ok)
      // Prefer the source's own column (straight drop); break ties toward the target.
      .sorted(key: c => (calc.abs(ux - c), calc.abs(c - vx)))
      .at(0, default: none)
  }

  // A long edge's route under the current widths: the corridor x, whether a decision
  // takes a side exit, and where it enters the target's top. The entry sits on the
  // corridor (a straight drop) unless that would crowd the target's direct inputs, in
  // which case it steps just outside them.
  let route-long = (from, to, x, w) => {
    let side = shapeof.at(str(from)) == "diamond"
    let cx = if side { corridor(from, to, true, x, w) } else { none }
    let side-ok = cx != none
    if not side-ok { cx = corridor(from, to, false, x, w) }
    let din-xs = din.at(str(to), default: ()).map(s => x.at(str(s)))
    let entry = cx
    if din-xs.len() > 0 {
      let dmin = calc.min(..din-xs)
      let dmax = calc.max(..din-xs)
      if entry > dmin - node-gap and entry < dmax + node-gap {
        entry = if entry <= x.at(str(to)) { dmin - node-gap } else {
          dmax + node-gap
        }
      }
    }
    (cx: cx, side-ok: side-ok, entry: entry)
  }

  // Widths may grow: relax, then widen each node to span its merging direct inputs
  // and to reach every long edge's entry column, and re-relax so the wider node still
  // fits. A few rounds settle the mutual dependence (entries depend on the widths).
  let w = wof
  let x = relax(w)
  for round in range(3) {
    let ent = (:)
    for c in sized {
      for it in lin.at(str(c.index), default: ()) {
        ent.insert(str(it.ei), route-long(it.from, c.index, x, w).entry)
      }
    }
    for c in sized {
      let d = din.at(str(c.index), default: ())
      let l = lin.at(str(c.index), default: ())
      let cxn = x.at(str(c.index))
      // A lone direct input fans in without widening; two or more merge, so the node
      // grows to span them. A long input always pulls the node out to its entry.
      let merge-xs = if d.len() >= 2 { d.map(s => x.at(str(s))) } else { () }
      let xs = merge-xs + l.map(it => ent.at(str(it.ei)))
      if xs.len() == 0 { continue }
      let lo = calc.min(cxn, ..xs)
      let hi = calc.max(cxn, ..xs)
      let reach = calc.max(cxn - lo, hi - cxn)
      w.insert(str(c.index), calc.max(
        wof.at(str(c.index)),
        2 * reach + 2 * pad-x,
      ))
    }
    x = relax(w)
  }

  // Final placement (with the possibly-widened widths).
  let pos = (:)
  for c in sized {
    pos.insert(str(c.index), (
      x: x.at(str(c.index)),
      y: rank-y.at(c.rank),
      rank: c.rank,
      w: w.at(str(c.index)),
      h: c.h,
      th: c.th,
      shape: c.shape,
      fill: c.fill,
      lbl: c.lbl,
    ))
  }
  // How many *direct* children each node fans out to. A node with one direct child
  // drops that edge straight down; a genuine fork spreads toward each target. Long and
  // back edges route on the side, so they don't count as fan-out.
  let fanout = (:)
  for e in g.edges {
    if e.kind == "direct" {
      fanout.insert(str(e.from), fanout.at(str(e.from), default: 0) + 1)
    }
  }

  // Each long edge's route for drawing. The widen loop above only needed `.entry`
  // each round; now that widths have settled, compute the full route once (corridor +
  // side-ok + entry) — a straight drop, stepped aside only to clear direct inputs.
  let route = (:)
  for c in sized {
    for it in lin.at(str(c.index), default: ()) {
      route.insert(str(it.ei), route-long(it.from, c.index, x, w))
    }
  }

  cetz.canvas({
    import cetz.draw: *

    // Two x-coordinates within this are treated as the same column (a straight run).
    let straight-eps = 0.02

    // Everything below is computed in the canonical downward-flow space; a horizontal
    // flow is that picture transposed. `map` sends a canonical point to the canvas
    // (identity for a vertical flow), and is applied to every drawn coordinate — so
    // lines and boxes rotate but text, placed at `map(centre)`, stays upright.
    let map = if orientation == "horizontal" {
      p => (-p.at(1), -p.at(0))
    } else {
      p => p
    }

    // A node's outline for its shape, centred at (x, y). Border, as on the timeline
    // markers: a filled node is ringed by a deeper shade of its own fill; an unfilled
    // one takes the neutral outline. (Any non-colour paint has no `.darken`, so fall
    // back to the fill itself rather than panic.)
    let draw-node = p => {
      // The outline is the node's canonical box `map`ped onto the canvas (so lines and
      // corners transpose with the flow), while the label is placed upright at the
      // mapped centre — text never rotates. Because the parallelogram's slant is kept
      // along the cross axis and drawn in canonical space, its flow faces stay flat under the
      // map; the rounded-box radius is capped by `th` so a grown merge keeps flat faces.
      let (x, y, w, h) = (p.x, p.y, p.w, p.h)
      let fc = if p.fill == none { node-fill } else { p.fill }
      let edge = (
        edge-width
          + if p.fill == none {
            node-outline
          } else if type(p.fill) == color {
            p.fill.darken(edge-darken)
          } else {
            p.fill
          }
      )
      if p.shape == "rounded" {
        rect(
          map((x - w / 2, y - h / 2)),
          map((x + w / 2, y + h / 2)),
          radius: calc.min(w, h, p.th) / 2,
          fill: fc,
          stroke: edge,
        )
      } else if p.shape == "diamond" {
        line(
          map((x, y + h / 2)),
          map((x + w / 2, y)),
          map((x, y - h / 2)),
          map((x - w / 2, y)),
          close: true,
          fill: fc,
          stroke: edge,
        )
      } else if p.shape == "parallelogram" {
        line(
          map((x - w / 2, y - h / 2)),
          map((x + w / 2 - io-slant, y - h / 2)),
          map((x + w / 2, y + h / 2)),
          map((x - w / 2 + io-slant, y + h / 2)),
          close: true,
          fill: fc,
          stroke: edge,
        )
      } else {
        rect(
          map((x - w / 2, y - h / 2)),
          map((x + w / 2, y + h / 2)),
          fill: fc,
          stroke: edge,
        )
      }
      content(map((x, y)), p.lbl)
    }

    // A point on a node's outline (top/bottom), nudged `toward` a target x — a
    // diamond's faces slope, so its ports ride up toward the sides. `spread` caps
    // how far along the face a port may sit.
    let attach = (p, toward, top, spread) => {
      let a = p.w / 2
      let b = p.h / 2
      let dx = calc.max(calc.min(toward - p.x, spread * a), -spread * a)
      let ey = if p.shape == "diamond" {
        let rise = b * (1 - calc.abs(dx) / a)
        if top { p.y + rise } else { p.y - rise }
      } else if top { p.y + b } else { p.y - b }
      (p.x + dx, ey)
    }
    // Place a branch label on the midpoint of the path's longest vertical run. A
    // label reads cleanly sitting on a vertical line (like the yes/no branches), but
    // its knockout box breaks up a short horizontal stub and looks like a gap in the
    // line. Fall back to the longest segment only if the path has no vertical run.
    let edge-label = (lbl, pts) => {
      let anchor = none
      let best = -1
      for i in range(pts.len() - 1) {
        let (ax, ay) = pts.at(i)
        let (bx, by) = pts.at(i + 1)
        let vertical = calc.abs(ax - bx) < straight-eps
        let score = (
          calc.abs(ay - by)
            + calc.abs(ax - bx)
            + if vertical { 1000 } else { 0 }
        )
        if score > best {
          best = score
          anchor = ((ax + bx) / 2, (ay + by) / 2)
        }
      }
      if anchor != none {
        content(
          map(anchor),
          box(
            fill: elabel-fill,
            inset: elabel-inset,
            text(size: elabel-size, fill: elabel-color, lbl),
          ),
        )
      }
    }

    // Diagram extent; back-edges climb a side channel, long edges take a corridor.
    let min-x = calc.min(..pos.values().map(p => p.x - p.w / 2))
    let max-x = calc.max(..pos.values().map(p => p.x + p.w / 2))
    let center-x = (min-x + max-x) / 2
    let left-i = 0
    let right-i = 0

    // Edges first, so nodes sit over the line ends.
    for (ei, e) in g.edges.enumerate() {
      let s = pos.at(str(e.from))
      let t = pos.at(str(e.to))
      if e.kind == "direct" {
        let forks = fanout.at(str(e.from), default: 0) >= 2
        let pts = if (
          orientation == "horizontal" and s.shape == "diamond" and forks
        ) {
          // A horizontal-flow decision that forks leaves through its cross faces (the
          // diamond's top and bottom points, in the final picture): out the vertex on
          // the child's side, then flow into the child — cleaner than crowding the
          // single flow vertex with both branches. (A lone child is the flow
          // continuing, so it falls through and exits straight on.) This assumes the
          // usual two-way split; 3+ children on one cross side would share a vertex.
          let side = if t.x > s.x { 1 } else { -1 }
          let exit = (s.x + side * s.w / 2, s.y)
          let entry = attach(t, t.x, true, 1.0)
          if calc.abs(t.x - s.x) >= s.w / 2 {
            // Child sits beyond the vertex: straight down the flank, then flow in.
            if calc.abs(exit.at(0) - entry.at(0)) < straight-eps {
              (exit, entry)
            } else {
              (exit, (entry.at(0), s.y), entry)
            }
          } else {
            // Child sits within the diamond's span: leave the vertex perpendicular (a
            // short stub past the point, so it reads as a right-angle exit like the
            // clear case), then flow along and drop into the child's column below the
            // diamond, so the run never cuts back through the body.
            let out = s.x + side * (s.w / 2 + node-gap / 2)
            let clear-y = s.y - s.h / 2 - rank-gap / 2
            (exit, (out, s.y), (out, clear-y), (entry.at(0), clear-y), entry)
          }
        } else {
          // Leave at the source's x (a multi-output node spreads toward each target)
          // and run straight into the target's flow-entry face; bend only if the
          // source overhangs the target.
          let exit = attach(
            s,
            if fanout.at(str(e.from), default: 0) == 1 { s.x } else { t.x },
            false,
            0.7,
          )
          let entry = attach(t, exit.at(0), true, 1.0)
          if calc.abs(exit.at(0) - entry.at(0)) < straight-eps {
            (exit, entry)
          } else {
            let my = (exit.at(1) + entry.at(1)) / 2
            (exit, (exit.at(0), my), (entry.at(0), my), entry)
          }
        }
        line(
          ..pts.map(map),
          stroke: edge-stroke,
          mark: (end: ">", fill: arrow-fill, scale: arrow-scale),
        )
        if e.label != none { edge-label(e.label, pts) }
      } else if e.kind == "back" {
        // A loop climbs a side channel: out of the source's side, up, into the target's.
        let left = s.x <= center-x
        let ch = if left {
          min-x - back-margin - left-i * back-gap
        } else {
          max-x + back-margin + right-i * back-gap
        }
        if left { left-i += 1 } else { right-i += 1 }
        let sx = if left { s.x - s.w / 2 } else { s.x + s.w / 2 }
        let tx = if left { t.x - t.w / 2 } else { t.x + t.w / 2 }
        let pts = ((sx, s.y), (ch, s.y), (ch, t.y), (tx, t.y))
        line(
          ..pts.map(map),
          stroke: edge-stroke,
          mark: (end: ">", fill: arrow-fill, scale: arrow-scale),
        )
        if e.label != none { edge-label(e.label, pts) }
      } else {
        // A long edge drops down its corridor into the target's top — the corridor,
        // vertical run, and entry share one x, so the drop is straight whenever the
        // source's column is clear. A decision exits by the side vertex facing the
        // corridor (kept outside the diamond, so the run leads away from it); any
        // other shape (or a boxed-in diamond) exits its bottom centre and drops
        // clear before jogging across only when the column is blocked.
        let r = route.at(str(ei))
        let cx = r.cx
        let side-ok = r.side-ok
        let entry = attach(t, r.entry, true, 1.0)
        let ay = entry.at(1) + rank-gap / 2
        let head = if side-ok {
          let sx = if cx < s.x { s.x - s.w / 2 } else { s.x + s.w / 2 }
          ((sx, s.y), (cx, s.y))
        } else {
          let dy = s.y - s.h / 2 - rank-gap / 2
          ((s.x, s.y - s.h / 2), (s.x, dy), (cx, dy))
        }
        let pts = head + ((cx, ay), (entry.at(0), ay), entry)
        line(
          ..pts.map(map),
          stroke: edge-stroke,
          mark: (end: ">", fill: arrow-fill, scale: arrow-scale),
        )
        if e.label != none { edge-label(e.label, pts) }
      }
    }

    for p in pos.values() { draw-node(p) }
  })
}
