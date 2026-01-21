#let feedback(
  feedback: none,
  response: none,
) = {
  counter("feedback").step()
  rect(
    width: 100%,
    inset: 10pt,
    radius: 3pt,
    stroke: 0.5pt + blue,
    fill: blue.lighten(75%),
  )[
    #text(
      weight: 700,
      counter("feedback").display() + ". Feedback: ",
    )
    #feedback
    #if response != none {
      line(length: 100%, stroke: 0.5pt + blue)
      [#text(weight: 700, "Response: ") #response]
    }
  ]
}
