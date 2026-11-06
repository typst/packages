#import "icons.typ": *

#let global-theme = state(
  "theme",
  ("accent-color": black)
)
// rgb(250, 0, 0)

#let styling(body, accent-color: none) = {
  if accent-color != none {
    global-theme.update(pt => {
      pt.insert("accent-color", accent-color)
    })
  }
  context {
    let theme = global-theme.get()
    let accent-color = theme.at("accent-color")
    show link: ct => underline(ct, background: true, evade: true, stroke: accent-color)
    set page(margin: (left: 2.5cm, right: 2.5cm, top: 2cm))
    body
  }
}

#let section(title, note: none) = {
  v(4pt)
  box(grid(
    columns: 2,
    [
      #heading(title, level: 2)
    ],
    context {
      let accent-color = global-theme.get().at("accent-color")
      line(start: (0% + 2pt, 0% + 8pt), length: 100%, stroke: accent-color)
    },
  ))
  if note != none {
    text(note, size: 7pt)
  }
}

#let subsection(title) = {
  [=== #title]
}

#let entry(left-text, right-text, description: none) = {
  grid(
    column-gutter: 0pt,
    row-gutter: 0.6em,
    columns: (1fr, auto),
    align(left, [#left-text]),
    align(right, [#right-text]),
    if description != none {
      grid.cell(
        colspan: 2,
        [#description]
      )
    }
  )
}
