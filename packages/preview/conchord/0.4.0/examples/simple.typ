#set page(height: auto, width: auto, margin: 1em)

#import "@preview/conchord:0.4.0": new-chordgen

#let chord = new-chordgen()

#box(chord("x32010", name: "C"))
#box(chord("x33222", name: "F#m/C#"))
#box(chord("x,9,7,8,9,9"))
