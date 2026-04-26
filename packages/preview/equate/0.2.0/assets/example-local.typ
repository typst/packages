#import "@preview/equate:0.2.0": equate

#set text(size: 14pt)
#set par(justify: true)
#set page(
  width: 11cm,
  height: auto,
  margin: 1em,
  background: pad(0.5pt, box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
    stroke: white.darken(10%),
  )),
)

// Allow references to a line of the equation.
#show ref: equate

#set math.equation(numbering: "(1.1)", supplement: "Eq.")

#equate($
  E &= m c^2 #<short> \
    &= sqrt(p^2 c^2 + m^2 c^4) #<long>
$)

While @short is the famous equation by Einstein, @long is a
more general form of the energy-momentum relation.
