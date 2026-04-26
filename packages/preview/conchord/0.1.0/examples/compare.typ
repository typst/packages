#import "@preview/chordx:0.1.0": *
#import "../lib.typ": new-chordgen, overchord

#set page(height: auto, margin: 1em)
#set align(center)
#show raw: set block(fill: gray.lighten(90%), inset: 3pt)
#table(
  columns: 3,
  inset: 1em,
  fill: (_, row) => if not calc.odd(row) { luma(220) } else { white },
  [Library], [Code], [Result],
  [conchord],
  [
    ```typst
#let chord = new-chordgen()
#chord("x, 6, 10, 7, 9, 6",
  name: "D#maj7sus4add13")
    ```
  ],
  [
    // Chordx chords are smaller, so for better
    // comparison need to make it smaller
    #let chord = new-chordgen()//scale-length: 0.6pt)
    #chord("x, 6, 10, 7, 9, 6", name: "D#maj7sus4add13")
  ],
  [chordx],
  [
    ```typst
    #let chord = new-graph-chords()

    #chord(
      capos: ((fret: 1, start: 1, end: 5),),
      fret-number: 6,
      ("x", "n", 5, 2, 4, "n")
    )[D\#maj7sus4add13]
    ```
  ],
  [
    #let chord = new-graph-chords()

    #chord(
      capos: ((fret: 1, start: 1, end: 5),),
      fret-number: 6,
      ("x", "n", 5, 2, 4, "n")
    )[D\#maj7sus4add13]
  ],
  [conchord],
  [
    ```typst
    #let chord(name) = overchord(strong(name))

    #chord[G] Jingle bells, jingle bells, jingle
    #chord[C] all the 
    #chord[G] way! \
    #chord[C] Oh what fun it #chord[G] is to ride
    ```
  ],
  [
    #let chord(name) = overchord(strong(name))

    #chord[G] Jingle bells, jingle bells, jingle
    #chord[C] all the 
    #chord[G] way! \
    #chord[C] Oh what fun it #chord[G] is to ride
  ],
  [chordx],
  [
    ```typst
    #let chord = new-single-chords(weight: "semibold")

    #chord[Jingle][G][2] bells, jingle bells, jingle #chord[all][C][2] the #chord[way!][G][2] \
    #chord[Oh][C][] what fun it #chord[is][G][] to ride
    ```
  ],
  [
    #let chord = new-single-chords(weight: "semibold")

    #chord[Jingle][G][2] bells, jingle bells, jingle #chord[all][C][2] the #chord[way!][G][2] \
    #chord[Oh][C][] what fun it #chord[is][G][] to ride
  ]
)
