#let quote-box(cite: none, body) = [
  #set text(size: 0.97em)
  #pad(left: 1.5em)[
    #block(
      breakable: true,
      width: 100%,
      fill: gray.lighten(95%),
      radius: (left: 0pt, right: 5pt),
      stroke: (left: 5pt + gray, rest: 1pt + silver.lighten(50%)),
      inset: 1em,
    )[#body]
  ]
]

#let indent(body) = [
  #block(
    width: 90%,
    inset: (left: 1.5em),
    [ #body ],
  )
]

#let smash(body, side: center) = math.display(
  box(
    width: 0pt,
    align(
      side.inv(),
      box(width: float.inf * 1pt, $ script(body) $),
    ),
  ),
)

#let maketitle(title, subtitle: "", position: center) = [
  #align(position)[
    #text(18pt)[ = #title ]
    #text(13pt, style: "italic")[ #subtitle ]
  ]
]

#let horizontalrule(color: gray, dashed: false) = {
  line(
    length: 100%,
    stroke: (
      paint: color,
      thickness: 1pt,
      dash: if dashed { ("dot", 2pt, 4pt, 2pt) } else { none },
    ),
  )
}

#let mathbox(content, higher: false) = {
  box(
    stroke: 0.5pt,
    inset: (x: 6pt, y: 3pt),
    outset: (x: 2pt, y: if higher { 8pt } else { 4pt }),
    if higher { $display(#content)$ } else { $#content$ },
  )
}

#let mathnote(content) = align(center)[(#content)]
