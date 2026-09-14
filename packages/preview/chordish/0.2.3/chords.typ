#import "chord-definitions.typ": chords as built-in

#let transpose-state = state("transpose", 0)

#let custom-chords = state("custom-chords", (:))
#let define-chord(name, frets) = {
  custom-chords.update(c => c + ((name): frets))
}

#let chord-regex = regex("^(\\^?)([A-G])([#b])?(.*)$")

#let keys = (
  "C": 0,
  "D": 2,
  "E": 4,
  "F": 5,
  "G": 7,
  "A": 9,
  "B": 11,
)

#let key-list = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")

#let get-chord(name) = {
  if type(name) == content {
    name = name.text
  }

  if name in custom-chords.get() {
    return (
      name: name,
      frets: custom-chords.get().at(name),
    )
  }

  let match = name.match(chord-regex)
  if match == none {
    return none
  }

  let (prefix, key, accidental, kind) = match.captures
  let semitones = keys.at(key)
  if accidental == "#" {
    semitones += 1
  } else if accidental == "b" {
    semitones -= 1
  }
  semitones = calc.rem-euclid(semitones, 12)

  if transpose-state.get() != 0 {
    semitones += transpose-state.get()
    semitones = calc.rem-euclid(semitones, 12)

    name = prefix + key-list.at(semitones) + kind
  }

  return (
    name: name,
    frets: built-in.at(state("instrument").get()).at(semitones).at(kind),
  )
}
