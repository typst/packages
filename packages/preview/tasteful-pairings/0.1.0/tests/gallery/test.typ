#import "/lib.typ": *

#set page(margin: 1em, height: auto, width: 5.5in)
#set par(justify: true, linebreaks: "optimized")

#let keys = font-pairings.keys().sorted()

#for key in keys {
  block(
    stroke: 1pt + navy,
    inset: 1em,
    radius: 1em,
    [
      #let pairing = font-pairings.at(key)
      #show heading: set text(font: pairing.heading, weight: "bold")
      = #pairing.heading & #pairing.body #h(1fr) #text(fill: eastern, weight: "light", size: 0.8em, baseline: -3pt, ["#key"])
      #set text(font: pairing.body, weight: "light")
      #pairing.description

      #lorem(20)
    ]
  )
}
