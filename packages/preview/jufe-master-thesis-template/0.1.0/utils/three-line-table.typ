#import "@preview/rexllent:0.4.0": xlsx-parser

//! 设置三线表格式
#let tlt(path) = {
  let data = read(path, encoding: none)
  xlsx-parser(
    data,
    parse-table-style: false,
    parse-alignment: false,
    parse-stroke: false,
    parse-fill: true,
    parse-font: true,
    parse-header: true,
    parse-formatted-cell: true,
    rows: 1.8em,
    align: horizon,
    prepend-elems: (table.hline()),
    stroke: (_, y) => {
      if y == 0 {
        return (bottom: 0.5pt)
      }
    },
    table.hline(),
  )
}
