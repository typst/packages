#import "@preview/pointless-size:0.1.1": zh


// 使用无上边框header实现续表，可以实现跨多页续表，且续表的标题行会自动拼接
#let thesis-table(title: "", header: none, body: none, columns: none, alignment: left + horizon, note: none) = {
  // Use a 五号字 size for text
  set text(size: zh(5))
  let xubiao = state("xubiao")

  // Handle the case when header or body is none
  let header_content = if header != none and type(header) == array { header } else if header != none {
    (header,)
  } else { () }
  let body_rows = if body != none and type(body) == array {
    if body.len() > 0 and type(body.at(0)) == array {
      // If body is an array of arrays
      body
        .map(row => row.map(cell => align(alignment)[
          #par(justify: false, leading: 0.5em)[
            #cell
          ]
        ]))
        .flatten()
    } else {
      // If body is a flat array
      body.map(cell => align(alignment)[
        #par(justify: false, leading: 0.5em)[
          #cell
        ]
      ])
    }
  } else {
    ()
  }


  let chapterNum = context counter(heading).get().at(0)
  let tableNum = context counter(figure.where(kind: "i-figured-table")).display()

  // Set table styles for three-line table (三线表)
  set table(stroke: (x, y) => {
    // 三线表：只有顶部、标题下方和底部有线
    if y == 0 { none } // 第一行（标题行）无上边界
    else if y == 1 { 1.5pt } // 标题行下方粗线
    else if y == 2 and header_content.len() > 0 { 0.75pt } // 表头下方细线
    else { none } // 其他位置无线
  })

  show table: it => xubiao.update(false) + it

  // Make figures breakable
  show figure: set block(breakable: true)

  figure(
    table(
      columns: if columns != none { columns } else { if header_content.len() > 0 { header_content.len() } else { 1 } },
      stroke: none,
      inset: 8pt,
      align: alignment,
      row-gutter: 4pt,
      // Smart header with continuation detection - 标题行作为表格第一行
      table.header(
        // 标题行 - 无上边界
        table.cell(
          colspan: if header_content.len() > 0 { header_content.len() } else { 1 },
          // 标题居中对齐
          align: center + horizon,
          inset: (x: 0pt, y: 0pt),
          [#context if xubiao.get() {
            text(weight: "bold", size: zh(5))[表#(chapterNum)-#(tableNum) #title（续表）#v(6pt)]
          } else {
            // text(weight: "bold", size: zh(5))[表#(chapterNum)-#(tableNum) #title]
            v(-0.3em)
            xubiao.update(true)
          }],
        ),

        // 标题行下方的分隔线
        table.hline(stroke: 1.5pt),

        // 列标题行（如果提供）
        ..if header_content.len() > 0 {
          header_content + (table.hline(stroke: 0.75pt),)
        } else {
          ()
        },

        repeat: true,
      ),

      // Body rows
      ..body_rows,

      // 底部粗线
      table.hline(stroke: 1.5pt),
    ),
    kind: table,
    caption: figure.caption(
      position: top,
      [#title],
    ),
    supplement: [表],
  )


  // Add note if provided
  if note != none {
    v(0.5em)
    align(left)[
      #text(size: zh(6))[注：#note]
    ]
  }
}
