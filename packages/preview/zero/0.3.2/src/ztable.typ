#import "num.typ": num, number-to-string-table
#import "state.typ": num-state

// #let ptable-counter = counter("__pillar-table__")

#let is-normal-cell(cell, format, default: none) = {
  format.at(cell.x, default: default) == none or number-to-string-table(cell.body) == none 
}
    
#let call-num(cell, format, col-widths: auto, default: none, state: auto) = context{
  let (numeral, prefix, suffix) = number-to-string-table(cell.body)
  let cell-fmt = format.at(cell.x, default: default)
  let args = if type(cell-fmt) == dictionary { cell-fmt } else { () }
  num(numeral, prefix: prefix, suffix: suffix, state: state, align: (col-widths: col-widths, col: cell.x), ..args) 
}



#let ztable(..children, format: none) = {
  if format == none { return table(..children) }
  assert.eq(type(format), array, message: "The parameter `format` requires an array argument, got " + repr(format))


  
  
  let table = context {
    let state = num-state.get()
    
    let table-end = query(selector(<__pillar-table__>).after(here())).first().location()
    
    let number-infos = query(selector(<__pillar-num__>)
      .after(here())
      .before(table-end))
      .map(x => x.value)

    
    // let debug-info = (counter: ptable-counter.get(), d: number-infos)


    if number-infos.len() == 0 { // first layout pass
      return {
        show table.cell: it => {
          if is-normal-cell(it, format) { it }
          else { call-num(it, format, state: state) }
        }    
        table(..children)
      }
    }
  
    // second layout pass
    let aligned-columns = range(format.len()).filter(x => format.at(x) != none)
    let col-widths = (none,) * format.len()
    for col in aligned-columns {
      let filtered-cells = number-infos.filter(x => x.at(0) == col)
      col-widths.at(col) = range(1, 5)
        .map(i => calc.max(0pt, ..filtered-cells.map(x => x.at(i))))
    }
      
    show table.cell: it => {
      if is-normal-cell(it, format) { it }
      else {
        table.cell(
          call-num(it, format, col-widths: col-widths.at(it.x), state: state),
          align: it.align,
          x: it.x, y: it.y,
          inset: it.inset,
        )
      }
    }
    table(..children)
  }
  table + [#metadata(none)<__pillar-table__>]
}
