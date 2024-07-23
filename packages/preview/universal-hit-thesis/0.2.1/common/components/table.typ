/* 
旧版三线表已弃用，推荐使用新版原生写法
#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  stroke: none,
  table.hline(),
  [t], [1], [2], [3],
  table.hline(stroke: .5pt),
  [y], [0.3s], [0.4s], [0.8s],
  table.hline(),
)
*/

#let three-line-table(..args) = {
  let values = args.pos()
  let header-values = if values.len() > 0 {
    values.at(0)
  } else {
    ()
  }
  let content-values = if values.len() > 1 {
    values.slice(1)
  } else {
    ()
  }

  let table-cell(content: none) = {
    set align(center)
    rect(
      width: 100%,
      stroke: none,
    )[
      #content
    ]
  }
  line(length: 100%, stroke: 0.3mm)
  v(0em, weak: true)
  pad(y: 0.25em)[
    #grid(
      columns: header-values.len(),
      ..header-values.map(content => table-cell(content: content)).flatten(),
    )
  ]
  v(0em, weak: true)
  line(length: 100%, stroke: 0.05mm)

  if content-values.len() > 0 {
    v(0em, weak: true)
    pad(y: 0.25em)[
      #grid(
        columns: header-values.len(),
        row-gutter: 0.25em,
        ..content-values.map(line-content => {
          (..line-content.map(content => table-cell(content: content)).flatten(),)
        }).flatten(),
      )
    ]
    v(0em, weak: true)
    line(length: 100%, stroke: 0.3mm)
  }
}