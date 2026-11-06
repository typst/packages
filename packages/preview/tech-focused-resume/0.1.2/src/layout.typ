#let body-helper(body, padding: true) = {
  if body != [] {
    v(-0.4em)
    set list(indent: 0.25em)
    pad(left: if padding { 1.5em } else { 0em }, body)
  }
}

#let no-marker-list-helper(body) = {
  set par(leading: 0.6em)
  set list(
    body-indent: 0em,
    marker: [],
  )
  body
}

#let section(title, spacing-between: -0.5em, body) = {
  [= #title]
  pad(left: 1.4em, body)
  v(spacing-between)
}


#let grid-section(
  columns: (1fr, 1fr),
  gutter: 2.5em,
  sections: (),
) = {
  v(2em, weak: true)
  grid(
    columns: columns,
    gutter: gutter,
    ..sections
  )
}

// Generic two by two component for resume
#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
  cols: (1fr, 1fr),
) = {
  assert.eq(type(cols), array)

  grid(
    columns: cols,
    align(left)[#top-left \ #bottom-left], align(right)[#top-right \ #bottom-right],
  )
  v(-0.2em)
}

// Generic one by two component for resume
#let generic-one-by-two(
  first,
  second,
  cols: (1fr, 1fr),
) = {
  assert.eq(type(cols), array)

  grid(
    columns: (cols),
    align(left, first), align(right, second),
  )
  v(-0.2em)
}
