#import "/src/cetz.typ"

#let grid(columns: 2, ..items) = {
  let items = items.pos()
  let valign = (horizon,) * columns

  (ctx => {
    let rows = ()
    let cells = ()

    for (i, item) in items.enumerate() {
      let (bounds: bounds, drawables: drawables, ..) = cetz.process.many(ctx, item)

      let width = bounds.high.at(0) - bounds.low.at(0)
      let height = bounds.high.at(1) - bounds.low.at(1)
      cells.push(((width, height), drawables))
    }

    let height = 0
    for i in range(0, items.len()) {
      let size = cells.at(i).at(0)
      height = calc.max(size.at(1), height)
      if calc.rem(i, columns) == 0{
        rows.push(height)
        height = 0
      }
    }

    cells = cells.enumerate().map(((i, (size, cell))) => {
      let t = cetz.matrix.ident()
      let row = rows.at(int(i / columns))

      t = cetz.matrix.transform-translate(0, -(row - size.at(1)) / 2, 0)

      cetz.drawable.apply-transform(t, cell)
    })

    return (
      ctx: ctx,
      drawables: cells.join(),
    )
  },)
}
