#import "general.typ": *
#import "@preview/fontawesome:0.6.0": fa-icon

#let style-headings(body) = {
  show heading: set block(above: 1em, below: 0.30em)
  body
}

#let style-lists(body) = {
  set list(
    marker: (
      star(),
      arrowhead(),
    ),
    tight: true,
    body-indent: 0.4em,
  )
  body
}

#let formal-cv(
  body,
  prefix: [],
  name: [John Doe],
  title: [Software Engineer],
  location: [San Francisco, CA],
  contacts: [],
  links: [],
  frame-thickness: 5mm,
) = {
  // Apply shared styles
  show: formal-general.with(frame-thickness: frame-thickness)

  // Apply overrides
  show: style-headings
  show: style-lists

  // Contact info
  if location != none {
    location = ghost(italic: true, location)
  }

  grid(
    columns: (25%, 50%, 25%),
    align: (left + horizon, center + horizon, right + horizon),
    for contact in contacts {
      contact + linebreak()
    },
    detail-stack(
      ghost(italic: false, prefix) + [ ] + text(size: 1.2em, weight: "bold", name),
      emph(title),
      location,
    ),
    for link in links {
      link + linebreak()
    },
  )

  body
}

// Grouped keyword list, e.g. to represent technical skills in a compact way
#let keyword-grid(n-rows: 4, row-gutter: 0.5em, column-gutter: 1em, columns: auto, ..skills) = {
  let skill-groups = skills.named()
  let n-groups = skill-groups.len()

  // Function to render a single keyword column with a title
  let keyword-group(title, values) = list(
    list.item(
      strong(title)
        + h(0.5em)
        + dotted-line()
        + if values.len() > 0 {
          (
            linebreak()
              + list(
                tight: true,
                ..values.map(list.item),
              )
          )
        },
    ),
  )

  if columns == auto {
    columns = (1fr,) * n-groups
  }

  // Render all columns in a grid layout
  grid(
    columns: columns,
    row-gutter: row-gutter,
    column-gutter: column-gutter,
    align: left + top,
    ..skill-groups.pairs().map(((title, values)) => keyword-group(title, values)),
  )
}

// About me block
#let summary(body) = {
  set par(justify: true)
  align(
    center,
    block(width: 80%, body),
  )
}

#let bullet-separator = [ • ]

// CV list item
#let cv-item(
  title: [],
  title-note: none,
  organization: [],
  organization-note: none,
  dates: [],
  location: none,
) = {
  // Make the first line
  let first-line = {
    text(weight: "bold", title)
    if title-note != none { bullet-separator + emph(title-note) }
    bullet-separator + dates
  }

  // Make the second line
  let second-line = {
    set text(size: 0.9em)
    emph(organization)
    if organization-note != none {
      ghost(bullet-separator) + ghost(italic: true, organization-note)
    }
    if location != none { bullet-separator + emph(location) }
  }

  // Render the list item
  first-line + linebreak() + second-line
}

#let small(body) = {
  set text(size: 0.9em)
  body
}

#let pub-item(title: [], journal: [], year: [], url: none) = {
  strong(year) + h(0.5em)
  title + bullet-separator
  emph(journal)
}

#let ref(url, prefix: "", icon: "globe") = {
  show link: set text(font: font-family)
  show: set text(fill: ghost-color)

  if prefix != "" {
    prefix = prefix + [: ]
  }

  let icon = fa-icon(icon, solid: true, size: 0.75em)

  "[" + link(url, prefix + icon) + "]"
}

#let label(body, dest: none, icon-name: none) = link(
  dest,
  ghost(fa-icon(icon-name, size: 0.75em)) + h(0.5em) + body,
)
