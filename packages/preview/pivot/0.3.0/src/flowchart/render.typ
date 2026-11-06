#import "@preview/cetz:0.5.2" as cetz
#import "../theme.typ" as theme-mod
#import "model.typ": model
#import "layout.typ": layout
#import "place.typ": label-spots, place

// flowchart: nodes joined by directed edges, laid out in ranked layers. `layout`
// fixes each node's rank and order; `place` (pure) turns measured sizes into
// coordinates — a straight spine, merge targets widened to seat their inputs, a
// corridor per long edge. Here we measure the labels and draw: a direct (one-rank)
// edge runs straight into a single-input target or fans into a shared one; a long or
// back edge takes a side channel clear of the body. The engine works in a canonical
// vertical (top to bottom) flow; `orientation: "horizontal"` is the same picture
// transposed at the draw step. Node colour is opt-in (`fill:`). Returns content.
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
  let max-reach = theme.flowchart-max-reach / 1cm
  let widen-skew = theme.flowchart-widen-skew / 1cm
  let edge-clearance = theme.flowchart-edge-clearance / 1cm
  let lane-gap = theme.flowchart-lane-gap / 1cm
  let stub = theme.flowchart-stub / 1cm
  let margin-step = theme.flowchart-margin-step / 1cm
  let group-pad = theme.flowchart-group-pad / 1cm
  let title-room = theme.flowchart-group-title-room / 1cm
  let gtitle-size = theme.flowchart-group-title-size
  let gtitle-color = theme.flowchart-group-title-color
  let gstroke-color = theme.flowchart-group-stroke-color
  let gstroke-width = theme.flowchart-group-stroke-width
  let gfill-wash = theme.flowchart-group-fill-wash
  let group-radius = theme.flowchart-group-radius / 1cm
  let edge-width = theme.flowchart-node-edge-width
  let edge-darken = theme.flowchart-node-edge-darken
  let node-outline = theme.flowchart-node-outline
  let node-fill = theme.flowchart-node-fill
  let label-size = theme.flowchart-label-size
  let label-color = theme.flowchart-label-color
  let dscale = theme.flowchart-decision-scale
  let io-slant = theme.flowchart-io-slant / 1cm
  let cyl-cap = theme.flowchart-cylinder-cap / 1cm
  let edge-stroke = theme.flowchart-edge-width + theme.flowchart-edge-color
  let line-w = theme.flowchart-edge-width / 1cm // sag tolerance for edge landings
  let arrow-fill = theme.flowchart-edge-color
  let bend-r = theme.flowchart-bend-radius / 1cm
  let arrow-scale = theme.flowchart-arrow-scale
  let elabel-size = theme.flowchart-edge-label-size
  let elabel-color = theme.flowchart-edge-label-color
  let elabel-fill = theme.flowchart-edge-label-fill
  let elabel-inset = theme.flowchart-edge-label-inset

  // Measure each label and give the node a box per shape (a diamond grows to hold
  // the label, a rounded rectangle rounds its corners, a parallelogram leans off vertical).
  let sized = g.cells.map(c => {
    // An outline node carries its accent onto the text too; a plain or filled
    // node keeps the neutral label colour. Decided here because the label is
    // built (and measured) before draw-node runs.
    let txt-col = if c.at("outline", default: none) != none {
      c.outline
    } else { label-color }
    // Centre the label: a multi-line label's shorter lines would otherwise
    // sit left (Typst's default paragraph alignment), off-centre in the
    // shape. A document `#set align` can't reach inside the canvas, so the
    // centring has to live here. Single-line labels fill their box, so it is
    // a no-op for them.
    let lbl = align(center, text(size: label-size, fill: txt-col, c.label))
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
    } else if c.shape == "cylinder" {
      // A cylinder stands upright whatever the flow, so its cap room always
      // rides the final vertical extent: the flow extent in a vertical flow,
      // the cross extent in a horizontal one. Four cap heights: two for the
      // silhouette's caps, two so the front rim dips only to the label's top.
      if orientation == "horizontal" { (ih + 4 * cyl-cap, iw) } else {
        (iw, ih + 4 * cyl-cap)
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

  // Pure placement: spine-aligned positions, merge-widened widths, and each long
  // edge's corridor route (see place.typ).
  // Each group's measured title width rides along: place treats it as the
  // box's minimum width, so a long name widens the box instead of overflowing.
  let ggroups = g.groups.map(gr => (
    ..gr,
    tw: measure(text(size: gtitle-size, gr.title)).width / 1cm,
  ))
  // Each edge label's extent ALONG the flow axis rides along too (the
  // knockout occludes the line over that span): its box height in a
  // vertical flow, its width in a horizontal one. Place grows the gap a
  // labelled edge crosses so the line stays visible past the label.
  let elabel-along = (:)
  for (ei, e) in g.edges.enumerate() {
    if e.label != none {
      let m = measure(box(
        inset: elabel-inset,
        text(size: elabel-size, e.label),
      ))
      elabel-along.insert(
        str(ei),
        (if orientation == "horizontal" { m.width } else { m.height }) / 1cm,
      )
    }
  }
  let placed = place(
    sized,
    g.edges,
    g.ranks,
    groups: ggroups,
    label-along: elabel-along,
    node-gap: node-gap,
    rank-gap: rank-gap,
    pad-x: pad-x,
    back-margin: back-margin,
    max-reach: max-reach,
    widen-skew: widen-skew,
    edge-clearance: edge-clearance,
    lane-gap: lane-gap,
    stub: stub,
    margin-step: margin-step,
    group-pad: group-pad,
    title-room: title-room,
  )

  // Final node geometry for the canvas: placement plus each node's label and style.
  let pos = (:)
  for c in sized {
    pos.insert(str(c.index), (
      x: placed.x.at(str(c.index)),
      y: placed.y.at(str(c.index)),
      rank: c.rank,
      w: placed.w.at(str(c.index)),
      h: c.h,
      th: c.th,
      shape: c.shape,
      fill: c.fill,
      outline: c.at("outline", default: none),
      lbl: c.lbl,
    ))
  }
  let fanout = placed.fanout
  let route = placed.route
  let dseat = placed.dseat
  let dexit = placed.dexit
  // Group boxes, outermost first (parents draw under their children). In a
  // horizontal flow the title band grows on the canonical cross-start side —
  // which maps to the final top, where a title belongs. The canonical-top
  // band is kept too: it is the box's flow-entry side, and entering arrows
  // need their heads clear of the border there.
  let hull-list = g
    .groups
    .filter(gr => gr.id in placed.hulls)
    .map(gr => {
      let h = placed.hulls.at(gr.id)
      if orientation == "horizontal" {
        h = (..h, x0: h.x0 - (title-room - group-pad))
      }
      (gr: gr, h: h)
    })
    .sorted(key: e => e.h.depth)

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

    // Every edge is drawn through here: its canonical points mapped to the
    // canvas, the polyline stroked with the arrowhead at the tip, and each
    // interior corner softened to a `bend-r` fillet — the softer look of a
    // hand-drawn or Mermaid diagram, applied to every edge kind. The fillet
    // cuts back along both incident segments and curves through the corner
    // with a quadratic bézier; the cut-back is capped at half of each
    // adjacent segment, so two neighbouring bends never overrun a short run
    // between them (and a run too short to round stays a crisp right angle).
    // Purely a drawing flourish — placement still reasons in sharp polylines,
    // and the radius is small next to `stub`/`lane-gap`, so labels and
    // clearances are unaffected. `bend-r: 0` restores hard right angles.
    let arrowhead = (end: ">", fill: arrow-fill, scale: arrow-scale)
    let draw-edge = pts => {
      // Collapse consecutive duplicate points (a side entry's tail bend
      // coincides with its endpoint): a zero-length final segment would
      // blunt the arrowhead and confuse the corner fillets.
      let m0 = pts.map(map)
      let m = (m0.first(),)
      for p in m0.slice(1) {
        if (
          calc.abs(p.at(0) - m.last().at(0)) > 1e-6
            or calc.abs(p.at(1) - m.last().at(1)) > 1e-6
        ) { m.push(p) }
      }
      if m.len() < 2 { return }
      if bend-r <= 0 or m.len() < 3 {
        line(..m, stroke: edge-stroke, mark: arrowhead)
        return
      }
      let seg-len = (a, b) => calc.sqrt(
        (b.at(0) - a.at(0)) * (b.at(0) - a.at(0))
          + (b.at(1) - a.at(1)) * (b.at(1) - a.at(1)),
      )
      merge-path(stroke: edge-stroke, mark: arrowhead, {
        let start = m.first()
        for i in range(1, m.len() - 1) {
          let (a, p, b) = (m.at(i - 1), m.at(i), m.at(i + 1))
          let (lin, lout) = (seg-len(a, p), seg-len(p, b))
          let r = calc.min(bend-r, lin / 2, lout / 2)
          if r < 1e-4 {
            // A degenerate or too-short corner stays sharp.
            line(start, p)
            start = p
          } else {
            let cin = (
              p.at(0) - r * (p.at(0) - a.at(0)) / lin,
              p.at(1) - r * (p.at(1) - a.at(1)) / lin,
            )
            let cout = (
              p.at(0) + r * (b.at(0) - p.at(0)) / lout,
              p.at(1) + r * (b.at(1) - p.at(1)) / lout,
            )
            if seg-len(start, cin) > 1e-4 { line(start, cin) }
            bezier(cin, cout, p)
            start = cout
          }
        }
        line(start, m.last())
      })
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
      // An outline node draws with no fill and its accent on the border at full
      // strength (the label already carries the accent). Otherwise: a filled
      // node's border is its own fill darkened, an unfilled one takes the
      // neutral outline. This one choice flows to every shape branch below.
      let outlined = p.outline != none
      let fc = if outlined { none } else if p.fill == none { node-fill } else {
        p.fill
      }
      let edge = (
        edge-width
          + if outlined {
            p.outline
          } else if p.fill == none {
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
      } else if p.shape == "cylinder" {
        // A datastore stands upright whatever the flow, so it is drawn around
        // the mapped centre with unswapped extents — putting it through `map`
        // would lay it on its side. Silhouette first (sides + back of the top
        // rim + front of the bottom), then the front rim over the fill.
        let (fx, fy) = map((x, y))
        let (fw, fh) = if orientation == "horizontal" { (h, w) } else {
          (w, h)
        }
        let fa = fw / 2
        let ytop = fy + fh / 2 - cyl-cap // top rim ellipse centre
        let ybot = fy - fh / 2 + cyl-cap // bottom rim ellipse centre
        merge-path(close: true, fill: fc, stroke: edge, {
          line((fx - fa, ybot), (fx - fa, ytop))
          arc(
            (fx - fa, ytop),
            start: 180deg,
            stop: 0deg,
            radius: (fa, cyl-cap),
            anchor: "arc-start",
          )
          line((fx + fa, ytop), (fx + fa, ybot))
          arc(
            (fx + fa, ybot),
            start: 0deg,
            stop: -180deg,
            radius: (fa, cyl-cap),
            anchor: "arc-start",
          )
        })
        arc(
          (fx - fa, ytop),
          start: 180deg,
          stop: 360deg,
          radius: (fa, cyl-cap),
          anchor: "arc-start",
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
      // The label sits at the node's centre — except in a cylinder, where the
      // visible body runs from the front rim down, so centre the label there.
      let lc = map((x, y))
      if p.shape == "cylinder" {
        lc = (lc.at(0), lc.at(1) - cyl-cap / 2)
      }
      content(lc, p.lbl)
    }

    // A point on a node's outline (top/bottom), nudged `toward` a target x — a
    // diamond's faces slope, so its ports ride up toward the sides. `spread` caps
    // how far along the face a port may sit.
    let attach = (p, toward, top, spread) => {
      let a = p.w / 2
      let b = p.h / 2
      let dx = calc.max(calc.min(toward - p.x, spread * a), -spread * a)
      // The bounding box overstates the landing face: a rounded box curves in at
      // its corners and a parallelogram's slant eats one end of each face. Clamp to
      // the flat span so an edge never points at the gap beside the outline (the
      // radius mirrors draw-node; a diamond's sloped faces are handled below). A
      // landing may run past the flat span while the corner arc has sagged by less
      // than a line width there (sag ≈ dx²/2r) — the tip still reads as touching,
      // and without that slack a hair-off-apex landing on a capsule end (a
      // horizontal terminal, whose entry face is all arc) snaps to the apex and
      // kinks an otherwise straight edge.
      if p.shape == "rounded" {
        let r = calc.min(p.w, p.h, p.th) / 2
        let flat = calc.max(a - r, 0) + calc.min(calc.sqrt(2 * r * line-w), r)
        dx = calc.max(calc.min(dx, flat), -flat)
      } else if p.shape == "parallelogram" {
        // Top face spans [-a + io-slant, a]; bottom face [-a, a - io-slant].
        if top {
          dx = calc.max(dx, calc.min(-a + io-slant, 0))
        } else {
          dx = calc.min(dx, calc.max(a - io-slant, 0))
        }
      } else if p.shape == "cylinder" {
        // Upright whatever the flow. Horizontal flow lands on the straight
        // side between the caps, with slack past its ends while the cap has
        // curved away by less than a line width (sag ≈ cap·dx²/2a²). Vertical
        // flow may land anywhere on the cap — `ey` below drops the landing
        // onto the arc itself. (Clamping to the arc's near-flat middle
        // instead collapsed spaced seats onto one point on a wide datastore,
        // doubling their arrowheads.)
        if orientation == "horizontal" {
          let flat = (
            calc.max(a - cyl-cap, 0)
              + calc.min(calc.sqrt(2 * cyl-cap * line-w), cyl-cap)
          )
          dx = calc.max(calc.min(dx, flat), -flat)
        }
      }
      let ey = if p.shape == "diamond" {
        let rise = b * (1 - calc.abs(dx) / a)
        if top { p.y + rise } else { p.y - rise }
      } else if p.shape == "cylinder" and orientation != "horizontal" {
        // The cap: a half-ellipse, semi-axes (a, cyl-cap), centred on the rim
        // a cap-height inside the bounding box.
        let sag = (
          cyl-cap * (1 - calc.sqrt(calc.max(1 - (dx / a) * (dx / a), 0)))
        )
        if top { p.y + b - sag } else { p.y - b + sag }
      } else if top { p.y + b } else { p.y - b }
      (p.x + dx, ey)
    }
    // A branch label prefers the midpoint of its path's longest vertical run —
    // a label reads cleanly sitting on a vertical line, while its knockout box
    // breaks up a short horizontal stub and looks like a gap. Labels are only
    // *collected* here (with their segments in preference order, mapped to
    // final space); after every edge is drawn, `label-spots` places them all at
    // once so they dodge each other and the nodes, and their knockouts sit over
    // every line already on the canvas.
    let labelled = ()
    let label-item = (lbl, pts) => {
      let segs = range(pts.len() - 1)
        .map(i => {
          let (ax, ay) = pts.at(i)
          let (bx, by) = pts.at(i + 1)
          let vertical = calc.abs(ax - bx) < straight-eps
          (
            score: calc.abs(ay - by)
              + calc.abs(ax - bx)
              + if vertical { 1000 } else { 0 },
            seg: {
              let (fax, fay) = map((ax, ay))
              let (fbx, fby) = map((bx, by))
              (fax, fay, fbx, fby)
            },
          )
        })
        .sorted(key: s => -s.score)
        .map(s => s.seg)
      // Built here only to be measured — the draw pass rebuilds the box with
      // a knockout fill matched to whatever is painted under the label's
      // final spot (fill doesn't change the measure).
      let body = box(
        fill: elabel-fill,
        inset: elabel-inset,
        text(size: elabel-size, fill: elabel-color, lbl),
      )
      let m = measure(body)
      (
        lbl: lbl,
        segs: segs,
        hw: m.width / 2cm,
        hh: m.height / 2cm,
        tip: map(pts.last()),
      )
    }
    // Every drawn segment, as a final-space obstacle box for the label solver:
    // paths are orthogonal, so a segment's bounding box (degenerate in one
    // axis) is the segment exactly. Tagged with its edge — a label may sit on
    // its own line (and break it up), never on another's.
    let edge-lines = ()
    let line-boxes = (ei, pts) => range(pts.len() - 1).map(i => {
      let (fax, fay) = map(pts.at(i))
      let (fbx, fby) = map(pts.at(i + 1))
      (
        edge: ei,
        box: (
          (fax + fbx) / 2,
          (fay + fby) / 2,
          calc.abs(fax - fbx) / 2,
          calc.abs(fay - fby) / 2,
        ),
      )
    })
    // An author's per-edge `label-offset`, in canvas units. It is a final-page
    // shift (+y up, +x right) — the label anchors are already in mapped page
    // space, so no orientation transpose is needed.
    let label-off = e => {
      let o = e.at("label-offset", default: none)
      if o == none { (0, 0) } else { (o.at(0) / 1cm, o.at(1) / 1cm) }
    }

    // Diagram extent; back-edges climb a side channel, long edges take a
    // corridor. Group boxes count: a channel must clear their borders too.
    let min-x = calc.min(
      ..pos.values().map(p => p.x - p.w / 2),
      ..hull-list.map(e => e.h.x0),
    )
    let max-x = calc.max(
      ..pos.values().map(p => p.x + p.w / 2),
      ..hull-list.map(e => e.h.x1),
    )
    let center-x = (min-x + max-x) / 2
    let left-i = 0
    let right-i = 0

    // Group boxes first — under every line and node — outermost to innermost,
    // then their titles (after all the rects, so a child's fill can't cover a
    // parent's title). A title sits inside the box's final-space top-left.
    // A keyword style draws in `bcolor` (the group's border-color) or the
    // theme default; a full Typst stroke carries its own paint and passes
    // through (model forbids pairing it with border-color).
    let gstroke = (s, bcolor) => {
      let paint = if bcolor == none { gstroke-color } else { bcolor }
      if s == "solid" {
        gstroke-width + paint
      } else if s in ("dashed", "dotted") {
        (paint: paint, thickness: gstroke-width, dash: s)
      } else { s }
    }
    // A solid group fill is washed to a gentle tint; a colour that already
    // carries transparency is the author's exact choice, left untouched.
    let gtint = f => if f == none { none } else if (
      type(f) == color and rgb(f).components().last() >= 99%
    ) { f.transparentize(gfill-wash) } else { f }
    let title-items = ()
    for e in hull-list {
      let h = e.h
      rect(
        map((h.x0, h.y0)),
        map((h.x1, h.y1)),
        radius: group-radius,
        stroke: gstroke(e.gr.stroke, e.gr.at("border-color", default: none)),
        fill: gtint(e.gr.fill),
      )
      let (ax, ay) = map((h.x0, h.y0))
      let (bx, by) = map((h.x1, h.y1))
      // Titles are placed after the edges are drawn (see below), so they can
      // slide clear of any line crossing the top band; collect the band now.
      let body = text(size: gtitle-size, fill: gtitle-color, e.gr.title)
      let m = measure(body)
      title-items.push((
        lo: calc.min(ax, bx),
        hi: calc.max(ax, bx),
        top: calc.max(ay, by),
        body: body,
        hw: m.width / 2cm,
        hh: m.height / 2cm,
      ))
      // Border segments join the label obstacles (tagged with no real edge,
      // so no label is exempt): a label must never knock a gap out of a box.
      let (x0, x1) = (calc.min(ax, bx), calc.max(ax, bx))
      let (y0, y1) = (calc.min(ay, by), calc.max(ay, by))
      let (cx, cy) = ((x0 + x1) / 2, (y0 + y1) / 2)
      let (hw, hh) = ((x1 - x0) / 2, (y1 - y0) / 2)
      edge-lines += (
        (edge: -1, box: (cx, y0, hw, 0)),
        (edge: -1, box: (cx, y1, hw, 0)),
        (edge: -1, box: (x0, cy, 0, hh)),
        (edge: -1, box: (x1, cy, 0, hh)),
      )
    }
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
          // Leave at the edge's own exit column — allocated by place when the
          // source has several departures, else the spread aim (the 0.7
          // matches place's projected-landing factor) — and run straight into
          // the target's flow-entry face; bend only if the source overhangs
          // the target.
          let dx2 = dexit.at(str(e.from) + ">" + str(e.to), default: none)
          let exit = if dx2 != none { attach(s, dx2, false, 1.0) } else {
            attach(
              s,
              if fanout.at(str(e.from), default: 0) == 1 { s.x } else { t.x },
              false,
              0.7,
            )
          }
          // A parent the widen caps left off the target's face bends into its
          // allocated seat: down to its fanned approach height, across, in.
          let ds = dseat.at(str(e.from) + ">" + str(e.to), default: none)
          if ds != none {
            let entry = attach(t, ds.x, true, 1.0)
            (exit, (exit.at(0), ds.ay), (entry.at(0), ds.ay), entry)
          } else {
            let entry = attach(t, exit.at(0), true, 1.0)
            if calc.abs(exit.at(0) - entry.at(0)) < straight-eps {
              (exit, entry)
            } else {
              let my = (exit.at(1) + entry.at(1)) / 2
              (exit, (exit.at(0), my), (entry.at(0), my), entry)
            }
          }
        }
        draw-edge(pts)
        edge-lines += line-boxes(ei, pts)
        if e.label != none {
          labelled.push((
            ..label-item(e.label, pts),
            edge: ei,
            off: label-off(e),
          ))
        }
      } else if e.kind == "back" {
        // A loop climbs a side channel: out of the source's side, up, into the target's.
        let left = s.x <= center-x
        let ch = if left {
          min-x - back-margin - left-i * back-gap
        } else {
          max-x + back-margin + right-i * back-gap
        }
        if left { left-i += 1 } else { right-i += 1 }
        // Side endpoints sit on the outline at mid-height: only the parallelogram
        // differs from its bounding box — its slanted side crosses mid-height
        // io-slant/2 in from the corner.
        let side-a = p => (
          p.w / 2 - if p.shape == "parallelogram" { io-slant / 2 } else { 0 }
        )
        let sx = if left { s.x - side-a(s) } else { s.x + side-a(s) }
        let tx = if left { t.x - side-a(t) } else { t.x + side-a(t) }
        let pts = ((sx, s.y), (ch, s.y), (ch, t.y), (tx, t.y))
        draw-edge(pts)
        edge-lines += line-boxes(ei, pts)
        if e.label != none {
          labelled.push((
            ..label-item(e.label, pts),
            edge: ei,
            off: label-off(e),
          ))
        }
      } else if e.kind == "self" {
        // A node onto itself: a small rectangular loop off the source's right
        // side (its cross-axis side once `map`ped), out and back into the same
        // face at quarter-height above and below centre. The parallelogram's
        // slanted side crosses the flank io-slant/2 in, like the back-edge case.
        let a = (
          s.w / 2
            - if s.shape == "parallelogram" { io-slant / 2 } else {
              0
            }
        )
        let d = node-gap * 0.7
        let x0 = s.x + a
        let pts = (
          (x0, s.y + s.h / 4),
          (x0 + d, s.y + s.h / 4),
          (x0 + d, s.y - s.h / 4),
          (x0, s.y - s.h / 4),
        )
        draw-edge(pts)
        edge-lines += line-boxes(ei, pts)
        if e.label != none {
          labelled.push((
            ..label-item(e.label, pts),
            edge: ei,
            off: label-off(e),
          ))
        }
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
        let ay = r.ay
        let head = if side-ok {
          let sx = if cx < s.x { s.x - s.w / 2 } else { s.x + s.w / 2 }
          ((sx, s.y), (cx, s.y))
        } else {
          let dy = r.hy
          let ex = r.at("exit", default: s.x)
          ((ex, s.y - s.h / 2), (ex, dy), (cx, dy))
        }
        // A segmented route steps between columns mid-descent: down to each
        // jog's height, across to its next column, and on. A straight route
        // has no jogs and this adds nothing.
        let px = cx
        let mids = ()
        for j in r.at("jogs", default: ()) {
          mids += ((px, j.y), (j.x, j.y))
          px = j.x
        }
        let pts = head + mids + ((px, ay), (entry.at(0), ay), entry)
        draw-edge(pts)
        edge-lines += line-boxes(ei, pts)
        if e.label != none {
          labelled.push((
            ..label-item(e.label, pts),
            edge: ei,
            off: label-off(e),
          ))
        }
      }
    }

    // Group titles now, with every line known: a title prefers its box's top
    // centre but slides along the band to a spot no edge crosses — an edge
    // entering through the top border would otherwise strike straight through
    // the name. Placed titles are obstacles for each other and for the edge
    // labels below.
    let titles = ()
    let thit = (a, b) => (
      calc.abs(a.at(0) - b.at(0)) < a.at(2) + b.at(2)
        and calc.abs(a.at(1) - b.at(1)) < a.at(3) + b.at(3)
    )
    for t in title-items {
      let cy = t.top - group-pad / 2 - t.hh
      let spot = none
      for f in (0.5, 0.35, 0.65, 0.2, 0.8, 0.12, 0.88) {
        if spot != none { break }
        let cx = calc.max(
          t.lo + t.hw,
          calc.min(t.hi - t.hw, t.lo + (t.hi - t.lo) * f),
        )
        let r = (cx, cy, t.hw + group-pad / 4, t.hh + group-pad / 4)
        if (
          edge-lines.all(q => not thit(r, q.box))
            and titles.all(q => not thit(r, q.box))
        ) { spot = (cx, cy) }
      }
      if spot == none { spot = ((t.lo + t.hi) / 2, cy) }
      titles.push((
        pos: spot,
        body: t.body,
        box: (spot.at(0), spot.at(1), t.hw, t.hh),
      ))
    }
    for t in titles { content(t.pos, t.body) }

    // Labels next, over every line at once: anchors solved together so labels
    // dodge each other and the node boxes (see label-spots).
    let boxes = (
      pos
        .values()
        .map(p => {
          let (fx, fy) = map((p.x, p.y))
          let (hw, hh) = if orientation == "horizontal" {
            (p.h / 2, p.w / 2)
          } else {
            (p.w / 2, p.h / 2)
          }
          (fx, fy, hw, hh)
        })
        // Group titles are obstacles too: a label may sit inside a box, but
        // not on its title.
        + titles.map(t => t.box)
    )
    let spots = label-spots(labelled, boxes, edge-lines, head-room: stub)
    // A label's knockout must vanish into whatever is painted beneath it: on
    // the plain page that is the base knockout colour, inside a tinted group
    // box it is the base with each containing wash layered over it. Composite
    // exactly what the hull pass painted (outermost first — hull-list is
    // depth-sorted), so the box blends in instead of showing as a pale
    // rectangle over the tint. The solver keeps labels off border lines, so
    // an anchor is cleanly inside or outside each box; anything that isn't a
    // plain colour (a gradient fill, a non-colour base) is skipped and the
    // running colour kept — degrade, never fail.
    let hull-tints = hull-list
      .map(e => {
        let (ax, ay) = map((e.h.x0, e.h.y0))
        let (bx, by) = map((e.h.x1, e.h.y1))
        (
          x0: calc.min(ax, bx),
          x1: calc.max(ax, bx),
          y0: calc.min(ay, by),
          y1: calc.max(ay, by),
          tint: gtint(e.gr.fill),
        )
      })
      .filter(t => t.tint != none)
    let knock = p => {
      let base = elabel-fill
      for t in hull-tints {
        if (
          p.at(0) >= t.x0
            and p.at(0) <= t.x1
            and p.at(1) >= t.y0
            and p.at(1) <= t.y1
            and type(base) == color
            and type(t.tint) == color
        ) {
          let b = rgb(base).components()
          let f = rgb(t.tint).components()
          let a = f.at(3)
          base = rgb(
            f.at(0) * a + b.at(0) * (100% - a),
            f.at(1) * a + b.at(1) * (100% - a),
            f.at(2) * a + b.at(2) * (100% - a),
          )
        }
      }
      base
    }
    for (i, it) in labelled.enumerate() {
      content(spots.at(i), box(
        fill: knock(spots.at(i)),
        inset: elabel-inset,
        text(size: elabel-size, fill: elabel-color, it.lbl),
      ))
    }

    for p in pos.values() { draw-node(p) }
  })
}
