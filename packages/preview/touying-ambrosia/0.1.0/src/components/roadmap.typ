#import "context.typ": component-wrapper
#import "../palettes.typ": contrast, on-color

#let _kinds = ("accent", "info", "success", "warning", "danger", "neutral")

#let _number(value) = type(value) in (int, float) and calc.abs(value) < calc.inf
#let _same-time(a, b, total) = calc.abs(a - b) <= total * 1e-14

// Avoid exposing arithmetic tails such as 0.30000000000000004 in labels.
#let _time-text(value) = {
  if value == 0 { "0" }
  else { str(calc.round(value, digits: int(10 - calc.floor(calc.log(calc.abs(value)))))) }
}

#let _time(value, total, name) = {
  assert(_number(value) and (0 <= value or _same-time(value, 0, total))
    and (value <= total or _same-time(value, total, total)),
    message: "Roadmap " + name + " must be a finite number between 0 and total.")
}

#let _range(item, total, name) = {
  assert(type(item) == dictionary and "start" in item and "end" in item,
    message: "Roadmap " + name + " needs start and end times.")
  _time(item.start, total, name + " start")
  _time(item.end, total, name + " end")
  assert(item.start < item.end, message: "Roadmap " + name + " start must be less than its end.")
  assert(not _same-time(item.start, item.end, total), message: "Roadmap " + name + " duration is too small relative to total.")
}

#let _validate(total, unit, now, milestones, phases, tasks, tick-every, tick-label, legend, fit, min-scale) = {
  assert(_number(total) and total > 0, message: "Roadmap total must be a positive finite number.")
  assert(type(unit) == str, message: "Roadmap unit must be a string, such as week, day, or sprint.")
  if now != none { _time(now, total, "now") }
  assert(_number(tick-every) and tick-every > 0, message: "Roadmap tick-every must be a positive finite number.")
  assert(total / tick-every <= 1000, message: "Roadmap has too many ticks. Increase tick-every to show at most 1000 periods.")
  assert(tick-label == auto or type(tick-label) == function, message: "Roadmap tick-label must be auto or a function of (start, end).")
  assert(type(legend) == bool and type(fit) == bool, message: "Roadmap legend and fit must be booleans.")
  assert(type(min-scale) == ratio and 0% < min-scale and min-scale <= 100%, message: "Roadmap min-scale must be between 0% and 100%.")
  for (name, items) in (("milestones", milestones), ("phases", phases), ("tasks", tasks)) {
    assert(type(items) == array, message: "Roadmap " + name + " must be an array.")
  }
  for milestone in milestones {
    if _number(milestone) { _time(milestone, total, "milestone") }
    else {
      assert(type(milestone) == dictionary and "at" in milestone, message: "Roadmap milestones need an at time.")
      _time(milestone.at("at"), total, "milestone")
    }
  }
  let cursor = 0
  for phase in phases {
    assert(type(phase) == dictionary and "name" in phase and "end" in phase, message: "Roadmap phases need name and end fields.")
    let phase = phase + (start: phase.at("start", default: cursor))
    _range(phase, total, "phase")
    assert(phase.start >= cursor or _same-time(phase.start, cursor, total), message: "Roadmap phases must be ordered and must not overlap.")
    cursor = phase.end
  }
  for track in tasks {
    let track = if type(track) == dictionary { (track,) } else { track }
    assert(type(track) == array and track.len() > 0, message: "A roadmap track must be a task or a nonempty array of tasks.")
    let cursor = 0
    for task in track {
      _range(task, total, "task")
      assert("content" in task, message: "Roadmap tasks need content.")
      assert(task.start >= cursor or _same-time(task.start, cursor, total), message: "Roadmap tasks in one track must be ordered and must not overlap. Use separate tracks for overlapping tasks.")
      cursor = task.end
      if "details" in task and type(task.details) == dictionary {
        assert("content" in task.details, message: "Roadmap detail drawers need content.")
        _range(task.details + (start: task.details.at("start", default: task.start),
          end: task.details.at("end", default: total)), total, "details")
      }
    }
  }
}

#let render-roadmap(self: none, total: 12, unit: "week", now: none, milestones: (), phases: (), tasks: (),
  tick-every: 2, tick-label: auto, legend: true, fit: true, min-scale: 75%,
) = layout(bounds => context {
  let accent(item, fallback: "accent") = {
    let kind = item.at("kind", default: fallback)
    assert(kind in _kinds, message: "Unknown roadmap kind: " + str(kind) + ".")
    let fill = item.at("fill", default: if kind == "accent" { self.colors.primary-dark } else { self.colors.at(kind) })
    assert(type(fill) == color, message: "Roadmap fill must be a solid color.")
    fill
  }
  let tint(ink, amount) = color.mix((ink, amount), (self.page.fill, 100% - amount), space: color.oklab)
  let readable(ink, background) = if contrast(ink, background) >= 4.5 { ink }
    else if contrast(self.colors.foreground, background) >= 4.5 { self.colors.foreground }
    else { on-color(background) }
  let milestones = milestones.map(m => if _number(m) { (at: m) } else { m })
  let ticks = range(int(calc.ceil(total / tick-every))).map(i => i * tick-every) + (total,)
  let points = ticks
  if now != none { points.push(now) }
  points += milestones.map(m => m.at("at"))
  let cursor = 0
  for phase in phases {
    points += (phase.at("start", default: cursor), phase.end)
    cursor = phase.end
  }
  for track in tasks {
    for task in (if type(track) == dictionary { (track,) } else { track }) {
      points += (task.start, task.end)
      if "details" in task {
        let d = if type(task.details) == dictionary { task.details } else { (:) }
        points += (d.at("start", default: task.start), d.at("end", default: total))
      }
    }
  }
  // One proportional column per actual boundary, independent of time unit or
  // precision. Fractional spans do not require a fixed sub-unit or dense grid.
  let unique = ()
  for point in points.map(p => calc.min(total, calc.max(0, p))).sorted() {
    if unique.len() == 0 or not _same-time(point, unique.last(), total) { unique.push(point) }
  }
  let points = unique
  let index(value) = points.position(point => _same-time(point, value, total))
  let columns = range(points.len() - 1).map(i => (points.at(i + 1) - points.at(i)) * 1fr)
  let prefix = (month: "M", week: "W", day: "D", year: "Y", hour: "h", minute: "min").at(unit, default: unit)
  let format-time(value) = if prefix == "" { _time-text(value) }
    else if unit in ("month", "week", "day", "year", "hour", "minute") { prefix + _time-text(value) }
    else { prefix + " " + _time-text(value) }
  let headers = if phases.len() > 0 { 2 } else { 1 }
  let cells = ()
  let rows = headers
  let spans = ()
  let phase-spans = ()
  let blank(start, end, row) = {
    // Individual intervals let the elapsed-time wash end at the exact boundary.
    range(index(start), index(end)).map(x => grid.cell(x: x, y: row, inset: 0em)[])
  }
  let cursor = 0
  for (ordinal, phase) in phases.enumerate() {
    let start = phase.at("start", default: cursor)
    cells += blank(cursor, start, 0)
    let ink = accent(phase, fallback: ("info", "success", "warning").at(calc.rem(ordinal, 3)))
    let background = tint(ink, if self.store.dark { 22% } else { 12% })
    cells.push(grid.cell(x: index(start), y: 0, colspan: index(phase.end) - index(start),
      fill: background, stroke: (bottom: 0.12em + ink), inset: (x: 0.35em, y: 0.45em), align: center + horizon,
      text(size: 0.75em, weight: "semibold", fill: readable(ink, background), phase.name)))
    phase-spans.push((start: start, end: phase.end))
    cursor = phase.end
  }
  if phases.len() > 0 { cells += blank(cursor, total, 0) }
  for (start, end) in ticks.windows(2).map(pair => (pair.first(), pair.last())) {
    let label = if tick-label != auto { tick-label(start, end) }
      else { [#format-time(start)#sym.dash.en#_time-text(end)] }
    cells.push(grid.cell(x: index(start), y: headers - 1, colspan: index(end) - index(start),
      fill: self.colors.surface-alt, align: center + horizon, inset: (x: 0em, y: 0.3em),
      block(width: 100%, above: 0em, below: 0em, {
        place(top + left, [#metadata((time: start))<ambrosia-roadmap-tick>])
        if end == total { place(top + right, [#metadata((time: end))<ambrosia-roadmap-tick>]) }
        align(center, text(size: 0.6em, weight: "medium", fill: self.colors.muted, label))
      })))
  }
  for track in tasks {
    let track = if type(track) == dictionary { (track,) } else { track }
    let cursor = 0
    let drawers = ()
    for task in track {
      cells += blank(cursor, task.start, rows)
      let ink = accent(task)
      let background = tint(ink, if self.store.dark { 20% } else { 10% })
      cells.push(grid.cell(x: index(task.start), y: rows, colspan: index(task.end) - index(task.start),
        fill: none, inset: 0em, align: left + horizon,
        // An inner panel keeps grid lines from replacing a task's accent stripe.
        block(width: 100%, fill: background, stroke: (left: 0.15em + ink),
          inset: (x: 0.35em, y: 0.4em),
          text(size: 0.7em, weight: "medium", fill: readable(ink, background), task.content))))
      spans.push((start: task.start, end: task.end, row: rows, details: false))
      cursor = task.end
      if "details" in task {
        let d = if type(task.details) == dictionary { task.details } else { (content: task.details) }
        drawers.push((start: d.at("start", default: task.start), end: d.at("end", default: total), content: d.content, ink: ink))
      }
    }
    cells += blank(cursor, total, rows)
    rows += 1
    // Commit every task on the track before its detail rows, preserving alignment.
    for d in drawers {
      cells += blank(0, d.start, rows)
      let background = tint(d.ink, if self.store.dark { 8% } else { 4% })
      cells.push(grid.cell(x: index(d.start), y: rows, colspan: index(d.end) - index(d.start),
        fill: none, inset: 0em, align: top + left,
        block(width: 100%, fill: background, stroke: (left: 0.06em + d.ink),
          inset: (x: 0.6em, y: 0.3em), {
          set text(size: 0.65em, fill: readable(self.colors.foreground, background))
          set list(indent: 0.8em, body-indent: 0.4em, spacing: 0.25em,
            marker: text(fill: d.ink)[•])
          d.content
        })))
      spans.push((start: d.start, end: d.end, row: rows, details: true))
      cells += blank(d.end, total, rows)
      rows += 1
    }
  }
  let render(scale) = block(width: bounds.width, breakable: false, {
    set text(size: text.size * scale, fill: self.colors.foreground)
    set par(justify: false, leading: 0.45em)
    grid(columns: columns, row-gutter: 0.2em, inset: 0em,
      fill: (x, y) => if now != none and y >= headers and x < index(now) { tint(self.colors.primary, 5%) },
      ..cells,
      ..ticks.slice(1, -1).map(time => grid.vline(x: index(time), start: headers, end: rows,
        stroke: 0.025em + self.colors.border.transparentize(40%))),
      ..milestones.map(m => grid.vline(x: index(m.at("at")), start: headers, end: rows,
        stroke: (paint: accent(m, fallback: "warning").transparentize(40%), thickness: 0.045em, dash: "dashed"))),
      ..if now == none { () } else { (grid.vline(x: index(now), start: headers, end: rows,
        stroke: 0.07em + self.colors.danger),) },
    )
    if legend and (now != none or milestones.len() > 0) {
      let entries = ()
      let key(ink, body) = box(inset: (right: 0.8em), [#text(fill: ink, weight: "bold")[│]#h(0.2em)#body])
      if now != none { entries.push(key(self.colors.danger, [Now: #format-time(now)])) }
      for m in milestones { entries.push(key(accent(m, fallback: "warning"), m.at("label", default: format-time(m.at("at"))))) }
      block(above: 0.5em, below: 0em, text(size: 0.6em, fill: self.colors.muted, entries.join(h(0em))))
    }
  })
  let height(scale) = measure(render(scale)).height
  let chosen = 100%
  if fit and height(chosen) > bounds.height {
    assert(height(min-scale) <= bounds.height,
      message: "Roadmap is too dense to fit at min-scale. Shorten labels/details, split the roadmap, or lower min-scale.")
    let low = min-scale
    let high = 100%
    for _ in range(10) {
      let mid = (low + high) / 2
      if height(mid) <= bounds.height { low = mid } else { high = mid }
    }
    chosen = low
  }
  [#metadata((total: total, unit: unit, points: points, now: now, rows: rows, headers: headers,
    phases: phase-spans, tasks: spans, milestones: milestones.map(m => m.at("at")),
    scale: chosen / 100%, height: height(chosen).pt(), available: bounds.height.pt()))<ambrosia-roadmap>]
  render(chosen)
})

/// A proportional timeline using elapsed positions from zero, including fractions.
/// Each task dictionary makes a track; an array of tasks shares one track.
/// -> content
#let ambrosia-roadmap(
  /// Positive finite duration of the complete plan.
  /// -> int | float
  total: 12,
  /// Time-unit label; no calendar conversion is performed.
  /// -> str
  unit: "week",
  /// Current elapsed position; none hides the marker.
  /// -> none | int | float
  now: none,
  /// Positions, or records with at and optional label/kind/fill.
  /// -> array
  milestones: (),
  /// Ordered name/end records; start defaults to the previous end.
  /// -> array
  phases: (),
  /// Tracks with content/start/end and optional kind/fill/details.
  /// -> array
  tasks: (),
  /// Positive tick spacing in the same unit as total.
  /// -> int | float
  tick-every: 2,
  /// Custom label function receiving (start, end).
  /// -> auto | function
  tick-label: auto,
  /// Show explanatory milestone/current-position labels.
  /// -> bool
  legend: true,
  /// Reduce size to fit the remaining height when necessary.
  /// -> bool
  fit: true,
  /// Lower fitting limit; exceeding it raises a diagnostic.
  /// -> ratio
  min-scale: 75%,
) = {
  _validate(total, unit, now, milestones, phases, tasks, tick-every, tick-label, legend, fit, min-scale)
  component-wrapper(render-roadmap.with(total: total, unit: unit, now: now,
    milestones: milestones, phases: phases, tasks: tasks, tick-every: tick-every,
    tick-label: tick-label, legend: legend, fit: fit, min-scale: min-scale))
}
