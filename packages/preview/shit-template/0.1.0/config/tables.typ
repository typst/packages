#let tables(caption: [], ..cells) = {
  figure(
    [
      #set text(size: 8pt) 
      #table(
        columns: (20%, 30%, 50%), 
        align: (left, right, left),
        stroke: none, 
        
        table.cell(colspan: 3, align: center)[#smallcaps[示例表格标题]],
        table.hline(stroke: 1pt), 
        [方法], [指标一], [指标二],
        table.hline(stroke: 0.5pt), 
        
        ..cells, 
        
        table.hline(stroke: 1pt) 
      )
    ],
    caption: caption
  )
}