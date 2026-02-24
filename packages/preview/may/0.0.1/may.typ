// package dependancies and show rules
#import "@preview/physica:0.9.5": *
#import "@preview/wrap-it:0.1.1": wrap-content

#show: super-T-as-transpose

#let _may(doc) = [

  // Page Configuration
  #let sea = rgb("#3b60a0")
  #let sky = rgb("#bdd0f1")
  #let skyl = rgb("#eff3ff")
  #let skyll = rgb("#f4f9ff")
  #let paper = rgb("#f5f6f8")
  #set page(
    paper: "a5",
    columns: 1,
    margin: (x: 1cm, y: 1cm),
    numbering: "- 1/1 -"
  )
  #show raw: it => {
    set text(font: "Maple Mono", size: 2.96mm)
    block(
      width: 100%,
      height: auto,
      fill: skyll,
      inset: 2.1mm,
      radius: 1.7mm,
      it
    )
  }
  #set par(
    justify: true,
  )

  // Links
  #show link: underline
  #show link: it => {
    set text(fill: sea)
    it
  }

  // Quote / Terms
  #show ">|": it => [
    #box(baseline: 1.34mm, rect(width: 0.9mm, height: 4.9mm, fill: sea))
    #h(2.3mm)
  ]

  // Headings
  #let subline() = {v(-4.53mm); line(length: 100%, stroke: sea); v(-0.7mm)}
  #show heading.where(
    level: 1
  ): it => [
    #set align(center)
    #set text(
      fill: sea,
      size: 6.3mm,
      weight: "bold",
      style: "normal",
    )
    #it.body
    #subline()
  ]
  #show heading.where(
    level: 2
  ): it => [
    #set text(
      fill: sea,
      size: 5.5mm,
      weight: "bold",
      style: "normal",
    )
    #it.body
    #subline()
  ]
  #show heading.where(
    level: 3
  ): it => [
    #set text(
      fill: sea,
      size: 4.8mm,
      weight: "bold",
      style: "normal",
    )
    #it.body
    #subline()
  ]
  #show heading.where(
    level: 4
  ): it => text(
    fill: sea,
    size: 4.45mm,
    weight: "bold",
    style: "normal",
    it.body
  )
  #show heading.where(
    level: 5
  ): it => text(
    fill: sea,
    size: 4.01mm,
    weight: "bold",
    style: "normal",
    it.body
  )
  #show heading.where(
    level: 6
  ): it => text(
    fill: sea,
    size: 3.7mm,
    weight: "bold",
    style: "normal",
    it.body
  )

  // Detail Decoration
  #show "->": it => [
    #math.limits(it)
  ]
  #show "-->": it => [
    #math.limits(it)
  ]
  #show "<--": it => [
    #math.limits(it)
  ]
  #show "<-": it => [
    #math.limits(it)
  ]
  #show "=>": it => [
    #math.limits(it)
  ]
  #show "==>": it => [
    #math.limits(it)
  ]
  #show "<=": it => [
    #math.limits(it)
  ]
  #show "<==": it => [
    #math.limits(it)
  ]
  #show "<=>": it => [
    #math.limits(it)
  ]
  #show "<==>": it => [
    #math.limits(it)
  ]

  #set table(
    stroke: none,
    gutter: 0.2em,
    align: center,
    fill: (x, y) => if y == 0 {sea},
    // inset: (right: 1.5em)
  )
  #show table.cell: it => {
    if it.y == 0 {
    set text(white)
    strong(it)
  } else {it}
  }

  #doc
]

#let may(doc) = [
  #set text(
    font: ("PingFang SC"),
    lang: "zh",
    size: 3.56mm,
    weight: "regular",
    style: "normal",
  )
  #_may(doc)
]

#let may-serif(doc) = [
  #set text(
    font: ("Libertinus Serif", "LXGW Neo ZhiSong"),
    lang: "zh",
    size: 3.56mm,
    weight: "regular",
    style: "normal",
  )
  // #show math.equation: set text(font: "Libertinus Math")
  #_may(doc)
]

#let may-sans(doc) = [
  #set text(
    font: ("Libertinus Sans", "LXGW Wenkai"),
    lang: "zh",
    size: 3.56mm,
    weight: "regular",
    style: "normal",
  )
  // #show math.equation: set text(font: "Libertinus Math")
  #_may(doc)
]

// information item
#let info(something, description) = [
  *#something* #h(1fr) *#description*\
]
