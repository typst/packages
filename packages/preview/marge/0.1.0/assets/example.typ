#import "@preview/marge:0.1.0": sidenote

#set text(size: 14pt)
#set par(justify: true)
#set page(
  width: 12cm,
  height: 8.05cm,
  margin: 1em,
  fill: none,
  background: pad(0.5pt, box(
    width: 100%,
    height: 100%,
    radius: 4pt,
    fill: white,
    stroke: white.darken(10%),
  )),
)

#set page(margin: (right: 5cm))

#let sidenote = sidenote.with(numbering: "1", padding: 1em)

The Simpsons is an iconic animated series that began in 1989
#sidenote[The show holds the record for the most episodes of any
American sitcom.]. The show features the Simpson family: Homer,
Marge, Bart, Lisa, and Maggie. 

Bart is the rebellious son who often gets into trouble, and Lisa
is the intelligent and talented daughter #sidenote[Lisa is known
for her saxophone playing and academic achievements.]. Baby
Maggie, though silent, has had moments of surprising brilliance
#sidenote[Maggie once shot Mr. Burns in a dramatic plot twist.].
