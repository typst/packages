#import "@preview/conchord:0.4.0": aligned-chords as ac, sized-chordlib
// For better png in README, doesn't matter
#set page(width: auto, height: auto, margin: 1em)

#let bl = block.with(stroke: gray, inset: 1em)

Center-aligned (default):\ 
#bl[
  #ac[A][Why] do #ac[B][birds] #ac[C][D][suddenly] #ac[E\#/D][appear]\
  #ac[A][D\#9][Center-aligned chords]
]

Left-aligned:
#bl[
  #ac(align: left)[A][Left-aligned chord] \
  // cases like this could be set up with wrapping-align
  #ac(align: left)[Asus2(b5)][Same]
] 

Right-aligned:
#bl[
  #ac(align: right)[A][Right-aligned chord] \
  // cases like this could be set up with wrapping-align
  #ac(align: right)[Asus2(b5)][Same]
] 