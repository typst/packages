#import "utils.typ": *
#import "data.typ": *
#import "core.typ": *

= Code Tests (Assertions)

#let test-is-integer() = {
  assert(is-integer("0"))
  assert(not is-integer("A"))
  assert(not is-integer(""))
  assert(not is-integer(none))

}

#let test-determine-key() = {
  // key can be:
// C -> C Major
// Bb -> Bb Major
// a# -> A# Minor
// bb -> Bb Minor
// none -> C Major
// "" (empty) -> C Major
// "3b" -> 3 flats (Eb Major)

  assert(determine-key("C").num-chromatics == 0)
  assert(determine-key("").num-chromatics == 0)
  assert(determine-key(none).num-chromatics == 0)
  assert(determine-key("Bb") == (num-chromatics: 2, symbol-type: "flat"))
  assert(determine-key("a#") == (num-chromatics: 7, symbol-type: "sharp"))
  assert(determine-key("3b") == (num-chromatics: 3, symbol-type: "flat"))
}

#let test-parse-note-string() = {
  assert(parse-note-string("Cb5") == letter-note("C", 5, accidental: "b"))
  assert(parse-note-string("A6") == letter-note("A", 6))
}

#let test-serialise-note() = {
  assert(serialise-note(letter-note("C", 5, accidental: "b")) == "Cb5")
  assert(serialise-note(letter-note("C", 5, accidental: "n"), suppress-natural: true) == "C5")
  assert(serialise-note(letter-note("C", 5, accidental: "n"), suppress-natural: false) == "Cn5")
}

#let test-accidental-string() = {
  assert(accidental-string("A", none) == "A")
  assert(accidental-string("B", "#") == "B#")
  assert(accidental-string("C", "n", suppress-natural: false) == "Cn")
  assert(accidental-string("D", "n", suppress-natural: true) == "D")
}

#let test-letter-to-index() = {
  assert(letter-to-index(letter-note("C", 4, accidental: none), "sharp").index == middle-c-index)
  assert(letter-to-index(letter-note("C", 5, accidental: none), "sharp").index == middle-c-index + semitones-per-octave)
  assert(letter-to-index(letter-note("C", 3, accidental: none), "sharp").index == middle-c-index - semitones-per-octave)
  assert(letter-to-index(letter-note("C", 4, accidental: "s"), "sharp").index == middle-c-index + 1)
  assert(letter-to-index(letter-note("B", 3, accidental: "n"), "sharp").index == middle-c-index - 1)
}

#let test-index-to-letter() = {
  let i = index-note(middle-c-index, "sharp")
  assert(i.index == middle-c-index)
  let actual = index-to-letter(i)

  assert(actual.letter == "C")
  assert(actual.accidental == none)
  assert(actual.octave == middle-c-octave)
  
  let expected = letter-note("C", 4, accidental: none)
  assert(actual == expected, message: serialise-note(actual) + " != " + serialise-note(expected))


  let i = index-note(middle-c-index + 1, "sharp")
  let actual = index-to-letter(i)
  assert(actual.letter == "C")
  assert(actual.accidental == "#")
  assert(actual.octave == middle-c-octave)
  
  let expected = letter-note("C", 4, accidental: "#")
  assert(actual == expected, message: serialise-note(actual) + " != " + serialise-note(expected))


  let i = index-note(middle-c-index - 2, "flat")
  let actual = index-to-letter(i)
  assert(actual.letter == "B", message: "actual.letter is " + actual.letter)
  assert(actual.accidental == "b")
  assert(actual.octave == middle-c-octave - 1)
  
  let expected = letter-note("B", 3, accidental: "b")
  assert(actual == expected, message: serialise-note(actual) + " != " + serialise-note(expected))



  let i = index-note(middle-c-index + 3 + semitones-per-octave, "sharp")
  let actual = index-to-letter(i)
  assert(actual.letter == "D", message: "actual.letter is " + actual.letter)
  assert(actual.accidental == "#")
  assert(actual.octave == middle-c-octave + 1)
  
  let expected = letter-note("D", 5, accidental: "#")
  assert(actual == expected, message: serialise-note(actual) + " != " + serialise-note(expected))
  
  
}

#let test-calc-note-height() = {
  assert(calc-note-height("treble", letter-note("C", 4)) == -1)
  assert(calc-note-height("treble", letter-note("F", 4)) == 0.5)
  assert(calc-note-height("treble", letter-note("B", 4)) == 2)
}


#let test-increment-letter() = {
  assert(increment-letter("A") == "B")
  assert(increment-letter("B") == "C")
  assert(increment-letter("G") == "A")
}

#let test-add-semitones() = {
  let actual = add-semitones("C", none, 4, steps: 1, side: "sharp")
  assert(actual.letter == "C")
  assert(actual.accidental != none)
  assert(actual.accidental == "#", message: "Got " + actual.accidental + " expected #")
  assert(actual.octave == 4)
}

#let test-set-accidental() = {
  assert(set-accidental(letter-note("C", 4), "#") == letter-note("C", 4, accidental: "#"))
  assert(set-accidental(letter-note("D", 5), "b") == letter-note("D", 5, accidental: "b"))
  assert(set-accidental(letter-note("F", 6), "n") == letter-note("F", 6, accidental: "n"))
}

#let test-increment-wholenote() = {
  let n = letter-note("C", 4)
  let expected = letter-note("D", 4)
  let actual = increment-wholenote(n)
  assert(expected == actual)

  let expected = letter-note("E", 4)
  let actual = increment-wholenote(n, steps: 2)
  assert(expected == actual)

  let expected = letter-note("C", 5)
  let actual = increment-wholenote(n, steps: 7)
  assert(expected == actual)

  let expected = letter-note("D", 5)
  let actual = increment-wholenote(n, steps: 8)
  assert(expected == actual)

  let expected = letter-note("B", 4)
  let actual = increment-wholenote(n, steps: 6)
  assert(expected == actual)

  let n = letter-note("B", 6)
  let expected = letter-note("D", 7)
  let actual = increment-wholenote(n, steps: 2)
  assert(expected == actual)
}

#let unit-test() = {
  test-is-integer()
  test-determine-key()
  test-parse-note-string() 
  test-accidental-string()
  test-letter-to-index()
  test-serialise-note()
  test-index-to-letter()
  test-calc-note-height()
  test-increment-letter()
  test-add-semitones()
  test-increment-wholenote()
  test-set-accidental()
}


#unit-test()

= Content Tests

= Key Signature Tests

Generate some staves of each type

No symbols
#stave("treble", "C")
#stave("treble", "")
#stave("treble", none)

Major vs minor
#stave("treble", "F")
#stave("treble", "f")

All symbols
#for clef in all-clefs {
  stave(clef, "C#")
  stave(clef, "Cb")
}

Using numbers

#stave("treble", "1#")
#stave("treble", "1b")
#stave("treble", "7#")
#stave("treble", "7b")

== Full Reference

=== Numbers

#let canvases = ()
#for clef in all-clefs {
  for num-symbols in range(0, 7) {
    for symbol-char in all-symbols {
      if symbol-char not in ("n", "x") {
        let key = str(num-symbols) + symbol-char
        canvases.push([
          stave(#clef,#key)
          #stave(clef, key)
        ])
      }
    }
  }
}

#grid(
  columns: 4,
  column-gutter: 1em,
  row-gutter: 1em,
  ..canvases
)


=== Letters

#let canvases = ()
#for clef in all-clefs {
  for tonality in ("major", "minor") {
    for key in key-data.at(tonality) {
        canvases.push([
          #stave(clef, key)
          #clef #key #tonality
        ])
    }    
  }
}

#grid(
  columns: 4,
  column-gutter: 1em,
  row-gutter: 1em,
  ..canvases
)

= Notes too

#stave("treble", "C", notes: ("C4", "Ds4", "E4", "F4", "G4", "A4", "B4", "C5"))

#let canvases = ()

#for clef in all-clefs {
  stave(clef, "C", notes: ("C2", "C3", "C4", "C5", "C6"))
}

= Arpeggios

#arpeggio(
  "treble",
  "D",
  5
)


#arpeggio(
  "treble",
  "D",
  5,
  geometric-scale: 1.2,
  note-duration: "crotchet"
)


= Minor Scales

#for key in key-data.at("minor") {
  for minor-type in minor-types {
    for seventh in seventh-types {
      figure(
        minor-scale("treble", key, 4, minor-type: minor-type, seventh: seventh),
        caption: [#key #minor-type Minor with seventh = #seventh]
      )
    }
  }
}

= Double sharp

#stave("treble", "C", notes: ("C5", "C#5", "Cx5"))