// Style parameters

#let bg-color = aqua.lighten(90%)

#let border-style = gray.mix(aqua).darken(50%) + 1pt


// Standard color (red & black)
#let suits-colors = (
  "heart": red, 
  "spade": black,
  "diamond": red,
  "club": black,
)

// Variant color (red & black, plus blue and orange)
#let suits-colors-variant = (
  "heart": red.mix((purple, 20%)), 
  "spade": black.mix((green, 10%)),
  "diamond": red.mix((orange, 90%)),
  "club": blue.mix((black, 10%)),
)

#if false {suits-colors = suits-colors-variant}