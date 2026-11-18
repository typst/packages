// kindling-packing-list: printable camping packing lists from plain-text
// .camp checklists. Format rules (shared by the CampChecklist packages):
//   - a line starting with "#" is a section header
//   - "- [ ] item" is to pack, "- [x] item" / "- [X] item" is packed
//   - "*" and "+" bullets work too, items may be indented
//   - every other line is ignored here

/// The car-camping kitchen starter list (19 items in 6 sections), with the
/// source of every number in the line itself.
#let starter-list = "# Fire
- [ ] Stove
- [ ] Fuel (one more canister than you think you need)
- [ ] Two ways to light it (lighter + matches in a zip bag)
- [ ] Windscreen
# Cold
- [ ] Cooler, pre-chilled the night before
- [ ] Thermometer in the cooler (keep it at 40F / 4C or below - USDA)
- [ ] Frozen water bottles instead of bought ice
- [ ] Raw meat in sealed containers (bottom layer)
# Water
- [ ] Water (about 1 gallon per person per day for drinking and washing, more in heat - Ready.gov)
- [ ] Wash water in its own jug, apart from drinking water
- [ ] Jug with a spigot
# Prep
- [ ] Cutting board, knife with sheath
- [ ] Spatula, tongs, can opener
- [ ] Paper towels, trash bags
# Clean
- [ ] Three bins or a sink
- [ ] Biodegradable soap, sponge
- [ ] Fine mesh strainer (graywater)
- [ ] Unscented bleach (about 1 tbsp per gallon to sanitize - CDC)
# Store
- [ ] Bear country: food, cooler and trash in the locker or a hard-sided car - NPS
"

/// Parse one line. Returns none for lines that are not items, otherwise a
/// dictionary (text: str, packed: bool).
#let parse-item(line) = {
  let t = line.trim(at: start)
  let m = t.match(regex("^[-*+][ \t]+\[([ xX])\](.*)$"))
  if m == none { return none }
  (text: m.captures.at(1).trim(), packed: m.captures.at(0) != " ")
}

/// Parse .camp text into an array of sections:
/// (title: str, items: array of (text, packed)).
/// Items before the first header go to a section titled "(no section)".
#let parse-camp(text) = {
  let sections = ()
  let current = none
  for raw in text.split("\n") {
    let line = raw.trim("\r", at: end)
    if line.trim(at: start).starts-with("#") {
      if current != none { sections.push(current) }
      let title = line.trim(at: start).trim("#", at: start).trim()
      current = (title: if title == "" { "(untitled)" } else { title }, items: ())
      continue
    }
    let item = parse-item(line)
    if item == none { continue }
    if current == none { current = (title: "(no section)", items: ()) }
    current.items.push(item)
  }
  if current != none { sections.push(current) }
  sections
}

/// Packed and total item counts of parsed sections.
#let progress(sections) = {
  let total = 0
  let packed = 0
  for s in sections {
    total += s.items.len()
    packed += s.items.filter(i => i.packed).len()
  }
  (packed: packed, total: total)
}

/// "Packed 12/22 (55%)", "Packed 5/5 - all packed", or "" with no items.
#let status-text(packed, total) = {
  if total == 0 { return "" }
  if packed == total { return "Packed " + str(packed) + "/" + str(total) + " - all packed" }
  "Packed " + str(packed) + "/" + str(total) + " (" + str(calc.round(100 * packed / total)) + "%)"
}

/// Drinking and washing water for a trip, in US gallons and liters.
/// Base: about 1 gallon per person per day (Ready.gov); `hot` adds 50%.
#let water-estimate(people: 2, days: 2, hot: false) = {
  let gallons = people * days * (if hot { 1.5 } else { 1 })
  (gallons: gallons, liters: calc.round(gallons * 3.785, digits: 1))
}

#let _box(packed, accent) = box(
  width: 0.8em, height: 0.8em, baseline: 0.1em,
  stroke: 0.7pt + accent, radius: 1.5pt,
  if packed { align(center + horizon, text(size: 0.7em, fill: accent, sym.checkmark)) },
)

/// Render parsed sections as a checklist in `columns` columns. Whole sections
/// are kept together and spread over the columns so they end at similar heights.
#let checklist(sections, columns: 2, accent: rgb("#2f5d50")) = {
  set par(justify: false, leading: 0.5em)
  let cols = range(columns).map(_ => ())
  let load = range(columns).map(_ => 0)
  for s in sections {
    let i = load.position(x => x == calc.min(..load))
    cols.at(i).push(s)
    load.at(i) += s.items.len() + 2
  }
  let render(s) = block(breakable: false, below: 0.9em, {
    text(weight: "bold", fill: accent, upper(s.title))
    v(-0.4em)
    line(length: 100%, stroke: 0.5pt + accent.lighten(40%))
    v(-0.2em)
    grid(
      columns: (1.2em, 1fr),
      row-gutter: 0.7em,
      ..s.items.map(i => (
        _box(i.packed, accent),
        if i.packed { text(fill: luma(120), strike(i.text)) } else { i.text },
      )).flatten(),
    )
  })
  grid(
    columns: range(columns).map(_ => 1fr),
    column-gutter: 1.6em,
    ..cols.map(c => stack(spacing: 1.3em, ..c.map(render))),
  )
}

/// A one-page printable packing sheet.
///
/// - camp: .camp text (for example `read("trip.camp")`); defaults to the starter list
/// - trip, dates: header text
/// - people, days, hot: used for the water estimate
/// - extra: rows of empty lines for items you add by hand
#let packing-sheet(
  camp: starter-list,
  trip: "Camping trip",
  dates: none,
  people: 2,
  days: 2,
  hot: false,
  columns: 2,
  accent: rgb("#2f5d50"),
  notes: none,
  extra: 0,
) = {
  let sections = parse-camp(camp)
  let p = progress(sections)
  let w = water-estimate(people: people, days: days, hot: hot)
  set text(size: 10pt)
  block(width: 100%, inset: (bottom: 0.6em), stroke: (bottom: 1.2pt + accent), {
    grid(
      columns: (1fr, auto),
      align: (left + bottom, right + bottom),
      text(size: 20pt, weight: "bold", fill: accent, trip),
      text(fill: luma(90), if dates != none { dates }),
    )
    v(0.3em)
    text(fill: luma(70))[
      #people #if people == 1 [person] else [people] · #days #if days == 1 [day] else [days]
      · water about #w.gallons gal (#w.liters L)#if hot [, hot weather] else []
      #if p.total > 0 [· #status-text(p.packed, p.total)]
    ]
  })
  v(0.8em)
  checklist(sections, columns: columns, accent: accent)
  if extra > 0 {
    v(0.4em)
    text(weight: "bold", fill: accent, upper("Also bring"))
    v(-0.4em)
    line(length: 100%, stroke: 0.5pt + accent.lighten(40%))
    grid(
      columns: (1fr,) * columns,
      column-gutter: 1.6em,
      row-gutter: 1.1em,
      ..range(extra * columns).map(_ => grid(
        columns: (1.2em, 1fr),
        _box(false, accent),
        align(bottom, line(length: 100%, stroke: 0.4pt + luma(170))),
      )),
    )
  }
  if notes != none {
    v(0.6em)
    block(width: 100%, inset: 0.7em, radius: 3pt, fill: accent.lighten(90%), notes)
  }
}
