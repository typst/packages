// boxplot.typ - Box-and-whisker plot
#import "../theme.typ": _resolve-ctx, get-color
#import "../validate.typ": validate-boxplot-data
#import "../primitives/frame.typ": cartesian-frame
#import "../primitives/axes.typ": value-axis, category-axis, value-text, compact-text
#import "../primitives/layout.typ": resolve-size, spread-labels

/// Renders a box-and-whisker plot for comparing distributions.
///
/// - data (dictionary): Dict with `labels` and `boxes` (each with `min`, `q1`, `median`, `q3`, `max`,
///   and optional `outliers` array of values outside the whiskers)
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - box-width (float): Box width as fraction of slot (0 to 1)
/// - show-values (bool): Display five-number summary labels beside each box. Where boxes sit
///   too close for all five, the labels shrink (to a legible floor), then thin out to the
///   median and extremes, then to the median alone, then none: they never touch a box or each other
/// - show-grid (auto, bool): Draw background grid lines; `auto` uses theme default
/// - stroke-width (auto, length): Stroke width for box outlines and whiskers; `auto` uses the theme's `stroke-mid`
/// - outlier-radius (length): Radius of outlier marker dots
/// - include-zero (bool): Extend the value axis to include zero; off by default so the axis fits the data
/// - x-label (none, content): X-axis title
/// - y-label (none, content): Y-axis title
/// - annotations (none, array): Optional annotation descriptors (see annotations.typ)
/// - theme (none, dictionary): Theme overrides
/// -> content
#let box-plot(
  data,
  width: auto,
  height: auto,
  title: none,
  box-width: 0.5,
  show-values: false,
  show-grid: auto,
  stroke-width: auto,
  outlier-radius: 2pt,
  include-zero: false,
  x-label: none,
  y-label: none,
  annotations: none,
  theme: none,
) = context {
  layout(size => {
  validate-boxplot-data(data, "box-plot")
  let grid-overrides = if show-grid != auto { (show-grid: show-grid) } else { none }
  let t = _resolve-ctx(theme, overrides: grid-overrides)
  let stroke-width = if stroke-width == auto { t.stroke-mid } else { stroke-width }
  let (width, height) = resolve-size(width, height, size, n: data.labels.len(), theme: t)
  let (labels, boxes) = (data.labels, data.boxes)

  // The axis covers every whisker and outlier. Box plots compare spreads, so by
  // default it fits the data rather than stretching down to a zero baseline.
  let extremes = boxes.map(b => (b.min, b.max, ..b.at("outliers", default: ()))).flatten()
  let (lo, hi) = (calc.min(..extremes), calc.max(..extremes))
  let (lo, hi) = if include-zero { (calc.min(0, lo), calc.max(0, hi)) } else { (lo, hi) }

  cartesian-frame(width, height, t,
    x: category-axis(labels, title: x-label),
    y: value-axis(lo, hi, title: y-label),
    title: title, annotations: annotations,
    p => {
      let (px, py) = (p.px, p.py)
      let half-box = p.X.pitch * box-width / 2
      let half-cap = half-box / 2
      for (i, b) in boxes.enumerate() {
        let cx = px(i)
        let color = get-color(t, i)
        let whisker = stroke-width + color
        let (y-min, y-q1, y-med, y-q3, y-max) = (b.min, b.q1, b.median, b.q3, b.max).map(py)

        // Whiskers (min to q1, q3 to max) with a cap at each end
        place(left + top, line(start: (cx, y-min), end: (cx, y-q1), stroke: whisker))
        place(left + top, line(start: (cx, y-q3), end: (cx, y-max), stroke: whisker))
        for y in (y-min, y-max) {
          place(left + top, line(start: (cx - half-cap, y), end: (cx + half-cap, y), stroke: whisker))
        }

        // Box from q1 to q3, with the median across it
        place(left + top, dx: cx - half-box, dy: y-q3,
          rect(width: half-box * 2, height: y-q1 - y-q3, fill: color.transparentize(20%), stroke: whisker))
        place(left + top, line(start: (cx - half-box, y-med), end: (cx + half-box, y-med),
          stroke: stroke-width * 2 + t.text-color-inverse))

        for o in b.at("outliers", default: ()) {
          place(left + top, dx: cx - outlier-radius, dy: py(o) - outlier-radius,
            circle(radius: outlier-radius, fill: color, stroke: none))
        }
      }

      // Five-number summary next to each box. What is shown is the richest set that fits
      // at a legible size: all five values, else the median and the extremes, else the
      // median, else the extremes alone, else the maxima. Each set is tried in the values as given, then
      // in 3 and in 2 significant digits (`15.35` -> `15.3` -> `15`, `85200` -> `85.2k`
      // -> `85k`). Values sit beside their box, on the side that is free; a maximum or
      // minimum with no room beside its box goes above or below the whisker instead. The
      // type is as large as the room allows (down to a floor), and every label is checked
      // against every box, whisker, outlier and other label, so none touches another. Only
      // when not even the extremes fit on every box are they shown on every second (third)
      // box, which have room for two (three) pitches.
      if show-values {
        let base = t.value-label-size
        let floor = calc.min(5.5pt, base * 0.8)
        let sums = boxes.map(b => (b.max, b.q3, b.median, b.q1, b.min))
        let n = boxes.len()
        let pitch = p.X.pitch
        let hit(a, b) = a.x < b.x + b.w and b.x < a.x + a.w and a.y < b.y + b.h and b.y < a.y + a.h
        let sw = stroke-width

        // texts.at(level).at(box).at(kind), and their widths at the base size
        let texts = (0, 1, 2).map(level => sums.map(vals => vals.map(v => {
          if level > 0 { compact-text(v, t, sig: 4 - level) } else {
            let tv = value-text(v, t)
            if type(tv) == int or type(tv) == float { str(tv) } else { tv }
          }
        })))
        let widths = texts.map(lv => lv.map(row => row.map(tx => measure(text(size: base)[#tx]).width)))
        let widest(level, kinds) = kinds.map(k => range(n).map(i => widths.at(level).at(i).at(k)).fold(0pt, calc.max)).fold(0pt, calc.max)

        // What labels must stay clear of, box by box: the box, whiskers with caps, outliers
        let solids = boxes.enumerate().map(((i, b)) => {
          let cx = px(i)
          let out = ((x: cx - half-box, y: py(b.q3), w: half-box * 2, h: py(b.q1) - py(b.q3)),
            (x: cx - sw / 2, y: py(b.max), w: sw, h: py(b.min) - py(b.max)))
          for y in (py(b.min), py(b.max)) { out.push((x: cx - half-cap, y: y - sw / 2, w: half-cap * 2, h: sw)) }
          for o in b.at("outliers", default: ()) {
            out.push((x: cx - outlier-radius, y: py(o) - outlier-radius, w: outlier-radius * 2, h: outlier-radius * 2))
          }
          out
        })

        // Tries to place the labels of `kinds` in `level` text at `size`, on every
        // `stride`-th box
        let attempt(kinds, level, size, stride) = {
          let lbl-h = size * 1.1
          let ratio = size / base
          // Beside a box, the values of that box keep clear of each other
          let ys = sums.map(vals => {
            let ks = kinds.sorted()
            let spread = spread-labels(ks.map(k => py(vals.at(k))), gap: lbl-h, lo: p.y0, hi: p.y1)
            let out = (:)
            for (j, k) in ks.enumerate() { out.insert(str(k), spread.at(j)) }
            out
          })
          let placed = range(n).map(_ => ())
          let items = ()
          for k in kinds {
            for i in range(0, n, step: stride) {
              let w = widths.at(level).at(i).at(k) * ratio
              let cx = px(i)
              let v-edge = if k == 0 { py(boxes.at(i).max) - sw / 2 - 1.2pt - lbl-h / 2 } else { py(boxes.at(i).min) + sw / 2 + 1.2pt + lbl-h / 2 }
              // Beside on the right, then on the left, then (extremes) above or below the whisker
              let spots = (
                (cx + half-box + 2.5pt, ys.at(i).at(str(k)), "beside"),
                (cx - half-box - 2.5pt - w, ys.at(i).at(str(k)), "beside"),
              )
              if k == 0 or k == 4 { spots.push((cx - w / 2, v-edge, if k == 0 { "above" } else { "below" })) }
              for (x0, yc, pos) in spots {
                if yc == none { continue }  // no room beside the box for this value
                // above or below a whisker the label may slide to stay inside the plot
                let x = if pos == "beside" { x0 } else { calc.min(calc.max(x0, p.x0 + 1.5pt), width - w - 1.5pt) }
                let r = (x: x - 0.5pt, y: yc - lbl-h / 2, w: w + 1pt, h: lbl-h)
                if r.x < (if pos == "beside" { p.x0 } else { 0pt }) or r.x + r.w > width { continue }
                if r.y < 0pt or (pos == "below" and r.y + r.h > p.y1) { continue }
                let near = range(calc.max(i - 1, 0), calc.min(i + 2, n))
                if near.any(j => solids.at(j).any(o => hit(o, r)) or placed.at(j).any(o => hit(o, r))) { continue }
                placed.at(i).push(r)
                items.push((x: x, y: yc, txt: texts.at(level).at(i).at(k), size: size))
                break
              }
            }
          }
          (placed: items.len(), total: kinds.len() * calc.ceil(n / stride), items: items)
        }

        // Sets in order of richness. Within a set the values as given win unless a shorter
        // form lets the type grow by a quarter or more; a set whose labels mostly (85%) find
        // a place is taken, else the set that placed the largest share is drawn
        let search(stride) = {
          let best = none
          for kinds in ((2, 0, 4, 1, 3), (2, 0, 4), (2,), (0, 4), (0,)) {
            if best != none and best.placed >= 0.85 * best.total { continue }
            let pick = none
            let side = kinds.filter(k => k in (1, 2, 3))
            for level in (0, 1, 2) {
              if level > 0 and texts.at(level) == texts.at(level - 1) { continue }
              // The type size the room gives this set: beside the boxes for the inner values,
              // beside or above for extremes alone
              let w-side = widest(level, kinds)
              let gap = pitch * stride - half-box * 2 - 3.5pt
              let room = if side.len() > 0 { gap } else { calc.max(gap, pitch * stride - 1pt) }
              let size = if w-side > 0pt and room > 0pt { calc.min(base, base * (room / w-side)) } else { 0pt }
              // (the extremes alone are the last resort: they may go a little below the floor)
              if size < (if side.len() > 0 { floor } else { calc.min(5pt, floor) }) { continue }
              let r = attempt(kinds, level, size, stride)
              if r.placed < 0.85 * r.total {
                if pick == none and (best == none or r.placed / r.total > best.placed / best.total) { best = r }
                continue
              }
              if pick == none or size >= pick.size * 1.25 { pick = (..r, size: size) }
            }
            if pick != none { best = pick }
          }
          best
        }
        let best = search(1)
        if best == none or best.placed == 0 {
          for stride in (2, 3) {
            let r = search(stride)
            if r != none and r.placed > 0 { best = r; break }
          }
        }
        if best != none {
          for it in best.items {
            place(left + top, dx: it.x, dy: it.y,
              box(height: 0pt, align(horizon, text(size: it.size, fill: t.text-color)[#it.txt])))
          }
        }
      }
    },
  )
  })
}
