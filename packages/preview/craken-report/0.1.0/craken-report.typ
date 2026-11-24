// ─────────────────────────────────────────────────────────────────────────────
//  Captain Craken — lab report template for Typst
//  The house style of the Craken books, cut down to an A4 report on the full
//  page width: a cover with everything the course asks for, numbered
//  sections, figures, tables, listings, equations, footnotes and charts
//  drawn in Typst.
//
//    typst init @preview/craken-report:0.1.0 my-lab
//    typst compile report.typ                          (A4 PDF)
//    typst compile --input theme=lantern report.typ    (dark PDF, for screens)
// ─────────────────────────────────────────────────────────────────────────────

// ── Colours ──────────────────────────────────────────────────────────────────

#let palettes = (
  paper: (
    paper: rgb("#fbf7f0"),
    paper-warm: rgb("#f4eadc"),
    rule: rgb("#e3d5c1"),
    ink: rgb("#2e221b"),
    ink-soft: rgb("#6c5849"),
    rust: rgb("#a63f29"),
    amber: rgb("#8f5e0e"),
    moss: rgb("#55602e"),
    coral: rgb("#e9664e"),
    peach: rgb("#f8c597"),
  ),
  lantern: (
    paper: rgb("#1c1612"),
    paper-warm: rgb("#282019"),
    rule: rgb("#3b3029"),
    ink: rgb("#f0e6d8"),
    ink-soft: rgb("#b9a695"),
    rust: rgb("#f08b6e"),
    amber: rgb("#deac55"),
    moss: rgb("#adba7a"),
    coral: rgb("#e8735b"),
    peach: rgb("#6e4632"),
  ),
)

#let theme = sys.inputs.at("theme", default: "paper")
#let palette = palettes.at(theme)

/// Chart series, in order: coral, moss, amber, ink-soft.
#let series-colors = (palette.coral, palette.moss, palette.amber, palette.ink-soft)

// ── Type ─────────────────────────────────────────────────────────────────────

#let fonts = (
  display: ("Fraunces Soft Display", "Libertinus Serif"), // title, sections
  label: ("Fraunces Soft Text", "Libertinus Serif"), // labels, subsections, folios
  text: ("Newsreader Text", "Libertinus Serif"), // everything you read
  mono: ("DM Mono", "DejaVu Sans Mono"), // code
  math: ("STIX Two Math", "New Computer Modern Math"),
)

// The Craken print sizes (body 10.5/17.5pt, everything else scaled by the
// same ratio): the line runs the full A4 width, so the type stays compact.
#let type-size = (
  title: 40pt,
  section: 17.5pt,
  subsection: 12.25pt,
  subsubsection: 10.5pt,
  label: 8.75pt,
  lede: 13pt,
  body: 10.5pt,
  caption: 8.75pt,
  note: 8.25pt,
  code: 8.75pt,
  tick: 8pt,
)

// Baseline-to-baseline distances (text boxes are exactly 1em tall).
#let line-height = (
  title: 44pt,
  section: 22pt,
  body: 17.5pt,
  lede: 20pt,
  caption: 13.5pt,
  note: 12.25pt,
  code: 14pt,
)

// ── Space, radius, page grid ─────────────────────────────────────────────────

#let spacing = (s1: 2.5pt, s2: 4.5pt, s4: 8.75pt, s6: 14pt, s8: 17.5pt, s12: 26.25pt, s24: 52.5pt)
#let radii = (s: 2pt, m: 5pt)

// A4, one column on the full width (166 mm), no margin column.
#let page-grid = (
  width: 210mm,
  height: 297mm,
  side: 22mm,
  top: 24mm,
  bottom: 26mm,
)

// ── Small helpers ────────────────────────────────────────────────────────────

#let _lead(size, height) = height - size // par leading for a 1em-tall line box

#let label-text(fill: palette.ink-soft, body) = text(
  font: fonts.label,
  weight: 600,
  size: type-size.label,
  fill: fill,
  body,
)

#let _sucker(color, d, filled, stroke) = box(
  width: d,
  height: d,
  baseline: 0.05em,
  {
    place(center + horizon, circle(radius: d / 2 - stroke / 2, stroke: stroke + color))
    if filled { place(center + horizon, circle(radius: d * 0.19, fill: color)) }
  },
)

/// The one ornament: a ring with a dot, from the kraken's tentacles.
#let sucker(color: palette.coral, d: 6.5pt, filled: true, stroke: 0.9pt) = _sucker(color, d, filled, stroke)

/// A new term, introduced once.
#let dfn(body) = text(style: "italic", weight: 600, body)

/// The report's first paragraph, a step larger.
#let lede(body) = block(below: spacing.s12, {
  set text(size: type-size.lede)
  set par(leading: _lead(type-size.lede, line-height.lede), justify: false)
  body
})

/// Three suckers: a break inside a section.
#let sbreak() = {
  let s = _sucker(palette.coral, 6.5pt, true, 0.9pt)
  block(above: spacing.s12, below: spacing.s12, width: 100%, align(center, stack(
    dir: ltr,
    spacing: spacing.s4,
    s,
    s,
    s,
  )))
}

// ── Code ─────────────────────────────────────────────────────────────────────

/// A titled, optionally numbered code box. Plain ```blocks``` get the same box.
///   #code(title: [solver.c], lang: [C], numbers: true)[```c …```]
/// first-line: the number of the first line, for an excerpt of a file.
#let code(body, title: none, lang: none, numbers: false, first-line: 1) = {
  show raw.line: it => {
    if numbers {
      box(width: 1.6em, align(right, text(fill: palette.ink-soft, str(it.number + first-line - 1))))
      h(1.2em)
    }
    it
  }
  [#block(
    width: 100%,
    above: spacing.s8,
    below: spacing.s8,
    radius: radii.m,
    clip: true,
    breakable: true,
    {
      if title != none or lang != none {
        block(
          width: 100%,
          inset: (x: spacing.s6, top: spacing.s4, bottom: 0pt),
          spacing: 0pt,
          sticky: true,
          {
            set text(font: fonts.mono, size: 7.5pt, fill: palette.ink-soft)
            set align(start)
            title
            h(1fr)
            lang
          },
        )
      }
      block(width: 100%, inset: (x: spacing.s6, y: spacing.s4), spacing: 0pt, {
        set align(start)
        show raw.where(block: true): set block(fill: none, inset: 0pt, radius: 0pt, above: 0pt, below: 0pt)
        body
      })
    },
  )<craken-code-box>]
}

/// A numbered listing ("Listing 2") with a caption above: code() in a figure.
#let listing(body, caption: none, title: none, lang: none, numbers: false, first-line: 1) = figure(
  code(body, title: title, lang: lang, numbers: numbers, first-line: first-line),
  kind: raw,
  supplement: [Listing],
  caption: caption,
)

/// Lines `from` to `to` (1-based, inclusive) of a source file you read():
///   #raw(lines(read("code/solver.c"), 12, 30), lang: "c", block: true)
#let lines(source, from, to) = source.split("\n").slice(from - 1, calc.min(to, source.split("\n").len())).join("\n")

// ── Tables ───────────────────────────────────────────────────────────────────

/// A row that names a group of rows below it, across `columns` columns.
///   table(columns: 5, …, table-section(5)[Efficiency], …)
#let table-section(columns, body) = table.cell(
  colspan: columns,
  align: start,
  inset: (x: spacing.s4, top: spacing.s6, bottom: spacing.s2),
  stroke: (bottom: 0.5pt + palette.rule),
  label-text(fill: palette.ink, body),
)

// ── Charts drawn in Typst ────────────────────────────────────────────────────
// No packages needed. Lines and dots in series order (coral, moss, amber,
// ink-soft), rule gridlines, each line labelled at its end, no title inside
// the chart (the figure's caption does that).

#let ink-line = 1.2pt + palette.ink

/// Points from a CSV you read with row-type: dictionary (or a header row):
///   #let data = csv("data/speedup.csv", row-type: dictionary)
///   points: csv-points(data, x: "threads", y: "jacobi")
#let csv-points(rows, x: 0, y: 1) = {
  if rows.len() == 0 { return () }
  if type(rows.first()) == dictionary {
    rows.map(r => (float(r.at(x).trim()), float(r.at(y).trim())))
  } else {
    let head = rows.first()
    let col(k) = if type(k) == str { head.position(h => h.trim() == k) } else { k }
    let (xi, yi) = (col(x), col(y))
    let body = if type(x) == str or type(y) == str { rows.slice(1) } else { rows }
    body.map(r => (float(r.at(xi).trim()), float(r.at(yi).trim())))
  }
}

#let _resolve(width, total) = if type(width) == ratio { total * (width / 100%) } else if type(width) == relative {
  total * (width.ratio / 100%) + width.length
} else { width }

#let _fmt(v) = {
  let r = calc.round(v, digits: 6)
  if calc.abs(r - calc.round(r)) < 1e-9 { str(int(calc.round(r))) } else { str(r) }
}

#let _fwd(v, scale) = if scale == "log2" { calc.log(v, base: 2) } else if scale == "log10" {
  calc.log(v, base: 10)
} else { v }

#let _inv(v, scale) = if scale == "log2" { calc.pow(2.0, v) } else if scale == "log10" { calc.pow(10.0, v) } else {
  v
}

// A round step giving about n intervals over [lo, hi].
#let _nice-step(lo, hi, n) = {
  let span = if hi > lo { hi - lo } else { calc.abs(hi) + 1 }
  let raw = span / n
  let mag = calc.pow(10.0, calc.floor(calc.log(raw, base: 10)))
  let f = raw / mag
  (if f < 1.5 { 1 } else if f < 3 { 2 } else if f < 7 { 5 } else { 10 }) * mag
}

// Resolves an axis: (lo, hi, ticks) in data units. Ticks are (value, label).
#let _axis(values, scale, lo, hi, ticks, zero: false, n: 5) = {
  let given = if ticks == auto or ticks == none { () } else {
    ticks.map(t => if type(t) == array { t } else { (t, _fmt(t)) })
  }
  let vals = values + given.map(t => t.at(0))
  let dmin = if vals.len() > 0 { calc.min(..vals) } else { 0 }
  let dmax = if vals.len() > 0 { calc.max(..vals) } else { 1 }
  if zero and scale == "linear" and dmin >= 0 { dmin = 0 }
  if dmax == dmin { dmax = dmin + 1 }
  if scale == "linear" {
    let step = _nice-step(if lo == auto { dmin } else { lo }, if hi == auto { dmax } else { hi }, n)
    let l = if lo != auto { lo } else if given.len() > 0 { dmin } else { calc.floor(dmin / step + 1e-9) * step }
    let h = if hi != auto { hi } else if given.len() > 0 { dmax } else { calc.ceil(dmax / step - 1e-9) * step }
    let t = if ticks == none { () } else if given.len() > 0 { given } else {
      let k0 = calc.ceil(l / step - 1e-9)
      let k1 = calc.floor(h / step + 1e-9)
      range(int(k0), int(k1) + 1).map(k => (k * step, _fmt(k * step)))
    }
    (l, h, t)
  } else {
    let base = if scale == "log2" { 2 } else { 10 }
    let e0 = calc.floor(_fwd(dmin, scale) + 1e-9)
    let e1 = calc.ceil(_fwd(dmax, scale) - 1e-9)
    let l = if lo != auto { lo } else if given.len() > 0 { dmin } else { _inv(e0, scale) }
    let h = if hi != auto { hi } else if given.len() > 0 { dmax } else { _inv(e1, scale) }
    let t = if ticks == none { () } else if given.len() > 0 { given } else {
      range(int(e0), int(e1) + 1).map(e => (_inv(e, scale), _fmt(_inv(e, scale))))
    }
    (l, h, t)
  }
}

#let _tick-text(body) = text(
  font: fonts.text,
  size: type-size.tick,
  fill: palette.ink-soft,
  number-type: "lining",
  number-width: "tabular",
  if type(body) == str { body } else { body },
)
#let _label-style(body) = text(font: fonts.text, size: type-size.caption, fill: palette.ink-soft, body)

// Places `body` so that its `anchor` point sits at (x, y).
#let _at(x, y, anchor, body) = context {
  let s = measure(body)
  let dx = if anchor.x == right { x - s.width } else if anchor.x == center { x - s.width / 2 } else { x }
  let dy = if anchor.y == bottom { y - s.height } else if anchor.y == horizon { y - s.height / 2 } else { y }
  place(top + left, dx: dx, dy: dy, body)
}

#let _stroke(color, dashed, thickness: 1.5pt) = (
  paint: color,
  thickness: thickness,
  cap: "round",
  join: "round",
  dash: if dashed { (3pt, 3pt) } else { none },
)

/// A line or scatter chart.
///   #plot(
///     x-label: [Threads], y-label: [Speed-up], x-scale: "log2",
///     series: (
///       (label: [Jacobi], points: ((1, 1), (2, 1.9), (4, 3.6))),
///       (label: [Ideal], fn: x => x, dashed: true, marks: false),
///     ),
///   )
/// Each series: label, points ((x, y), …) or fn (x => y), and optionally
/// color (default: series order), line (false: dots only), dashed, marks.
/// Scales: "linear", "log2", "log10". Ticks: auto, none, (1, 2, 4) or
/// ((1, [one]), (2, [two])). legend: "end" labels each line at its end,
/// "top" puts a key above the chart, none hides labels.
#let plot(
  series: (),
  width: 100%,
  height: 62mm,
  x-label: none,
  y-label: none,
  x-scale: "linear",
  y-scale: "linear",
  x-min: auto,
  x-max: auto,
  y-min: auto,
  y-max: auto,
  x-ticks: auto,
  y-ticks: auto,
  x-grid: false,
  legend: "end",
  samples: 60,
) = layout(size => {
  let w = _resolve(width, size.width)
  let ht = height
  // data extents: the axes follow the measured points; fn lines (an ideal
  // speed-up, say) may run off the top, unless there are no points at all
  let xs = series.filter(s => "points" in s).map(s => s.points.map(p => p.at(0))).flatten()
  let ys = series.filter(s => "points" in s).map(s => s.points.map(p => p.at(1))).flatten()
  let (x0v, x1v, xt) = _axis(xs, x-scale, x-min, x-max, x-ticks)
  if ys.len() == 0 {
    for s in series.filter(s => "fn" in s) {
      for i in range(samples + 1) {
        let u = _fwd(x0v, x-scale) + (_fwd(x1v, x-scale) - _fwd(x0v, x-scale)) * i / samples
        ys.push((s.fn)(_inv(u, x-scale)))
      }
    }
  }
  let (y0v, y1v, yt) = _axis(ys, y-scale, y-min, y-max, y-ticks, zero: true)

  // colours: series without one take the next in order
  let k = 0
  let styled = ()
  for s in series {
    let c = s.at("color", default: auto)
    if c == auto {
      c = series-colors.at(calc.rem(k, series-colors.len()))
      k += 1
    }
    styled.push(s + (color: c))
  }

  // margins from what the labels need
  let ytw = calc.max(0pt, ..yt.map(t => measure(_tick-text(t.at(1))).width))
  let tick-h = measure(_tick-text("0")).height
  let lab-h = measure(_label-style[Ag]).height
  let end-labels = legend == "end" and styled.any(s => s.at("label", default: none) != none)
  let lw = if end-labels {
    calc.max(0pt, ..styled.filter(s => s.at("label", default: none) != none).map(s => measure(_label-style(s.label)).width))
  } else { 0pt }
  let key-h = if legend == "top" { lab-h + spacing.s2 } else { 0pt }
  let ml = ytw + 5pt
  let mt = (if y-label != none { lab-h + spacing.s2 } else { 0pt }) + tick-h / 2 + key-h
  let mr = if end-labels { lw + 8pt } else { 6pt }
  let mb = tick-h + 6pt + (if x-label != none { lab-h + 4pt } else { 0pt })
  let pw = w - ml - mr
  let ph = ht - mt - mb

  let px(v) = ml + pw * (_fwd(v, x-scale) - _fwd(x0v, x-scale)) / (_fwd(x1v, x-scale) - _fwd(x0v, x-scale))
  let py(v) = mt + ph * (1 - (_fwd(v, y-scale) - _fwd(y0v, y-scale)) / (_fwd(y1v, y-scale) - _fwd(y0v, y-scale)))
  let in-x(v) = v >= x0v - 1e-9 and v <= x1v + 1e-9

  box(width: w, height: ht, {
    // gridlines and y ticks
    for (v, l) in yt {
      let yy = py(v)
      place(top + left, dx: ml, dy: yy, line(length: pw, stroke: 0.5pt + palette.rule))
      _at(ml - 5pt, yy, right + horizon, _tick-text(l))
    }
    // x axis and ticks
    place(top + left, dx: ml, dy: mt + ph, line(length: pw, stroke: 0.6pt + palette.ink-soft))
    for (v, l) in xt {
      let xx = px(v)
      if x-grid { place(top + left, dx: xx, dy: mt, line(angle: 90deg, length: ph, stroke: 0.5pt + palette.rule)) }
      place(top + left, dx: xx, dy: mt + ph, line(angle: 90deg, length: 3pt, stroke: 0.6pt + palette.ink-soft))
      _at(xx, mt + ph + 5pt, center + top, _tick-text(l))
    }
    if y-label != none { _at(0pt, key-h, left + top, _label-style(y-label)) }
    if x-label != none { _at(ml + pw / 2, ht, center + bottom, _label-style(x-label)) }

    // the series, clipped to the plot area (with room for the dots)
    let pad = 4pt
    let ends = ()
    place(top + left, dx: ml - pad, dy: mt - pad, box(width: pw + 2 * pad, height: ph + 2 * pad, clip: true, {
      for s in styled {
        let pts = if "points" in s { s.points.filter(p => in-x(p.at(0))) } else {
          range(samples + 1).map(i => {
            let u = _fwd(x0v, x-scale) + (_fwd(x1v, x-scale) - _fwd(x0v, x-scale)) * i / samples
            let xv = _inv(u, x-scale)
            (xv, (s.fn)(xv))
          })
        }
        if pts.len() == 0 { continue }
        let xy = pts.map(p => (px(p.at(0)) - ml + pad, py(p.at(1)) - mt + pad))
        if s.at("line", default: true) != false and xy.len() > 1 {
          place(top + left, curve(
            stroke: _stroke(s.color, s.at("dashed", default: false)),
            curve.move(xy.first()),
            ..xy.slice(1).map(p => curve.line(p)),
          ))
        }
        let marks = s.at("marks", default: "points" in s)
        if marks {
          for p in xy {
            place(top + left, dx: p.at(0) - 2.6pt, dy: p.at(1) - 2.6pt, circle(
              radius: 2.6pt,
              fill: s.color,
              stroke: 0.9pt + palette.paper,
            ))
          }
        }
      }
    }))
    // labels at the line ends, nudged apart so they never overlap
    if end-labels {
      for s in styled {
        if s.at("label", default: none) == none { continue }
        let last = if "points" in s {
          let p = s.points.filter(p => in-x(p.at(0)))
          if p.len() == 0 { continue }
          p.last()
        } else { (x1v, (s.fn)(x1v)) }
        let yy = calc.min(calc.max(py(last.at(1)), mt), mt + ph)
        ends.push((y: yy, x: px(last.at(0)), label: s.label))
      }
      ends = ends.sorted(key: e => e.y)
      let gap = lab-h * 1.15
      for i in range(1, ends.len()) {
        if ends.at(i).y < ends.at(i - 1).y + gap { ends.at(i).y = ends.at(i - 1).y + gap }
      }
      for e in ends { _at(ml + pw + 6pt, e.y, left + horizon, text(font: fonts.text, size: type-size.caption, fill: palette.ink, e.label)) }
    }
    if legend == "top" {
      let items = styled.filter(s => s.at("label", default: none) != none)
      place(top + left, dx: ml, dy: 0pt, stack(dir: ltr, spacing: spacing.s6, ..items.map(s => box({
        if s.at("line", default: true) == false {
          box(width: 10pt, height: 6pt, baseline: 0.05em, place(center + horizon, circle(radius: 2.6pt, fill: s.color)))
        } else {
          box(baseline: -0.1em, line(length: 10pt, stroke: _stroke(s.color, s.at("dashed", default: false), thickness: 2pt)))
        }
        h(4pt)
        text(font: fonts.text, size: type-size.caption, fill: palette.ink, s.label)
      }))))
    }
  })
})

/// A bar chart, grouped when there is more than one series.
///   #bar-chart(
///     categories: ([v1], [v2], [swap]),
///     series: ((label: [4 threads], values: (2.1, 2.6, 3.4)),
///              (label: [8 threads], values: (3.0, 4.1, 5.9))),
///     y-label: [Speed-up], values: true,
///   )
/// values: true prints each bar's value on top (format with value-format).
#let bar-chart(
  categories: (),
  series: (),
  width: 100%,
  height: 62mm,
  x-label: none,
  y-label: none,
  y-min: 0,
  y-max: auto,
  y-ticks: auto,
  values: false,
  value-format: v => _fmt(v),
  legend: auto,
  gap: 35%,
) = layout(size => {
  let w = _resolve(width, size.width)
  let ht = height
  let all = series.map(s => s.values).flatten()
  let (y0v, y1v, yt) = _axis(all, "linear", y-min, y-max, y-ticks, zero: true)
  let k = 0
  let styled = ()
  for s in series {
    let c = s.at("color", default: auto)
    if c == auto {
      c = series-colors.at(calc.rem(k, series-colors.len()))
      k += 1
    }
    styled.push(s + (color: c))
  }
  let show-key = if legend == auto { styled.len() > 1 } else { legend == true or legend == "top" }

  let ytw = calc.max(0pt, ..yt.map(t => measure(_tick-text(t.at(1))).width))
  let tick-h = measure(_tick-text("0")).height
  let lab-h = measure(_label-style[Ag]).height
  let cat-h = calc.max(tick-h, ..categories.map(c => measure(_tick-text(c)).height))
  let key-h = if show-key { lab-h + spacing.s2 } else { 0pt }
  let ml = ytw + 5pt
  let mt = (if y-label != none { lab-h + spacing.s2 } else { 0pt }) + tick-h / 2 + key-h + (if values { tick-h } else { 0pt })
  let mr = 6pt
  let mb = cat-h + 6pt + (if x-label != none { lab-h + 4pt } else { 0pt })
  let pw = w - ml - mr
  let ph = ht - mt - mb
  let py(v) = mt + ph * (1 - (v - y0v) / (y1v - y0v))

  box(width: w, height: ht, {
    for (v, l) in yt {
      place(top + left, dx: ml, dy: py(v), line(length: pw, stroke: 0.5pt + palette.rule))
      _at(ml - 5pt, py(v), right + horizon, _tick-text(l))
    }
    let n = categories.len()
    let band = pw / calc.max(n, 1)
    let group = band * ((100% - gap) / 100%)
    let ns = calc.max(styled.len(), 1)
    let bw = (group - 1.5pt * (ns - 1)) / ns
    for (i, c) in categories.enumerate() {
      let gx = ml + band * i + (band - group) / 2
      for (j, s) in styled.enumerate() {
        let v = s.values.at(i, default: none)
        if v == none { continue }
        let yv = calc.min(calc.max(v, y0v), y1v)
        let bh = py(y0v) - py(yv)
        let bx = gx + j * (bw + 1.5pt)
        place(top + left, dx: bx, dy: py(yv), rect(width: bw, height: bh, fill: s.color, radius: (top: radii.s)))
        if values {
          _at(bx + bw / 2, py(yv) - 2pt, center + bottom, _tick-text(value-format(v)))
        }
      }
      _at(ml + band * i + band / 2, mt + ph + 5pt, center + top, _tick-text(c))
    }
    place(top + left, dx: ml, dy: mt + ph, line(length: pw, stroke: 0.6pt + palette.ink-soft))
    if y-label != none { _at(0pt, key-h, left + top, _label-style(y-label)) }
    if x-label != none { _at(ml + pw / 2, ht, center + bottom, _label-style(x-label)) }
    if show-key {
      place(top + left, dx: ml, dy: 0pt, stack(dir: ltr, spacing: spacing.s6, ..styled.map(s => box({
        box(width: 8pt, height: 8pt, baseline: 0.05em, radius: radii.s, fill: s.color)
        h(4pt)
        text(font: fonts.text, size: type-size.caption, fill: palette.ink, s.at("label", default: []))
      }))))
    }
  })
})

// ── Appendix ─────────────────────────────────────────────────────────────────

/// Everything after `#show: appendix` is numbered A, B, … :
///   #show: appendix
///   = Creating your own synchronisation objects
#let appendix(body) = {
  counter(heading).update(0)
  set heading(numbering: "A.1", supplement: [Appendix])
  body
}

// ── The cover ────────────────────────────────────────────────────────────────

#let _as-content(v) = if type(v) == str { [#v] } else { v }

#let _field(name, body) = block(above: spacing.s8, below: 0pt, breakable: false, {
  label-text(name)
  v(spacing.s2 + 1pt, weak: true)
  body
})

#let _cover(kicker, title, subtitle, authors, fields, date, logo, logo-width, labels) = page(
  header: none,
  footer: none,
  margin: (x: page-grid.side, top: 30mm, bottom: page-grid.bottom),
  {
    set par(justify: false)
    set text(hyphenate: false)
    let col = page-grid.width - 2 * page-grid.side
    // kicker (and logo)
    block(width: col, grid(
      columns: (1fr, auto),
      align: (start + top, end + top),
      if kicker != none { label-text(fill: palette.rust, kicker) },
      if logo != none { box(width: logo-width, image(logo, width: 100%)) },
    ))
    v(1fr)
    // title and subtitle
    block(width: 88% * col, {
      set text(font: fonts.display, weight: 600, size: type-size.title, fill: palette.ink)
      set par(leading: _lead(type-size.title, line-height.title))
      title
    })
    if subtitle != none {
      v(spacing.s4)
      block(width: 88% * col, {
        set text(size: type-size.lede, fill: palette.ink-soft)
        set par(leading: _lead(type-size.lede, line-height.lede))
        subtitle
      })
    }
    v(1.6fr)
    // authors: name, id, e-mail
    if authors.len() > 0 {
      let people = authors.map(a => if type(a) == dictionary { a } else { (name: a) })
      let has-id = people.any(p => p.at("id", default: none) != none)
      let has-mail = people.any(p => p.at("email", default: none) != none)
      let small(body) = text(size: type-size.caption, fill: palette.ink-soft, number-type: "lining", body)
      _field(if people.len() == 1 { labels.author } else { labels.authors }, grid(
        columns: (auto,) + (if has-id { (auto,) } else { () }) + (if has-mail { (auto,) } else { () }),
        column-gutter: spacing.s12,
        row-gutter: spacing.s2 + 1pt,
        align: start + bottom,
        ..people
          .map(p => {
            (_as-content(p.name),)
            if has-id { (small(text(font: fonts.mono, size: 0.92em, _as-content(p.at("id", default: [])))),) }
            if has-mail {
              let m = p.at("email", default: none)
              (small(if m == none { [] } else if type(m) == str { link("mailto:" + m, m) } else { m }),)
            }
          })
          .flatten(),
      ))
    }
    for (name, body) in (if type(fields) == dictionary { fields.pairs() } else { fields }) {
      if body != none { _field(_as-content(name), _as-content(body)) }
    }
    v(1fr)
    if date != none { label-text(date) }
  },
)

// ── The template ─────────────────────────────────────────────────────────────

/// The report. Use it with #show: report.with(…). Every cover field is
/// optional: leave it out (or none) and its line disappears.
#let report(
  course: none, // "HPC", shown in the kicker and the header
  lab: none, // "Lab 2"
  kicker: auto, // the line above the title; auto: "course · lab"
  title: none,
  subtitle: none,
  short-title: auto, // the header's right-hand side; auto: the title
  authors: (), // strings, or (name: "…", id: "…", email: "…")
  group: none, // "Group 5"
  academic-year: none, // "2026/2027 Q1"
  fields: (), // more cover fields: (("Professor", [Jane Doe]), …)
  date: auto, // auto: today; a datetime, any content, or none
  logo: none, // bytes: read("figures/logo.png", encoding: none); top right of the cover
  logo-width: 28mm,
  cover: true, // false: no cover page
  contents: false, // a contents page after the cover
  contents-depth: 3,
  heading-numbering: "1.1", // "a)" for one section per question; none for none
  equation-numbers: "labelled", // "labelled": only equations you label; "all"
  justify: true, // false for ragged right
  lang: "en",
  labels: (:), // cover and contents words, e.g. (authors: [Autores], group: [Grupo])
  body,
) = {
  let labels = (
    author: [Author],
    authors: [Authors],
    group: [Group],
    academic-year: [Academic year],
    contents: [Contents],
  ) + labels
  let kicker = if kicker != auto { kicker } else {
    let parts = (course, lab).filter(p => p != none).map(_as-content)
    if parts.len() > 0 { parts.join[ · ] } else { none }
  }
  let short-title = if short-title == auto { title } else { short-title }
  let date = if date == auto { datetime.today() } else { date }
  let date = if type(date) == datetime { date.display("[day padding:none] [month repr:long] [year]") } else { date }
  let names = authors
    .map(a => if type(a) == dictionary { a.name } else { a })
    .filter(n => type(n) == str)
  let hn = if heading-numbering == "a)" {
    (..n) => if n.pos().len() == 1 { numbering("a)", ..n) } else { numbering("a.1", ..n) }
  } else { heading-numbering }

  set document(title: title, author: names)

  // Page: the Craken A4 grid. Header: kicker on the left, title on the right.
  set page(
    width: page-grid.width,
    height: page-grid.height,
    margin: (x: page-grid.side, top: page-grid.top, bottom: page-grid.bottom),
    fill: palette.paper,
    header: {
      if kicker != none { label-text(kicker) }
      h(1fr)
      if short-title != none { label-text(short-title) }
    },
    footer: align(right, label-text(context counter(page).display())),
  )

  // Text: Newsreader, 1em line boxes so leading sets an exact baseline grid.
  set text(
    font: fonts.text,
    size: type-size.body,
    fill: palette.ink,
    lang: lang,
    top-edge: 0.8em,
    bottom-edge: -0.2em,
    hyphenate: justify,
  )
  set par(leading: _lead(type-size.body, line-height.body), spacing: spacing.s4, justify: justify)
  show strong: set text(weight: 600)
  set footnote.entry(separator: none, clearance: spacing.s8)
  show footnote.entry: set text(size: type-size.note, fill: palette.ink-soft)
  show footnote.entry: set par(leading: _lead(type-size.note, line-height.note), justify: false)
  set footnote(numbering: n => text(fill: palette.rust, weight: 600, str(n)))
  show link: set text(fill: palette.rust)
  show ref: set text(fill: palette.rust)

  // Lists: a coral dot, then a short dash, then a small dot; numbers in rust.
  let dot(r, fill) = box(width: 2 * r, height: 0.5em, baseline: 0pt, place(left + horizon, circle(radius: r, fill: fill)))
  set list(
    marker: (
      dot(2.1pt, palette.coral),
      box(width: 5pt, height: 0.5em, place(left + horizon, line(length: 5pt, stroke: 0.9pt + palette.ink-soft))),
      dot(1.3pt, palette.ink-soft),
    ),
    indent: 0pt,
    body-indent: spacing.s4,
  )
  set enum(
    numbering: n => text(font: fonts.label, weight: 600, fill: palette.rust, number-type: "lining", str(n) + "."),
    indent: 0pt,
    body-indent: spacing.s4,
  )
  set terms(separator: h(spacing.s4), hanging-indent: spacing.s8)

  // Headings: sections (1), subsections (1.1), sub-subsections (1.1.1).
  set heading(numbering: hn)
  show heading: set text(fill: palette.ink, hyphenate: false)
  show heading: set par(justify: false)
  let number(it) = if it.numbering != none {
    context counter(heading).display(it.numbering)
    h(0.5em)
  }
  show heading.where(level: 1): it => block(above: spacing.s12, below: spacing.s4, sticky: true, {
    set text(font: fonts.display, weight: 600, size: type-size.section)
    set par(leading: _lead(type-size.section, line-height.section))
    number(it)
    it.body
  })
  show heading.where(level: 2): it => block(above: spacing.s8, below: spacing.s4, sticky: true, {
    set text(font: fonts.label, weight: 600, size: type-size.subsection)
    number(it)
    it.body
  })
  show heading: it => if it.level < 3 { it } else {
    block(above: spacing.s6, below: spacing.s2 + 2pt, sticky: true, {
      set text(font: fonts.label, weight: 600, size: type-size.subsubsection)
      number(it)
      it.body
    })
  }

  // Math: STIX Two Math, a step above the text, numbered (1) on the right.
  show math.equation: set text(font: fonts.math, size: 1.06em)
  set math.equation(numbering: "(1)", supplement: [Equation])
  show math.equation.where(block: true): it => {
    if equation-numbers != "all" and it.numbering != none and not it.has("label") {
      counter(math.equation).update(v => v - 1)
      math.equation(it.body, block: true, numbering: none)
    } else { it }
  }
  show math.equation.where(block: true): set block(above: spacing.s6, below: spacing.s6)
  show math.equation.where(block: true): set text(number-type: "lining")

  // Code: DM Mono on paper-warm, four colour roles.
  set raw(theme: "themes/craken-" + theme + ".tmTheme")
  show raw: set text(font: fonts.mono, fill: palette.ink, hyphenate: false)
  show raw.where(block: true): set text(size: type-size.code)
  show raw.where(block: true): set par(leading: _lead(type-size.code, line-height.code), justify: false)
  show raw.where(block: true): set block(
    width: 100%,
    above: spacing.s8,
    below: spacing.s8,
    inset: (x: spacing.s6, y: spacing.s4),
    fill: palette.paper-warm,
    radius: radii.m,
  )
  show <craken-code-box>: set block(fill: palette.paper-warm)
  show raw.where(block: false): set text(size: 0.86em)
  show raw.where(block: false): set box(fill: palette.paper-warm)
  show raw.where(block: false): it => box(radius: radii.s, inset: (x: 1.5pt), outset: (y: 2pt), it)

  // Figures, tables, listings: numbered 1, 2, …; label in rust, caption in
  // ink-soft. Tables and listings carry their caption above, figures below.
  set figure(gap: spacing.s4)
  show figure: set block(above: spacing.s8, below: spacing.s8)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: raw): set figure.caption(position: top)
  show figure.where(kind: raw): set block(breakable: true)
  show figure.caption: it => block(width: 100%, {
    set align(start)
    set text(size: type-size.caption, fill: palette.ink-soft)
    set par(leading: _lead(type-size.caption, line-height.caption), justify: false)
    label-text(fill: palette.rust)[#it.supplement #context it.counter.display(it.numbering)]
    h(0.6em)
    it.body
  })

  // Tables: hairlines, no boxes, tabular figures.
  set table(
    align: (x, _) => if x == 0 { start } else { end },
    stroke: (_, y) => if y == 0 { (bottom: 0.5pt + palette.ink-soft) } else { none },
    inset: (x: spacing.s4, y: spacing.s2 + 1pt),
  )
  show table: set text(number-type: "lining", number-width: "tabular", hyphenate: false)
  show table: set par(justify: false)
  show table.cell.where(y: 0): set text(font: fonts.label, weight: 600, size: type-size.label, fill: palette.ink-soft)

  // Contents.
  show outline.entry.where(level: 1): set text(font: fonts.label, weight: 600)
  show outline.entry.where(level: 1): set block(above: spacing.s6)
  set outline.entry(fill: box(width: 1fr, repeat(gap: 0.3em, text(fill: palette.ink-soft)[.])))

  if cover and (title != none or kicker != none) {
    _cover(
      kicker,
      title,
      subtitle,
      authors,
      ((labels.group, group), (labels.academic-year, academic-year)) + fields,
      date,
      logo,
      logo-width,
      labels,
    )
    counter(page).update(1)
  }
  if contents {
    outline(title: labels.contents, depth: contents-depth)
    pagebreak(weak: true)
  }
  body
}
