#import "/src/lib.typ": *

#set page(width: auto, height: auto, margin: (x: 1cm, y: .2cm), fill: white)
#set text(16pt)
#show raw: set text(.5em)

#let lab(body) = rect(stroke: silver, inset: 2pt, text(size: .7em, font: "DejaVu Sans Mono", body))

#table(
  columns: (10em, 10em),
  stroke: none,
  ```typc
  #annot(<1>, pos: top)[annotation]
  ```,
  ```typc
  #annot(
    <1>, pos: top, dx: 1em, dy: -1em
  )[annotation]
  ```,

  [
    #set align(bottom)
    #show: pad.with(right: 2cm)
    $
      markrect(integral x dif x, tag: #<1>, color: #red)
      #annot(<1>, pos: top)[annotation]
    $
  ],
  [
    #set align(bottom)
    #show: pad.with(right: 2cm)
    #v(2em)
    $
      markrect(integral x dif x, tag: #<1>, color: #red)
      #annot(<1>, pos: top, dx: 1em, dy: -1em)[annotation]
    $
  ],
)
