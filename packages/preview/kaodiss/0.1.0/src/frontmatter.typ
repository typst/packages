// Title page, its back side and the declaration.
#import "metrics.typ" as m
#import "state.typ": *
#import "i18n.typ": format-date
#import "page.typ": area-top

// Fonts: serif for everything, sans (Heros) for title and subtitle.
#let sans = ("TeX Gyre Heros", "Helvetica", "Arial")

// Vertical space so that the next baseline is `distance` below the previous one.
#let skip(distance, above, below) = v(m.gap(distance, above-size: above, below-size: below), weak: false)

#let title-page(
  title: none,
  subtitle: none,
  author: none,
  degree-type: none,
  degree-for: auto,
  degree: none,
  date: none,
  logos: (),
  university: none,
  department: none,
  chair: none,
  strings: (:),
) = {
  set align(center)
  set par(justify: false, spacing: 0pt)
  let L = m.size.Large
  // first baseline at 142.5pt from the top of the page
  v(142.5pt - area-top - 0.75 * L)
  {
    set text(size: L, weight: "bold")
    set par(leading: m.leading-for("Large"))
    if degree-type != none { upper(degree-type) }
    if degree != none {
      linebreak()
      if degree-for == auto { strings.degree-for } else { degree-for }
      linebreak()
      degree
    }
  }
  skip(55.64pt, L, m.sans-size.huge)
  {
    set text(font: sans, size: m.sans-size.huge, weight: "bold")
    set par(leading: m.baselineskip.huge - m.sans-size.huge)
    title
  }
  if subtitle != none {
    skip(24.59pt, m.sans-size.huge, m.sans-size.large)
    set text(font: sans, size: m.sans-size.large, weight: "bold")
    set par(leading: m.baselineskip.large - m.sans-size.large)
    subtitle
  }
  skip(38.52pt, m.sans-size.large, L)
  {
    set text(size: L)
    author
    skip(33.68pt, L, L)
    if type(date) == datetime { str(date.year()) } else { date }
  }
  if logos.len() > 0 {
    v(78.4pt - 0.25 * L)
    stack(dir: ttb, spacing: 5mm, ..logos.slice(0, 1))
    v(76.75pt - 0.75 * L)
  } else {
    v(1fr)
  }
  {
    set text(size: L)
    set par(leading: m.leading-for("Large"))
    (university, department, chair).filter(x => x != none).join(linebreak())
  }
  if logos.len() > 1 {
    v(5mm)
    stack(dir: ttb, spacing: 5mm, ..logos.slice(1))
  }
}

// Back of the title page: title, supervisors, defence date, statements, copyright.
// `people` is an array of (role, entries) where every entry is content.
#let title-back(
  title: none,
  subtitle: none,
  people: (),
  defense: none,
  transparency: none,
  copyright: none,
  extra: (),
  strings: (:),
  lang: "en",
) = {
  set par(justify: false, spacing: 0pt)
  let line-skip = m.baselineskip.normalsize
  let item(heading, body) = block(below: 0pt, above: 0pt, {
    strong(heading)
    linebreak()
    body
  })
  v(1fr)
  block({
    strong(title)
    if subtitle != none { linebreak(); subtitle }
  })
  v(31.56pt - line-skip + m.leading-for("normalsize"))
  let blocks = ()
  for (role, entries) in people {
    // one block per person, separated by an empty line (as in the reference)
    blocks.push(block(below: 0pt, {
      strong(role)
      linebreak()
      entries.first()
      for e in entries.slice(1) {
        block(above: 25.58pt - m.baselineskip.normalsize + m.leading-for("normalsize"), below: 0pt, e)
      }
    }))
  }
  if defense != none { blocks.push(item(strings.defense, format-date(defense, lang))) }
  for (heading, body) in extra { blocks.push(item(heading, body)) }
  if transparency != none { blocks.push(item(strings.transparency, transparency)) }
  if copyright != none { blocks.push(item(strings.copyright, copyright)) }
  for (i, b) in blocks.enumerate() {
    if i > 0 { v(18.77pt - line-skip + m.leading-for("normalsize")) }
    b
  }
}

// Signature line for the declaration.
#let signature(place: none, date: none, author: none) = {
  v(2 * m.baselineskip.normalsize)
  grid(
    columns: (1fr, 1fr),
    column-gutter: 2em,
    align: (left, left),
    [#place#if place != none and date != none [, ] #date],
    [],
    line(length: 100%, stroke: 0.4pt), line(length: 100%, stroke: 0.4pt),
    [], author,
  )
}
