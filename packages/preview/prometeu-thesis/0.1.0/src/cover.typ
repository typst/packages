#import "colors.typ"

#let render-cover(
  author: [],
  title: [],
  date: [],
  supervisors: (),
  images: (),
  gray-images: (),
  school: [],
  degree: []
) = [
  #set text(fill: colors.pantonecoolgray7)

  #set page(margin: (top: 0mm, bottom: 10mm, left: 79mm, right: 0mm))
  #set par(spacing: 0pt)

  #grid(
    columns: 2,
    ..images.map(block.with(width: 26mm, height: 26mm)),
  )

  #v(8.72mm)

  #[
    #set par(leading: 0.4em)
    #set text(size: 14.5pt)
    *University of Minho*\
    #text(font: "NewsGoth Lt BT", school)
  ]

  #v(37.32mm)

  #place(top + left, float: false, dy: 90mm)[
    #set text(size: 17pt)
    #set par(leading: 20.4pt - 0.75em, spacing: 25pt)

    #author

    *#title*
  ]

  #align(bottom, text(size: 10pt, date))

  #page(fill: colors.pantonecoolgray7)[]

  #grid(
    columns: 2,
    ..gray-images.map(block.with(width: 26mm, height: 26mm)),
    column-gutter: 0.5mm,
  )

  #v(8.72mm)

  #[
    #set par(leading: 0.4em)
    #set text(size: 14.5pt)
    *University of Minho*\
    #text(font: "NewsGoth Lt BT", school)
  ]

  #place(top + left, float: false, dy: 90mm)[
    #set text(size: 17pt)
    #set par(leading: 20.4pt - 0.75em, spacing: 25pt)

    #author

    *#title*
  ]

  #place(top + left, float: false, dy: 180mm)[
    #set text(size: 14.5pt)
    #set par(leading: 16.8pt - 0.75em, spacing: 25pt)

    #degree

    Dissertation supervised by\
    #supervisors.map(text.with(weight: "bold")).join(linebreak())
  ]

  #align(bottom, text(size: 10pt, date))
]
