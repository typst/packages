#import "../lib.typ": stickybox

#set page(width: auto, margin: 0.5cm, height: auto)

#grid(
  columns: 3 * (auto,), gutter: 3em, 
  stickybox(width: 5cm, rotation: 5deg)[
    #lorem(20)
  ],

  stickybox(width: 5cm, rotation: -5deg, fill: rgb("#ffb6a6"))[
    #lorem(20)
  ],

  stickybox(
    width: 5cm,
    fill: rgb("#d4ffdc"),
    tape: false,
  )[
    #lorem(20)
  ],
)

