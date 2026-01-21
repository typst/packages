#import "preview/pinit:0.2.1": *
#import "@preview/fletcher:0.5.1"

Con#pin(1)#h(4em)#pin(2)nect

#pinit-fletcher-edge(
  fletcher, 1, end: 2, (1, 0), [bend], bend: -20deg, "<->",
  decorations: fletcher.cetz.decorations.wave.with(amplitude: .1),
)