#let gru(content, last-content: none) = [
  #set page(width: 250pt, height: 166.6pt)
  #[
    #set page(
      margin: (top: 43pt, bottom: 3pt, left: 145pt, right: 15pt),
      background: context image("assets/gru-" + str(calc.rem-euclid(counter(page).get().at(0), 4)) + ".jpg"),
    )
    #content
  ]
  #if last-content != none [
    #set page(margin: (x: 0pt, y: 0pt))
    #page(
      background: image("assets/gru-3.jpg"),
      place(dx: 145pt, dy: 43pt, box(width: 90pt, height: 120.6pt, last-content)),
    )
    #page(
      background: image("assets/gru-4.jpg"),
      place(dx: 145pt, dy: 43pt, box(width: 90pt, height: 120.6pt, last-content)),
    )
  ]
]
