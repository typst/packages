#let small-text-size = 8pt
#let large-text-size = 14pt

#let abnormals = rgb("FF9A00")

#let style-state = state("style", "0")

#let topic(
  title,
  fill-clr: rgb("FFFFFF"),
  body
) = {
  box(width: 100%, stroke: 1pt, outset: 4pt, fill: fill-clr)[
    #v(5pt)
    #align(center)[#text(size: 20pt, upper(strong(title)))]
    #v(5pt)
  ]
  columns(2)[
    #body
  ]
}

#let section(
  title,
  fill-clr: rgb("FFFFFF"),
  body
) = locate(loc => {
  if (title != none and title != "") {
    box(width: 100%, stroke: 1pt, outset: 4pt, fill: fill-clr)[
      #v(5pt)
      #align(center)[#upper(strong(title))]
      #v(5pt)
    ]
    linebreak()
    v(-(small-text-size))
    if (style-state.at(loc) == 1) {
      box(width: 1fr, stroke: 1pt, outset: 4pt, )[
        #v(5pt)
        #body
        #v(5pt)
      ]
    } else {
      body
      v(-10pt)
      ellipse(width: 30pt, height: 20pt, fill: rgb("000000"))[
        #align(center + horizon)[#text(size: 8pt, fill: rgb("FFFFFF"), upper(strong("END")))]
      ]
    }
  }
})

#let step(a, b) = {
  if ((a != none and a != "") or (b != none and b != "")) {
    a; " "; box(width: 1fr,repeat[.]); " "; b; linebreak()
  }
}

#let small-caution(
  caution
) = {
  text(size: small-text-size)[
    #text("Caution: ", fill: rgb("FF0000"))
  ]
  v(-1.6em)
  align(top + right)[#box(width: 85%)[#align(left)[
        #text(size: small-text-size)[#caution]
  ]]]
}

#let note(note) = {
  text(size: small-text-size)[Note:]
  v(-1.6em)
  align(top + right)[#box(width: 90%)[#align(left)[
    #text(size: small-text-size)[#note]
  ]]]
}

#let page-number() = locate(loc => {
  loc.page()
})

#let checklist(
  title: none,

  disclaimer: none,

  style: 0,

  body
) = {
  set page("a4", margin: 0.4in,
  footer: [
    #line(start: (0pt, -15pt), length: 100%)
    #place(left, dy: -10pt,
      text(size: 8pt, fill: rgb("000000"))[
        #datetime.today().display()
      ]
    )
    #place(center, dy: -10pt,
      text(size: 8pt, fill: rgb("000000"))[
        #page-number()
      ]
    )
    #place(right, dy: -10pt,
      text(size: 8pt, fill: rgb("000000"))[
        #title
      ]
    )
  ])
  set text(size: large-text-size, font: "Open Sans")

  style-state.update(style)

  if title != none {
    box(width: 100%, stroke: 1pt, outset: 4pt, fill: rgb("FFFFFF"))[
      #v(5pt)
      #align(center)[#text(size: 20pt, upper(strong(title)))]
      #v(5pt)
    ]
  }

  if disclaimer != none {
    box(width: 100%, stroke: 1pt, outset: 4pt, fill: rgb("FF1100").lighten(40%))[
      #v(5pt)
      #align(center)[#text(size: 20pt, upper(strong(disclaimer)))]
      #v(5pt)
    ]
  }

  body

}
