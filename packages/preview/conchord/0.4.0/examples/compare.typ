#import "@preview/chordx:0.6.0": *
#import "@preview/conchord:0.4.0": new-chordgen, overchord, smart-chord, aligned-chords

#set page(height: auto, margin: 1em)
#set align(center)
#show raw: set block(fill: gray.lighten(90%), inset: 3pt)
#table(
  columns: 3,
  inset: 1em,
  fill: (_, row) => if not calc.odd(row) { luma(220) } else { white },
  [Library], [Code], [Result],
  [*conchord*],
  [
    ```typst
  #let chord = new-chordgen(number-to-left: true)
  #chord("x, 6, 10, 7, 9, 6",
  name: "D#maj7sus4add13")
    ```

    or you can do

    ```typ
    // removing omit-fifth and n will give you
    // simpler versions of this chord 
    #smart-chord("D#maj7sus4add13",
                  omit-fifth: false, n: 1)
    ```
  ],
  [
    // Chordx chords are smaller, so for better
    // comparison need to make it smaller
    #let chord = new-chordgen(number-to-left: true)//scale-length: 0.6pt)
    #chord("x, 6, 10, 7, 9, 6", name: "D#maj7sus4add13")

    #smart-chord("D#maj7sus4add13", omit-fifth: false, n: 1)
  ],
  [chordx],
  [
    ```typst
    #let chord = chart-chord.with(size: 1.5em, design: "round")

    #chord(
      capos: "115",
      fret: 6,
      tabs: "xn524n"
    )[D\#maj7sus4add13]
    ```
  ],
  [
    #let chord = chart-chord.with(size: 1.5em, design: "round")

    #chord(
      capos: "115",
      fret: 6,
      tabs: "xn524n"
    )[D\#maj7sus4add13]
  ],
  [*conchord*],
  [
    ```typst
    // a simple placement function
    // .with(styling: strong) is default
    #let och = overchord 
    // another one that requires more work,
    // but nicely aligns chords
    #let ac = aligned-chords

    #och[G] Jingle bells, jingle bells, jingle
    #och[C] all the #ac[G][way]! \
    #och[C] Oh what fun it #och[G] is to ride
    ```
  ],
  [
    // a simple placement function
    #let och = overchord
    // another one that requires more work,
    // but nicely aligns chords
    #let ac = aligned-chords

    #och[G] Jingle bells, jingle bells, jingle
    #och[C] all the 
    #ac[G][way]! \
    #och[C] Oh what fun it #och[G] is to ride
  ],
  [chordx],
  [
    ```typst
    #let chord = single-chord.with(weight: "semibold")

    #chord[Jingle][G][2] bells, jingle bells, jingle #chord[all][C][2] the #chord[way!][G][2] \
    #chord[Oh][C][] what fun it #chord[is][G][] to ride
    ```
  ],
  [
    #let chord = single-chord.with(weight: "semibold")

    #chord[Jingle][G][2] bells, jingle bells, jingle #chord[all][C][2] the #chord[way!][G][2] \
    #chord[Oh][C][] what fun it #chord[is][G][] to ride
  ]
)
