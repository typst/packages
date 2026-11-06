#let highlight = rgb("#24449e")

#let section(title) = {
  set text(weight: "semibold", size: 1.25em, fill: white)
  block(below: 0.2em, fill: highlight, inset: 3pt)[#title]
  box(
    height: 0.5pt,
    fill: highlight,
    width: 100%
  )
  
}

#let exp-header(content) = {
  set text(weight: "semibold", size: 1.25em)
  block(above: 1em, below: 1em)[
    #grid(
      columns: (1fr, 1fr, 1fr),
      align(left)[#content.left],
      align(center)[#content.center],
      align(right)[#content.right]
    )
  ]
}

#let project-header(content) = {
  set text(weight: "semibold", size: 1.25em)
  block(above: 1em, below: 1em)[
    #content.title \ 
    #text(size: 0.8em, weight: "regular")[#link(content.website)]
  ]
}