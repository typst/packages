// return the number of rows of the table
#let table-row-counter(cells,columns)={
  let last-row = (0,) * columns
  let x = 0
  let y = 0
  let volume = 0
  for cell in cells{
    if cell.has("body"){
      let colspan = 1
      let rowspan = 1
      if cell.has("colspan"){
        colspan=cell.colspan
      }
      if cell.has("rowspan"){
        rowspan=cell.rowspan
      }
      volume += colspan*rowspan
      let end = x + colspan
      while x < end{
        last-row.at(x) += rowspan
        x += 1
      }
      let next = last-row.position(ele=>{ele==y})
      if next == none{
        y = calc.min(..last-row)
        x = last-row.position(ele=>{ele==y})
      }else{ 
        x = next
      }
    }
  }
  let rows = calc.max(..last-row)
  let volume-empty = columns*rows - volume
  assert(volume == last-row.sum())
  return (rows, volume-empty)
}

// A three-line-table returned as a figure
#let meppp-tl-table(
  caption: none,
  supplement: auto,
  stroke:0.5pt,
  tbl
)={
  let align = center+horizon
  if tbl.has("align"){
    align = tbl.align
  }

  let columns = 1
  let column-count = 1
  if tbl.has("columns"){
    columns = tbl.columns
    if type(tbl.columns)==int{
      column-count = tbl.columns
    }
    else if type(tbl.columns)==array{
      column-count = columns.len()
    }
  }

  let header = tbl.children.at(0)
  assert(
    header.has("children"),
    message: "Header is needed."
  )
  let header-children = header.children
  let header-rows = table-row-counter(header-children,column-count).at(0)
  
  let content = tbl.children.slice(1)
  let content-trc = table-row-counter(content,column-count)
  let content-rows = content-trc.at(0)
  let content-empty-cells = content-trc.at(1)
  content = content + ([],)*content-empty-cells

  let rows = (1.5pt,)+(1.5em,)*(header-rows+content-rows)+(1.5pt,)

  let hline = table.hline(stroke:stroke)
  let empty-row = table.cell([],colspan: column-count)


  return figure( 
    table(
      align:align,
      columns:columns,
      rows:rows,
      stroke:none,
      table.header(
        hline,
        empty-row,
        hline,
        ..header-children,
        hline,
      ),
      ..content,
      table.footer(
        hline,
        empty-row,
        hline,
        repeat: false
      )
      
    ),
    kind:table,
    caption:figure.caption(caption, position:top),
    supplement: supplement,
  )
}