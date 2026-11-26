// Table of contents and lists of figures/tables/listings (KOMA tocbasic as
// configured by kaobook).
#import "metrics.typ" as m
#import "state.typ": *
#import "headings.typ": has-number, heading-number, part-subtitle

#let em = m.size.normalsize

#let leaders = box(width: 1fr, repeat(gap: 4.94pt, justify: false)[.])

// One entry: number in a fixed-width box, title with hanging indent, leaders
// and the page number flush right.
#let entry(
  indent: 0pt,
  number-width: 0pt,
  page-width: 2.1 * em,
  number: none,
  title: [],
  page: [],
  dots: true,
  target: none,
) = {
  let line = {
    box(width: number-width, number)
    title
    if dots { [ ]; leaders; h(0.5em) } else { h(1fr) }
    box(width: 0pt, box(width: page-width, align(right, page)))
  }
  block(
    width: 100%,
    inset: (left: indent, right: page-width),
    spacing: m.leading-for("normalsize"),
    par(hanging-indent: number-width, justify: false, if target != none { link(target, line) } else { line }),
  )
}

// Vertical gap so that the first baseline of an entry is `distance` below the
// last baseline of the previous entry.
#let entry-gap(distance, size: em) = v(m.gap(distance, below-size: size) - m.leading-for("normalsize"))

#let toc-body(depth: 3) = context {
  let headings = query(heading).filter(h => h.outlined and h.level <= depth)
  set text(top-edge: m.top-edge, bottom-edge: m.bottom-edge)
  set par(leading: m.leading-for("normalsize"), spacing: m.leading-for("normalsize"))
  for (i, h) in headings.enumerate() {
    let page = page-label(h.location())
    if is-part(h) {
      let size = m.size.large
      let number = numbering("I", part-counter.at(h.location()).first() + 1)
      v(m.gap(36.67pt, below-size: size), weak: true)
      let subtitle = part-subtitle(h)
      set text(size: size, weight: "bold")
      set par(leading: m.leading-for("large"))
      let prefix = [#number.~]
      let title = smallcaps(h.body)
      if subtitle != none { title = [#title\ #smallcaps(subtitle)] }
      context entry(
        number-width: measure(prefix).width,
        number: smallcaps(prefix),
        title: title,
        page: page,
        page-width: 2.5 * em,
        dots: false,
        target: h.location(),
      )
    } else if h.level == 1 {
      // KOMA: 1em of extra space before chapter entries (also before the first)
      if i == 0 { v(27.5pt) } else { v(m.gap(22.5pt), weak: true) }
      set text(weight: "bold")
      let numbered = has-number(h)
      entry(
        number-width: if numbered { 1.5 * em } else { 0pt },
        number: if numbered { heading-number(h) },
        title: h.body,
        page: page,
        page-width: 2.5 * em,
        dots: false,
        target: h.location(),
      )
    } else {
      let (indent, number-width) = (
        (1.5 * em, 2.3 * em),
        (3.8 * em, 3.2 * em),
        (7.0 * em, 4.1 * em),
        (11.1 * em, 5.0 * em),
      ).at(calc.min(h.level - 2, 3))
      let numbered = has-number(h)
      entry(
        indent: if numbered { indent } else { indent + number-width },
        number-width: if numbered { number-width } else { 0pt },
        number: if numbered { heading-number(h) },
        title: h.body,
        page: page,
        target: h.location(),
      )
    }
  }
}

// List of figures, tables, listings or algorithms; entries are grouped by
// chapter with 10pt of extra space between groups.
#let figure-list-body(kind) = context {
  let figures = query(figure.where(kind: kind)).filter(f => f.outlined and f.numbering != none)
  if figures.len() == 0 { return }
  set text(top-edge: m.top-edge, bottom-edge: m.bottom-edge)
  set par(leading: m.leading-for("normalsize"), spacing: m.leading-for("normalsize"))
  // The figure numbering refers to the current chapter, so it is rebuilt from
  // the chapter heading in front of each figure (1.1, 2.3, A.1, ...).
  let number-of(f) = {
    let n = f.counter.at(f.location()).first()
    let before = query(heading.where(level: 1).before(f.location())).filter(h => not is-part(h))
    if before.len() == 0 or before.last().numbering == none { return str(n) }
    let c = before.last()
    let label = numbering(c.numbering, ..counter(heading).at(c.location()))
    if label == none { str(n) } else { label + "." + str(n) }
  }
  let numbers = figures.map(number-of)
  let number-width = calc.max(2 * em, ..numbers.map(n => measure(n).width + 0.6 * em))
  let chapter = none
  for (i, f) in figures.enumerate() {
    let c = counter(heading).at(f.location()).first()
    if chapter != none and c != chapter { v(10pt) }
    chapter = c
    entry(
      number-width: number-width,
      number: numbers.at(i),
      title: if f.caption != none { f.caption.body } else { [] },
      page: page-label(f.location()),
      target: f.location(),
    )
  }
}
