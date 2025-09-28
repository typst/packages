#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

          
/// Display a protein sequence in a block with amino acid numbering
/// -> content
#let protein-diag(

  /// The maximum length of amino acid to display in a line. *Optional*.
  /// -> int
  line-length: 50,
  
  /// Array of boxes to draw in the protein sequence *Optional*.
  ///
  /// This can be used to visualize the position of one or more peptides
  /// #parbreak() example for 3 peptides :
  ///
  /// ((pos: (1,5), style: tint(green)),(pos: (12,17), style: tint(teal)),(pos: (75,177), style: tint(red)))
  /// -> array
  boxes: (),
  
  /// Amino acid sequence (one letter code) of the protein to display
  /// -> str
  protein,
 
  /// box item to draw in the protein sequence *Optional*.
  ///
  /// This can be used to visualize the position of one or more peptides
  /// #parbreak() example :
  ///
  /// (pos: (1,5), style: tint(green))
  
  /// ```example
  /// #import "@preview/proteograph:0.2.0": *
  /// #protein-diag(line-length: 60,
  /// "MASTKAPGPGEKHHSIDAQLRQLV",
  /// (pos: (1,5), style: (stroke: red, inset: 1pt)),
  /// (pos: (12,17), style: (stroke: teal, inset: 3pt))
  /// )
  /// ```
  /// -> dictionary
  ..box
 
) = {
  set text(font: "Andale Mono")

  let arr_prot = ()
  let i=0
  while (i < protein.len()) {
    arr_prot.push(protein.slice(i, calc.min(i+line-length,protein.len())))
    i = i + line-length
  }
  [
    #diagram(
    node-inset: 0pt,
    node-outset: 0pt,
    cell-size: (0.5em,1.2em),
    spacing: (0em, 0em), 
        ({
          i=0
          for line in arr_prot {
              let j = 0
              for aa in line {
                  node((j, i), [#aa])
                  j = j + 1
              }
              i = i + 1
          }
          }),
          ({
          box.pos().enumerate().map(((index,one_box)) => {
            let pos_start = one_box.pos.at(0) - 1
            let pos_end_const = one_box.pos.at(1) - 1
            let line_pos = calc.floor(pos_start / line-length)
            pos_start = pos_start - (line_pos * line-length)
            let pos_end = pos_end_const - (line_pos * line-length)
            while (pos_end >= line-length) {
              pos_end = line-length - 1
              node(enclose: ((pos_start,line_pos), (pos_end,line_pos)), ..one_box.style)
              pos_start = 0
              line_pos = line_pos + 1
              pos_end = pos_end_const - (line_pos * line-length)
            }
            node(enclose: ((pos_start,line_pos), (pos_end,line_pos)), ..one_box.style)
          })
          })
    )
  ]
}


