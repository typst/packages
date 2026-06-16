#import  "/template.typ": *

// optional page containing quote

#v(1fr)

#grid(
  columns: (1fr, auto),
  gutter: 14pt,
  [],
  align(left)[
  #set text(fill: luma(30), size: 10pt)
  #set par(leading: 5pt, justify: false, hanging-indent: 5pt)
  #emph[
  #lorem(5) \
  #lorem(6) \
  #lorem(5) \
  #lorem(6)
  ]
  ],[],[
  #set align(left)
      #set text(fill: luma(120), size: 9pt)
      #set par(leading: 4pt, justify: false)
      #emph[— Lorem Ipsum Machine]
  ]
)




#v(1fr)

#pagebreak() 
