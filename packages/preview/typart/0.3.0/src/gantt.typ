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
// Each task is a tuple; only the first three are required, and a trailing colour
// replaces the accent for that task:
//   (name, start, end)                  -> progress 0%, highlighted
//   (name, start, end, progress)        -> progress bar, highlighted
//   (name, start, end, progress, group) -> group=false renders it greyed (e.g. papers)
#import "common.typ": _fluid, _items, _lens, _on, _theme, _txt

#let gantt(
  tasks,
  span: 48,
  grid-step: auto,       // faint vertical line every N units; auto = one per period boundary
  today: none,           // dashed marker + label at this unit (none = off)
  today-label: [Today],
  periods: (),           // axis header labels, spread evenly across the span
  progress-fill: auto,  // filled progress portion of every bar (auto = the task's colour)
  track-fill: auto,     // unfilled bar (auto = the task's colour, tinted)
  row-gap: 0em,          // vertical space between task rows
  period-gap: 0em,       // vertical space between period headers and first task
  name-width: 31%,       // share of the width taken by the task names
  gap: 0.6em,            // space between the names and the timeline
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("gantt", theme, style)
  let tasks = _items("gantt", tasks, (t.accent,), fields: ("name", "start", "end"), optional: ("progress", "group"))
  if not (type(name-width) == ratio) { assert(false, message: "gantt: `name-width` must be a ratio such as 31%, got " + repr(name-width)) }
  let (row-gap, period-gap, gap, size, em) = _lens("gantt", row-gap: row-gap, period-gap: period-gap, gap: gap,
    text-size: text-size, em: 1em).values()
  let avail = _fluid("gantt", width, area) - gap
  let name-w = avail * name-width
  let bar-w = avail - name-w
  let (row-h, bar-h) = (1.3 * em, 0.85 * em)
  let x = m => bar-w * m / span
  let name(task) = text(hyphenate: false, _txt(task.name, t.ink, size, weight: auto))
  let heading(body) = _txt(body, t.ink, size)
  // a label of width w centred on x, kept inside the timeline
  let clamp(x, w) = calc.max(0pt, calc.min(x - w / 2, bar-w - w))
  let row(name-cell, bar-cell, h) = grid(columns: (name-w, bar-w), rows: h, column-gutter: gap,
    align: (right + horizon, left + horizon), name-cell, bar-cell)
  let track(task, h) = {
    let (s, e) = (task.start, task.end)
    let prog = if task.progress == none { 0 } else { task.progress }
    let grouped = task.group != false
    let base = if track-fill != auto { track-fill } else if grouped {
      color.mix((task.fill, 55%), (t.surface, 45%))
    } else { t.muted }
    let done = if progress-fill != auto { progress-fill } else if grouped { task.fill } else { t.line }
    let lbl = _txt([#prog%], t.line, size * t.small)
    let lw = measure(lbl).width
    let radius = calc.min(t.corner-radius, bar-h / 2)
    row(name(task), box(width: bar-w, height: row-h, {
      place(left + horizon, dx: x(s), box(width: x(e - s), height: bar-h, radius: radius, fill: base,
        box(width: prog * 1%, height: 100%, radius: radius, fill: done)))
      // no room after the bar -> tuck the label inside its end, readable on what it covers
      if x(e) + 0.4 * em + lw <= bar-w { place(left + horizon, dx: x(e) + 0.4 * em, lbl) } else {
        let under = if x(e - s) * prog / 100 > x(e - s) - lw - 0.2 * em { done } else { base }
        place(left + horizon, dx: x(e) - lw - 0.2 * em, text(fill: _on(t, under), lbl))
      }
    }), h)
  }
  // only the names wrap, so they alone decide each row's height
  let heights = tasks.map(task => calc.max(row-h, measure(name(task), width: name-w).height) + 0.1 * em)
  let h = heights.sum() + row-gap * (tasks.len() - 1)
  // grid-step: auto -> one line per period boundary; a number -> every N units
  let lines = if grid-step == auto {
    let n = calc.max(periods.len(), 1)
    range(1, n).map(i => i * span / n)
  } else {
    range(1, calc.ceil(span / grid-step)).map(i => i * grid-step)
  }
  let header = if periods.len() > 0 {
    let seg = span / periods.len()
    (row([], box(width: bar-w, height: 1.4 * em, for (i, lbl) in periods.enumerate() {
      let lbl = heading(lbl)
      place(top + left, dx: clamp(x(i * seg + seg / 2), measure(lbl).width), lbl)
    }), auto), period-gap)
  }
  let footer = if today != none {
    let lbl = heading(today-label)
    (period-gap + 0.3 * em, row([], box(width: bar-w, height: em, place(top + left,
      dx: clamp(x(today), measure(lbl).width), lbl)), auto))
  }
  // grid lines are drawn once over the whole stack of tasks
  let chart = block(width: avail + gap, {
    for m in lines {
      place(top + left, dx: name-w + gap + x(m), line(length: h, angle: 90deg, stroke: t.muted + t.stroke))
    }
    if today != none {
      place(top + left, dx: name-w + gap + calc.max(0.1 * em, calc.min(x(today), bar-w - 0.1 * em)),
        line(length: h, angle: 90deg, stroke: (paint: t.line, thickness: t.thick, dash: (0.8 * em, 0.5 * em))))
    }
    stack(dir: ttb, spacing: row-gap, ..tasks.zip(heights).map(((task, h)) => track(task, h)))
  })
  stack(dir: ttb, ..header, chart, ..footer)
})
