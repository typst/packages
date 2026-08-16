#import "@preview/cetz:0.5.2" as cetz
#import "../theme.typ" as theme-mod
#import "../field/model.typ": model
#import "../field/layout.typ": layout

// packet: the entry function. Collects element descriptors, runs the pure
// model -> layout pipeline, and draws the segments with cetz. Returns content.
//
// `callout` controls where narrow fields' labels go:
//   "gap"  — fanned into the enlarged gap below their row (orthogonal leaders)
//   "left" — left-aligned column, leaders fanning left/right (orthogonal)
// `ruler` controls the bit-edge numbers:
//   "dedup" — a boundary number is shown only the first time (top-down) it
//             appears; repeats are hidden and rows that introduce no new boundary
//             lose their number strip and tuck closer (default)
//   "full"  — every box edge is numbered on every row
#let packet(
  ..args,
  bits-per-row: 32,
  callout: "left",
  ruler: "dedup",
  theme: theme-mod.default,
) = context {
  let fields = model(args.pos())
  let segments = layout(fields, bits-per-row: bits-per-row)

  // Capture tokens into differently-named locals BEFORE `import cetz.draw: *`.
  let cell-stroke = theme.stroke
  let cell-fill = theme.fill
  let gap-stroke = theme.gap-stroke
  let gap-fill = theme.gap-fill
  let leader-stroke = theme.leader-stroke
  let bit-w = theme.bit-width / 1cm
  let row-h = theme.row-height / 1cm
  let row-gap = theme.row-gap / 1cm
  let col-gap = theme.col-gap / 1cm
  let strip = theme.strip / 1cm
  let label-size = theme.label-size
  let bit-size = theme.bit-size
  let bit-fill = theme.bit-color
  let bit-font = theme.bit-font
  let label-pad = theme.label-pad / 1cm
  let callout-drop = theme.callout-drop / 1cm
  let callout-bottom = theme.callout-bottom / 1cm
  let callout-spacing = theme.callout-spacing / 1cm
  let callout-gap = theme.callout-gap / 1cm
  let line-h = theme.callout-line-height / 1cm
  let stub = theme.callout-stub / 1cm
  let side-gap = theme.callout-side-gap / 1cm
  let label-gap = theme.callout-label-pad / 1cm
  let gap-drop = theme.callout-gap-drop / 1cm
  let lane-top = theme.callout-gap-lane-top / 1cm
  let lane-bot = theme.callout-gap-lane-bot / 1cm
  let gap-leader = theme.callout-gap-leader / 1cm

  // Measure each segment's label once. "narrow" (label wider than its box -> it
  // needs a callout) and the label width are then O(1) lookups, reused by the
  // filters, the crowding check, the callout list, and the draw loop below.
  let meas = (:)
  for s in segments {
    let w = if s.kind == "gap" or s.label == none {
      0.0
    } else {
      measure(text(size: label-size, s.label)).width / 1cm
    }
    let box-w = (s.col-end - s.col-start + 1) * bit-w - col-gap - 2 * label-pad
    meas.insert(
      str(s.row) + "/" + str(s.col-start),
      (w: w, narrow: s.kind != "gap" and s.label != none and w > box-w),
    )
  }
  let is-narrow = s => meas.at(str(s.row) + "/" + str(s.col-start)).narrow
  let width-of = s => meas.at(str(s.row) + "/" + str(s.col-start)).w
  let callout-rows = segments.filter(is-narrow).map(s => s.row).dedup()
  let max-row = calc.max(0, ..segments.map(s => s.row))
  let count-in = r => segments.filter(s => s.row == r and is-narrow(s)).len()

  // A narrow field's horizontal centre (independent of the vertical layout).
  let cx-of = s => (s.col-start + s.col-end + 1) * bit-w / 2

  // The compact split's LEFT label column: hug the leftmost field, but clamp so
  // the widest label can't cross the frame's left edge (x = 0). Shared by the
  // crowding test and the layout so both reason about the same geometry. `lg` is
  // a non-empty list of items with `.cx` (field centre) and `.w` (label width).
  let left-col-x = lg => calc.max(
    calc.min(..lg.map(c => c.cx)) - side-gap,
    calc.max(..lg.map(c => c.w)) + label-gap,
  )

  // Per callout row: would the compact left/right split cross a label? It does
  // when a left-column field's drop falls within a higher label's text — i.e. the
  // row is crowded with thin segments. Such rows switch to a single column placed
  // OUTSIDE the frame (the struct layout), crossing-free by construction.
  let crowded = (:)
  for r in callout-rows {
    let info = segments
      .filter(s => s.row == r and is-narrow(s))
      .sorted(key: s => s.col-start)
      .map(s => (cx: cx-of(s), w: width-of(s)))
    let left = info.slice(0, calc.ceil(info.len() / 2))
    // Predict the compact-split LEFT layout: labels right-aligned at
    // `lx - label-gap`; a field left of `lx` drops a short straight stub. Such a
    // stub crosses an earlier label when the field's centre falls within that
    // label's text span. (A field right of `lx` turns in from beyond every label,
    // and the right group's labels sit beyond every field, so neither can cross.)
    // A row that would cross switches to the crowded single-column layout below.
    let cross = false
    if left.len() >= 2 {
      let lx = left-col-x(left)
      let label-right = lx - label-gap
      for j in range(1, left.len()) {
        if left.at(j).cx < lx {
          for i in range(0, j) {
            if (
              left.at(j).cx >= label-right - left.at(i).w
                and left.at(j).cx <= label-right
            ) { cross = true }
          }
        }
      }
    }
    crowded.insert(str(r), cross)
  }

  // Height of the annotation band below a callout row. A crowded row uses one
  // tall column; otherwise the taller of the split's two columns sets the height.
  let band = r => {
    if callout != "left" {
      callout-gap
    } else if crowded.at(str(r), default: false) {
      callout-drop + (count-in(r) - 1) * line-h + callout-bottom
    } else {
      let half = calc.ceil(count-in(r) / 2)
      let lanes = calc.max(half, count-in(r) - half)
      callout-drop + (lanes - 1) * line-h + callout-bottom
    }
  }

  // Ruler de-duplication. A boundary is keyed by (position, number) so a right
  // edge `15` and a left edge `16` near the same x stay distinct. In "dedup"
  // mode a key is shown only the first time it appears top-down; later repeats
  // hide, and a row that introduces none keeps no number strip. "full" shows all.
  let seen = ()
  let show-num = (:)
  let row-has-num = (:)
  for r in range(0, max-row + 1) {
    let any = false
    for s in segments.filter(s => s.row == r).sorted(key: s => s.col-start) {
      let lk = (s.col-start, s.col-start)
      let rk = (s.col-end + 1, s.col-end)
      let sl = ruler == "full" or not seen.contains(lk)
      let sr = ruler == "full" or not seen.contains(rk)
      if not seen.contains(lk) { seen.push(lk) }
      if not seen.contains(rk) { seen.push(rk) }
      show-num.insert(str(r) + "/" + str(s.col-start), (left: sl, right: sr))
      any = any or sl or sr
    }
    row-has-num.insert(str(r), any)
  }

  // Precompute each row's box-top y (rows stack downward; up is positive). A row
  // with no visible ruler numbers needs no top strip, so it tucks closer.
  let box-tops = ()
  let row-pad = ()
  let yacc = 0.0
  for r in range(0, max-row + 1) {
    let pad = if row-has-num.at(str(r)) { strip } else { 0.0 }
    row-pad.push(pad)
    box-tops.push(-(yacc + pad))
    let gap-below = if callout-rows.contains(r) { band(r) } else { row-gap }
    yacc += pad + row-h + gap-below
  }

  // Geometry of a segment's box, and the narrow ones' callout data (widths
  // measured here, in `context`, so leaders can stop just past each label).
  let seg-box = s => {
    let x0 = s.col-start * bit-w + col-gap / 2
    let x1 = (s.col-end + 1) * bit-w - col-gap / 2
    let top = box-tops.at(s.row)
    (x0: x0, x1: x1, top: top, bot: top - row-h)
  }
  let callouts = segments
    .filter(is-narrow)
    .map(s => {
      let b = seg-box(s)
      (
        row: s.row,
        cx: (b.x0 + b.x1) / 2,
        by: b.bot,
        label: s.label,
        w: width-of(s),
      )
    })

  cetz.canvas({
    import cetz.draw: *

    for s in segments {
      let b = seg-box(s)
      let is-gap = s.kind == "gap"
      let box-stroke = if is-gap { gap-stroke } else { cell-stroke }
      let box-fill = if is-gap { gap-fill } else if s.fill != none {
        s.fill
      } else { cell-fill }
      rect((b.x0, b.bot), (b.x1, b.top), stroke: box-stroke, fill: box-fill)

      if (not is-gap) and s.label != none and not is-narrow(s) {
        content(((b.x0 + b.x1) / 2, (b.top + b.bot) / 2), text(
          size: label-size,
          s.label,
        ))
      }

      let ny = b.top + row-pad.at(s.row) / 2
      let sn = show-num.at(str(s.row) + "/" + str(s.col-start))
      if sn.left {
        content(
          (b.x0, ny),
          text(size: bit-size, font: bit-font, fill: bit-fill, str(
            s.col-start,
          )),
          anchor: "west",
        )
      }
      if sn.right {
        content(
          (b.x1, ny),
          text(size: bit-size, font: bit-font, fill: bit-fill, str(s.col-end)),
          anchor: "east",
        )
      }
    }

    for r in callouts.map(c => c.row).dedup() {
      let group = callouts.filter(c => c.row == r).sorted(key: c => c.cx)
      let n = group.len()
      let row-bot = box-tops.at(r) - row-h

      if callout == "left" and crowded.at(str(r), default: false) {
        // Crowded row: one column OUTSIDE the frame (the struct layout). Labels
        // right-aligned just left of the leftmost field, drops stay inside the
        // frame, so a drop can never cut a label; leftmost field on top keeps the
        // orthogonal leaders un-crossed.
        let gutter = calc.min(..group.map(c => c.cx)) - side-gap
        for (i, c) in group.enumerate() {
          let y = row-bot - callout-drop - i * line-h
          line((c.cx, c.by), (c.cx, y), (gutter, y), stroke: leader-stroke)
          content(
            (gutter - label-gap, y),
            text(size: label-size, c.label),
            anchor: "east",
          )
        }
      } else if callout == "left" {
        // Compact split into two columns, each anchored to its OWN fields: the
        // left half fans left to just past the leftmost field, the right half
        // fans right past the rightmost — so neither group strands its labels at
        // the frame edge. Lane order (outermost field on top per side) keeps the
        // orthogonal leaders un-crossed. Used when the row would not crowd.
        let mid = calc.ceil(n / 2)
        let left-grp = group.slice(0, mid)
        let right-grp = group.slice(mid)

        // Left column (see `left-col-x`): hug the leftmost field, clamped to the
        // frame edge. A field hard against the edge then gets a straight stub
        // rather than a leader turning rightward through its own label.
        let left-x = left-col-x(left-grp)
        for (i, c) in left-grp.enumerate() {
          let y = row-bot - callout-drop - i * line-h
          // A field to the right of the column turns left onto its label; a field
          // sitting over its own label (clamped column) gets a short straight
          // stub instead, so the leader never runs through the text.
          if c.cx >= left-x {
            line((c.cx, c.by), (c.cx, y), (left-x, y), stroke: leader-stroke)
          } else {
            line((c.cx, c.by), (c.cx, y + stub), stroke: leader-stroke)
          }
          content(
            (left-x - label-gap, y),
            text(size: label-size, c.label),
            anchor: "east",
          )
        }

        // Right half — empty when the row has a single narrow field (it falls in
        // `left-grp`), so guard against `calc.max` of nothing. Unlike the left, it
        // extends outward unclamped: a long label on a far-right field may spill
        // past the frame's right edge, the accepted fallback when a label has
        // nowhere else to go.
        if right-grp.len() > 0 {
          let right-x = calc.max(..right-grp.map(c => c.cx)) + side-gap
          let right-n = right-grp.len()
          for (i, c) in right-grp.enumerate() {
            let y = row-bot - callout-drop - (right-n - 1 - i) * line-h
            line((c.cx, c.by), (c.cx, y), (right-x, y), stroke: leader-stroke)
            content(
              (right-x + label-gap, y),
              text(size: label-size, c.label),
              anchor: "west",
            )
          }
        }
      } else {
        // In-gap fan: orthogonal Z leaders, label row near the band's bottom.
        let centroid = group.map(c => c.cx).sum() / n
        let start-lx = centroid - (n - 1) * callout-spacing / 2
        let items = group
          .enumerate()
          .map(((i, c)) => (
            cx: c.cx,
            by: c.by,
            label: c.label,
            lx: start-lx + i * callout-spacing,
          ))
        let label-y = row-bot - callout-gap + gap-drop
        let lane-hi = row-bot - lane-top
        let lane-lo = label-y + lane-bot
        let order = items
          .enumerate()
          .sorted(key: ((j, it)) => -calc.abs(it.lx - centroid))
        for (rank, (j, it)) in order.enumerate() {
          let t = if n <= 1 { 0 } else { rank / (n - 1) }
          let lane = lane-lo + t * (lane-hi - lane-lo)
          line(
            (it.cx, row-bot),
            (it.cx, lane),
            (it.lx, lane),
            (it.lx, label-y + gap-leader),
            stroke: leader-stroke,
          )
          content(
            (it.lx, label-y),
            text(size: label-size, it.label),
            anchor: "north",
          )
        }
      }
    }
  })
}
