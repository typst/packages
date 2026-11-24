//
// Description: Creating nice looking karnugh tables
// Author     : Silvan Zahno

/// Display a Karnaugh table
///
/// - inputs (array): input labels
/// - output (content): output label
/// - stroke (stroke): _*Deprecated*_
/// - content (array): cell contents as a 2D array (2x4, 4x4 or 8x4)
/// -> content
#let karnaugh(
  inputs: ($a$,$b$,$c$,$d$,$e$),
  output: [$y$],
  stroke: 0.5pt,
  content: none,
) = {
  if content != none {
    if content.len() == 2 and content.at(0).len() == 4 {
      figure(table(
        columns: (0.7cm,0.7cm,0.7cm,0.7cm,0.7cm,0.2cm,0.6cm,0.6cm),
        rows: (0.6cm,0.6cm,0.2cm,0.7cm,0.7cm),
        stroke:none,
        align: center+horizon,
        table.vline(x: 1, start:3, end:5, stroke:0.5pt), table.vline(x:2, start:3, end:7, stroke:0.5pt), table.vline(x: 3, start:3, end:5, stroke:0.5pt), table.vline(x: 4, start:3, end:5, stroke:0.5pt), table.vline(x: 5, start:3, end:5, stroke:0.5pt),
        [],       [], [], table.cell(colspan: 2, align: center)[#inputs.at(2)], [], [], [], table.hline(start:3, end:5, stroke:0.5pt),
        [],       [], table.cell(colspan:2, align:center)[#inputs.at(1)], [], [], [], [], table.hline(start:2, end:4, stroke:0.5pt),
        [#output], [], [], [], [], [], [], [], table.hline(start:1, end:5, stroke:0.5pt),
        [],       [#content.at(0).at(0)], [#content.at(0).at(1)], [#content.at(0).at(2)], [#content.at(0).at(3)], [], [], [], table.hline(start:1, end:5, stroke:0.5pt),
        [],       [#content.at(1).at(0)], [#content.at(1).at(1)], [#content.at(1).at(2)], [#content.at(1).at(3)], [], [#inputs.at(0)], [], table.hline(start:1, end:5, stroke:0.5pt),
      ))
    } else if content.len() == 4 and content.at(0).len() == 4 {
      figure(table(
        columns: (0.7cm,0.7cm,0.7cm,0.7cm,0.7cm,0.2cm,0.6cm,0.6cm),
        rows: (0.6cm,0.6cm,0.2cm,0.7cm,0.7cm,0.7cm,0.7cm,),
        stroke:none,
        align: center+horizon,
        table.vline(x: 1, start:3, end:7, stroke:0.5pt), table.vline(x:2, start:3, end:7, stroke:0.5pt), table.vline(x: 3, start:3, end:7, stroke:0.5pt), table.vline(x: 4, start:3, end:7, stroke:0.5pt), table.vline(x: 5, start:3, end:7, stroke:0.5pt), table.vline(x: 6, start:4, end:6, stroke:0.5pt), table.vline(x: 7, start:5, end:7, stroke:0.5pt),
        [],        [], [], table.cell(colspan: 2, align: center)[#inputs.at(3)], [], [], [], table.hline(start:3, end:5, stroke:0.5pt),
        [],        [], table.cell(colspan:2, align:center)[#inputs.at(2)], [], [], [], [], table.hline(start:2, end:4, stroke:0.5pt),
        [#output], [], [], [], [], [], [], [], table.hline(start:1, end:5, stroke:0.5pt),
        [],        [#content.at(0).at(0)], [#content.at(0).at(1)], [#content.at(0).at(2)], [#content.at(0).at(3)], [], [], [], table.hline(start:1, end:5, stroke:0.5pt),
        [],        [#content.at(1).at(0)], [#content.at(1).at(1)], [#content.at(1).at(2)], [#content.at(1).at(3)], [], table.cell(rowspan:2)[#inputs.at(0)], [], table.hline(start:1, end:5, stroke:0.5pt),
        [],        [#content.at(2).at(0)], [#content.at(2).at(1)], [#content.at(2).at(2)], [#content.at(2).at(3)], [], table.cell(rowspan:2)[#inputs.at(1)], table.hline(start:1, end:5, stroke:0.5pt),
        [],        [#content.at(3).at(0)], [#content.at(3).at(1)], [#content.at(3).at(2)], [#content.at(3).at(3)], [], [], table.hline(start:1, end:5, stroke:0.5pt),
      ))
    } else if content.len() == 8 and content.at(0).len() == 4 {
      figure(table(
        columns: (0.7cm,0.7cm,0.7cm,0.7cm,0.7cm,0.2cm,0.6cm,0.6cm,0.7cm,0.7cm,0.7cm,0.7cm,0.7cm,0.2cm,0.6cm,0.6cm),
        rows: (0.6cm, 0.6cm,0.6cm,0.2cm,0.7cm,0.7cm,0.7cm,0.7cm),
        stroke:none,
        align: center+horizon,
        table.vline(x: 1, start:4, end:8, stroke:0.5pt), table.vline(x: 2, start:4, end:8, stroke:0.5pt), table.vline(x: 3, start:4, end:8, stroke:0.5pt), table.vline(x: 4, start:4, end:8, stroke:0.5pt), table.vline(x: 5, start:4, end:8, stroke:0.5pt), table.vline(x: 6, start:5, end:7, stroke:0.5pt), table.vline(x: 7, start:6, end:8, stroke:0.5pt), table.vline(x: 9, start:4, end:8, stroke:0.5pt), table.vline(x: 10, start:4, end:8, stroke:0.5pt), table.vline(x:11, start:4, end:8, stroke:0.5pt), table.vline(x: 12, start:4, end:8, stroke:0.5pt), table.vline(x: 13, start:4, end:8, stroke:0.5pt), table.vline(x: 14, start:5, end:7, stroke:0.5pt), table.vline(x: 15, start:6, end:8, stroke:0.5pt),
        [],        [], [], [], [], [], [], [],                                                                                                                                                              [], table.cell(colspan: 4, align: center)[#inputs.at(4)], [], [], [], table.hline(start:9, end:13, stroke:0.5pt),
        [],        [], [], table.cell(colspan: 2, align: center)[#inputs.at(3)], [], [], [], table.hline(start:3, end:5, stroke:0.5pt),                                                                     [],        [], [], table.cell(colspan: 2, align: center)[#inputs.at(3)], [], [], [], table.hline(start:11, end:13, stroke:0.5pt),
        [],        [], table.cell(colspan:2, align:center)[#inputs.at(2)], [], [], [], [], table.hline(start:2, end:4, stroke:0.5pt),                                                                       [],        [], table.cell(colspan:2, align:center)[#inputs.at(2)], [], [], [], [], table.hline(start:10, end:12, stroke:0.5pt),
        [#output], [], [], [], [], [], [], [], table.hline(start:1, end:5, stroke:0.5pt),                                                                                                                   [#output], [], [], [], [], [], [], [], table.hline(start:9, end:13, stroke:0.5pt),
        [],        [#content.at(0).at(0)], [#content.at(0).at(1)], [#content.at(0).at(2)], [#content.at(0).at(3)], [], [], [], table.hline(start:1, end:5, stroke:0.5pt),                                   [],        [#content.at(4).at(0)], [#content.at(4).at(1)], [#content.at(4).at(2)], [#content.at(4).at(3)], [], [], [], table.hline(start:9, end:13, stroke:0.5pt),
        [],        [#content.at(1).at(0)], [#content.at(1).at(1)], [#content.at(1).at(2)], [#content.at(1).at(3)], [], table.cell(rowspan:2)[#inputs.at(0)], table.hline(start:1, end:5, stroke:0.5pt),     [], [],    [#content.at(5).at(0)], [#content.at(5).at(1)], [#content.at(5).at(2)], [#content.at(5).at(3)], [], table.cell(rowspan:2)[#inputs.at(0)], table.hline(start:9, end:13, stroke:0.5pt),
        [], [],    [#content.at(2).at(0)], [#content.at(2).at(1)], [#content.at(2).at(2)], [#content.at(2).at(3)], [], table.cell(rowspan:2)[#inputs.at(1)], table.hline(start:1, end:5, stroke:0.5pt),     [],        [#content.at(6).at(0)], [#content.at(6).at(1)], [#content.at(6).at(2)], [#content.at(6).at(3)], [], table.cell(rowspan:2)[#inputs.at(1)], table.hline(start:9, end:13, stroke:0.5pt),
        [],        [#content.at(3).at(0)], [#content.at(3).at(1)], [#content.at(3).at(2)], [#content.at(3).at(3)], [], [], table.hline(start:1, end:5, stroke:0.5pt),                                       [],        [#content.at(7).at(0)], [#content.at(7).at(1)], [#content.at(7).at(2)], [#content.at(7).at(3)], [], [], table.hline(start:9, end:13, stroke:0.5pt),
      ))
    }
  }
}
