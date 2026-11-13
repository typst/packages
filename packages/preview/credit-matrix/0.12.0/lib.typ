// CRediT authorship statements, tables and heatmaps.
// The wording follows the credit-matrix package (src/core/generate-statement.ts); the role
// names and UI strings come from translations.json, which scripts/build-typst-translations.mjs
// writes from the core's catalogs.

#let _data = json("translations.json")
#let _slugs = _data.roles.map(r => r.slug)
#let _slug-by-name = _data.roles.map(r => (r.name, r.slug)).to-dict()
#let _levels = ("lead", "equal", "supporting")

// The heatmap colours of the app (src/core/contributor-color.ts).
#let _none-fill = rgb("#ececea")
#let _ink = rgb("#16181c")
#let _ink-dim = rgb("#595c63")
#let _fractions = (lead: 1, equal: 0.7, supporting: 0.4)

// Same bands as scoreToLevel in src/core/author.ts.
#let _score-level(score) = if score == 0 { "none" } else if score <= 33 { "supporting" } else if score <= 66 {
  "equal"
} else { "lead" }

#let _level(value, role, name) = {
  let bad = () => panic(
    "credit-matrix: " + name + " has " + repr(value) + " for " + role
      + "; use \"lead\", \"equal\", \"supporting\", true, false or a whole score from 0 to 100",
  )
  if value == true { "lead" } else if value == false or value == none or value == "none" { "none" } else if (
    type(value) == int or type(value) == float
  ) {
    if value < 0 or value > 100 or value != calc.round(value) { bad() }
    _score-level(value)
  } else if type(value) == str and value in _levels { value } else { bad() }
}

#let _unknown-role(role, name) = panic(
  "credit-matrix: unknown CRediT role \"" + role + "\" for " + name + ". Use one of: " + _slugs.join(", "),
)

// One person as (name, initials, ack, levels: (slug: level), equal, corresponding), from an inline dict
// or an author of the app's JSON export.
#let _person(entry) = {
  if type(entry) != dictionary or type(entry.at("name", default: none)) != str {
    panic("credit-matrix: each contributor needs a name, got " + repr(entry))
  }
  let name = entry.name.trim().replace(regex("\s+"), " ")
  let scores = (:)
  if "contributions" in entry {
    // JSON export: canonical English role names with 0-100 scores; a repeated role keeps its top score.
    for c in entry.contributions {
      let slug = _slug-by-name.at(c.role, default: none)
      if slug == none { _unknown-role(c.role, name) }
      scores.insert(slug, calc.max(scores.at(slug, default: 0), c.score))
    }
    scores = scores.pairs().map(((slug, score)) => (slug, _level(score, slug, name))).to-dict()
  } else {
    let roles = entry.at("roles", default: (:))
    if type(roles) == array { roles = roles.map(r => (r, true)).to-dict() }
    for (role, value) in roles {
      if role not in _slugs { _unknown-role(role, name) }
      scores.insert(role, _level(value, role, name))
    }
  }
  (
    name: name,
    initials: entry.at("initials", default: none),
    ack: entry.at("contributorType", default: none) == "non-author" or entry.at("non-author", default: false),
    levels: _slugs.filter(s => scores.at(s, default: "none") != "none").map(s => (s, scores.at(s))).to-dict(),
    equal: entry.at("equalContribution", default: entry.at("equal-contribution", default: false)),
    corresponding: entry.at("corresponding", default: false),
  )
}

#let _people(contributors) = {
  let list = if type(contributors) == dictionary and "authors" in contributors { contributors.authors } else {
    contributors
  }
  if type(list) == dictionary { list = (list,) }
  list.map(_person)
}

// The catalog for `lang`: auto takes the document's text.lang and falls back to English.
// Typst keeps the region apart (text.region), so auto sees TW, HK and MO there: Traditional Chinese has no
// catalog and must not get Simplified.
#let _locale(lang) = {
  let wanted = if lang == auto { text.lang } else { lang }
  let base = wanted.split("-").first()
  let subtags = wanted.split("-").slice(1).map(lower)
  let traditional = base == "zh" and not subtags.contains("hans") and (
    subtags.any(part => part in ("hant", "tw", "hk", "mo"))
      or (lang == auto and text.region != none and upper(text.region) in ("TW", "HK", "MO"))
  )
  let code = if traditional { "en" } else if wanted in _data.locales { wanted } else if base == "pt" {
    "pt-PT"
  } else if base == "zh" { "zh-Hans" } else if base in _data.locales { base } else if lang == auto { "en" } else {
    panic("credit-matrix: no translations for lang \"" + lang + "\". Use one of: " + _data.locales.keys().join(", "))
  }
  _data.locales.at(code)
}

#let _fill(template, vars) = template.replace(regex("\{(\w+)\}"), m => vars.at(
  m.captures.first(),
  default: m.text,
))

// Spanish "y" becomes "e" before an i sound, as in ICU: "Ana e Isabel", but "Ana y Hierro".
#let _sep(sep, next) = if sep.trim() == "y" and next.contains(regex("^(?i)h?i")) and not next.contains(
  regex("^(?i)hi[aeiou]"),
) { sep.replace("y", "e") } else { sep }

#let _join-names(names, list) = if names.len() <= 2 { names.join(_sep(list.pair, names.last())) } else {
  names.first() + list.start + names.slice(1, -1).join(list.middle) + _sep(list.end, names.last()) + names.last()
}

#let _with-level(label, level, loc, levels) = if levels and level != "lead" {
  _fill(loc.ui.levelAnnotation, (label: label, level: loc.ui.at(level)))
} else { label }

// The statement as lines of (label, rest) segments, each line led by its prefix, plus the notes.
#let _statement-lines(people, format, levels, loc) = {
  let ui = loc.ui
  let body(group) = if format == "by-role" {
    _slugs
      .filter(s => group.any(p => s in p.levels))
      .map(s => (
        loc.roles.at(s),
        group.filter(p => s in p.levels).map(p => _with-level(p.name, p.levels.at(s), loc, levels)).join(ui.nameListSeparator),
      ))
  } else {
    group
      .filter(p => p.levels.len() > 0)
      .map(p => (
        p.name,
        p.levels.pairs().map(((s, l)) => _with-level(loc.roles.at(s), l, loc, levels)).join(ui.nameListSeparator),
      ))
  }
  let lines = ()
  let credit = body(people.filter(p => not p.ack))
  if credit.len() > 0 { lines.push(("CRediT:", credit)) }
  let ack = body(people.filter(p => p.ack))
  if ack.len() > 0 { lines.push((ui.acknowledgements + ui.labelSeparator.trim(at: end), ack)) }
  if lines.len() == 0 { return ((), ()) }
  let notes = ()
  let equal = people.filter(p => p.equal).map(p => p.name)
  if equal.len() > 1 { notes.push(_fill(ui.equalContributionNote, (names: _join-names(equal, loc.list)))) }
  let corr = people.filter(p => p.corresponding).map(p => p.name)
  if corr.len() > 0 { notes.push(_fill(ui.correspondenceNote, (names: _join-names(corr, loc.list)))) }
  (lines, notes)
}

#let _check-format(format) = if format not in ("by-role", "by-author") {
  panic("credit-matrix: format must be \"by-role\" or \"by-author\", got " + repr(format))
}

/// The statement as plain text, the same as the app's: "CRediT: Marie Skłodowska-Curie: Conceptualization; ...".
/// Needs context when `lang` is auto.
#let credit-statement-text(contributors, format: "by-author", levels: false, lang: auto) = {
  _check-format(format)
  let loc = _locale(lang)
  let (lines, notes) = _statement-lines(_people(contributors), format, levels, loc)
  (
    lines.map(((prefix, segs)) => prefix + " " + segs.map(((l, r)) => l + loc.ui.labelSeparator + r).join(loc.ui.segmentSeparator))
      + notes
  ).join("\n\n", default: "")
}

/// A CRediT statement, one paragraph per line, labels in bold. Contributors are an array of
/// `(name: .., roles: (slug: level))` dicts or the app's JSON export.
#let credit-statement(contributors, format: "by-author", levels: false, lang: auto) = context {
  _check-format(format)
  let loc = _locale(lang)
  let (lines, notes) = _statement-lines(_people(contributors), format, levels, loc)
  for (prefix, segs) in lines {
    par[#strong(prefix) #segs.map(((l, r)) => [#strong(l)#(loc.ui.labelSeparator)#r]).join(loc.ui.segmentSeparator)]
  }
  for note in notes { par(note) }
  [#metadata(credit-statement-text(contributors, format: format, levels: levels, lang: lang)) <credit-statement>]
}

/// A role-by-contributor table. A cell shows the level word (or `marks`), or a check mark
/// when `levels` is false. Only roles someone holds are listed.
#let credit-table(contributors, levels: true, lang: auto, marks: auto) = context {
  let loc = _locale(lang)
  let people = _people(contributors)
  let mark(level) = if marks != auto { marks.at(level) } else if levels { loc.ui.at(level) } else { sym.checkmark }
  let roles = _slugs.filter(s => people.any(p => s in p.levels))
  table(
    columns: (auto,) + (auto,) * people.len(),
    align: (x, _) => if x == 0 { left } else { center },
    table.header([], ..people.map(p => strong(p.name))),
    ..roles
      .map(s => (
        [#loc.roles.at(s)],
        ..people.map(p => if s in p.levels { mark(p.levels.at(s)) } else { [] }),
      ))
      .flatten(),
  )
}

/// A role-by-contributor heatmap in the app's colours, as a figure whose alt text is the
/// by-author statement. `caption` and the other named arguments go to `figure`.
#let credit-heatmap(
  contributors,
  levels: true,
  lang: auto,
  color: auto,
  palette: "blue",
  shape: "square",
  size: auto,
  font: "sans",
  font-size: 7.5pt,
  legend: true,
  legend-position: "auto",
  marks: false,
  labels: "full",
  horizontal: false,
  initials: false,
  skipempty: true,
  cell: 14pt,
  gap: 1.5pt,
  ..figure-args,
) = context {
  let palettes = (blue: rgb("#1f4e79"), green: rgb("#00724c"), gray: rgb("#404040"))
  assert(palette in palettes, message: "credit-matrix: unknown palette")
  assert(shape in ("square", "rounded", "circle"), message: "credit-matrix: unknown shape")
  assert(labels in ("full", "short"), message: "credit-matrix: labels must be full or short")
  assert(type(marks) == bool, message: "credit-matrix: marks must be true or false")
  assert(legend-position in ("auto", "right", "bottom"), message: "credit-matrix: legend-position must be auto, right or bottom")
  assert(font in ("sans", "serif"), message: "credit-matrix: font must be sans or serif")
  assert(font-size >= 4.5pt and font-size <= 24pt, message: "credit-matrix: font-size must be between 4.5pt and 24pt")
  set text(font: if font == "serif" { ("Libertinus Serif", "Times New Roman") } else { ("IBM Plex Sans", "DejaVu Sans", "Arial", "DejaVu Sans Mono") })
  let font-ratio = font-size / 7.5pt
  let hue = if color == auto { palettes.at(palette) } else { color }
  let cell = if size == auto { cell } else { size }
  assert(cell > 0pt and cell <= 192pt, message: "credit-matrix: size must be between 0 and 192pt")
  let radius(side) = if shape == "circle" { side / 2 } else if shape == "rounded" { 2pt } else { 0pt }
  let loc = _locale(lang)
  let people = _people(contributors)
  let roles = _slugs.filter(s => not skipempty or people.any(p => s in p.levels))
  let role-label(s) = {
    let label = loc.roles.at(s)
    if labels == "short" {
      // clusters, not bytes: str.len/slice count UTF-8 bytes and would cut inside a character
      let c = label.clusters()
      str(_slugs.position(x => x == s) + 1) + " " + c.slice(0, calc.min(12, c.len())).join() + if c.len() > 12 { "…" }
    } else { label }
  }
  let fill(level) = if level == "none" { _none-fill } else {
    let f = if levels { _fractions.at(level) } else { 1 }
    std.color.mix((rgb("#ffffff"), (1 - f) * 100%), (hue, f * 100%), space: rgb)
  }
  let luminance(c) = {
    let v = rgb(c).components().slice(0, 3).map(v => {
      let s = v / 100%
      if s <= 0.03928 { s / 12.92 } else { calc.pow((s + 0.055) / 1.055, 2.4) }
    })
    0.2126 * v.at(0) + 0.7152 * v.at(1) + 0.0722 * v.at(2)
  }
  let swatch(level, side: cell) = {
    let background = fill(level)
    let l = luminance(background)
    let ink = if (l + 0.05) / (luminance(_ink) + 0.05) >= 1.05 / (l + 0.05) { _ink } else { rgb("#ffffff") }
    box(width: side, height: side)[
      #place(top + left, rect(width: side, height: side, radius: radius(side), fill: background, stroke: 0.35pt + rgb("#c9c9c5")))
      #if marks and level != "none" {
        if levels {
          let dots = (supporting: 1, equal: 2, lead: 3).at(level)
          for i in range(dots) {
            place(top + left, dx: side / 2 + (i - (dots - 1) / 2) * side * 0.22 - side * 0.085,
              dy: side / 2 - side * 0.085, circle(radius: side * 0.085, fill: ink))
          }
        } else {
          place(center + horizon, text(size: side * 0.7, fill: ink, sym.checkmark))
        }
      }
    ]
  }
  let short-name(p) = if type(p.initials) == str and p.initials.trim() != "" { p.initials } else {
    let words = p.name.split(" ").filter(w => w != "")
    if words.len() <= 1 { p.name } else { words.map(w => upper(w.clusters().first())).join() }
  }
  let author-label(p) = if not initials { p.name } else {
    let label = short-name(p)
    if people.filter(other => short-name(other) == label).len() > 1 { p.name } else { label }
  }
  let top-labels = if horizontal { roles.map(role-label) } else { people.map(author-label) }
  let left-labels = if horizontal { people.map(author-label) } else { roles.map(role-label) }
  let top = top-labels.map(label => text(size: 8pt * font-ratio, weight: 500, fill: _ink, label))
  let top-height = calc.max(8pt * font-ratio * 1.2, ..top.map(t => measure(t).height))
  let column-gap = calc.max(gap, top-height * calc.sqrt(2) - cell)
  let row-gap = calc.max(gap, font-size * 1.2 - cell)
  let climb = (calc.max(0pt, ..top.map(t => measure(t).width)) + top-height) * calc.sqrt(0.5)
  let overhang = calc.max(0pt, ..range(top.len()).map(i =>
    (measure(top.at(i)).width + top-height) * calc.sqrt(0.5) - cell / 2
      - (top.len() - 1 - i) * (cell + column-gap)
  ))
  let cols = top.len()
  let rows = left-labels.len()
  let drawing = if roles.len() == 0 or people.len() == 0 { text(size: 8pt * font-ratio, fill: _ink-dim, loc.ui.emptyState) } else {
    let grid-figure = pad(right: overhang, grid(
      columns: (auto,) + (cell,) * cols,
      column-gutter: (6pt,) + (column-gap,) * cols,
      row-gutter: (6pt,) + (row-gap,) * rows,
      align: (x, _) => if x == 0 { right + horizon } else { center + horizon },
      [], ..top.map(t => box(width: cell, height: climb, place(
        bottom + left,
        dx: cell / 2,
        rotate(-45deg, origin: bottom + left, box(width: measure(t).width, t)),
      ))),
      ..range(rows).map(row => (
        text(size: font-size, fill: _ink-dim, left-labels.at(row)),
        ..range(cols).map(col => {
          let p = people.at(if horizontal { row } else { col })
          let s = roles.at(if horizontal { col } else { row })
          swatch(p.levels.at(s, default: "none"))
        }),
      )).flatten(),
    ))
    if legend {
      let keys = if levels { ("lead", "equal", "supporting", "none") } else { ("contributed", "none") }
      let key = keys.map(k => box[#box(baseline: 25%, swatch(if k == "contributed" { "lead" } else { k }, side: 10pt)) #text(
        size: font-size, fill: _ink-dim, loc.ui.at(k),
      )])
      let right-key = stack(spacing: 6pt, ..key)
      let bottom = stack(spacing: 10pt, grid-figure, align(center, key.join(h(10pt))))
      let right = stack(dir: ltr, spacing: 12pt, grid-figure, pad(top: climb + 6pt, right-key))
      let bottom-bounds = measure(bottom)
      let right-bounds = measure(right)
      let grid-width = cols * (cell + column-gap) - column-gap
      let grid-height = measure(grid-figure).height - climb - 6pt
      let use-right = legend-position == "right" or (
        legend-position == "auto" and grid-height >= grid-width * 1.5
          and right-bounds.width <= bottom-bounds.width * 1.35
          and right-bounds.width <= font-size * 48
          and right-bounds.height <= bottom-bounds.height
      )
      if use-right { right } else { bottom }
    } else { grid-figure }
  }
  figure(
    drawing,
    kind: image,
    alt: loc.ui.heatmapTitle + ". " + credit-statement-text(contributors, levels: levels, lang: lang),
    ..figure-args,
  )
}
