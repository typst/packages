#import "primitives.typ": accidental-width, draw-accidental, draw-clef, draw-time-signature, notehead-half-width, staff-y, time-signature-width
#import "../foundation/diagnostics.typ": _score-error
#import "event-geometry.typ": _clef-origin-y

// Clefs, key signatures, time signatures, and measure-prologue geometry.

#let _clef-advance = 3.45
#let _change-clef-scale = 0.72
#let _change-clef-advance = 2.35
#let _prologue-gap = 0.7
#let _content-lead-in = 1.2
#let _barline-clearance = 1.2
#let _repeat-side-clearance = 0.3

// Staff positions of the seven key-signature accidentals, in signature order.
// Tenor clef places its first sharp on the low F line so the whole signature
// stays inside the staff, which is why it cannot reuse the treble layout.
// Octave clefs keep their plain clef's signature layout.
#let _flat-order-positions = (
  treble: (6, 9, 5, 8, 4, 7, 3),
  bass: (4, 7, 3, 6, 2, 5, 1),
  alto: (5, 8, 4, 7, 3, 6, 2),
  tenor: (7, 10, 6, 9, 5, 8, 4),
)
#_flat-order-positions.insert("treble-8", _flat-order-positions.treble)
#_flat-order-positions.insert("bass-8", _flat-order-positions.bass)
#let _sharp-order-positions = (
  treble: (10, 7, 11, 8, 5, 9, 6),
  bass: (8, 5, 9, 6, 3, 7, 4),
  alto: (9, 6, 10, 7, 4, 8, 5),
  tenor: (4, 8, 5, 9, 6, 10, 7),
)
#_sharp-order-positions.insert("treble-8", _sharp-order-positions.treble)
#_sharp-order-positions.insert("bass-8", _sharp-order-positions.bass)

// ---------------------------------------------------------------------------
// Key signatures
// ---------------------------------------------------------------------------

#let _key-signature-name(key) = {
  if key == none { none }
  else if key == "Am" { "C" }
  else if key == "Em" { "G" }
  else if key == "Bm" { "D" }
  else if key == "F#m" { "A" }
  else if key == "C#m" { "E" }
  else if key == "G#m" { "B" }
  else if key == "D#m" { "F#" }
  else if key == "A#m" { "C#" }
  else if key == "Dm" { "F" }
  else if key == "Gm" { "Bb" }
  else if key == "Cm" { "Eb" }
  else if key == "Fm" { "Ab" }
  else if key == "Bbm" { "Db" }
  else if key == "Ebm" { "Gb" }
  else if key == "Abm" { "Cb" }
  else { key }
}

#let _key-accidentals(key) = {
  let key = _key-signature-name(key)
  let flats = ("F": 1, "Bb": 2, "Eb": 3, "Ab": 4, "Db": 5, "Gb": 6, "Cb": 7)
  let sharps = ("G": 1, "D": 2, "A": 3, "E": 4, "B": 5, "F#": 6, "C#": 7)
  if key == "C" or key == none {
    (kind: none, count: 0)
  } else if key in flats {
    (kind: "Flat", count: flats.at(key))
  } else if key in sharps {
    (kind: "Sharp", count: sharps.at(key))
  } else {
    panic("unsupported key signature " + key)
  }
}

#let _key-suppresses-accidental(pitch, key) = {
  let signature-accidentals = _key-accidentals(key)
  if signature-accidentals.count == 0 or pitch.accidental != signature-accidentals.kind {
    false
  } else {
    let flat-letters = ("B", "E", "A", "D", "G", "C", "F")
    let sharp-letters = ("F", "C", "G", "D", "A", "E", "B")
    let letters = if signature-accidentals.kind == "Flat" { flat-letters } else { sharp-letters }
    letters.slice(0, signature-accidentals.count).contains(pitch.letter)
  }
}

#let _key-alters-natural(pitch, key) = {
  let signature-accidentals = _key-accidentals(key)
  if pitch.accidental != "Natural" or signature-accidentals.count == 0 {
    false
  } else {
    let flat-letters = ("B", "E", "A", "D", "G", "C", "F")
    let sharp-letters = ("F", "C", "G", "D", "A", "E", "B")
    let letters = if signature-accidentals.kind == "Flat" { flat-letters } else { sharp-letters }
    letters.slice(0, signature-accidentals.count).contains(pitch.letter)
  }
}

#let _key-default-accidental(letter, key, percussion: false) = {
  let signature-accidentals = _key-accidentals(key)
  if signature-accidentals.count == 0 or percussion {
    "Natural"
  } else {
    let flat-letters = ("B", "E", "A", "D", "G", "C", "F")
    let sharp-letters = ("F", "C", "G", "D", "A", "E", "B")
    let letters = if signature-accidentals.kind == "Flat" { flat-letters } else { sharp-letters }
    if letters.slice(0, signature-accidentals.count).contains(letter) {
      signature-accidentals.kind
    } else {
      "Natural"
    }
  }
}

#let _key-accidental-step(kind) = accidental-width(kind) + 0.12
#let _key-cancellation-gap = 0.45

#let _key-signature-width(key) = {
  let signature-accidentals = _key-accidentals(key)
  if signature-accidentals.count == 0 {
    0
  } else {
    signature-accidentals.count * _key-accidental-step(signature-accidentals.kind)
  }
}

// A percussion staff never carries a key signature; its column stays empty
// so the time signatures of every staff still align.
#let _draw-key-signature(clef, key, x, bottom-y: 0, unit: 8pt, paint: black) = {
  let signature-accidentals = _key-accidentals(key)
  if signature-accidentals.count > 0 and clef != "percussion" {
    let positions = if signature-accidentals.kind == "Flat" {
      _flat-order-positions.at(clef)
    } else {
      _sharp-order-positions.at(clef)
    }
    for accidental-index in range(signature-accidentals.count) {
      draw-accidental(
        signature-accidentals.kind,
        x + accidental-index * _key-accidental-step(signature-accidentals.kind),
        staff-y(positions.at(accidental-index), bottom-y: bottom-y),
        unit: unit,
        paint: paint,
      )
    }
  }
}

#let _key-cancellation-indices(previous-key, key) = {
  if previous-key == none or previous-key == key {
    return ()
  }
  let previous = _key-accidentals(previous-key)
  let current = _key-accidentals(key)
  if previous.count == 0 {
    return ()
  }
  let flat-letters = ("B", "E", "A", "D", "G", "C", "F")
  let sharp-letters = ("F", "C", "G", "D", "A", "E", "B")
  let previous-order = if previous.kind == "Flat" { flat-letters } else { sharp-letters }
  let current-letters = if current.count == 0 or current.kind != previous.kind {
    ()
  } else {
    let current-order = if current.kind == "Flat" { flat-letters } else { sharp-letters }
    current-order.slice(0, current.count)
  }
  let indices = ()
  for accidental-index in range(previous.count) {
    if previous-order.at(accidental-index) not in current-letters {
      indices.push(accidental-index)
    }
  }
  indices
}

#let _key-change-width(previous-key, key) = {
  let cancellation-count = _key-cancellation-indices(previous-key, key).len()
  let cancellation-width = cancellation-count * _key-accidental-step("Natural")
  let signature-width = _key-signature-width(key)
  let between = if cancellation-width > 0 and signature-width > 0 { _key-cancellation-gap } else { 0 }
  cancellation-width + between + signature-width
}

#let _draw-key-change(clef, previous-key, key, x, bottom-y: 0, unit: 8pt, paint: black) = {
  let cancellation-indices = _key-cancellation-indices(previous-key, key)
  let cursor = x
  if cancellation-indices.len() > 0 and clef != "percussion" {
    let previous = _key-accidentals(previous-key)
    let positions = if previous.kind == "Flat" {
      _flat-order-positions.at(clef)
    } else {
      _sharp-order-positions.at(clef)
    }
    for (j, i) in cancellation-indices.enumerate() {
      draw-accidental(
        "Natural",
        cursor + j * _key-accidental-step("Natural"),
        staff-y(positions.at(i), bottom-y: bottom-y),
        unit: unit,
        paint: paint,
      )
    }
    cursor += cancellation-indices.len() * _key-accidental-step("Natural")
    if _key-signature-width(key) > 0 {
      cursor += _key-cancellation-gap
    }
  }
  _draw-key-signature(clef, key, cursor, bottom-y: bottom-y, unit: unit, paint: paint)
}

// ---------------------------------------------------------------------------
// Prologue (clef + key + time) geometry
// ---------------------------------------------------------------------------

// Absolute x where measure content coordinate 0 begins on the first
// measure of a system. Every system restates its clef and key, but the time
// signature appears only where the meter is first set or changes.
#let _prologue-start-x(key, time, show-time, previous-key: none, staff-x: 0, clef-x: 0.35) = {
  let x = clef-x + _clef-advance
  let key-width = _key-change-width(previous-key, key)
  if key-width > 0 { x += key-width + _prologue-gap }
  let time-width = if show-time { time-signature-width(time) } else { 0 }
  if time-width > 0 { x += time-width + _prologue-gap }
  x + _content-lead-in
}

// Left edge of the time signature in a system's opening prologue.
#let _prologue-time-x(key, previous-key: none, clef-x: 0.35) = {
  let x = clef-x + _clef-advance
  let key-width = _key-change-width(previous-key, key)
  if key-width > 0 { x += key-width + _prologue-gap }
  x
}

#let _draw-prologue(clef, key, time, show-time, previous-key: none, bottom-y: 0, unit: 8pt, staff-x: 0, clef-x: 0.35, paint: black) = {
  draw-clef(clef, clef-x, _clef-origin-y(clef, bottom-y: bottom-y), unit: unit, paint: paint)
  _draw-key-change(clef, previous-key, key, clef-x + _clef-advance, bottom-y: bottom-y, unit: unit, paint: paint)
  if show-time {
    draw-time-signature(
      time,
      _prologue-time-x(key, previous-key: previous-key, clef-x: clef-x),
      bottom-y: bottom-y,
      unit: unit,
      paint: paint,
    )
  }
}

// Mid-score key/time changes shown at the start of a measure.
#let _inline-signature-note-start(
  measure-start,
  key,
  time,
  show-key,
  show-time,
  show-clef: false,
  previous-key: none,
  repeat-start: false,
) = {
  let x = measure-start + 0.8
  let has-signature = false
  if show-clef {
    x += _change-clef-advance + _prologue-gap
    has-signature = true
  }
  if show-key {
    let key-width = _key-change-width(previous-key, key)
    if key-width > 0 {
      x += key-width + _prologue-gap
      has-signature = true
    }
  }
  if show-time and time != none {
    x += time-signature-width(time) + _prologue-gap
    has-signature = true
  }
  if has-signature {
    x + 0.4
  } else {
    let repeat-clearance = if repeat-start { _repeat-side-clearance } else { 0 }
    measure-start + notehead-half-width + _barline-clearance + repeat-clearance
  }
}

// Left edge of a mid-score time signature, after any clef or key change.
#let _inline-time-x(measure-start, key, show-key, reserve-clef: false, previous-key: none) = {
  let x = measure-start + 0.8
  if reserve-clef { x += _change-clef-advance + _prologue-gap }
  if show-key {
    let key-width = _key-change-width(previous-key, key)
    if key-width > 0 { x += key-width + _prologue-gap }
  }
  x
}

#let _draw-inline-signature(
  clef,
  key,
  time,
  measure-start,
  previous-key: none,
  bottom-y: 0,
  unit: 8pt,
  show-key: false,
  show-time: false,
  show-clef: false,
  reserve-clef: false,
  paint: black,
) = {
  let x = measure-start + 0.8
  if show-clef {
    draw-clef(
      clef,
      x,
      _clef-origin-y(clef, bottom-y: bottom-y),
      unit: unit,
      scale: _change-clef-scale,
      paint: paint,
    )
  }
  if show-clef or reserve-clef { x += _change-clef-advance + _prologue-gap }
  if show-key {
    _draw-key-change(clef, previous-key, key, x, bottom-y: bottom-y, unit: unit, paint: paint)
  }
  if show-time {
    draw-time-signature(
      time,
      _inline-time-x(measure-start, key, show-key, reserve-clef: show-clef or reserve-clef, previous-key: previous-key),
      bottom-y: bottom-y,
      unit: unit,
      paint: paint,
    )
  }
}


// ---------------------------------------------------------------------------
// Clef and key validation
// ---------------------------------------------------------------------------

#let _valid-clefs = ("treble", "bass", "alto", "tenor", "percussion", "treble-8", "bass-8", "tab")

#let _validate-clef(value, label) = {
  if type(value) != str or value not in _valid-clefs {
    _score-error(
      label,
      "unknown clef",
      value: value,
      expected: "treble, bass, alto, tenor, percussion, treble-8, bass-8, or tab",
      fix: "choose one of the supported clef names",
    )
  }
  value
}

#let _valid-keys = (
  "C", "G", "D", "A", "E", "B", "F#", "C#",
  "F", "Bb", "Eb", "Ab", "Db", "Gb", "Cb",
  "Am", "Em", "Bm", "F#m", "C#m", "G#m", "D#m", "A#m",
  "Dm", "Gm", "Cm", "Fm", "Bbm", "Ebm", "Abm",
)

#let _validate-key(value, label) = {
  if value != none and (type(value) != str or value not in _valid-keys) {
    _score-error(
      label,
      "unsupported key signature",
      value: value,
      expected: "a supported major or minor key such as C, Eb, F#, Am, or F#m",
      fix: "use a conventional key name with exact capitalization",
    )
  }
  value
}
