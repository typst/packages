#import "../lib.typ": outline-colorbox

#set page(paper: "a4", margin: 0.5cm, height: auto)

#outline-colorbox(title: lorem(5), color: "gray")[
  #lorem(50)
]

#outline-colorbox(title: lorem(5), centering: true, color: "green")[
  #lorem(50)
]