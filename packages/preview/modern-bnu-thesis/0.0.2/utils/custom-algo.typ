#import "@preview/algo:0.3.6":*
#import "@preview/i-figured:0.2.4":show-figure

#let show-algo(it) = context { 
  // show math.equation: set text(font: "Fira Math")
  let it = show-figure(it) 
  let c = counter(figure.where(kind: "algo")).get().at(0) 
  block(
    width: 100%, 
    align(std.left, 
      table(columns: (1fr),stroke: none, align: left,
        table.hline(stroke: 1.25pt), 
        text(weight: "bold",[
          #it.caption.supplement
          #numbering(it.numbering, c)
          #it.caption.body
          ]), 
        table.hline(stroke: .75pt),
        algo(
          //   header: [                    // note that title and parameters
          //   #set text(size: 15pt)     // can be content
          //   #emph(smallcaps("Fib"))
          // ],
          // parameters: ([#math.italic("n")],),
          // comment-prefix: [#sym.triangle.stroked.r ],
          // comment-styles: (fill: rgb(100%, 0%, 0%)),
          indent-size: 15pt,
          indent-guides: 1pt + gray,
          row-gutter: 5pt,
          column-gutter: 5pt,
          inset: 5pt,
          stroke: none,
          fill: none,
          block-align: left,
          it.body
          ), 
        table.hline(stroke: .75pt),
      )
    ) 
  )
 
}