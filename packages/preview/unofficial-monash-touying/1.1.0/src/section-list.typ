// Lists of sections on the outline slide and on section dividers. Lists of
// level-one sections are laid out here rather than by Touying's outline,
// so that up to 12 sections fit on one slide.

#import "@preview/touying:0.8.0": utils
#import "design.typ": *
#import "appendix.typ": in-appendix, section-label

#let _number-box(self, label, current: true, alpha: 0%, large: false) = {
  let accent = self.store.accent-color
  box(
    width: 1.85em,
    height: 1.45em,
    fill: if current { accent } else { accent.transparentize(alpha) },
    baseline: 18%,
    align(center + horizon, text(
      size: if large { 1em } else { .78em },
      fill: if current { white } else { white.transparentize(alpha) },
      weight: "bold",
      label,
    )),
  )
}

// One outline entry: a filled number box and the section title. Appendix
// sections are left out of every outline.
#let outline-entry(self, it, current: true, alpha: 0%, large: false) = context {
  let location = it.element.location()
  if in-appendix(location) { return }
  let fill = if current { monash-blue } else { monash-muted.transparentize(alpha) }
  let title = utils.short-heading(self: self, it.element)
  // Deeper levels are indented under their section, without a number box.
  if it.level > 1 {
    return link(location, pad(left: 2.9em * (it.level - 1), text(
      size: .8em,
      fill: fill,
      title,
    )))
  }
  link(location, grid(
    columns: (2.2em, 1fr),
    column-gutter: .7em,
    align: (center + horizon, left + horizon),
    _number-box(
      self,
      section-label(location, level: it.level),
      current: current,
      alpha: alpha,
      large: large,
    ),
    text(
      size: if large { 1.1em } else { .92em },
      fill: fill,
      weight: if current { "bold" } else { "regular" },
      title,
    ),
  ))
}


/// Lays `body` out at the full width of the region and scales it down when
/// it is taller than the region, to at most `floor` of its size; below
/// that it is left to continue on another page.
#let shrink-to-fit(body, floor: 55%) = layout(region => {
  let natural = measure(block(width: region.width, body)).height
  if natural <= region.height {
    body
  } else {
    let ratio = calc.max(floor / 100%, region.height / natural)
    scale(
      ratio * 100%,
      origin: top + left,
      reflow: true,
      block(width: region.width / ratio, body),
    )
  }
})

// Main-part headings of `level`, in document order. Needs context.
#let _main-headings(level) = query(heading.where(level: level, outlined: true))
  .filter(it => not in-appendix(it.location()))

#let _entry(self, element, ..args) = outline-entry(
  self,
  (element: element, level: element.level),
  ..args,
)

/// All main sections for the outline slide: one column for up to 6, two
/// columns (filled top to bottom) for more. Needs no context.
#let section-grid(self) = context {
  let headings = _main-headings(1)
  let columns = if headings.len() > 6 { 2 } else { 1 }
  let rows = calc.ceil(headings.len() / columns)
  let cells = range(rows * columns).map(i => {
    let index = calc.rem(i, columns) * rows + calc.quo(i, columns)
    if index < headings.len() { _entry(self, headings.at(index)) }
  })
  grid(
    columns: (1fr,) * columns,
    column-gutter: 1.4em,
    row-gutter: if columns == 1 { .82em } else { .9em },
    ..cells,
  )
}

#let _more = text(fill: monash-muted, size: .8em)[#h(2.9em)#sym.dots.h]

/// Sections on a divider slide: all of them up to 6, otherwise a window of
/// 5 around `location`, with dots where entries are left out. Needs context.
#let section-window(self, level, location) = {
  let headings = _main-headings(level)
  let current = headings.position(it => it.location() == location)
  if current == none { return }
  let (start, end) = if headings.len() <= 6 { (0, headings.len()) } else {
    let start = calc.clamp(current - 2, 0, headings.len() - 5)
    (start, start + 5)
  }
  let rows = range(start, end).map(i => {
    if i == current {
      _entry(self, headings.at(i), large: true)
    } else {
      _entry(self, headings.at(i), current: false, alpha: 58%)
    }
  })
  if start > 0 { rows.insert(0, _more) }
  if end < headings.len() { rows.push(_more) }
  set par(leading: .58em)
  stack(spacing: .46em, ..rows)
}
