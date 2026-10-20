#import "th_color.typ": th-color

#let frame() = (x, y) => (
  left: none,
  right: none,
  top: 0pt,
  bottom: .5pt + gray,
)

#let x-header(doc) = {
  // default styling for tables
  set table(
    fill: (x, y) => if y == 0 { th-color.paleblue } else if calc.even(y) { color.white } else { th-color.lightblue },
    stroke: frame(),
  )
  show table.cell: it => {
    if it.y == 0 {
      set text(white)
      strong(it)
    } else {
      it
    }
  }
  doc
}

#let xy-header(doc) = {
  // default styling for tables
  set table(
    fill: (x, y) => if x == 0 or y == 0 { th-color.paleblue } else if calc.even(y) { color.white } else {
      th-color.lightblue
    },
    // TODO: the border is 1px to long at the left-bottom corner
    stroke: frame(),
  )
  show table.cell: it => {
    if it.x == 0 or it.y == 0 {
      set text(white)
      strong(it)
    } else {
      it
    }
  }
  doc
}
