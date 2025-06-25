
// clef-data contains information about clefs:
// the symbols, as well as which line is which
// and where the key signature symbols go
//
// reference for key order:
// sharps: https://music-theory-practice.com/images/order-of-sharps-staves.png
// flats: https://music-theory-practice.com/images/order-of-flats-staves.jpeg
#let clef-data = (
  treble: (
    clef: (
      image: "/assets/clefs/treble.svg",
      y-offset: 2,
      y-span: 2,
    ),
    middle-c: -1,
    accidentals: (
      sharp: (4, 2.5, 3.5, 2, 3, 1.5, 2.5),
      flat: (2, 3.5, 1.5, 3, 1, 2.5, 0.5)
    )
  ),
  bass: (
    clef: (
      image: "/assets/clefs/bass.svg",
      y-offset: 2.4,
      y-span: 1,
    ),
    middle-c: 5,
    accidentals: (
      sharp: (3, 1.5, 3.5, 2, 4, 2.5, 4.5),
      flat: (1, 2.5, 0.5, 2, 0, 1.5, -0.5)
    )
  ),
  alto: (
    clef: (
      image: "/assets/clefs/alto.svg",
      y-offset: 2,
      y-span: 1.2,
    ),
    middle-c: 2,
    accidentals: (
      sharp: (3.5, 2, 4, 2.5, 1, 3, 1.5),
      flat: (1.5, 3, 1, 2.5, 0.5, 2, 0)
    )
  ),
  tenor: (
    clef: (
      image: "/assets/clefs/alto.svg",
      y-offset: 3,
      y-span: 1.2,
    ),
    middle-c: 3,
    accidentals: (
      sharp: (1, 3, 1.5, 3.5, 2, 4, 2.5),
      flat: (2.5, 4, 2, 3.5, 1.5, 3, 1)
    )
  ),
)

// this is data about accidental/chromatic icons
#let symbol-data = (
  sharp: (
    image: "/assets/accidental/sharp.svg",
    y-offset: 0,
    y-span: 0.8
  ),
  flat: (
    image: "/assets/accidental/flat.svg",
    y-offset: 0.4,
    y-span: 0.6
  ),
  natural: (
    image: "/assets/accidental/natural.svg",
    y-offset: 0,
    y-span: 0.8
  ),
  double-sharp-x: (
    image: "/assets/accidental/double-sharp-x.svg",
    y-offset: 0,
    y-span: 0.3
  )
)


// write out the circle of fifths
// from 7 flats, to C (nothing) to 7 sharps
// correctness reference:
// https://www.music-theory-for-musicians.com/staves.html
#let key-data = (
  major: (
    "Cb", "Gb", "Db", "Ab", "Eb", "Bb", "F",
    "C",
    "G", "D", "A", "E", "B", "F#", "C#"
  ),
  minor: (
    "ab", "eb", "bb", "f", "c", "g", "d", 
    "a",
    "e", "b", "f#", "c#", "g#", "d#", "a#"
    
  )
)

#let symbol-map = (
 "#": "sharp",
 "s": "sharp",
 "b": "flat",
 "n": "natural",
 "x": "double-sharp-x",
)

// for the note (heads) themselves
#let note-duration-data = (
  whole: (
    image: "/assets/notes/whole.svg",
    y-offset: 0, 
    y-span: 0.3,
    stem: false
  ),
  quarter: (
    // without stem
    image: "/assets/notes/crotchet-head.svg",
    y-offset: 0, 
    y-span: 0.3,
    width: 1.08,
    stem: true
  )
)

// add aliases
#note-duration-data.insert("semibreve", note-duration-data.at("whole"))
#note-duration-data.insert("crotchet", note-duration-data.at("quarter"))

#let semitones-per-octave = 12

#let middle-c-octave = 4
#let middle-c-index = 60
#let all-notes-from-c = (
  sharp: ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"),
  flat:  ("C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B")
)
#let all-letters-from-c = ("C", "D", "E", "F", "G", "A", "B")
#let num-letters-per-octave = all-letters-from-c.len()

#let allowed-sides = ("sharp", "flat") // not plural

// export some dict keys for documentation and testing
#let all-clefs = clef-data.keys()
#let all-note-durations = note-duration-data.keys()
#let all-symbols = symbol-map.keys()