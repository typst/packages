#import "helpers.typ": *
// #import "style.typ": *


#let textbf(it) = [
  #set text(font: ("Times New Roman","SimHei"), weight: "semibold", size: 10.5pt)
  #h(0em, weak: true)
  #it
  #h(0em, weak: true)
]

#let booktab(columns: (), aligns: (), width: auto, caption: none, legend:none, ..cells) = {
  let headers = cells.pos().slice(0, columns.len())
  let contents = cells.pos().slice(columns.len(), cells.pos().len())
  // show figure: set align(center + horizon)

  if aligns == () {
    for i in range(0, columns.len()) {
      aligns.push(center)
    }
  }

  let content_aligns = ()
  for i in range(0, contents.len()) {
    content_aligns.push(aligns.at(calc.rem(i, aligns.len())))
  }

  figure(
    block(
      width: width,
      grid(
        columns: (auto),
        row-gutter: 1em,
        line(length: 100%),
        [
          #set align(center+horizon)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              ..zip(headers, aligns).map(it => [
                #set align(it.last())
                #textbf(it.first())
              ])
            )
          )
        ],
        line(length: 100%),
        [
          #set align(center+horizon)
          #set text(font: ("Times New Roman","SimSun"), size: 10.5pt)
          #box(
            width: 100% - 1em,
            grid(
              columns: columns,
              row-gutter: 1em,
              ..zip(contents, content_aligns).map(it => [
                #set align(it.last())
                #it.first()
              ])
            )
          )
        ],
        line(length: 100%),
      ),
    ),
    caption: caption,
    kind: table,
    supplement: [表],
    numbering: i=> numbering("1-1", ..counter(heading.where(level: 1)).get(), i),
  )
}
