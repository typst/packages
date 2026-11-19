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

/// Colour themes. Pass a name to `theme:` or any colour to `accent:`.
#let themes = (
  forest: rgb("#2f5d50"),
  lake: rgb("#2d5c7f"),
  desert: rgb("#9a5b2e"),
  ember: rgb("#a23b2c"),
  slate: rgb("#3d4a5c"),
)

/// Resolve the accent colour: an explicit `accent` wins, then a theme name.
#let theme-color(theme: "forest", accent: none) = {
  if accent != none { return accent }
  themes.at(theme, default: themes.forest)
}

/// Words in a section title that pick an icon. The first match wins.
#let icon-words = (
  fire: ("fire", "stove", "fuel", "burn"),
  cold: ("cold", "cooler", "fridge", "ice", "food safety"),
  water: ("water", "drink", "hydration"),
  prep: ("prep", "knife", "utensil", "tool"),
  clean: ("clean", "wash", "dish", "trash", "hygiene"),
  store: ("store", "storage", "bear", "pantry", "food box"),
  cook: ("cook", "kitchen", "meal", "pan", "pot"),
  camp: ("camp", "shelter", "tent", "sleep", "site"),
  pack: ("pack", "gear", "bag", "bring", "clothes", "misc"),
)

/// The icon key ("fire", "cold", ...) for a section title, or none.
#let icon-key(title) = {
  let t = lower(title)
  for (key, words) in icon-words {
    if words.any(w => t.contains(w)) { return key }
  }
  none
}

/// The bundled illustration for a key, `height` tall.
#let icon(key, height: 1.4em) = image("icons/" + key + ".png", height: height)

#let _box(packed, accent) = box(
  width: 0.8em, height: 0.8em, baseline: 0.1em,
  stroke: 0.7pt + accent, radius: 1.5pt,
  if packed { align(center + horizon, text(size: 0.7em, fill: accent, sym.checkmark)) },
)

/// Render parsed sections as a checklist in `columns` columns. Whole sections
/// are kept together and spread over the columns so they end at similar heights.
#let checklist(sections, columns: 2, accent: rgb("#2f5d50"), icons: true) = {
  set par(justify: false, leading: 0.5em)
  let cols = range(columns).map(_ => ())
  let load = range(columns).map(_ => 0)
  for s in sections {
    let i = load.position(x => x == calc.min(..load))
    cols.at(i).push(s)
    load.at(i) += s.items.len() + 2
  }
  let render(s) = block(breakable: false, below: 0.9em, {
    let k = if icons { icon-key(s.title) } else { none }
    if k != none {
      grid(columns: (auto, 1fr), column-gutter: 0.5em, align: horizon,
        icon(k, height: 1.6em), text(weight: "bold", fill: accent, upper(s.title)))
    } else {
      text(weight: "bold", fill: accent, upper(s.title))
    }
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

/// The header block shared by both pages: trip name, dates, a summary line and
/// the camp illustration on the right.
#let _header(trip, dates, summary, accent, art: "camp") = block(
  width: 100%, inset: (bottom: 0.6em), stroke: (bottom: 1.2pt + accent),
  grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    align: (left + bottom, right + bottom),
    {
      text(size: 20pt, weight: "bold", fill: accent, trip)
      if dates != none { h(0.8em); text(fill: luma(90), dates) }
      v(0.3em)
      text(fill: luma(70), summary)
    },
    if art != none { icon(art, height: 3.4em) },
  ),
)

/// A printable packing sheet.
///
/// - camp: .camp text (for example `read("trip.camp")`); defaults to the starter list
/// - trip, dates: header text
/// - people, days, hot: used for the water estimate
/// - theme: "forest", "lake", "desert", "ember" or "slate"; `accent` overrides it
/// - icons: draw the bundled illustration next to sections it recognises
/// - extra: rows of empty lines for items you add by hand
/// - notes: content shown in a shaded box at the end
#let packing-sheet(
  camp: starter-list,
  trip: "Camping trip",
  dates: none,
  people: 2,
  days: 2,
  hot: false,
  columns: 2,
  theme: "forest",
  accent: none,
  icons: true,
  notes: none,
  extra: 0,
) = {
  let accent = theme-color(theme: theme, accent: accent)
  let sections = parse-camp(camp)
  let p = progress(sections)
  let w = water-estimate(people: people, days: days, hot: hot)
  set text(size: 10pt)
  _header(trip, dates, [
    #people #if people == 1 [person] else [people] · #days #if days == 1 [day] else [days]
    · water about #w.gallons gal (#w.liters L)#if hot [, hot weather] else []
    #if p.total > 0 [· #status-text(p.packed, p.total)]
  ], accent, art: if icons { "camp" } else { none })
  v(0.8em)
  checklist(sections, columns: columns, accent: accent, icons: icons)
  if extra > 0 {
    v(0.4em)
    if icons {
      grid(columns: (auto, 1fr), column-gutter: 0.5em, align: horizon,
        icon("pack", height: 1.6em), text(weight: "bold", fill: accent, upper("Also bring")))
    } else { text(weight: "bold", fill: accent, upper("Also bring")) }
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

/// Day labels for a trip: "Day 1", "Day 2", ... or the names you pass.
#let day-labels(days, names: none) = {
  if names != none { return names }
  range(days).map(d => "Day " + str(d + 1))
}

/// A printable meal plan: one row per day, one column per meal, with room to
/// write dishes, and a cooler / shopping column. Pre-filled cells come from
/// `plan`, a dictionary such as ("Day 1": (Dinner: "Foil-pack tacos")).
///
/// - days or day-names: the rows
/// - meals: the columns (default Breakfast, Lunch, Dinner, Snacks)
/// - shopping: add the "Cooler / shop" column
/// - rules: show the food-safety reminders strip at the bottom
/// - note-lines: ruled lines for trip notes under the table (0 for none)
#let meal-plan(
  trip: "Camping trip",
  dates: none,
  people: 2,
  days: 2,
  day-names: none,
  meals: ("Breakfast", "Lunch", "Dinner", "Snacks"),
  plan: (:),
  shopping: true,
  rules: true,
  theme: "forest",
  accent: none,
  icons: true,
  row-height: 6.5em,
  note-lines: 8,
) = {
  let accent = theme-color(theme: theme, accent: accent)
  let labels = day-labels(days, names: day-names)
  set text(size: 10pt)
  _header(trip + " - meal plan", dates, [
    #people #if people == 1 [person] else [people] · #labels.len() #if labels.len() == 1 [day] else [days]
    · #(labels.len() * meals.len()) meal slots
  ], accent, art: if icons { "cook" } else { none })
  v(0.8em)
  let cols = meals + if shopping { ("Cooler / shop",) } else { () }
  table(
    columns: (auto,) + (1fr,) * cols.len(),
    stroke: 0.5pt + accent.lighten(55%),
    fill: (x, y) => if y == 0 { accent.lighten(85%) } else if x == 0 { accent.lighten(93%) },
    inset: 0.55em,
    align: (x, y) => if y == 0 or x == 0 { left + horizon } else { left + top },
    table.header(
      [],
      ..cols.map(c => text(weight: "bold", fill: accent, c)),
    ),
    ..labels.map(d => (
      box(height: row-height, align(horizon, text(weight: "bold", fill: accent, d))),
      ..cols.map(c => {
        let entry = plan.at(d, default: (:)).at(c, default: none)
        if entry != none { entry } else { [] }
      }),
    )).flatten(),
  )
  if rules {
    v(0.8em)
    block(width: 100%, inset: 0.7em, radius: 3pt, fill: accent.lighten(90%), grid(
      columns: (auto, 1fr),
      column-gutter: 0.8em,
      align: horizon,
      if icons { icon("cold", height: 2.6em) },
      [
        *Cooler rules.* Keep it at 40F / 4C or below and pack raw meat sealed on
        the bottom (USDA). Perishable food left out more than 2 hours, or 1 hour
        above 90F / 32C, goes in the trash (USDA). Plan the first night's dinner
        from the coldest food; eat shelf-stable meals last.
      ],
    ))
  }
  if note-lines > 0 {
    v(0.8em)
    if icons {
      grid(columns: (auto, 1fr), column-gutter: 0.5em, align: horizon,
        icon("pack", height: 1.6em), text(weight: "bold", fill: accent, upper("Trip notes")))
    } else { text(weight: "bold", fill: accent, upper("Trip notes")) }
    v(-0.4em)
    line(length: 100%, stroke: 0.5pt + accent.lighten(40%))
    for _ in range(note-lines) {
      v(1.15em)
      line(length: 100%, stroke: 0.4pt + luma(170))
    }
  }
}
