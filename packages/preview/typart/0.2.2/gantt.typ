// Reusable Gantt chart. Import with:  #import "gantt.typ": gantt
//
// Works in any unit: pass `span` as a total number of months OR years, and
// `periods` as the axis headers spread evenly across that span.
//
//   Months:  gantt(tasks, span: 48, grid-step: 6, today: 7,
//                   periods: ("Year 1", "Year 2", "Year 3", "Year 4"))
//   Years:   gantt(tasks, span: 4,  grid-step: 1, today: 0.5,
//                   periods: ("Y1", "Y2", "Y3", "Y4"))
//
// Each task is a tuple; only the first three are required:
//   (name, start, end)                  -> progress 0%, highlighted
//   (name, start, end, progress)        -> progress bar, highlighted
//   (name, start, end, progress, group) -> group=false renders it greyed (e.g. papers)
#let gantt(
  tasks,
  span: 48,
  grid-step: auto,       // faint vertical line every N units; auto = one per period boundary
  today: none,           // dashed marker + label at this unit (none = off)
  today-label: [Today],
  periods: (),           // axis header labels, spread evenly across the span
  accent: rgb("#40a02b"),    // main highlighted-task colour
  base-color: luma(210),     // bar fill for non-highlighted tasks
  done-color: rgb("#4c4f69"),// progress fill for non-highlighted tasks
  // ---- colour overrides (auto = derive from the colours above) ----
  progress-color: auto,      // filled progress portion of every bar
  track-color: auto,         // unfilled bar (auto = accent lightened)
  row-gap: 0pt,          // vertical space between task rows
  period-gap: 0pt,       // vertical space between period headers and first task
  name-fr: 15,           // width ratio of the task-name column
  bar-fr: 33,            // width ratio of the timeline column
  gutter: 10pt,
) = layout(size => {
  let N = span
  let avail = size.width - gutter
  let name-w = avail * name-fr / (name-fr + bar-fr)
  let bar-w = avail - name-w
  let x = m => bar-w * m / N
  let name(t) = text(size: 21pt, fill: luma(60), hyphenate: false, t.at(0))
  // a label of width w centred on x, kept inside the timeline
  let clamp(x, w) = calc.max(0pt, calc.min(x - w / 2, bar-w - w))
  let row(name-cell, bar-cell, h) = grid(columns: (name-w, bar-w), rows: h, column-gutter: gutter,
    align: (right + horizon, left + horizon), name-cell, bar-cell)
  let track(t, row-h) = {
    let (s, e) = (t.at(1), t.at(2))
    let prog = t.at(3, default: 0)
    let grp = t.at(4, default: true)
    let base = if track-color != auto { track-color } else if grp { accent.lighten(45%) } else { base-color }
    let done = if progress-color != auto { progress-color } else if grp { accent } else { done-color }
    let lbl = text(size: 18pt, weight: "bold", fill: luma(80))[#prog%]
    let lw = measure(lbl).width
    row(name(t), box(width: bar-w, height: 0.8cm, {
      place(left + horizon, dx: x(s), box(width: x(e - s), height: 0.62cm, radius: 3pt, fill: base,
        box(width: prog * 1%, height: 100%, radius: 3pt, fill: done)))
      // no room after the bar -> tuck the label inside its end
      if x(e) + 8pt + lw <= bar-w { place(left + horizon, dx: x(e) + 8pt, lbl) }
      else { place(left + horizon, dx: x(e) - lw - 4pt, lbl) }
    }), row-h)
  }
  // only the names wrap, so they alone decide each row's height
  let heights = tasks.map(t => calc.max(0.8cm, measure(name(t), width: name-w).height) + 2pt)
  let h = heights.sum(default: 0pt) + row-gap * calc.max(0, tasks.len() - 1)
  // grid-step: auto -> one line per period boundary; a number -> every N units
  let lines = if grid-step == auto {
    let n = calc.max(periods.len(), 1)
    range(1, n).map(i => i * N / n)
  } else {
    range(1, calc.ceil(N / grid-step)).map(i => i * grid-step)
  }
  set block(above: 0pt, below: 0pt)
  if periods.len() > 0 {
    let seg = N / periods.len()
    row([], box(width: bar-w, height: 0.9cm, for (i, lbl) in periods.enumerate() {
      let lbl = text(size: 20pt, weight: "bold", lbl)
      let w = measure(lbl).width
      place(top + left, dx: clamp(x(i * seg + seg / 2), w), lbl)
    }), auto)
    v(period-gap)
  }
  // grid lines are drawn once over the whole stack of tasks
  block(width: 100%, {
    for m in lines {
      place(top + left, dx: name-w + gutter + x(m), line(length: h, angle: 90deg,
        stroke: (paint: luma(210), thickness: 0.8pt)))
    }
    if today != none {
      place(top + left, dx: name-w + gutter + calc.max(2pt, calc.min(x(today), bar-w - 2pt)), line(length: h, angle: 90deg,
        stroke: (paint: done-color, thickness: 4pt, dash: (array: (14pt, 9pt)))))
    }
    stack(dir: ttb, spacing: row-gap, ..tasks.zip(heights).map(((t, row-h)) => track(t, row-h)))
  })
  if today != none {
    v(period-gap)
    let lbl = text(size: 20pt, weight: "bold", fill: done-color, today-label)
    let w = measure(lbl).width
    row([], box(width: bar-w, height: 0.8cm, place(top + left, dx: clamp(x(today), w), lbl)), auto)
  }
})
