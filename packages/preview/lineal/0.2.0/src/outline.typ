#import "navigation/heading-model.typ": get-heading-model, current-heading, headings-context

#let navigation-options(depth, indent, gap, size, ink, accent, fill, page-numbering) = {
  assert(depth == none or (type(depth) == int and depth > 0), message: "navigation: depth must be a positive integer or none")
  assert(indent >= 0pt and gap >= 0pt and size > 0pt, message: "navigation: size must be positive and spacing must be non-negative")
  let ink = if ink == auto { text.fill } else { ink }
  let accent = if accent == auto { ink } else { accent }
  assert(type(ink) == color and type(accent) == color, message: "navigation: ink and accent must be colours or auto")
  assert(type(page-numbering) in (str, function), message: "navigation: page-numbering must be a string or function")
  (indent: indent, gap: gap, size: size, ink: ink, accent: accent, fill: fill, page-numbering: page-numbering)
}

#let navigation-row(entry, options, transform, base, right-aligned: false, page-numbers: false) = {
  let active = entry.is-active or (entry.relation != none and entry.relation.parent)
  let label = text(
    weight: if active or entry.level == 1 { "semibold" } else { "regular" },
    fill: if active { options.accent } else { options.ink },
    transform(entry, entry.heading.body),
  )
  let body = if page-numbers {
    let number = context numbering(options.page-numbering, ..counter(page).at(entry.loc))
    label + h(.75em) + box(width: 1fr, if options.fill == none { [] } else { options.fill }) + h(.75em) + number
  } else { label }
  block(width: 100%, breakable: false, above: 0pt, below: options.gap, {
    set align(if right-aligned { right } else { left })
    pad(left: if right-aligned { 0pt } else { (entry.depth - base) * options.indent }, link(entry.loc, body))
  })
}

#let navigation-rows(entries, options, transform, right-aligned: false, page-numbers: false, group-roots: true) = {
  if entries.len() == 0 { return [] }
  let roots = if group-roots { entries.map(entry => entry.root-id).dedup() } else { (none,) }
  for (index, root) in roots.enumerate() {
    let group = if group-roots { entries.filter(entry => entry.root-id == root) } else { entries }
    let base = calc.min(..group.map(entry => entry.depth))
    if index > 0 { v(options.gap * .75) }
    for entry in group {
      navigation-row(entry, options, transform, base, right-aligned: right-aligned, page-numbers: page-numbers)
    }
  }
}

#let navigation-content(title, options, body) = {
  set text(size: options.size, fill: options.ink)
  set par(spacing: .5em, leading: .35em)
  if title != none {
    let title = if title == auto { [Contents] } else { title }
    block(above: 0pt, below: .8em, text(size: 1.2em, weight: "bold", title))
  }
  body
}

/// Contextual section navigation. Selection changes visibility, never ancestry.
#let lineal-outline(
  title: none, target: heading.where(outlined: true), depth: none,
  filter: entry => true, transform: (_, body) => body,
  columns: (1fr, 2fr), gutter: 2em,
  indent: 1.1em, gap: .45em, size: 1em,
  ink: auto, accent: auto, page-numbers: false, page-numbering: "1", fill: none,
) = context {
  assert(type(columns) == array and columns.len() == 2, message: "lineal-outline: columns must contain two widths")
  assert(gutter >= 0pt, message: "lineal-outline: gutter must be non-negative")
  assert(type(filter) == function and type(transform) == function, message: "navigation: filter and transform must be functions")
  assert(type(page-numbers) == bool, message: "navigation: page-numbers must be a boolean")
  let options = navigation-options(depth, indent, gap, size, ink, accent, fill, page-numbering)
  let model = get-heading-model(target: target, depth: depth, filter: filter)
  let sections = model.visible.filter(entry => entry.level == 1)
  let has-sections = model.entries.any(entry => entry.level == 1)
  let body = if model.current == none or not has-sections or model.section == none {
    navigation-rows(model.visible, options, transform, page-numbers: page-numbers)
  } else {
    let current = model.visible.filter(entry => entry.root-id == model.section.id)
    if sections.len() == 0 {
      navigation-rows(current, options, transform, page-numbers: page-numbers)
    } else {
      grid(columns: columns, column-gutter: gutter, align: top,
        navigation-rows(sections, options, transform, right-aligned: true, page-numbers: page-numbers, group-roots: false),
        navigation-rows(current, options, transform, page-numbers: page-numbers),
      )
    }
  }
  navigation-content(title, options, body)
}

/// A complete, linked hierarchy that flows across normal document pages.
#let lineal-toc(
  title: [Contents], target: heading.where(outlined: true), depth: none,
  filter: entry => true, transform: (_, body) => body,
  indent: 1.1em, gap: .45em, size: 1em,
  ink: auto, accent: auto, page-numbers: false, page-numbering: "1", fill: none,
) = context {
  assert(type(filter) == function and type(transform) == function, message: "navigation: filter and transform must be functions")
  assert(type(page-numbers) == bool, message: "navigation: page-numbers must be a boolean")
  let options = navigation-options(depth, indent, gap, size, ink, accent, fill, page-numbering)
  let model = get-heading-model(target: target, depth: depth, filter: filter)
  navigation-content(title, options,
    navigation-rows(model.visible, options, transform, page-numbers: page-numbers),
  )
}
