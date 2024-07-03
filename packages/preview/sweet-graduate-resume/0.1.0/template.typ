#import "lib_fontawesome.typ": *

#let preamble(doc) = {
  set page(
    paper: "a4",
    margin: (x: 0.5cm, y: 0.5cm),
  )

  set text(
    font: "DejaVu Sans",
    size: 8pt,
  )

  set par(justify: true)

  show link: name => {
    set text(blue)
    name
  }

  set block(spacing: 0.5em)

  set align(left)
  doc
}

#let header(author, roll, school, urls) = {
  set text(17pt, weight: "bold")
  set block(spacing: 0.3em)
  [
    #author | #roll

    #set text(13pt)
    #box(
      width: 1fr,
      inset: (bottom: 5pt),
      stroke: (bottom: (1pt + black)),
    )[#school]

  ]

  set text(7pt)
  for value in urls {
    let img = if value.fa {
      if value.brand {
        fa-icon(value.svg)
      } else {
        fa-icon(value.svg, solid: value.solid)
      }
    } else {
      value.svg
    }

    link(value.url)[
      #value.name
      #box(height: 1em, baseline: 20%)[#img]
    ] + if value == urls.last() {
      ""
    } else {
      "|"
    }
  }
}

#let section-header(head) = {
  box(
    inset: (top: 0.3em, left: 0.4em, bottom: 0.3em),
    width: 1fr,
    fill: rgb(120, 230, 230),
  )[#set text(weight: "black"); #head]
}

#let education(rows) = {
  table(
    stroke: none,
    columns: (1fr, 1fr, auto),
    inset: 5pt,
    align: horizon,
    table.hline(),
    table.header(
      [*Program*],
      [*Institution*],
      [#set align(right); *Grade*],
    ),
    table.hline(),
    table.vline(x: 0),
    ..rows.map(r => (
      r.prog,
      r.school,
      [#set align(right); #r.grade],
    )).flatten(),
    table.vline(),
    table.hline(),
  )
}

#let points(arr) = {
  list(..arr)
}

#let dual(arr) = {
  columns(2, gutter: 11pt)[
    #let i = 0
    #let first-half = ();
    #while i < arr.len() / 2 {
      first-half.push(arr.at(i))
      i += 1
    }
    #list(..first-half)
    #colbreak()
    #let second-half = ();
    #while i < arr.len() {
      second-half.push(arr.at(i))
      i += 1
    }
    #list(..second-half)
  ]
}

#let dated-section(
  title,
  subtitle,
  date-start: none,
  date-end: none,
  ongoing: false,
  points: array,
) = {
  [

    #box(
      width: 1fr,
      inset: (bottom: 3pt),
      stroke: (bottom: (1pt + black)),
    )[#text(9.5pt)[*⊚ #title*] #h(1fr) #text(7pt)[_#subtitle #if date-start != none {[(#date-start]} #if date-end != none {[\- #date-end)]} else if ongoing {[\- Ongoing)]} else if date-start != none {[)]}_]]

    #list(..points)
  ]

}
