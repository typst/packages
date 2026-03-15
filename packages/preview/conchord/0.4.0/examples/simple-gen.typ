#import "@preview/conchord:0.4.0": smart-chord
#set page(height: auto, width: auto, margin: 1em)

#box(smart-chord("Am"))
// what variant number to select
#box(smart-chord("Am", n: 2))
// at what fret to play the chord
#box(smart-chord("Am", at: 5, n: 1))
// what tuning to use
#box(smart-chord("C", tuning: "G1 C1 E1 A1")) // ukulele
