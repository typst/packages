#import "chord-definitions.typ": chords as built-in
#import "state.typ": chordish-state

#let define-chord(name, frets) = {
  chordish-state.update(s => (..s, custom: s.custom + ((name): frets)))
}

#let chord-regex = regex("^(\\^?)([A-G])([#b])?([^/]*)(?:/([A-G])([#b])?)?$")

#let key-list = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")

#let to-semitones(key, accidental) = {
  let semitones = key-list.position(item => item == key)
  if accidental == "#" {
    semitones += 1
  } else if accidental == "b" {
    semitones -= 1
  }
  calc.rem-euclid(semitones, 12)
}

#let get-chord(name) = {
  if type(name) == content {
    name = name.text
  }

  let current = chordish-state.get()
  if name in current.custom {
    return (
      name: name,
      frets: current.custom.at(name),
    )
  }

  let match = name.match(chord-regex)
  if match == none {
    return none
  }

  let (prefix, key, accidental, kind, bass-key, bass-accidental) = match.captures
  let semitones = to-semitones(key, accidental)
  let transpose = current.transpose
  if transpose != 0 {
    semitones = calc.rem-euclid(semitones + transpose, 12)
  }

  let root-name = if transpose != 0 {
    key-list.at(semitones)
  } else {
    key + if accidental != none { accidental } else { "" }
  }

  let lookup-key = kind
  let display-name = if transpose != 0 {
    prefix + root-name + kind
  } else {
    name
  }

  let has-slash = bass-key != none
  if has-slash {
    let bass-semitones = to-semitones(bass-key, bass-accidental)
    if transpose != 0 {
      bass-semitones = calc.rem-euclid(bass-semitones + transpose, 12)
    }
    lookup-key = kind + "/" + key-list.at(bass-semitones)
    if transpose != 0 {
      display-name += "/" + key-list.at(bass-semitones)
    }
  }

  let chord-dict = built-in.at(current.instrument).at(semitones)
  if lookup-key not in chord-dict and has-slash {
    let simplify = current.simplify-slash
    if simplify == "diagram" {
      lookup-key = kind
    } else if simplify == "all" {
      lookup-key = kind
      display-name = prefix + root-name + kind
    }
  }

  return (
    name: display-name,
    frets: chord-dict.at(lookup-key),
  )
}
