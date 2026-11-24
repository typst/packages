#import "diagnostics.typ": _score-error

// Transposing intervals and the spellings Typst draws itself: key signatures
// and chord-symbol roots. The parser moves notes by the same interval.

#let _letters = ("C", "D", "E", "F", "G", "A", "B")
#let _natural-semitones = (0, 2, 4, 5, 7, 9, 11)
// Position of each letter on the line of fifths, counted from C.
#let _letter-fifths = (C: 0, D: 2, E: 4, F: -1, G: 1, A: 3, B: 5)
#let _accidental-alterations = ("": 0, "#": 1, "b": -1, "##": 2, "bb": -2)

#let _accidental-text(alteration) = {
  ("bb", "b", "", "#", "##").at(alteration + 2)
}

// An interval such as "M6" or "-M2" becomes signed letter steps and
// semitones, so a major sixth up is (steps: 5, semitones: 9).
#let _parse-transposition(value, label) = {
  if value == none { return none }
  let syntax = if type(value) == str {
    value.match(regex("^([+-]?)([PMmAd])([1-9][0-9]?)$"))
  }
  if syntax == none {
    _score-error(
      label,
      "transposition must be an interval name",
      value: value,
      expected: "an optional - for downward, a quality P, M, m, A, or d, and a size, such as \"M6\" or \"-M2\"",
      fix: "write the interval from the pitches as typed to the pitches as drawn",
    )
  }
  let (sign, quality, size-text) = syntax.captures
  let size = int(size-text)
  let simple = calc.rem(size - 1, 7)
  let perfect-class = simple in (0, 3, 4)
  if (perfect-class and quality in ("M", "m")) or (not perfect-class and quality == "P") {
    _score-error(
      label,
      "interval quality does not exist for this size",
      value: value,
      expected: if perfect-class {
        "P, A, or d for unisons, fourths, fifths, and octaves"
      } else {
        "M, m, A, or d for seconds, thirds, sixths, and sevenths"
      },
      fix: "choose a quality that matches the interval size",
    )
  }
  if size == 1 and quality == "d" {
    _score-error(
      label,
      "a diminished unison is not a transposition",
      value: value,
      expected: "a chromatic semitone written as \"A1\" or \"-A1\"",
      fix: "use \"-A1\" to lower every pitch by a semitone on the same letter",
    )
  }
  let alteration = if quality in ("P", "M") { 0 }
    else if quality == "m" { -1 }
    else if quality == "A" { 1 }
    else if perfect-class { -1 }
    else { -2 }
  let steps = size - 1
  let semitones = calc.div-euclid(steps, 7) * 12 + _natural-semitones.at(simple) + alteration
  let direction = if sign == "-" { -1 } else { 1 }
  (steps: direction * steps, semitones: direction * semitones)
}

// Moves a letter and alteration by the interval. As in the parser, a result
// needing more than `max-alteration` accidentals is respelled on the nearest
// letter that can reach the pitch.
#let _transpose-spelling(letter, alteration, transposition, max-alteration: 2) = {
  let letter-index = _letters.position(candidate => candidate == letter)
  let target = _natural-semitones.at(letter-index) + alteration + transposition.semitones
  let diatonic-index = letter-index + transposition.steps
  while true {
    let natural = (
      calc.div-euclid(diatonic-index, 7) * 12
        + _natural-semitones.at(calc.rem-euclid(diatonic-index, 7))
    )
    if target - natural > max-alteration {
      diatonic-index += 1
    } else if target - natural < -max-alteration {
      diatonic-index -= 1
    } else {
      return (
        letter: _letters.at(calc.rem-euclid(diatonic-index, 7)),
        alteration: target - natural,
      )
    }
  }
}

#let _key-fifths(letter, alteration, minor) = {
  _letter-fifths.at(letter) + 7 * alteration - if minor { 3 } else { 0 }
}

// The drawn key for a written key, and the interval the measure's notes use.
// A transposed key keeps the interval's spelling unless that needs more
// accidentals than six or the written key's own count; then the key and the
// notes take the enharmonic spelling, so concert F# major for a B-flat
// instrument is written in A-flat rather than G-sharp.
#let _transpose-key(key, transposition) = {
  if transposition == none or key == none {
    return (key: key, transposition: transposition)
  }
  let (letter, accidental, mode) = key.match(regex("^([A-G])([#b]?)(m?)$")).captures
  let alteration = _accidental-alterations.at(accidental)
  let minor = mode == "m"
  let limit = calc.max(6, calc.abs(_key-fifths(letter, alteration, minor)))
  let tonic = _transpose-spelling(letter, alteration, transposition)
  let fifths = _key-fifths(tonic.letter, tonic.alteration, minor)
  let effective = transposition
  if fifths > limit {
    effective.steps += 1
  } else if fifths < -limit {
    effective.steps -= 1
  }
  if effective != transposition {
    tonic = _transpose-spelling(letter, alteration, effective)
  }
  (
    key: tonic.letter + _accidental-text(tonic.alteration) + mode,
    transposition: effective,
  )
}

// Transposes the root and any slash bass of a chord symbol, leaving its
// quality and extensions as written. Roots are respelled rather than given a
// double accidental. Symbols without a root, such as N.C., are unchanged.
#let _transpose-harmony-symbol(symbol, transposition) = {
  if transposition == none { return symbol }
  symbol.replace(regex("(^|/)([A-G])(##|bb|#|b)?"), found => {
    let (prefix, letter, accidental) = found.captures
    let spelled = _transpose-spelling(
      letter,
      _accidental-alterations.at(if accidental == none { "" } else { accidental }),
      transposition,
      max-alteration: 1,
    )
    prefix + spelled.letter + _accidental-text(spelled.alteration)
  })
}
