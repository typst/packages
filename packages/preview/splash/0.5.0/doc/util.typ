#let code(body) = {
  set text(weight: "regular")
  show: box.with(
    fill: luma(240),
    inset: 0.4em,
    radius: 3pt,
    baseline: 0.4em,
  )
  raw(body)
}

#let get-color-value(color) = {
  let s = repr(color)
  let m = s.match(regex("(.*)\\((.*)\\)"))
  let p = (name: m.captures.at(0), value: m.captures.at(1).replace("\"", "", count: 2))
  text(fill: luma(200))[
    #raw(p.name)
    #h(1fr)
    #raw(p.value)
  ]
}

#let make-title(title: none, author: none, date: none, description: none) = [
  #set align(center)

  = #title

  #v(1em)

  #text(style: "italic", description)

  #v(1em)

  / Author: #author
  / Date: #date

  #v(3em)
]

#let section(
  title: none,
  description: none,
  cols: 2,
  col-gutter: 2em,
  row-gutter: 2pt,
  do-page-break: true,
  name: none,
  colors,
) = {
  heading(level: 3, title + if name != none [ --- #code(name); ])
  v(.5em)
  if description != none {
    description
  }
  let arr = ()
  for (name, color) in colors.pairs() {
    let blk = rect(
      stroke: none,
    )[
      #set align(horizon)
      #code(name)
      #h(1fr)
      #box(
        width: 3em,
        height: 1em,
        fill: color,
        stroke: luma(230),
        radius: 2pt,
        baseline: 0.25em,
      )
      #linebreak()
      #get-color-value(color)
    ]
    arr.push(blk)
  }
  grid(
    row-gutter: row-gutter,
    column-gutter: col-gutter,
    columns: (1fr,) * cols,
    ..arr,
  )
  if do-page-break { pagebreak(weak:true) }
}

