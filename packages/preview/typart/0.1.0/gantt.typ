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
) = {
  let N = span
  let x = m => (m / N) * 100%
  let cols = (name-fr * 1fr, bar-fr * 1fr)
  let track(t) = {
    set text(hyphenate: false)
    let name = t.at(0)
    let s = t.at(1)
    let e = t.at(2)
    let prog = t.at(3, default: 0)
    let grp = t.at(4, default: true)
    let base = if track-color != auto { track-color } else if grp { accent.lighten(45%) } else { base-color }
    let done = if progress-color != auto { progress-color } else if grp { accent } else { done-color }
    grid(columns: cols, align: (right + horizon, left + horizon),
      column-gutter: gutter, inset: (y: 1pt),
      text(size: 21pt, fill: luma(60))[#name],
      box(width: 100%, height: 0.8cm)[
        #place(left + horizon, stack(dir: ltr,
          box(width: x(s)),
          box(width: (e - s) / N * 100%, height: 0.62cm, radius: 3pt, fill: base,
            stack(dir: ltr, box(width: prog * 1%, height: 100%, radius: 3pt, fill: done)))))
        #{
          let lbl = text(size: 18pt, weight: "bold", fill: luma(80))[#prog%]
          // bars reaching the end have no room on the right -> tuck label inside
          if e < N { place(left + horizon, dx: x(e) + 8pt, lbl) }
          else { place(right + horizon, dx: -4pt, lbl) }
        }
      ])
  }
  block({
    set block(above: 0pt, below: 0pt)
    // period header (evenly spaced labels)
    if periods.len() > 0 {
      let seg = N / periods.len()
      grid(columns: cols, column-gutter: gutter,
        [], box(width: 100%, height: 0.9cm)[
          #for (i, lbl) in periods.enumerate() {
            place(top + left, dx: x(i * seg + seg / 2),
              move(dx: -3cm, box(width: 6cm)[
                #align(center)[#text(size: 20pt, weight: "bold")[#lbl]]]))
          }
        ])
      v(period-gap)
    }
    // tasks with continuous grid lines drawn once over the whole stack
    layout(size => {
      let avail = size.width - gutter
      let total-fr = name-fr + bar-fr
      let mx = m => avail * name-fr / total-fr + gutter + avail * bar-fr / total-fr * (m / N)
      let body = {
        let first = true
        for t in tasks {
          if first { first = false } else { v(row-gap) }
          track(t)
        }
      }
      // measure at the real width so fr columns resolve and wrapping matches the render
      let h = measure(box(width: size.width, body)).height
      // grid-step: auto -> one line per period boundary; a number -> every N units
      let lines = ()
      if grid-step == auto {
        let n = calc.max(periods.len(), 1)
        for i in range(1, n) { lines.push(i * N / n) }
      } else {
        let m = grid-step
        while m < N { lines.push(m); m = m + grid-step }
      }
      block(width: 100%, {
        for m in lines {
          place(top + left, dx: mx(m), line(length: h, angle: 90deg,
            stroke: (paint: luma(210), thickness: 0.8pt)))
        }
        if today != none {
          place(top + left, dx: mx(today), line(length: h, angle: 90deg,
            stroke: (paint: done-color, thickness: 4pt, dash: (array: (14pt, 9pt)))))
        }
        body
      })
    })
    if today != none {
      v(period-gap)
      grid(columns: cols, column-gutter: gutter,
        [], box(width: 100%, height: 0.8cm)[
          #place(top + left, dx: x(today), move(dx: -1.2cm,
            text(size: 20pt, weight: "bold", fill: done-color)[Today]))
        ])
    }
  })
}
