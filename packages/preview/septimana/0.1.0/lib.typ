// A week plan until a thesis is due: one row of seven boxes per week until the due date, milestones in their week,
// then a page for one week. Print it and tick the boxes by hand.

#let _t = (
  de: (
    title: "Wochenplan bis zur Abgabe",
    due: "Abgabe",
    left: n => if n == 0 { "Abgabe in dieser Woche" } else if n == 1 { "noch 1 Woche" } else { "noch " + str(n) + " Wochen" },
    week: "KW",
    days: ("Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"),
    note: "Notiz",
    to: "bis",
    week-page: "Diese Woche",
    goal: "Ziel",
    rows: ("Schreiben", "Lesen", "Quellen sortieren", "Betreuung", "Pause"),
    done: "Fertig geworden",
    next: "Nächste Woche",
    gap: "Ein leeres Kästchen ist ein leerer Tag, kein Scheitern. Die Woche zählt trotzdem.",
    credit: "Wochenraster von sevengrid.app",
    date: "[day].[month].",
    date-long: "[day].[month].[year]",
  ),
  en: (
    title: "Week plan until submission",
    due: "Due",
    left: n => if n == 0 { "due this week" } else if n == 1 { "1 week left" } else { str(n) + " weeks left" },
    week: "Week",
    days: ("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"),
    note: "Note",
    to: "to",
    week-page: "This week",
    goal: "Goal",
    rows: ("Writing", "Reading", "Sorting sources", "Supervisor", "Break"),
    done: "Got done",
    next: "Next week",
    gap: "An empty box is an empty day, not a failure. The week still counts.",
    credit: "Week grid by sevengrid.app",
    date: "[day padding:none] [month repr:short]",
    date-long: "[day padding:none] [month repr:short] [year]",
  ),
)

#let _accent = rgb("#1DC7B7")   // boxes
#let _accent-text = rgb("#0E7F75") // text in the accent colour, readable on white and in grey print
#let _ink = rgb("#20272B")
#let _soft = rgb("#7A8489")
#let _line = rgb("#C9D0D3")

#let _box(size: 5.2mm, kind: "open") = box(
  width: size, height: size, radius: 1.2mm,
  stroke: if kind == "open" { 0.6pt + _soft } else if kind == "due" { 0.8pt + _accent } else if kind == "mile" { 1.1pt + _accent } else { none },
  fill: if kind == "off" { _line.lighten(55%) } else if kind == "due" { _accent.lighten(78%) } else { none },
)

// Monday of the week that contains d
#let _monday(d) = d - duration(days: d.weekday() - 1)

/// The plan.
/// - due (datetime): the due date
/// - start (datetime): first day of the plan, default today
/// - title (content, str): the thesis title, shown under the heading
/// - lang (str): "de" or "en"
/// - milestones (array): pairs of a date (or a number of weeks before the due date) and a label,
///   e.g. ((6, [First draft]), (datetime(year: 2027, month: 1, day: 15), [Talk]))
/// - habits (array): row names of the week page, default from the language
/// - week-pages (int): how many week pages to print
/// - credit (bool): the small line at the foot of each page
#let week-plan(
  due: none,
  start: none,
  title: none,
  lang: "de",
  milestones: (),
  habits: none,
  week-pages: 1,
  credit: true,
) = {
  assert(lang in _t, message: "week-plan: lang must be \"de\" or \"en\"")
  let t = _t.at(lang)
  let start = if start == none { datetime.today() } else { start }
  assert(due != none, message: "week-plan: set the due date, e.g. due: datetime(year: 2027, month: 3, day: 31)")
  assert(due >= start, message: "week-plan: the due date lies before the start")
  let rows = if habits == none { t.rows } else { habits }
  for m in milestones {
    assert(type(m) == array and m.len() == 2,
      message: "week-plan: a milestone is a pair like (6, [First draft]) or (datetime(year: 2027, month: 1, day: 15), [Talk])")
  }
  let miles = milestones
    .map(m => (if type(m.at(0)) == int { due - duration(weeks: m.at(0)) } else { m.at(0) }, m.at(1)))
    .filter(m => m.at(0) >= start and m.at(0) <= due)

  set document(title: t.title)
  set page(
    paper: "a4",
    margin: (x: 18mm, top: 18mm, bottom: 20mm),
    footer: if credit { align(center, text(7pt, fill: _soft, t.credit)) } else { none },
  )
  set text(font: ("Libertinus Serif", "New Computer Modern"), size: 10pt, fill: _ink, lang: lang)

  // heading
  let first = _monday(start)
  let last = _monday(due)
  let weeks = int((last - first).days() / 7) + 1
  let weeks-left = int(calc.ceil((due - start).days() / 7))
  text(17pt, weight: "bold", t.title)
  if title != none { linebreak(); text(11pt, fill: _soft, title) }
  v(2mm)
  grid(columns: (1fr, auto),
    text(10pt)[#t.due: *#due.display(t.date-long)*],
    text(10pt, fill: _accent-text, weight: "bold", (t.left)(weeks-left)),
  )
  v(4mm)

  // one row per week
  let head = (
    text(8pt, fill: _soft, t.week), text(8pt, fill: _soft, ""),
    ..t.days.map(d => align(center, text(8pt, fill: _soft, d))),
    text(8pt, fill: _soft, t.note),
  )
  let body = ()
  for w in range(weeks) {
    let mon = first + duration(days: 7 * w)
    let sun = mon + duration(days: 6)
    body.push(text(9pt, weight: "bold", mon.display("[week_number repr:iso]")))
    body.push(text(8pt, fill: _soft, mon.display(t.date) + " " + t.to + " " + sun.display(t.date)))
    for i in range(7) {
      let d = mon + duration(days: i)
      let kind = if d < start or d > due { "off" } else if d == due { "due" } else if miles.any(m => m.at(0) == d) { "mile" } else { "open" }
      body.push(align(center + horizon, _box(kind: kind)))
    }
    let here = miles.filter(m => m.at(0) >= mon and m.at(0) <= sun)
    let label = if mon <= due and due <= sun { (..here.map(m => m.at(1)), strong(t.due)) } else { here.map(m => m.at(1)) }
    body.push(block(width: 100%, stroke: (bottom: 0.4pt + _line), inset: (bottom: 1mm),
      text(8pt, fill: _accent-text, label.join(", "))))
  }
  table(
    columns: (9mm, 30mm, ..range(7).map(_ => 7.5mm), 1fr),
    align: (left + horizon, left + horizon, ..range(7).map(_ => center + horizon), left + bottom),
    stroke: none,
    inset: (x: 1mm, y: 1.6mm),
    table.header(..head),
    ..body,
  )
  v(3mm)
  text(8pt, fill: _soft, t.gap)

  // week pages
  for p in range(week-pages) {
    pagebreak()
    text(15pt, weight: "bold", t.week-page)
    h(1fr)
    text(9pt, fill: _soft, t.week + " ____   ____ " + t.to + " ____")
    v(5mm)
    let wh = (
      text(8pt, fill: _soft, ""),
      ..t.days.map(d => align(center, text(8pt, fill: _soft, d))),
      align(center, text(8pt, fill: _soft, t.goal)),
    )
    let wb = ()
    for r in rows + ("", "") {
      wb.push(if r == "" { line(length: 90%, stroke: 0.4pt + _line) } else { text(10pt, r) })
      for i in range(7) { wb.push(align(center + horizon, _box(size: 8mm))) }
      wb.push(align(center + horizon, text(10pt, fill: _soft, "__ / 7")))
    }
    table(
      columns: (1fr, ..range(7).map(_ => 11mm), 16mm),
      align: horizon,
      stroke: none,
      inset: (x: 1mm, y: 2.4mm),
      table.header(..wh),
      ..wb,
    )
    v(8mm)
    grid(columns: (1fr, 1fr), gutter: 8mm,
      [#text(10pt, weight: "bold", t.done) #v(2mm) #for _ in range(6) { line(length: 100%, stroke: 0.4pt + _line); v(6mm) }],
      [#text(10pt, weight: "bold", t.next) #v(2mm) #for _ in range(6) { line(length: 100%, stroke: 0.4pt + _line); v(6mm) }],
    )
  }
}
