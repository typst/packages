// funnel.typ - Funnel chart for process/conversion stages
#import "../theme.typ": _resolve-ctx, get-color
#import "../util.typ": normalize-data, nonzero, contrast-text
#import "../validate.typ": validate-simple-data
#import "../primitives/container.typ": chart-container
#import "../primitives/layout.typ": resolve-size, text-width, fit-font-size, spread-labels, place-centered
#import "../primitives/rows.typ": value-str

/// Renders a funnel chart for visualizing process or conversion stages.
///
/// Each stage's name (and, optionally, its value and share of the first
/// stage) is written inside its segment when it fits, in the segment's
/// contrast colour. Segments too narrow for their label are labelled in a
/// shared column to the right, joined by a thin horizontal leader.
///
/// The outside column gets the room its labels *measure*: the funnel gives up
/// width (it narrows, and moves left of centre if it must) rather than wrap a
/// label into a sliver. Labels are two lines (name over detail) when they fit
/// the stage pitch, else one line, shrinking to a floor; only past that are
/// stages left unlabelled, spread evenly with the first and last kept.
///
/// - data (dictionary, array): Label-value pairs as dict or array of tuples
/// - width (length): Chart width
/// - height (length): Chart height
/// - title (none, content): Optional chart title
/// - show-values (bool): Display numeric values on segments
/// - show-percentages (bool): Display conversion percentages relative to the first stage
/// - gap (auto, length): Vertical gap between segments; `auto` scales with the theme's `base-size` (0.375x, 3pt in the default theme)
/// - color-by-stage (bool): Give every stage its own palette colour. By default all stages share the first palette colour: the stage is named by its label and the share by its width, so a colour per stage would encode nothing
/// - theme (none, dictionary): Theme overrides
/// -> content
#let funnel-chart(
  data,
  width: auto,
  height: auto,
  title: none,
  show-values: true,
  show-percentages: true,
  gap: auto,
  color-by-stage: false,
  theme: none,
) = context {
  layout(size => {
  validate-simple-data(data, "funnel-chart")
  let t = _resolve-ctx(theme)
  let gap = if gap == auto { 0.375 * t.base-size } else { gap }
  let norm = normalize-data(data)
  let labels = norm.labels
  let values = norm.values
  let n = values.len()
  let (width, height) = resolve-size(width, height, size, n: n, theme: t, rows: true, row-pitch: t.cell-size * 1.5)

  let max-val = nonzero(calc.max(..values))
  let first-val = nonzero(values.at(0))
  let seg-h = (height - gap * (n - 1)) / n
  let pitch = seg-h + gap
  let mid-y(i) = i * pitch + seg-h / 2

  // "value · share" under each name
  let details = values.map(v => {
    let parts = ()
    if show-values { parts.push(value-str(v, t)) }
    if show-percentages { parts.push(str(calc.round(v / first-val * 100, digits: 1)) + "%") }
    if parts.len() > 0 { parts.join(" · ") } else { "" }
  })

  let s0 = t.value-label-size
  let detail-k = 0.85   // detail line size relative to the name
  let lead-k = 0.3      // leading between the two lines, in em of the name
  let pad = 4pt         // clear space between text and the segment edge
  let s-min = calc.min(s0, 8pt)  // smallest size for a label set inside a segment
  let s-out = calc.max(6pt, s0 * 0.9)  // size of labels set outside
  let s-floor = 6pt     // ... and the least they shrink to
  let lead = 12pt       // clear space between the funnel and its label column
  let col-cap = width * 0.45  // the label column never takes more than this

  // Segment geometry for a funnel whose widest stage has half width `hw`:
  // half widths at the top and bottom edge of every segment
  let geom(hw) = {
    let half(v) = calc.max(0pt, v / max-val * hw)
    (
      tops: values.map(half),
      bots: values.enumerate().map(((i, v)) => if i < n - 1 { half(values.at(i + 1)) } else { half(v) }),
    )
  }

  // Decide how each label is set: the largest size (down to `s-min`) at which
  // the full label (name and detail) fits inside the trapezoid, measured at
  // the text's lowest edge; otherwise outside. A stage never loses its value
  // to the segment's size: the name alone is only set inside when the chart
  // has no detail to show
  let plan-for(g) = values.enumerate().map(((i, v)) => {
    let name = labels.at(i)
    let det = details.at(i)
    // Usable width at height `y` below the segment's top
    let width-at(y) = 2 * (g.tops.at(i) + (g.bots.at(i) - g.tops.at(i)) * (y / seg-h))
    let found = none
    for k in range(int(calc.max(0pt, s0 - s-min) / 1pt) + 1) {
      if found != none { continue }
      let s = s0 - k * 1pt
      let w-name = text-width(name, s, weight: "bold")
      let w-det = if det != "" { text-width(det, s * detail-k) } else { 0pt }
      let stack-h = s * (1.2 + detail-k * 1.2 + lead-k)
      let line-h = s * 1.2
      if det != "" and stack-h <= seg-h - 2pt and calc.max(w-name, w-det) <= width-at(seg-h / 2 + stack-h / 2) - 2 * pad {
        found = (mode: "stack", size: s)
      } else if det != "" and line-h <= seg-h - 2pt and w-name + 0.4 * s + w-det <= width-at(seg-h / 2 + line-h / 2) - 2 * pad {
        found = (mode: "inline", size: s)
      } else if det == "" and line-h <= seg-h - 2pt and w-name <= width-at(seg-h / 2 + line-h / 2) - 2 * pad {
        found = (mode: "name", size: s)
      }
    }
    if found == none { (mode: "out", size: s-out) } else { found }
  })
  let outs-of(pl) = array.range(n).filter(i => pl.at(i).mode == "out")

  // An outside label: name over detail ("stack") or "name  detail" on one line
  // ("inline"), wrapped at `w`; one word wider than `w` shrinks instead
  let out-body(i, style, sz0, w) = {
    let name = labels.at(i)
    let det = details.at(i)
    let words = if type(name) == str { name.split(" ") } else { (name,) }
    let sz = calc.min(sz0, ..words.map(wd => fit-font-size(wd, w, sz0, min: s-floor, weight: "bold")))
    let name-t = text(size: sz, weight: "bold", fill: t.text-color)[#name]
    if det == "" { name-t } else {
      let det-t = text(size: sz * detail-k, fill: t.text-color-light)[#det]
      if style == "inline" { [#name-t#h(0.5 * sz)#det-t] } else {
        stack(dir: ttb, spacing: sz * lead-k, name-t, det-t)
      }
    }
  }

  // One style for the whole column: two lines when they fit the stage pitch
  // (or the column, when the labels are few), else one line, as large as the
  // pitch allows
  let out-style(outs) = {
    let tallest(style, sz) = outs.map(i => measure(box(width: col-cap, out-body(i, style, sz, col-cap))).height)
      .fold(0pt, (a, b) => calc.max(a, b))
    let h-stack = tallest("stack", s-out)
    if outs.len() == 0 or h-stack + 0.3 * s-out <= pitch or outs.len() * (h-stack + 0.3 * s-out) <= height {
      (style: "stack", size: s-out)
    } else {
      let found = none
      for k in range(int((s-out - s-floor) / 0.5pt) + 1) {
        if found != none { continue }
        let s = s-out - k * 0.5pt
        if tallest("inline", s) + 0.3 * s <= pitch { found = (style: "inline", size: s) }
      }
      if found == none { (style: "inline", size: s-floor) } else { found }
    }
  }
  let out-width(outs, st) = calc.min(col-cap,
    outs.map(i => measure(out-body(i, st.style, st.size, col-cap)).width).fold(0pt, (a, b) => calc.max(a, b)))
  // How far out the stages that need labels reach, relative to the widest stage
  let out-reach(outs) = calc.max(..outs.map(i => (values.at(i) + values.at(calc.min(i + 1, n - 1))) / 2 / max-val))

  // Fit the funnel to its label column: start full width, find which labels
  // go outside, give them the room they measure, and repeat (narrower funnel,
  // more outside labels, wider column) until nothing changes
  let hw = width / 2
  for _ in range(6) {
    let outs = outs-of(plan-for(geom(hw)))
    if outs.len() == 0 { break }
    let lw = out-width(outs, out-style(outs))
    let hw2 = calc.min(width / 2, (width - lead - lw) / (1 + out-reach(outs)))
    if hw2 >= hw - 0.25pt { break }
    hw = hw2
  }
  let g = geom(hw)
  let (tops, bots) = (g.tops, g.bots)
  let plan = plan-for(g)
  let outs = outs-of(plan)

  // Funnel centre and the label column: the column starts just clear of the
  // widest outside stage and runs to the right edge
  let st = out-style(outs)
  let reach = if outs.len() > 0 { out-reach(outs) } else { 0 }
  let cx = if outs.len() == 0 { width / 2 } else {
    calc.max(hw, calc.min(width / 2, width - lead - out-width(outs, st) - hw * reach))
  }
  let out-x = cx + hw * reach + lead
  let out-w = calc.max(24pt, width - out-x)
  let out-bodies = outs.map(i => {
    let b = out-body(i, st.style, st.size, out-w)
    (body: b, h: measure(box(width: out-w, b)).height)
  })

  // The column is spread by the tallest label, with room for descenders; if
  // they cannot all fit even so, as many as fit are kept, spread evenly (first
  // and last kept), rather than let them overlap
  let h-out = out-bodies.fold(0pt, (acc, b) => calc.max(acc, b.h))
  let desc = 0.3 * st.size
  let out-ys = spread-labels(outs.map(mid-y), sizes: h-out, gap: desc, min-gap: desc, lo: 0pt, hi: height)

  chart-container(width, height, title, t)[
    #box(width: width, height: height)[
      #for (i, val) in values.enumerate() {
        let y-top = i * pitch
        let color = get-color(t, if color-by-stage { i } else { 0 })
        place(left + top, dy: y-top, polygon(
          fill: color,
          stroke: t.marker-stroke,
          (cx - tops.at(i), 0pt), (cx + tops.at(i), 0pt),
          (cx + bots.at(i), seg-h), (cx - bots.at(i), seg-h),
        ))

        let p = plan.at(i)
        let name = labels.at(i)
        let det = details.at(i)
        if p.mode != "out" {
          let fg = contrast-text(color, theme: t)
          let name-t = text(size: p.size, weight: "bold", fill: fg)[#name]
          let det-t = text(size: p.size * detail-k, fill: fg)[#det]
          let body = if p.mode == "stack" {
            stack(dir: ttb, spacing: p.size * lead-k, name-t, det-t)
          } else if p.mode == "inline" {
            [#name-t#h(0.4 * p.size)#det-t]
          } else { name-t }
          place-centered(cx - tops.at(i), y-top + seg-h / 2, body, width: 2 * tops.at(i), align: center)
        }
      }

      // Outside labels: one column, joined to their stage by a leader
      #for (j, i) in outs.enumerate() {
        let ly = out-ys.at(j)
        if ly == none { continue }
        let edge = cx + (tops.at(i) + bots.at(i)) / 2 + 3pt
        place(left + top, line(start: (edge, mid-y(i)), end: (out-x - 3pt, ly), stroke: t.stroke-thin + t.text-color-light))
        place-centered(out-x, ly, out-bodies.at(j).body, width: out-w, align: left)
      }
    ]
  ]
  })
}
