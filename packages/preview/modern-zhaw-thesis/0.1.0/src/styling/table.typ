#import "tokens.typ": tokens

#let table-styles(doc) = {
  show table.cell.where(y: 0): strong
  set table(
    fill: (_, y) => if y == 0 { tokens.colour.main } else { tokens.colour.lightest },
    stroke: none,
    gutter: 0.08cm,
    align: horizon + left,
    inset: (x: 8pt, y: 10pt),
  )
  show table.cell.where(y: 0): c => {
    text(fill: white, font: tokens.font-families.headers, size: tokens.font-sizes.body - 1.4pt, c)
  }

  show table.cell: c => {
    set par(justify: false)
    set text(size: tokens.font-sizes.body - 1pt)
    c
  }

  show table: t => {
    block(
      clip: true,
      radius: tokens.radius,
      t,
    )
  }

  doc
}
