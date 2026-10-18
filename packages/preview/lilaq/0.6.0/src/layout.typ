#import "@preview/elembic:1.1.1" as e
#import "model/diagram.typ": diagram

// #let lbox = e.element.declare(
//   "lbox",
//   prefix: "lilaq",
//   display: it => {
//     let result = box(it.body, stroke: it.stroke)
//     if it._pad != auto {
//       result = pad(result, ..it._pad)
//     }
//     let bounds = (top: 0pt, bottom: 0pt, left: 0pt, right: 0pt)
//     result + [#metadata(it._grid-pos + bounds)<__lilaq_diagram__>]
//   },

//   fields: (
//     e.field("body", content, required: true),
//     e.field("_grid-pos", e.types.wrap(dictionary, fold: none), default: (:)),
//     e.field("_pad", e.types.any, default: auto),
//     e.field("stroke", e.types.option(stroke), default: none),
//   )
// )
// 


#let is-direct-diagram(body) = e.eid(body) == e.eid(diagram)

#let is-std-styled-diagram(body, test: is-direct-diagram) = {
  if repr(body.func()) == "styled" {
    return test(body.child)
  }
  return false
}

#let is-elembic-styled-diagram(body, test: is-direct-diagram) = {
  
  let sequence = [].func()
  if body.func() != sequence { return false }

  body = body.children.first(default: none)

  if type(body) != content or body.func() != sequence { return false }

  body = body.children.first(default: none)

  if type(body) != content or body.func() != metadata or "body" not in body.value { return false }

  body = body.value.body.children.slice(1, 3)

  test(sequence(body))
}

// This will become easier with types: just check whether it is a (natively) styled diagram
#let is-styled-diagram(body) = {
  if is-direct-diagram(body) { return true }

  
  if is-std-styled-diagram(
    body, 
    test: body => is-direct-diagram(body) or is-elembic-styled-diagram(body)
  ) {
    return true
  }

  if is-elembic-styled-diagram(
    body, 
    test: body => is-direct-diagram(body) or is-std-styled-diagram(body)
  ) {
    return true
  }
  return false
}






#let layout-impl(it) = {
  if it.children.len() == 0 { return it }

  // protect other grids such as the legend grid
  // if it.children.all(cell => e.eid(cell.body) != e.eid(diagram)) { return it }
  if it.children.all(cell => cell.func() != grid.cell or not is-styled-diagram(cell.body)) { return it }
  
  
  let grid = context {
    
    let grid-end = query(selector(<__lilaq_layout__>)
      .after(here()))
      .first()
      .location()
    
    let diagram-meta = query(
      selector(<__lilaq_diagram__>).after(here()).before(grid-end)
    ).map(metadata => metadata.value)


    // first layout pass
    if diagram-meta.len() == 0 { 
      return {
        show grid.cell: it => {

          show: e.set_(diagram,
            _grid-pos: (
              x: it.x, 
              y: it.y, 
              xn: it.x + it.colspan - 1, 
              yn: it.y + it.rowspan - 1
            )
          )

          // show: e.set_(lbox,
          //   _grid-pos: (
          //     x: it.x, 
          //     y: it.y, 
          //     xn: it.x + it.colspan - 1, 
          //     yn: it.y + it.rowspan - 1
          //   )
          // )
          it
        }    
        it
      }
    }

    // Second layout pass


    // let cols = calc.max(..diagram-meta.map(d => calc.max(d.x, d.xn))) + 1
    let cols = calc.max(1, it.columns.len())
    let rows = calc.max(..diagram-meta.map(d => calc.max(d.y, d.yn))) + 1

    let left = range(cols)
      .map(col => {
        calc.max(0pt, ..diagram-meta.filter(d => d.x == col).map(d => d.left))
      })
    let right = range(cols)
      .map(col => {
        calc.max(0pt, ..diagram-meta.filter(d => d.xn == col).map(d => d.right))
      })
    let top = range(rows)
      .map(row => {
        calc.max(0pt, ..diagram-meta.filter(d => d.y == row).map(d => d.top))
      })
    let bottom = range(rows)
      .map(row => {
        calc.max(0pt, ..diagram-meta.filter(d => d.yn == row).map(d => d.bottom))
      })
      
    show grid.cell: it => {

      let data = diagram-meta.find(d => d.x == it.x and d.y == it.y)
      if data == none { // cell may not contain a diagram
        return it
      }

      let pad = (
        left: left.at(it.x) - data.left, 
        right: right.at(it.x + it.colspan - 1) - data.right, 
        top: top.at(it.y) - data.top, 
        bottom: bottom.at(it.y + it.rowspan - 1) - data.bottom, 
      )
      show: e.set_(diagram,
        _grid-pos: (
          x: it.x, 
          y: it.y, 
          xn: it.x + it.colspan - 1, 
          yn: it.y + it.rowspan - 1
        ),
        pad: pad
      )
      // show: e.set_(lbox,
      //   _grid-pos: (
      //     x: it.x, 
      //     y: it.y, 
      //     xn: it.x + it.colspan - 1, 
      //     yn: it.y + it.rowspan - 1
      //   ),
      //   _pad: pad
      // )
      it
    }
    it
  }
  grid + [#metadata(none)<__lilaq_layout__>]
}



/// Applies special show rules that align diagrams as cells
/// of a Typst grid. 
/// Refer to the #link("tutorials/plot-grids")[subplot tutorial] for more details. 
/// 
/// Example:
/// ```example
/// #show: lq.set-diagram(width: 4cm, height: 2.2cm)
/// 
/// #figure({
///   show: lq.layout // special layout rule
/// 
///   grid(
///     columns: 2, 
///     row-gutter: 1em,
///     column-gutter: 1em,
///     lq.diagram(
///       lq.plot((1, 2, 3), (3, 2, 5)),
///       lq.plot((1, 2, 3), (4, 4.5, 3)),
///     ),
///     lq.diagram(
///       lq.bar((1, 2, 3), (3, 2, 5))
///     ),
///     lq.diagram(
///       lq.plot((5, 7, 8, 9), (2, 3, 3, 4))
///     ),
///     lq.diagram(
///       lq.bar((1, 2, 3), (11, 1, 4))
///     ),
///   )
/// })
/// ```
/// 
/// The alignment algorithm guarantees that the horizontal/vertical axis spines
/// of diagrams in cells of a row/column line up nicely, independent of ticks, 
/// axis labels, titles, legends etc. When a diagram is placed in a cell that
/// spans multiple rows or columns, the diagrams are aligned accordingly to 
/// match the correct row or column. 
#let layout(

  /// The body to transform.
  /// -> content
  body

) = {
  show grid: layout-impl
  body
}
