#import "/utils/utils.typ": single-color-svg
#import "/utils/states.typ": heh-config

#let box-default-styling = box.with(
  width: 100%,
  inset: 14pt,
)

#let grid-with-box-default-styling = grid.with(
  columns: (auto, 1fr),
  row-gutter: 14pt,
  column-gutter: 8pt,
  align: (alignment.center, alignment.horizon),
)

#let box-default(
  content,
  accent-color: rgb("#34356B"),
  title: "Default box",
  icon-path: "/assets/icons/information.vsvg",
  bg: auto,
) = context {
  let config = heh-config.get()
  let monochrome = config.print.at("monochrome", default: false)

  let true-accent = if monochrome { black } else { accent-color }

  let bg = if monochrome {
    white
  } else {
    if bg == auto {
      accent-color.lighten(90%)
    } else {
      bg
    }
  }

  set text(fill: true-accent)

  box-default-styling(
    fill: bg,
    stroke: if monochrome { 1pt + black } else { none },
    grid-with-box-default-styling(
      single-color-svg(icon-path, true-accent),
      title,
      grid.cell(
        x: 0,
        y: 1,
        colspan: 2,
        align(left, rect(
          stroke: (left: 1pt + true-accent),
          inset: (left: 20pt),
          outset: (left: -6.5pt),
          content,
        )),
      ),
    ),
  )
}

#let info = box-default.with(
  icon-path: "/assets/icons/information.vsvg",
  title: "Information",
)

#let important = box-default.with(
  icon-path: "/assets/icons/important.vsvg",
  accent-color: rgb("#d02020"),
  title: "Important",
)

#let hint = box-default.with(
  icon-path: "/assets/icons/hint.vsvg",
  accent-color: rgb("#168a5c"),
  title: "Indice",
)

#let silly = box-default.with(
  icon-path: "/assets/icons/silly.vsvg",
  accent-color: rgb("#b31077"),
  title: "Info Silly",
)
