#let color-box = (
  rgb(190, 149, 196),
  rgb(255, 205, 178),
  rgb(102, 155, 188),
  rgb(229, 152, 155),
  rgb("6a4c93"),
  rgb("E0A500"),
  rgb("#934c84"),
  rgb("#934c5a"),
)

#let concept-block(
  body: content,
  alignment: start,
  width: 100%,
  fill_color: white,
) = context {
  let heading-count = counter(heading).at(here()).first()
  let current-color = color-box.at(calc.rem(heading-count - 1, color-box.len()))

  block(
    stroke: current-color,
    fill: fill_color,
    radius: 3pt,
    inset: 6pt,
    width: width,
  )[
    #align(alignment)[
      #body
    ]
  ]
}

#let inline(title) = context {
  let heading-count = counter(heading).at(here()).first()
  let current-color = color-box.at(calc.rem(heading-count - 1, color-box.len()))

  box(grid(
    columns: (1fr, auto, 1fr),
    align: horizon + center,
    column-gutter: 1em,
    line(length: 100%, stroke: 1pt + current-color),
    text(fill: current-color, weight: "bold")[#title],
    line(length: 100%, stroke: 1pt + current-color),
))
}

#let cheatsheet(
  title: [],
  homepage: "",
  authors: (),
  write-title: false,
  title-align: center,
  title-number: true,
  title-delta: 1pt,
  scaling-size: false,
  font-size: 5.5pt,
  line-skip: 5.5pt,
  x-margin: 30pt,
  y-margin: 0pt,
  num-columns: 5,
  column-gutter: 4pt,
  numbered-units: false,
  body) = {

    set page(
      paper: "a4",
      flipped: true,
      margin: (x: x-margin, y: y-margin),
      header: [
        #grid(
          columns: (1fr, 1fr, 1fr),
          align: (left, center, right),
          gutter: 0pt,
          [
            #text(datetime.today().display("[month repr:long] [day], [year]"), weight: "bold")
          ],
          [
            #text(title, weight: "bold")
          ],
          [
            #text(authors + " @ " + homepage, weight: "bold")
          ]
        )
        #v(-3pt)
        #line(length: 100%, stroke: black)
      ]
    )
    
    set text(size: font-size)

    set heading(numbering: "1.1") if title-number
             
    show heading: it => {
      let index = counter(heading).at(it.location()).first()
      let hue = color-box.at(calc.rem(index, color-box.len()))
      if title-number {
        hue = color-box.at(calc.rem(index - 1, color-box.len()))
      }
 
      let color = hue.darken(8% * (it.depth - 1))

      let heading_size = font-size
      let inset_size = 1.0mm

      if scaling-size {
       heading_size = heading_size + 2pt * (3 - it.depth)
       inset_size = inset_size + 0.25mm * (3 - it.depth)
      }

      set text(white, size: heading_size)
      set align(title-align)
      block(
        radius: 0.6mm,
        inset: inset_size,
        width: 100%,
        above: line-skip,
        below: line-skip,
        fill: color,
        it
      )
    }


    let new-body = {
      if write-title {
        align(center, [
          #text(style: "italic", size: font-size + 5pt + title-delta, [#title])

          #text(size: font-size+2pt+ title-delta, [#authors])

          #text(size: font-size+2pt+title-delta, [#datetime.today().display("[month repr:long] [day], [year]")])
        ])
      }
      body
    }

    columns(num-columns, gutter: column-gutter, new-body)
}

#let cheatsheet_scaling(
  title: [], 
  authors: (),
  write-title: false,
  title-align: center,
  page-w: auto,
  page-h: auto,
  title-number: true,
  title-delta: 1pt,
  scaling-size: false,
  font-size: 5.5pt,
  line-skip: 5.5pt,
  x-margin: 30pt,
  y-margin: 0pt,
  num-columns: 5,
  column-gutter: 4pt,
  numbered-units: false,
  body) = {

    set page(
      width: page-w,
      height: page-h,
      flipped: true,
      margin: (x: x-margin, y: y-margin),
      header: [
        #grid(
          columns: (1fr, 1fr, 1fr),
          align: (left, center, right),
          gutter: 0pt,
          [
            #text(datetime.today().display("[month repr:long] [day], [year]"), weight: "bold")
          ],
          [
            #text(title, weight: "bold")
          ],
          [
            #text(authors + " @ " + homepage, weight: "bold")
          ]
        )
        #v(-3pt)
        #line(length: 100%, stroke: black)
      ]
    )
    
    set text(size: font-size)

    set heading(numbering: "1.1") if title-number
             
    show heading: it => {
      let index = counter(heading).at(it.location()).first()
      let hue = color-box.at(calc.rem(index, color-box.len()))
      if title-number {
        hue = color-box.at(calc.rem(index - 1, color-box.len()))
      }
 
      let color = hue.darken(8% * (it.depth - 1))

      let heading_size = font-size
      let inset_size = 1.0mm

      if scaling-size {
       heading_size = heading_size + 2pt * (3 - it.depth)
       inset_size = inset_size + 0.25mm * (3 - it.depth)
      }

      set text(white, size: heading_size)
      set align(title-align)
      block(
        radius: 0.6mm,
        inset: inset_size,
        width: 100%,
        above: line-skip,
        below: line-skip,
        fill: color,
        it
      )
    }


    let new-body = {
      if write-title {
        align(center, [
          #text(style: "italic", size: font-size + 5pt + title-delta, [#title])

          #text(size: font-size+2pt+ title-delta, [#authors])

          #text(size: font-size+2pt+title-delta, [#datetime.today().display("[month repr:long] [day], [year]")])
        ])
      }
      body
    }

    columns(num-columns, gutter: column-gutter, new-body)
}