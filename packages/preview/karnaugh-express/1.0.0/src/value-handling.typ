#import "@preview/cetz:0.5.3"

// Draws content like cetz's internal draw.content, but way faster
#let fast-content(name: none, anchor-se: false, pos, body) = ((ctx) => {
  let (width: w, height: h) = measure(body)
  let (w, h) = (w / ctx.length, h / ctx.length)
  let p = cetz.util.apply-transform(ctx.transform, (pos.at(0), pos.at(1), 0))
  if anchor-se {
    p = (p.at(0)-w/2, p.at(1)+h/2, p.at(2))
  }

  (
    ctx: ctx,
    name: name,
    anchors: p,
    drawables: ((
      type: "content", pos: p,
      width: w, height: h,
      segments: (), body: body, tags: (),
    ),),
  )
},)

// Draws the subscripts and values to the correct cells
#let draw-values-and-subscripts(placed-values, cell-graycodes, value-font-size, draw-subscripts, subscript-dist, subscript-font-size, use-cetz-naming) = {
  import cetz: draw
  import draw: *

  let row-count = cell-graycodes.len()
  let column-count = cell-graycodes.at(0).len()

  // Loop thorugh every cell
  for row in range(row-count) {
    for column in range(column-count) {

      let cell-graycode = cell-graycodes.at(row).at(column)

      let value = [#placed-values.at(row, default: ()).at(column, default: none)]
      // Draw values
      let str-graycode = str(cell-graycode)
      let name = none
      if use-cetz-naming {
        name = str-graycode
      }
      fast-content(name: name, (column, (row-count - 1) - row), text(value, size: value-font-size))

      // Draw subscripts
      if draw-subscripts{
      fast-content(
        (column + subscript-dist, ((row-count -1)-row) - subscript-dist),
        text(str-graycode, size: subscript-font-size), anchor-se: true
        )
      }

    }
  }
}


// Places provided values in the order of the truth table
#let order-values(values, cell-graycodes, default) = {
  let values-placed = ()
  for row in range(cell-graycodes.len()){
    let row-placed = ()

    // Loop thorugh all of the cells, retrieve the cell-gray-code there
    // and place the correct value
    for col in range(cell-graycodes.at(row).len()){

      // Find the value that belongs here by using
      // the gray code of the cell as an index
      row-placed.push(values.at(cell-graycodes.at(row).at(col), default: default))

    }
    values-placed.push(row-placed)
  }
  values-placed
}
