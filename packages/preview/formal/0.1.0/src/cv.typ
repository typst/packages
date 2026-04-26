#import "general.typ": *
#import "@preview/fontawesome:0.6.0": fa-icon


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
  // Styles

  show: formal-general.with(frame-thickness: frame-thickness)
  show: formal-syntax

  show heading: set block(above: 1.5em, below: 1.2em)


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
    ghost(italic: false, prefix)
      + [ ]
      + text(size: 1.2em, weight: "bold", name)
      + linebreak()
      + emph(title)
      + linebreak()
      + location,
    for link in links {
      link + linebreak()
    },
  )

  body
}

// Grid of keywords, e.g. to represent technical skills in a compact way
#let keyword-grid(n-rows: 4, row-gutter: 0.5em, column-gutter: 1em, columns: auto, ..skills) = {
  // Keyword group header representing 1st level item in a list
  let skills = skills.named()
  let n-groups = skills.len()
  let group-title(name) = list.item(
    name
      + h(0.5em)
      + box(
        width: 1fr,
        line(length: 100%, stroke: (dash: "loosely-dotted")),
        baseline: -0.3em,
      ),
  )

  // Split array into columns
  let split-columns(values) = values.chunks(n-rows)

  // Apply styles to a keyword representing 2nd level item in a list
  let keyword(word) = list.with(marker: none)(list(word))

  // Render a column of keywords
  let grid-column(col-vals) = grid(rows: n-rows, row-gutter: row-gutter, ..col-vals.map(keyword))

  // Render a group of keywords
  let group-keywords(values) = {
    let n-columns = calc.ceil(values.len() / n-rows)
    let grid-not-intended = grid(columns: (1fr,) * n-columns, ..split-columns(values).map(
        grid-column,
      ))
    grid(
      columns: (0.9em, 1fr),
      none, grid-not-intended,
    )
  }

  // Render the final grid of keywords with group titles
  if columns == auto {
    columns = (auto,) * n-groups
  }

  grid(
    rows: 2,
    row-gutter: 0.3em,
    columns: columns,
    column-gutter: column-gutter,
    ..skills.keys().map(title => group-title(strong(title))),
    ..skills.values().map(group-keywords),
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

// CV list item
#let cv-item(
  title: [],
  title-comment: none,
  organization: [],
  organization-comment: none,
  dates: [],
  location: none,
) = {
  // Make the first line
  let first-line = {
    text(weight: "bold", title)
    if title-comment != none { [ > ] + emph(title-comment) }
    [|] + dates
  }

  // Make the second line
  let second-line = {
    set text(size: 0.9em)
    emph(organization)
    if organization-comment != none { ghost([ > ]) + ghost(italic: true, organization-comment) }
    if location != none { [|] + emph(location) }
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
  title + [ > ]
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
