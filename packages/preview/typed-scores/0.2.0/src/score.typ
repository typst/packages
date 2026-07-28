#import "render.typ": *

#let score-plugin = plugin("plugin.wasm")

// ---------------------------------------------------------------------------
// Diagnostics
// ---------------------------------------------------------------------------

#let _score-error(
  location,
  problem,
  value: auto,
  expected: none,
  fix: none,
) = {
  let message = "typed-scores error in " + location + ": " + problem
  if value != auto {
    message += "; got " + repr(value)
  }
  if expected != none {
    message += "; expected " + expected
  }
  if fix != none {
    message += "; fix: " + fix
  }
  panic(message)
}

#let _validate-plugin-response(response, location, sequence-str) = {
  if type(response) != dictionary {
    _score-error(
      location,
      "the parser returned malformed data",
      value: response,
      expected: "a typed-scores plugin response dictionary",
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  let ok = response.at("ok", default: none)
  if type(ok) != bool {
    _score-error(
      location,
      "the parser response is missing its boolean ok field",
      value: response,
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  if not ok {
    let parser-message = response.at("error", default: none)
    if type(parser-message) != str or parser-message.trim() == "" {
      _score-error(
        location,
        "the parser failed without an actionable message",
        value: response,
        fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
      )
    }
    _score-error(
      location,
      parser-message,
      value: sequence-str,
      fix: "correct the quoted notes token or delimiter using the syntax named above",
    )
  }
  let data = response.at("data", default: none)
  if (
    type(data) != dictionary
      or type(data.at("layouts", default: none)) != array
  ) {
    _score-error(
      location,
      "the parser returned an invalid layout payload",
      value: data,
      expected: "a dictionary containing a layouts array",
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  let anchor = data.at("anchor", default: none)
  let duration-anchor = data.at("duration_anchor", default: none)
  if (
    (anchor != none and type(anchor) != str)
      or (duration-anchor != none and type(duration-anchor) != str)
      or data.layouts.any(layout => type(layout) != dictionary)
  ) {
    _score-error(
      location,
      "the parser returned malformed layout state",
      value: data,
      expected: "dictionary layouts plus optional string anchors",
      fix: "rebuild or reinstall typed-scores so plugin.wasm matches the Typst sources",
    )
  }
  data
}

// ---------------------------------------------------------------------------
// Plugin calls
// ---------------------------------------------------------------------------

#let _layout-sequence(
  sequence-str,
  clef: "treble",
  time: none,
  anchor: none,
  duration-anchor: none,
  location: "notes",
) = {
  let anchor-str = if anchor == none { "" } else { anchor }
  let duration-anchor-str = if duration-anchor == none { "" } else { duration-anchor }
  let response = if time == none {
    json(score-plugin.layout_sequence_relative(bytes(
      (clef, "\n", anchor-str, "\n", duration-anchor-str, "\n", sequence-str).join(),
    )))
  } else {
    json(score-plugin.layout_sequence_timed_relative(bytes(
      (
        clef, "\n", time, "\n", anchor-str, "\n",
        duration-anchor-str, "\n", sequence-str,
      ).join(),
    )))
  }
  _validate-plugin-response(response, location, sequence-str)
}

// ---------------------------------------------------------------------------
// Layout constants (staff spaces)
// ---------------------------------------------------------------------------

#let _default-stem-length = 3.5 - stem-anchor-dy
#let _accidental-gap = 0.25
#let _dot-gap-from-head = 0.4
#let _dot-step = 0.55
#let _clef-advance = 3.45
#let _change-clef-scale = 0.72
#let _change-clef-advance = 2.35
#let _prologue-gap = 0.7
#let _content-lead-in = 1.2
#let _barline-clearance = 1.2
#let _repeat-side-clearance = 0.3
#let _system-repeat-start-gap = 1.7
#let _min-onset-step = 1.0
#let _grace-note-step = 1.05
#let _grace-main-gap = 0.42
#let _grace-notation-scale = 0.7071
#let _grace-stem-length-fraction = 0.80
#let _grace-beam-thickness = 0.384
#let _grace-beam-center-step = 0.648
#let _grace-stem-length = 3.5 * _grace-stem-length-fraction - stem-anchor-dy * _grace-notation-scale
#let _default-left-bar-x = 1.36
#let _group-symbol-to-bar-gap = 0.34
#let _system-clef-after-barline-gap = 0.8
#let _staff-label-to-group-gap = 0.6

#let _flat-order-positions = (
  treble: (8, 11, 7, 10, 6, 9, 5),
  bass: (6, 9, 5, 8, 4, 7, 3),
  alto: (7, 10, 6, 9, 5, 8, 4),
  tenor: (8, 11, 7, 10, 6, 9, 5),
)
#let _sharp-order-positions = (
  treble: (10, 7, 11, 8, 5, 9, 6),
  bass: (8, 5, 9, 6, 3, 7, 4),
  alto: (9, 6, 10, 7, 4, 8, 5),
  tenor: (10, 7, 11, 8, 5, 9, 6),
)

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let _duration-base(layout) = str(layout.duration.base)

#let _duration-denominator(layout) = {
  let base = _duration-base(layout)
  if base == "Whole" { 1 }
  else if base == "Half" { 2 }
  else if base == "Quarter" { 4 }
  else if base == "Eighth" { 8 }
  else if base == "Sixteenth" { 16 }
  else { 32 }
}

#let _single-tremolo-strokes(layout, subdivision) = {
  if subdivision == 8 { 1 }
  else if subdivision == 16 { 2 }
  else if subdivision == 32 { 3 }
  else { 4 }
}

#let _alternating-tremolo-strokes(layout, subdivision) = {
  let ratio = subdivision / _duration-denominator(layout)
  if ratio == 2 { 1 }
  else if ratio == 4 { 2 }
  else if ratio == 8 { 3 }
  else { 4 }
}

#let _stem-direction(positions) = {
  if positions.len() == 0 {
    "up"
  } else {
    let sum = 0
    for p in positions {
      sum += p
    }
    if sum / positions.len() < 6 { "up" } else { "down" }
  }
}

#let _layout-stem-direction(layout) = {
  let forced = layout.at("stem-direction", default: none)
  if forced != none { forced }
  else if layout.at("grace", default: false) { "up" }
  else { _stem-direction(layout.pitches.map(p => p.staff_position)) }
}

#let _clef-origin-y(clef, bottom-y: 0, line-gap: 1.0) = {
  if clef == "treble" { staff-y(4, bottom-y: bottom-y, line-gap: line-gap) }
  else if clef == "bass" { staff-y(8, bottom-y: bottom-y, line-gap: line-gap) }
  else if clef == "alto" { staff-y(6, bottom-y: bottom-y, line-gap: line-gap) }
  else if clef == "tenor" { staff-y(8, bottom-y: bottom-y, line-gap: line-gap) }
  else { panic("unknown clef " + clef) }
}

#let _head-half-width(layout) = {
  if layout.notehead == "whole" { 0.844 } else { notehead-half-width }
}

// Dots sit in the space above line notes.
#let _dot-y(position, y, line-gap) = {
  if calc.rem(position, 2) == 0 { y + line-gap / 2 } else { y }
}

#let _draw-dots(x, y, dots, unit: 8pt) = {
  for dot-index in range(dots) {
    draw-augmentation-dot(x + dot-index * _dot-step, y, unit: unit)
  }
}

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

#let _key-default-accidental(letter, key) = {
  let signature-accidentals = _key-accidentals(key)
  if signature-accidentals.count == 0 {
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

#let _draw-key-signature(clef, key, x, bottom-y: 0, unit: 8pt) = {
  let signature-accidentals = _key-accidentals(key)
  if signature-accidentals.count > 0 {
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

#let _draw-key-change(clef, previous-key, key, x, bottom-y: 0, unit: 8pt) = {
  let cancellation-indices = _key-cancellation-indices(previous-key, key)
  let cursor = x
  if cancellation-indices.len() > 0 {
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
      )
    }
    cursor += cancellation-indices.len() * _key-accidental-step("Natural")
    if _key-signature-width(key) > 0 {
      cursor += _key-cancellation-gap
    }
  }
  _draw-key-signature(clef, key, cursor, bottom-y: bottom-y, unit: unit)
}

// ---------------------------------------------------------------------------
// Prologue (clef + key + time) geometry
// ---------------------------------------------------------------------------

// Absolute x where measure content coordinate 0 begins on the first
// measure of a system.
#let _prologue-start-x(key, time, previous-key: none, staff-x: 0, clef-x: 0.35) = {
  let x = clef-x + _clef-advance
  let key-width = _key-change-width(previous-key, key)
  if key-width > 0 { x += key-width + _prologue-gap }
  let time-width = time-signature-width(time)
  if time-width > 0 { x += time-width + _prologue-gap }
  x + _content-lead-in
}

#let _draw-prologue(clef, key, time, previous-key: none, bottom-y: 0, unit: 8pt, staff-x: 0, clef-x: 0.35) = {
  draw-clef(clef, clef-x, _clef-origin-y(clef, bottom-y: bottom-y), unit: unit)
  let x = clef-x + _clef-advance
  _draw-key-change(clef, previous-key, key, x, bottom-y: bottom-y, unit: unit)
  let key-width = _key-change-width(previous-key, key)
  if key-width > 0 { x += key-width + _prologue-gap }
  draw-time-signature(time, x, bottom-y: bottom-y, unit: unit)
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
) = {
  let x = measure-start + 0.8
  if show-clef {
    draw-clef(
      clef,
      x,
      _clef-origin-y(clef, bottom-y: bottom-y),
      unit: unit,
      scale: _change-clef-scale,
    )
  }
  if show-clef or reserve-clef { x += _change-clef-advance + _prologue-gap }
  if show-key {
    _draw-key-change(clef, previous-key, key, x, bottom-y: bottom-y, unit: unit)
    let key-width = _key-change-width(previous-key, key)
    if key-width > 0 { x += key-width + _prologue-gap }
  }
  if show-time {
    draw-time-signature(time, x, bottom-y: bottom-y, unit: unit)
  }
}

// ---------------------------------------------------------------------------
// Horizontal spacing: onset-aligned positions shared by all voices
// ---------------------------------------------------------------------------

// Seconds (and unisons) inside one chord cannot share a column: the upper
// note of each clashing pair sits on the right of the stem while the lower
// keeps the left, so for up-stems the displaced head crosses to the right
// and for down-stems to the left, alternating through longer clusters.
// Returns x offsets parallel to layout.pitches; displaced heads share the
// stem line with their neighbors.
#let _cluster-offsets(layout, direction) = {
  let offsets = layout.pitches.map(_ => 0.0)
  if layout.pitches.len() < 2 { return offsets }
  let order = ()
  for (pitch-index, positioned-pitch) in layout.pitches.enumerate() {
    order.push((index: pitch-index, pos: positioned-pitch.staff_position))
  }
  let order = order.sorted(key: e => e.pos)
  let shift = 2 * (_head-half-width(layout) - stem-thickness / 2)
  if not layout.stem { shift = 2 * _head-half-width(layout) }
  let walk = if direction == "up" { order } else { order.rev() }
  let sign = if direction == "up" { 1 } else { -1 }
  let previous = none
  let previous-displaced = false
  for entry in walk {
    let displaced = (
      previous != none
        and calc.abs(entry.pos - previous) <= 1
        and not previous-displaced
    )
    if displaced { offsets.at(entry.index) = sign * shift }
    previous = entry.pos
    previous-displaced = displaced
  }
  offsets
}

// Vertical ink extents of an accidental glyph (above, below) relative to
// the notehead center it modifies, in staff spaces.
#let _accidental-extent(kind) = {
  if kind == "Sharp" { (1.4, 1.4) } else if kind == "Flat" { (1.76, 0.7) } else if kind == "Natural" { (1.37, 1.34) } else if kind == "DoubleSharp" { (0.51, 0.5) } else { (1.75, 0.7) }
}

// Column-packed accidentals for one event (Gould): working from the
// outside in - topmost first, then bottommost - each accidental takes the
// column nearest the noteheads where it fits without vertical overlap.
// Returns per-pitch glyph placements (distance from the gap edge left of
// the noteheads to the glyph's left edge) and the total width the
// accidentals claim, including the gap to the noteheads.
#let _accidental-plan(layout, key) = {
  let overrides = layout.at("visible-accidentals", default: none)
  let entries = ()
  for (pitch-index, positioned-pitch) in layout.pitches.enumerate() {
    let override = if overrides == none { auto } else { overrides.at(pitch-index) }
    let kind = if override != auto {
      override
    } else if _key-alters-natural(positioned-pitch.pitch, key) {
      "Natural"
    } else if (
      positioned-pitch.pitch.accidental != "Natural"
        and not _key-suppresses-accidental(positioned-pitch.pitch, key)
    ) {
      positioned-pitch.pitch.accidental
    } else {
      none
    }
    if kind != none {
      entries.push((
        index: pitch-index,
        kind: kind,
        y: positioned-pitch.staff_position / 2,
      ))
    }
  }
  if entries.len() == 0 { return (placements: (:), total: 0) }
  let entries = entries.sorted(key: e => -e.y)
  let order = ()
  let lo = 0
  let hi = entries.len() - 1
  while lo <= hi {
    order.push(entries.at(lo))
    if hi != lo { order.push(entries.at(hi)) }
    lo += 1
    hi -= 1
  }
  let columns = ()
  let assignment = ()
  for entry in order {
    let (top, bottom) = _accidental-extent(entry.kind)
    let placed = none
    for (c, members) in columns.enumerate() {
      let fits = members.all(m => {
        let (m-top, m-bottom) = _accidental-extent(m.kind)
        entry.y - bottom >= m.y + m-top + 0.1 or entry.y + top <= m.y - m-bottom - 0.1
      })
      if placed == none and fits { placed = c }
    }
    if placed == none {
      columns.push((entry,))
      placed = columns.len() - 1
    } else {
      columns.at(placed).push(entry)
    }
    assignment.push((entry: entry, column: placed))
  }
  let column-widths = columns.map(members => calc.max(..members.map(m => accidental-width(m.kind))))
  let placements = (:)
  for a in assignment {
    let before = 0
    for c in range(a.column) { before += column-widths.at(c) + 0.08 }
    placements.insert(str(a.entry.index), (
      kind: a.entry.kind,
      dx: before + accidental-width(a.entry.kind),
    ))
  }
  (
    placements: placements,
    total: _accidental-gap + column-widths.sum() + 0.08 * (column-widths.len() - 1),
  )
}

// Space needed to the left of the notehead center (accidental columns,
// left-displaced cluster heads, wider whole-note heads).
#let _left-pad(layout, key) = {
  let pad = _head-half-width(layout) - notehead-half-width
  if not layout.rest and layout.pitches.len() > 1 {
    let offsets = _cluster-offsets(layout, _stem-direction(layout.pitches.map(p => p.staff_position)))
    pad += -calc.min(..offsets, 0)
  }
  let arpeggio-pad = if layout.annotations.any(mark => str(mark) == "arpeggio" or str(mark).starts-with("arpeggio=")) { 0.95 } else { 0 }
  pad + _accidental-plan(layout, key).total + arpeggio-pad
}

// Space the event's own ink needs to the right of the notehead center.
#let _right-extent(layout, beamed) = {
  let x = _head-half-width(layout)
  if not layout.rest and layout.pitches.len() > 1 {
    let offsets = _cluster-offsets(layout, _stem-direction(layout.pitches.map(p => p.staff_position)))
    x += calc.max(..offsets, 0)
  }
  if layout.duration.dots > 0 {
    x += _dot-gap-from-head + layout.duration.dots * _dot-step
  }
  if layout.flags > 0 and not beamed {
    x += 1.1
  }
  if layout.rest { x += rest-width(_duration-base(layout)) }
  x
}

// Classical duration spacing (Ross): the measure's shortest duration gets a
// fixed two-unit width, and every doubling of duration adds one more unit,
// so space grows with the logarithm of duration rather than proportionally.
// `note-spacing` remains the user-facing density knob: it is the width a
// quarter note receives in a bar of quarters.
#let _duration-spacing(layout, note-spacing, shortest) = {
  let duration-value = layout.duration_value.numerator / layout.duration_value.denominator
  let spacing-unit = note-spacing / 2
  spacing-unit * (2 + calc.log(calc.max(duration-value / shortest, 1), base: 2))
}

#let _event-rhythmic-advance(layout, note-spacing, shortest, beamed) = {
  calc.max(
    _duration-spacing(layout, note-spacing, shortest),
    _right-extent(layout, beamed) + 1.1,
  )
}

#let _is-beamed(layout, beams) = {
  beams and layout.at("beam_group", default: none) != none
}

// Exact integer key for an onset rational (all durations divide 4096).
#let _onset-key(onset) = {
  int(onset.numerator * 4096 / onset.denominator)
}

// Compute shared x positions for every distinct onset across all voices
// of one measure, in content coordinates (0 = measure content start).
// Returns (positions: onset-key -> x, width: total content width).
// A compact estimate keeps adjacent onset-anchored chord symbols from
// colliding when a harmony change falls between note onsets. The score's
// musical spacing still supplies the final position; this only adds the
// text's required clearance.
#let _harmony-width(symbol) = 0.75 * symbol.clusters().len() + 1.2

#let _measure-positions(
  voices-layouts,
  harmony: (),
  note-spacing: 3.1,
  beams: false,
  key: "C",
) = {
  let first-onset-x = 0
  let has-polyphony = voices-layouts.any(layouts => layouts.any(layout => (
    layout.at("stem-direction", default: none) != none
  )))
  let onset-keys = ()
  let seen-onsets = (:)
  // The measure's shortest sounding duration sets the spacing unit. It is
  // clamped so extreme subdivisions cannot collapse or explode the scale.
  let shortest-duration-value = 1.0
  for layouts in voices-layouts {
    let main-layouts = layouts.filter(layout => not layout.at("grace", default: false))
    if main-layouts.len() > 0 {
      let first = main-layouts.first()
      first-onset-x = calc.max(
        first-onset-x,
        _left-pad(first, key) + first.at("grace_before", default: 0) * _grace-note-step + _grace-main-gap,
      )
    }
    for layout in main-layouts {
      let duration-value = layout.duration_value.numerator / layout.duration_value.denominator
      shortest-duration-value = calc.min(shortest-duration-value, duration-value)
      let onset-key = _onset-key(layout.onset)
      if str(onset-key) not in seen-onsets {
        seen-onsets.insert(str(onset-key), true)
        onset-keys.push(onset-key)
      }
    }
  }
  for layout in harmony {
    let onset-key = _onset-key(layout.onset)
    if str(onset-key) not in seen-onsets {
      seen-onsets.insert(str(onset-key), true)
      onset-keys.push(onset-key)
    }
  }
  if harmony.len() > 0 {
    // The first symbol is centered on its onset, so reserve its left half
    // before the first note column and keep it clear of the system material.
    first-onset-x = calc.max(
      first-onset-x,
      _harmony-width(harmony.first().symbol) / 2 + 0.35,
    )
  }
  shortest-duration-value = calc.clamp(shortest-duration-value, 1 / 32, 1 / 4)
  onset-keys = onset-keys.sorted()

  // For each onset, the spacing constraints imposed by events that end
  // there: x[onset] >= x[event onset] + advance(event) + left pad of next.
  let demands-by-ending-onset = (:)
  let measure-end-demands = ()
  for layouts in voices-layouts {
    let main-layouts = layouts.filter(layout => not layout.at("grace", default: false))
    for layout-index in range(main-layouts.len()) {
      let layout = main-layouts.at(layout-index)
      let current-onset-key = _onset-key(layout.onset)
      if layout-index + 1 < main-layouts.len() {
        let event-advance = _event-rhythmic-advance(
          layout,
          note-spacing,
          shortest-duration-value,
          _is-beamed(layout, beams),
        )
        let next-layout = main-layouts.at(layout-index + 1)
        let next-onset-key = str(_onset-key(next-layout.onset))
        let grace-width = next-layout.at("grace_before", default: 0) * _grace-note-step + (
          if next-layout.at("grace_before", default: 0) > 0 { _grace-main-gap } else { 0 }
        )
        let demand = (
          from: current-onset-key,
          distance: event-advance + _left-pad(next-layout, key) + grace-width,
        )
        if next-onset-key in demands-by-ending-onset {
          demands-by-ending-onset.at(next-onset-key).push(demand)
        } else {
          demands-by-ending-onset.insert(next-onset-key, (demand,))
        }
      } else {
        // Measure content ends at the same ink-to-barline clearance that the
        // next signature-free measure uses before its first event.
        let distance = (
          _right-extent(layout, _is-beamed(layout, beams))
          + _barline-clearance
          + if has-polyphony { 1.15 } else { 0 }
        )
        measure-end-demands.push((from: current-onset-key, distance: distance))
      }
    }
  }
  for harmony-index in range(harmony.len()) {
    let layout = harmony.at(harmony-index)
    let width = _harmony-width(layout.symbol)
    let distance = if harmony-index + 1 < harmony.len() {
      let next-width = _harmony-width(harmony.at(harmony-index + 1).symbol)
      // Both symbols are centered on their onset columns. Preserve the
      // existing rhythmic clearance and add enough room for their extents.
      calc.max(width, (width + next-width) / 2 + 0.35)
    } else {
      width
    }
    let demand = (from: _onset-key(layout.onset), distance: distance)
    if harmony-index + 1 < harmony.len() {
      let next-key = str(_onset-key(harmony.at(harmony-index + 1).onset))
      if next-key in demands-by-ending-onset {
        demands-by-ending-onset.at(next-key).push(demand)
      } else {
        demands-by-ending-onset.insert(next-key, (demand,))
      }
    } else {
      measure-end-demands.push(demand)
    }
  }

  let positions = (:)
  let previous-onset-x = none
  for onset-key in onset-keys {
    let x = if previous-onset-x == none {
      first-onset-x
    } else {
      previous-onset-x + _min-onset-step
    }
    for demand in demands-by-ending-onset.at(str(onset-key), default: ()) {
      x = calc.max(x, positions.at(str(demand.from)) + demand.distance)
    }
    positions.insert(str(onset-key), x)
    previous-onset-x = x
  }

  let width = if previous-onset-x == none { 0 } else { previous-onset-x }
  for demand in measure-end-demands {
    width = calc.max(width, positions.at(str(demand.from)) + demand.distance)
  }
  (positions: positions, width: width)
}

// Place one voice's layouts at the shared onset positions.
#let _polyphony-clash(left-layout, right-layout) = {
  if left-layout.rest or right-layout.rest { return false }
  let left-positions = left-layout.pitches.map(pitch => pitch.staff_position)
  let right-positions = right-layout.pitches.map(pitch => pitch.staff_position)
  let exact-unison = (
    left-layout.notehead == right-layout.notehead
      and left-positions.sorted() == right-positions.sorted()
  )
  if exact-unison { return false }
  left-positions.any(
    left-position => right-positions.any(
      right-position => calc.abs(left-position - right-position) <= 1,
    ),
  )
}

#let _polyphony-shift(layout, voice, all-voices) = {
  if voice == none or voice.layer-count == 1 or voice.layer-index == 0 or layout.at("grace", default: false) {
    return 0
  }
  for sibling in all-voices {
    if sibling.staff-index == voice.staff-index and sibling.layer-index < voice.layer-index {
      for other in sibling.layouts {
        if other.onset == layout.onset and _polyphony-clash(layout, other) {
          let rank = calc.floor(voice.layer-index / 2) + 1
          return if calc.rem(voice.layer-index, 2) == 1 { 1.10 * rank } else { -1.10 * rank }
        }
      }
    }
  }
  0
}

#let _place-voice-at-onsets(layouts, positions, note-start, scale: 1.0, voice: none, all-voices: ()) = {
  layouts.map(layout => {
    let base = note-start + positions.at(str(_onset-key(layout.onset))) * scale
    let grace-shift = if layout.at("grace", default: false) {
      -(layout.grace_count - layout.grace_index) * _grace-note-step - _grace-main-gap
    } else { 0 }
    (
      layout: layout,
      x: base + grace-shift + _polyphony-shift(layout, voice, all-voices),
    )
  })
}

// ---------------------------------------------------------------------------
// Drawing events
// ---------------------------------------------------------------------------

#let _draw-notated-event(
  layout,
  x: 0,
  bottom-y: 0,
  line-gap: 1.0,
  unit: 8pt,
  suppress-flags: false,
  stem-length-override: none,
  stem-direction-override: none,
  key: "C",
) = {
  import cetz.draw: *
  let notation-scale = if layout.at("grace", default: false) { _grace-notation-scale } else { 1.0 }
  if layout.rest {
    let rest-bottom = bottom-y + layout.at("rest-offset", default: 0)
    draw-rest(_duration-base(layout), x, bottom-y: rest-bottom, line-gap: line-gap, unit: unit)
    let dot-x = x + rest-width(_duration-base(layout)) + _dot-gap-from-head
    _draw-dots(dot-x, rest-bottom + 2.5 * line-gap, layout.duration.dots, unit: unit)
  } else {
    let positions = layout.pitches.map(p => p.staff_position)
    let y-values = positions.map(p => staff-y(p, bottom-y: bottom-y, line-gap: line-gap))
    let direction = if stem-direction-override == none {
      _layout-stem-direction(layout)
    } else {
      stem-direction-override
    }
    let head-half-width = _head-half-width(layout) * notation-scale
    let accidental-plan = _accidental-plan(layout, key)
    let cluster-offsets = _cluster-offsets(layout, direction)
    let left-spread = -calc.min(..cluster-offsets, 0)
    let right-spread = calc.max(..cluster-offsets, 0)
    let ledger-left-extension = layout.at(
      "ledger-left-extension",
      default: ledger-extension * notation-scale,
    )
    let ledger-right-extension = layout.at(
      "ledger-right-extension",
      default: ledger-extension * notation-scale,
    )

    for (pitch-index, positioned-pitch) in layout.pitches.enumerate() {
      let staff-position = positioned-pitch.staff_position
      let notehead-y = y-values.at(pitch-index)
      let head-x = x + cluster-offsets.at(pitch-index)
      draw-ledger-lines(
        head-x,
        staff-position,
        bottom-y: bottom-y,
        line-gap: line-gap,
        head-half-width: head-half-width,
        left-extension: ledger-left-extension,
        right-extension: ledger-right-extension,
        unit: unit,
      )
      let placement = accidental-plan.placements.at(str(pitch-index), default: none)
      if placement != none {
        draw-accidental(
          placement.kind,
          x - left-spread - head-half-width - _accidental-gap - placement.dx,
          notehead-y,
          unit: unit,
          scale: notation-scale,
        )
      }
      if layout.notehead == "whole" {
        draw-whole-notehead(head-x, notehead-y, unit: unit, scale: notation-scale)
      } else if layout.notehead == "half" {
        draw-open-notehead(head-x, notehead-y, unit: unit, scale: notation-scale)
      } else {
        draw-filled-notehead(head-x, notehead-y, unit: unit, scale: notation-scale)
      }
      let dot-x = x + right-spread + head-half-width + _dot-gap-from-head + 0.2
      for dot-index in range(layout.duration.dots) {
        draw-augmentation-dot(
          dot-x + dot-index * _dot-step * notation-scale,
          _dot-y(staff-position, notehead-y, line-gap),
          unit: unit,
          scale: notation-scale,
        )
      }
    }

    let tremolo = none
    for mark in layout.annotations {
      let annotation-text = str(mark)
      if annotation-text.starts-with("tremolo=") {
        tremolo = int(annotation-text.slice(8))
      }
    }
    if layout.stem or layout.at("alternating_tremolo", default: false) {
      let low-y = calc.min(..y-values)
      let high-y = calc.max(..y-values)
      let stem-start-y = if direction == "up" { low-y } else { high-y }
      let stem-length = if stem-length-override == none {
        (high-y - low-y) + if notation-scale < 1 { _grace-stem-length } else { _default-stem-length }
      } else {
        stem-length-override
      }
      if tremolo != none and stem-length-override == none {
        let strokes = _single-tremolo-strokes(layout, tremolo)
        // Four StemTremolo strips require one extra inter-strip step so the
        // head-side strip retains LilyPond's clearance from the notehead.
        if strokes == 4 { stem-length += 0.82 }
      }
      draw-stem(x, stem-start-y, direction: direction, length: stem-length, unit: unit, glyph-scale: notation-scale)
      if tremolo != none {
        let strokes = _single-tremolo-strokes(layout, tremolo)
        let sign = if direction == "up" { 1 } else { -1 }
        let stem-x = x + sign * stem-center-offset(scale: notation-scale)
        let tip-y = stem-tip(
          x,
          stem-start-y,
          direction: direction,
          length: stem-length,
          glyph-scale: notation-scale,
        ).at(1)
        // LilyPond anchors the strip cluster at the stem tip. At the stem
        // edge, the nearest strip center is 0.6225 spaces inward; additional
        // strips progress toward the notehead in 0.81-space steps.
        let near-tip-y = tip-y - sign * 0.6225 - if direction == "up" { 0.375 } else { 0 }
        for stroke-index in range(strokes) {
          let y = near-tip-y - sign * (strokes - 1 - stroke-index) * 0.81
          draw-stem-tremolo(stem-x, y, unit: unit)
        }
      }
      if layout.flags > 0 and not suppress-flags {
        let tip = stem-tip(x, stem-start-y, direction: direction, length: stem-length, glyph-scale: notation-scale)
        draw-flag(tip.at(0), tip.at(1), direction: direction, count: layout.flags, unit: unit, scale: notation-scale)
      }
    } else if tremolo != none {
      let strokes = _single-tremolo-strokes(layout, tremolo)
      for stroke-index in range(strokes) {
        let y = calc.max(..y-values) + 0.8 + stroke-index * 0.81
        draw-stem-tremolo(x, y, unit: unit)
      }
    }
    let arpeggio-direction = none
    for mark in layout.annotations {
      let annotation-text = str(mark)
      if annotation-text == "arpeggio" { arpeggio-direction = "normal" }
      if annotation-text.starts-with("arpeggio=") {
        arpeggio-direction = annotation-text.slice(9)
      }
    }
    if arpeggio-direction != none {
      draw-arpeggio(
        x - left-spread - head-half-width - accidental-plan.total - 0.52,
        calc.min(..y-values),
        calc.max(..y-values),
        direction: arpeggio-direction,
        unit: unit,
      )
    }
  }
}

// Stem tip and geometry of an event; alternating tremolos add stems to whole notes.
#let _event-stem-geometry(layout, x, bottom-y: 0, line-gap: 1.0, direction-override: none) = {
  if layout.rest or (not layout.stem and not layout.at("alternating_tremolo", default: false)) {
    none
  } else {
    let positions = layout.pitches.map(p => p.staff_position)
    let direction = if direction-override == none { _layout-stem-direction(layout) } else { direction-override }
    let y-values = positions.map(p => staff-y(p, bottom-y: bottom-y, line-gap: line-gap))
    let low-y = calc.min(..y-values)
    let high-y = calc.max(..y-values)
    let stem-start-y = if direction == "up" { low-y } else { high-y }
    let notation-scale = if layout.at("grace", default: false) { _grace-notation-scale } else { 1.0 }
    let stem-length = (high-y - low-y) + if notation-scale < 1 { _grace-stem-length } else { _default-stem-length }
    // Ledger-line notes: the stem always reaches the middle staff line.
    let middle-y = bottom-y + 2 * line-gap
    if direction == "up" {
      let tip = stem-start-y + stem-anchor-dy + stem-length
      stem-length += calc.max(middle-y - tip, 0)
    } else {
      let tip = stem-start-y - stem-anchor-dy - stem-length
      stem-length += calc.max(tip - middle-y, 0)
    }
    (
      point: stem-tip(x, stem-start-y, direction: direction, length: stem-length, glyph-scale: notation-scale),
      direction: direction,
      flags: layout.flags,
    )
  }
}

// ---------------------------------------------------------------------------
// Beam groups
// ---------------------------------------------------------------------------

#let _ideal-beamed-stem = 3.25
#let _min-beamed-stem = 2.5
#let _beam-stub-length = 0.75

// Beam slant grows with the interval between the outer notes, in
// quarter-space steps, and never exceeds one staff space (Ross).
#let _beam-ideal-rise(dy) = {
  let magnitude = calc.abs(dy)
  let rise = if magnitude < 0.01 { 0.0 } else if magnitude <= 0.5 { 0.25 } else if magnitude <= 1.0 { 0.5 } else if magnitude <= 1.75 { 0.75 } else { 1.0 }
  if dy < 0 { -rise } else { rise }
}

#let _draw-beam-group(group, bottom-y: 0, line-gap: 1.0, unit: 8pt, key: "C") = {
  if group.len() == 0 { return }
  if group.len() == 1 {
    let item = group.first()
    _draw-notated-event(item.layout, x: item.x, bottom-y: bottom-y, unit: unit, key: key)
    return
  }

  let all-positions = ()
  for item in group {
    for pitch in item.layout.pitches {
      all-positions.push(pitch.staff_position)
    }
  }
  let forced-direction = if group.first().layout.at("grace", default: false) {
    "up"
  } else {
    group.first().layout.at("stem-direction", default: none)
  }
  let direction = if forced-direction == none { _stem-direction(all-positions) } else { forced-direction }
  let sign = if direction == "up" { 1 } else { -1 }
  let is-grace = group.first().layout.at("grace", default: false)
  let notation-scale = if is-grace { _grace-notation-scale } else { 1.0 }
  let stem-length-scale = if is-grace { _grace-stem-length-fraction } else { 1.0 }
  let local-beam-thickness = if is-grace { _grace-beam-thickness } else { beam-thickness }
  let beam-center-step = if is-grace { _grace-beam-center-step } else { beam-thickness + beam-spacing }

  let items = group.map(item => {
    let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y, line-gap: line-gap))
    (
      layout: item.layout,
      x: item.x,
      sx: item.x + sign * stem-center-offset(scale: notation-scale),
      base-y: if direction == "up" { calc.min(..y-values) } else { calc.max(..y-values) },
      extreme-y: if direction == "up" { calc.max(..y-values) } else { calc.min(..y-values) },
      flags: item.layout.flags,
    )
  })

  // Beam slant: flat when an inner note reaches past both outer notes on
  // the beam side (a concave contour takes a horizontal beam); otherwise
  // the slant follows the outer interval in quarter-space steps.
  let first = items.first()
  let last = items.last()
  let dx = last.sx - first.sx
  let outer-limit = calc.max(sign * first.extreme-y, sign * last.extreme-y)
  let inner-beyond = range(1, items.len() - 1).any(i => (
    sign * items.at(i).extreme-y > outer-limit - 0.01
  ))
  let rise = if inner-beyond { 0.0 } else {
    _beam-ideal-rise(last.extreme-y - first.extreme-y)
  }
  let slope = if dx == 0 { 0 } else { rise / dx }

  // Place the beam so every stem keeps a workable length.
  let intercept = none
  for item in items {
    let by-base = item.base-y + sign * ((item.extreme-y - item.base-y) * sign + _ideal-beamed-stem * stem-length-scale) - slope * item.sx
    let by-extreme = item.extreme-y + sign * _min-beamed-stem * stem-length-scale - slope * item.sx
    let candidate = if direction == "up" { calc.max(by-base, by-extreme) } else { calc.min(by-base, by-extreme) }
    intercept = if intercept == none {
      candidate
    } else if direction == "up" {
      calc.max(intercept, candidate)
    } else {
      calc.min(intercept, candidate)
    }
  }

  // Quantize the first beam end against the staff: inside the staff a beam
  // end sits on, straddles, or hangs from a line (quarter-space grid,
  // never centered in a space). The snap moves away from the noteheads so
  // stems can only lengthen, keeping the minimum-length guarantee.
  let end-y = slope * first.sx + intercept
  if end-y > bottom-y - 0.5 and end-y < bottom-y + 4.5 {
    let rel = (end-y - bottom-y) * 4
    let quant = if sign > 0 { calc.ceil(rel - 0.001) } else { calc.floor(rel + 0.001) }
    if calc.rem(calc.rem(quant, 4) + 4, 4) == 2 { quant += sign }
    intercept += bottom-y + quant / 4 - end-y
  }

  let beam-y(sx) = slope * sx + intercept

  for item in items {
    let tip-y = beam-y(item.sx)
    let length = sign * (tip-y - item.base-y) - stem-anchor-dy * notation-scale
    _draw-notated-event(
      item.layout,
      x: item.x,
      bottom-y: bottom-y,
      unit: unit,
      suppress-flags: true,
      stem-length-override: length,
      stem-direction-override: direction,
      key: key,
    )
  }

  // Beam centers step inward (toward the noteheads) from the stem tips.
  let level-offset(level) = -sign * (local-beam-thickness / 2 + level * beam-center-step)

  // Full segments between neighbors.
  for item-index in range(items.len() - 1) {
    let left-item = items.at(item-index)
    let right-item = items.at(item-index + 1)
    let count = calc.min(left-item.flags, right-item.flags)
    for level in range(count) {
      let dy = level-offset(level)
      draw-beam(
        (left-item.sx, beam-y(left-item.sx) + dy),
        (right-item.sx, beam-y(right-item.sx) + dy),
        thickness: local-beam-thickness,
      )
    }
  }

  // Stubs for notes with more flags than both neighbors share.
  for item-index in range(items.len()) {
    let item = items.at(item-index)
    let left = if item-index > 0 {
      calc.min(items.at(item-index - 1).flags, item.flags)
    } else {
      0
    }
    let right = if item-index + 1 < items.len() {
      calc.min(items.at(item-index + 1).flags, item.flags)
    } else {
      0
    }
    let covered = calc.max(left, right)
    if item.flags > covered {
      let toward-left = item-index > 0
      let x2 = if toward-left { item.sx - _beam-stub-length * stem-length-scale } else { item.sx + _beam-stub-length * stem-length-scale }
      for level in range(covered, item.flags) {
        let dy = level-offset(level)
        draw-beam((item.sx, beam-y(item.sx) + dy), (x2, beam-y(x2) + dy), thickness: local-beam-thickness)
      }
    }
  }
}

// Draw a placed voice, joining beam groups computed by the plugin.
#let _resolve-measure-accidentals(placed, key, tied-from-previous: false) = {
  let state = (:)
  let resolved-events = ()
  for item in placed {
    let visible = ()
    for pitch in item.layout.pitches {
      let pitch-key = pitch.pitch.letter + str(pitch.pitch.octave)
      let current = state.at(
        pitch-key,
        default: _key-default-accidental(pitch.pitch.letter, key),
      )
      let actual = pitch.pitch.accidental
      if tied-from-previous and resolved-events.len() == 0 {
        visible.push(none)
        state.insert(pitch-key, actual)
      } else if actual == current {
        visible.push(none)
      } else {
        visible.push(actual)
        state.insert(pitch-key, actual)
      }
    }
    resolved-events.push((
      x: item.x,
      layout: item.layout + (visible-accidentals: visible,),
    ))
  }
  resolved-events
}

#let _layout-ledger-levels(layout) = {
  if layout.rest { return () }
  let levels = ()
  for pitch in layout.pitches {
    let position = pitch.staff_position
    let pitch-levels = if position <= 0 {
      range(0, position - 1, step: -2)
    } else if position >= 12 {
      range(12, position + 1, step: 2)
    } else {
      ()
    }
    for level in pitch-levels {
      if level not in levels { levels.push(level) }
    }
  }
  levels
}

#let _ledger-column-span(item) = {
  let layout = item.layout
  let scale = if layout.at("grace", default: false) { _grace-notation-scale } else { 1.0 }
  let direction = _layout-stem-direction(layout)
  let offsets = _cluster-offsets(layout, direction)
  let head-half = _head-half-width(layout) * scale
  (
    left: item.x + calc.min(..offsets, 0) - head-half,
    right: item.x + calc.max(..offsets, 0) + head-half,
    extension: ledger-extension * scale,
    levels: _layout-ledger-levels(layout),
  )
}

// LilyPond's LedgerLineSpanner considers neighboring note columns together.
// Shorten facing ledger extensions when two columns use the same ledger level,
// leaving a small break instead of allowing separate segments to merge.
#let _resolve-ledger-clearance(placed) = {
  let plans = placed.map(item => {
    let span = _ledger-column-span(item)
    (left: span.extension, right: span.extension, span: span)
  })
  let gap = 0.16
  for item-index in range(placed.len() - 1) {
    let left = plans.at(item-index)
    let right = plans.at(item-index + 1)
    if left.span.levels.any(level => level in right.span.levels) {
      let available = calc.max(0, right.span.left - left.span.right - gap)
      let requested = left.right + right.left
      if requested > available and requested > 0 {
        let scale = available / requested
        plans.at(item-index) = left + (right: left.right * scale,)
        plans.at(item-index + 1) = right + (left: right.left * scale,)
      }
    }
  }
  range(placed.len()).map(i => {
    let item = placed.at(i)
    let plan = plans.at(i)
    item + (layout: item.layout + (
      ledger-left-extension: plan.left,
      ledger-right-extension: plan.right,
    ),)
  })
}

#let _draw-grace-details(placed, bottom-y: 0, unit: 8pt) = {
  import cetz.draw: *
  let groups = (:)
  for item in placed {
    if item.layout.at("grace", default: false) {
      let key = str(item.layout.grace_group)
      if key not in groups { groups.insert(key, ()) }
      groups.at(key).push(item)
    }
  }
  for group in groups.values() {
    let first = group.first()
    let last = group.last()
    let main = placed.find(item => (
      not item.layout.at("grace", default: false) and item.layout.onset == last.layout.onset
    ))
    let style = first.layout.grace_style
    // LilyPond implements the acciaccatura stroke as a flag style. A beamed
    // multi-note group therefore has no stroke; only a single flagged grace
    // note receives one.
    if style == "acciaccatura" and group.len() == 1 and first.layout.flags > 0 {
      let stem = _event-stem-geometry(first.layout, first.x, bottom-y: bottom-y)
      if stem != none {
        let sign = if stem.direction == "up" { 1 } else { -1 }
        let y = stem.point.at(1) - sign * 1.02
        line(
          (stem.point.at(0) - 0.47, y - 0.42),
          (stem.point.at(0) + 0.67, y + 0.42),
          stroke: 0.20 * unit + black,
        )
      }
    }
    if main != none and style in ("acciaccatura", "appoggiatura") and not main.layout.rest {
      let grace-y = calc.min(..first.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y)))
      let main-y = calc.min(..main.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y)))
      // LilyPond leaves visible white between a grace slur's tapered tips and
      // both notehead outlines. Grace heads scale the regular half-space
      // extent; the remaining clearance is just under half a staff space.
      let tip-clearance = 0.48
      draw-bow(
        (first.x - 0.08, grace-y - (0.5 * _grace-notation-scale + tip-clearance)),
        (main.x - 0.13, main-y - (0.5 + tip-clearance)),
        direction-sign: -1,
        height: 0.55,
        maximum-control-height: 1.2,
        unit: unit,
      )
    }
  }
}

#let _draw-alternating-tremolos(placed, bottom-y: 0, unit: 8pt) = {
  for item in placed {
    for tremolo in item.layout.at("tremolo_starts", default: ()) {
      let end = placed.at(tremolo.end_index)
      let first-stem = _event-stem-geometry(item.layout, item.x, bottom-y: bottom-y)
      let last-stem = _event-stem-geometry(end.layout, end.x, bottom-y: bottom-y)
      if first-stem != none and last-stem != none {
        let strokes = _alternating-tremolo-strokes(item.layout, tremolo.subdivision)
        let direction = first-stem.direction
        let sign = if direction == "up" { 1 } else { -1 }
        for stroke-index in range(strokes) {
          let offset = -sign * stroke-index * 0.48
          draw-beam(
            (first-stem.point.at(0), first-stem.point.at(1) + offset),
            (last-stem.point.at(0), last-stem.point.at(1) + offset),
            thickness: 0.30,
          )
        }
      }
    }
  }
}

#let _beam-group-visible(group, beams) = {
  beams or group.any(item => item.layout.at("grace", default: false)) or group.any(item => item.layout.at("beam_join_before", default: false))
}

#let _draw-placed-sequence(
  placed,
  bottom-y: 0,
  unit: 8pt,
  beams: false,
  key: "C",
  tied-from-previous: false,
) = {
  let placed = _resolve-measure-accidentals(placed, key, tied-from-previous: tied-from-previous)
  let placed = _resolve-ledger-clearance(placed)
  let event-index = 0
  while event-index < placed.len() {
    let item = placed.at(event-index)
    let group-id = item.layout.at("beam_group", default: none)
    if group-id != none {
      let group = (item,)
      let group-end-index = event-index + 1
      while (
        group-end-index < placed.len()
          and placed.at(group-end-index).layout.at("beam_group", default: none)
            == group-id
      ) {
        group.push(placed.at(group-end-index))
        group-end-index += 1
      }
      if _beam-group-visible(group, beams) {
        _draw-beam-group(group, bottom-y: bottom-y, unit: unit, key: key)
      } else {
        for member in group {
          _draw-notated-event(
            member.layout,
            x: member.x,
            bottom-y: bottom-y,
            unit: unit,
            key: key,
          )
        }
      }
      event-index = group-end-index
    } else {
      _draw-notated-event(
        item.layout,
        x: item.x,
        bottom-y: bottom-y,
        unit: unit,
        suppress-flags: item.layout.at("alternating_tremolo", default: false),
        key: key,
      )
      event-index += 1
    }
  }
  _draw-grace-details(placed, bottom-y: bottom-y, unit: unit)
  _draw-alternating-tremolos(placed, bottom-y: bottom-y, unit: unit)
}

// LilyPond-style tuplets print their numerator by default. A bracket is
// omitted only when one visible beam spans the entire tuplet.
#let _tuplet-full-beam(group, beams) = {
  if group.len() < 2 or not _beam-group-visible(group, beams) {
    return false
  }
  let group-id = group.first().layout.at("beam_group", default: none)
  group-id != none and group.all(item =>
    not item.layout.rest
      and item.layout.flags > 0
      and item.layout.at("beam_group", default: none) == group-id
  )
}

#let _tuplet-side(group, requested) = {
  if requested == "above" or requested == "below" {
    return requested
  }
  let positions = ()
  for item in group {
    for pitch in item.layout.pitches {
      positions.push(pitch.staff_position)
    }
  }
  if _stem-direction(positions) == "up" { "above" } else { "below" }
}

#let _draw-tuplets(placed, bottom-y: 0, unit: 8pt, beams: false) = {
  import cetz.draw: *
  for start-index in range(placed.len()) {
    let start = placed.at(start-index)
    for tuplet in start.layout.at("tuplet_starts", default: ()) {
      let end-index = tuplet.end_index
      if end-index < start-index or end-index >= placed.len() { continue }
      let group = placed.slice(start-index, end-index + 1)
      let side = _tuplet-side(group, tuplet.side)
      let above = side == "above"
      // LilyPond centers a TupletNumber on the note-column origins. Our event
      // x coordinates denote notehead centers, so use each boundary head's
      // left-side origin rather than the center of its bounding box. The
      // asymmetric terminal padding includes the last column's stem edge.
      let left = group.first().x - _head-half-width(group.first().layout) - 0.16
      let right = group.last().x - _head-half-width(group.last().layout) + 0.32
      let lane = tuplet.depth * 1.12
      let y = if above {
        let top = calc.max(..group.map(item => {
          if item.layout.rest or item.layout.pitches.len() == 0 {
            bottom-y + 3
          } else {
            let heads = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y))
            let stem = _event-stem-geometry(item.layout, item.x, bottom-y: bottom-y)
            if stem != none and stem.direction == "up" {
              calc.max(calc.max(..heads), stem.point.at(1))
            } else {
              calc.max(..heads)
            }
          }
        }))
        top + 0.66 + lane
      } else {
        let bottom = calc.min(..group.map(item => {
          if item.layout.rest or item.layout.pitches.len() == 0 {
            bottom-y
          } else {
            let heads = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y))
            let stem = _event-stem-geometry(item.layout, item.x, bottom-y: bottom-y)
            if stem != none and stem.direction == "down" {
              calc.min(calc.min(..heads) - 0.3, stem.point.at(1))
            } else {
              calc.min(..heads) - 0.3
            }
          }
        }))
        bottom - 0.66 - lane
      }
      let number = text(size: unit * 1.55, style: "italic", str(tuplet.numerator))
      let number-half = measure(number).width / unit / 2 + 0.32
      // Compensate for the rightward ink overhang of the italic digit so its
      // visible center, not merely its advance box, lands on the span center.
      let center = (left + right) / 2 - 0.04
      let show-bracket = tuplet.bracket == "always" or (
        tuplet.bracket == "auto" and not _tuplet-full-beam(group, beams)
      )
      if show-bracket {
        let stroke = 0.16 * unit + black
        if center - number-half > left {
          line((left, y), (center - number-half, y), stroke: stroke)
        }
        if center + number-half < right {
          line((center + number-half, y), (right, y), stroke: stroke)
        }
        let hook = if above { -0.70 } else { 0.70 }
        line((left, y), (left, y + hook), stroke: stroke)
        line((right, y), (right, y + hook), stroke: stroke)
      }
      content(
        (center, y),
        number,
        anchor: "center",
        padding: 0pt,
      )
    }
  }
}

// ---------------------------------------------------------------------------
// Event annotations and direction spanners
// ---------------------------------------------------------------------------

#let _annotation-with-prefix(layout, prefix) = {
  for annotation in layout.annotations {
    let annotation-text = str(annotation)
    if annotation-text.starts-with(prefix) {
      return annotation-text.slice(prefix.len())
    }
  }
  none
}

#let _has-annotation(layout, expected) = {
  layout.annotations.any(annotation => str(annotation) == expected)
}

#let _event-top(item, bottom-y: 0, line-gap: 1.0) = {
  if item.layout.rest or item.layout.pitches.len() == 0 {
    bottom-y + 3 * line-gap
  } else {
    let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y, line-gap: line-gap))
    let stem-geometry = _event-stem-geometry(
      item.layout,
      item.x,
      bottom-y: bottom-y,
      line-gap: line-gap,
    )
    if stem-geometry != none and stem-geometry.direction == "up" {
      calc.max(calc.max(..y-values), stem-geometry.point.at(1))
    } else {
      calc.max(..y-values)
    }
  }
}

#let _annotation-stem-direction(item, placed, beams: false, bottom-y: 0) = {
  let group-id = item.layout.at("beam_group", default: none)
  if group-id != none {
    let group = placed.filter(candidate => candidate.layout.at("beam_group", default: none) == group-id)
    if group.len() > 1 and _beam-group-visible(group, beams) {
      let positions = ()
      for candidate in group {
        for pitch in candidate.layout.pitches {
          positions.push(pitch.staff_position)
        }
      }
      let forced-direction = group.first().layout.at("stem-direction", default: none)
      return if forced-direction == none { _stem-direction(positions) } else { forced-direction }
    }
  }
  let stem = _event-stem-geometry(item.layout, item.x, bottom-y: bottom-y)
  if stem == none { none } else { stem.direction }
}

#let _articulation-height(kind) = {
  if kind == "staccato" { 0.336 }
  else if kind == "tenuto" { 0.192 }
  else if kind == "staccatissimo" { 1.16 }
  else if kind == "accent" { 0.98 }
  else if kind == "marcato" { 1.016 }
  else { panic("unknown articulation " + kind) }
}

// Quantize a staff offset to the half-space grid in the given direction,
// skipping staff lines, whenever it falls inside the staff or on the far
// side of the middle line. This is LilyPond's quantize-position rule for
// scripts: a quantized point never rests on a staff line.
#let _script-quantize(y, sign, bottom-y) = {
  let p = y - bottom-y
  if (p >= 0 and p <= 4) or sign * (p - 2) < 0 {
    let q = if sign == 1 { calc.ceil(p * 2) / 2 } else { calc.floor(p * 2) / 2 }
    if calc.abs(q - calc.round(q)) < 0.01 { q += sign * 0.5 }
    bottom-y + q
  } else {
    y
  }
}

// Vertical placement of an articulation stack, following LilyPond's script
// rules. Marks leave the notehead with a fifth of a space of padding beyond
// the head's half-space of ink, then quantize what their glyph anchors to the
// staff: the centered staccato dot and tenuto bar quantize their center to
// the half-space grid, the wedge and marcato quantize their near edge, and
// the accent — the one script without quantization — clears the staff
// outline entirely with a quarter space of staff padding. Returns (mark, y)
// center placements in reading order; `sign` is 1 above the head, -1 below.
#let _articulation-stack(articulations, y-values, sign, bottom-y) = {
  let cursor = if sign == 1 { calc.max(..y-values) + 0.7 } else { calc.min(..y-values) - 0.7 }
  let placements = ()
  for mark in articulations {
    let mark-height = _articulation-height(mark)
    let mark-y = if mark == "staccato" or mark == "tenuto" {
      // The dot reserves the reach of a full-size script even though the
      // Bravura glyph is small, so an unquantized dot beyond the staff sits
      // a whole space from the pitch center, right in the adjacent space.
      let half-reach = if mark == "staccato" { 0.3 } else { mark-height / 2 }
      _script-quantize(cursor + sign * half-reach, sign, bottom-y)
    } else if mark == "staccatissimo" or mark == "marcato" {
      _script-quantize(cursor, sign, bottom-y) + sign * mark-height / 2
    } else if sign == 1 {
      calc.max(cursor + mark-height / 2, bottom-y + 4 + 0.25 + mark-height / 2)
    } else {
      calc.min(cursor - mark-height / 2, bottom-y - 0.25 - mark-height / 2)
    }
    placements.push((mark: mark, y: mark-y))
    cursor = mark-y + sign * (mark-height / 2 + 0.18)
  }
  placements
}

#let _event-articulations(layout) = {
  let marks = ()
  // Near-note duration articulations come first; force accents sit outside.
  if _has-annotation(layout, "stacc") { marks.push("staccato") }
  if _has-annotation(layout, "staccatissimo") { marks.push("staccatissimo") }
  if _has-annotation(layout, "tenuto") or _has-annotation(layout, "legato") { marks.push("tenuto") }
  if _has-annotation(layout, "accent") { marks.push("accent") }
  if _has-annotation(layout, "marcato") or _has-annotation(layout, "strong") { marks.push("marcato") }
  marks
}

#let _event-decoration-top(item, placed, beams: false, bottom-y: 0) = {
  let top = _event-top(item, bottom-y: bottom-y) + 0.55
  if item.layout.rest or item.layout.pitches.len() == 0 {
    return top
  }
  let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y))
  let articulations = _event-articulations(item.layout)
  let articulation-above = false
  let articulation-top = none
  if articulations.len() > 0 {
    let direction = _annotation-stem-direction(item, placed, beams: beams, bottom-y: bottom-y)
    articulation-above = direction != "up"
    if articulation-above {
      let last = _articulation-stack(articulations, y-values, 1, bottom-y).last()
      articulation-top = last.y + _articulation-height(last.mark) / 2 + 0.18
      top = calc.max(top, articulation-top)
    }
  }
  let has-turn = _has-annotation(item.layout, "turn") or _has-annotation(item.layout, "chromatic-turn")
  let turn-top = none
  if has-turn {
    let stack-base = calc.max(..y-values) + 0.5
    if articulation-top != none {
      stack-base = calc.max(stack-base, articulation-top - 0.18)
    }
    let turn-y = calc.max(_event-top(item, bottom-y: bottom-y) + 1.22, stack-base + 0.75)
    turn-top = turn-y + 0.42
    if _has-annotation(item.layout, "chromatic-turn") {
      turn-top = turn-y + 0.95
    }
    if _annotation-with-prefix(item.layout, "turn-f=") != none {
      turn-top = turn-y + 1.85
    }
    top = calc.max(top, turn-top)
  }
  if _annotation-with-prefix(item.layout, "f=") != none {
    let ink-top = calc.max(..y-values) + 0.5
    if articulation-top != none {
      ink-top = calc.max(ink-top, articulation-top - 0.18)
    }
    let fingering-y = calc.max(bottom-y + 4.56, ink-top + 0.55)
    if turn-top != none {
      fingering-y = calc.max(fingering-y, turn-top + 0.3)
    }
    top = calc.max(top, fingering-y + 0.95)
  }
  if _has-annotation(item.layout, "fermata") {
    top = calc.max(top, _event-top(item, bottom-y: bottom-y) + 1.75)
  }
  if _has-annotation(item.layout, "breath") {
    top = calc.max(top, _event-top(item, bottom-y: bottom-y) + 1.35)
  }
  top
}

// The bow height (with a small gap) over a point strictly inside a laid-out
// slur, or none when no slur covers it. Annotations that belong above the
// bow use this to climb over it.
#let _slur-clearance-at(slur-layouts, x) = {
  let lift = none
  for layout in slur-layouts {
    if layout.dir == 1 and x > layout.start.at(0) + 0.3 and x < layout.end.at(0) - 0.3 {
      let y = sampled-y-at-x(layout.samples, x)
      if y != none {
        lift = if lift == none { y } else { calc.max(lift, y) }
      }
    }
  }
  lift
}

// The bottom of one event's ink: the lowest notehead or, for stem-down
// events, the stem tip. Dynamics use this to stay clear of beams and stems
// that reach under the staff.
#let _event-ink-bottom(item, bottom-y: 0) = {
  let event-bottom = bottom-y
  if not item.layout.rest and item.layout.pitches.len() > 0 {
    let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y))
    event-bottom = calc.min(event-bottom, calc.min(..y-values) - 0.3)
    let stem-geometry = _event-stem-geometry(item.layout, item.x, bottom-y: bottom-y)
    if stem-geometry != none and stem-geometry.direction == "down" {
      event-bottom = calc.min(event-bottom, stem-geometry.point.at(1))
    }
  }
  event-bottom
}

// All dynamics of one voice share a baseline per system: far enough below
// the staff for every event that carries a dynamic, so a run of marks sits
// on one line instead of bobbing with the notation above each one. The
// tallest dynamic letter (f) reaches 1.78 above the baseline, so the
// demand below each event's ink keeps that ascent clear.
#let _dynamics-baseline(placed-flat, bottom-y: 0) = {
  let baseline = none
  for item in placed-flat {
    if _annotation-with-prefix(item.layout, "dyn=") != none {
      let demand = calc.min(
        bottom-y - 2.0,
        _event-ink-bottom(item, bottom-y: bottom-y) - 2.05,
      )
      baseline = if baseline == none { demand } else { calc.min(baseline, demand) }
    }
  }
  baseline
}

#let _draw-placed-annotations(placed, bottom-y: 0, unit: 8pt, beams: false, slur-layouts: (), dynamics-baseline: none) = {
  import cetz.draw: *
  for item in placed {
    let dynamic = _annotation-with-prefix(item.layout, "dyn=")
    if dynamic != none {
      let y = if dynamics-baseline == none { bottom-y - 2.0 } else { dynamics-baseline }
      draw-dynamic(dynamic, item.x, y, unit: unit)
    }
    if _has-annotation(item.layout, "fermata") {
      draw-fermata(item.x, _event-top(item, bottom-y: bottom-y) + 1.15, unit: unit)
    }
    if _has-annotation(item.layout, "breath") {
      draw-breath-mark(
        item.x + _head-half-width(item.layout) + 0.72,
        _event-top(item, bottom-y: bottom-y) + 0.78,
        unit: unit,
      )
    }
    if item.layout.rest { continue }
    let top = _event-top(item, bottom-y: bottom-y)
    let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y))
    let articulations = _event-articulations(item.layout)
    let articulation-placement = none
    let articulation-cursor = none
    if articulations.len() > 0 {
      let stem-direction = _annotation-stem-direction(item, placed, beams: beams, bottom-y: bottom-y)
      // The entire stack belongs on the notehead ("bubble") side: below for
      // stem-up notes and above for stem-down notes, including beam groups.
      articulation-placement = if stem-direction == "up" { "below" } else { "above" }
      let sign = if articulation-placement == "above" { 1 } else { -1 }
      let placements = _articulation-stack(articulations, y-values, sign, bottom-y)
      for placement in placements {
        draw-articulation(placement.mark, item.x, placement.y, placement: articulation-placement, unit: unit)
      }
      let last = placements.last()
      articulation-cursor = last.y + sign * (_articulation-height(last.mark) / 2 + 0.18)
    }
    // The stack above the note grows outward in LilyPond's script order:
    // articulations first, then the turn ornament, then the fingering digit
    // on top.
    let ink-top = calc.max(..y-values) + 0.5
    if articulations.len() > 0 and articulation-placement == "above" {
      ink-top = calc.max(ink-top, articulation-cursor - 0.18)
    }
    let turn-top = none
    if _has-annotation(item.layout, "turn") or _has-annotation(item.layout, "chromatic-turn") {
      let turn-y = calc.max(top + 1.22, ink-top + 0.75)
      let slur-y = _slur-clearance-at(slur-layouts, item.x)
      if slur-y != none {
        // The chromatic variant hangs a natural sign below the turn, so it
        // needs more air to clear the bow underneath.
        let lift = if _has-annotation(item.layout, "chromatic-turn") { 1.7 } else { 0.8 }
        turn-y = calc.max(turn-y, slur-y + lift)
      }
      draw-ornament-turn(item.x, turn-y, unit: unit, scale: 0.82)
      turn-top = turn-y + 0.42
      if _has-annotation(item.layout, "chromatic-turn") {
        draw-accidental("Flat", item.x - 0.72, turn-y + 0.58, unit: unit, scale: 0.38)
        draw-accidental("Natural", item.x + 0.34, turn-y - 0.74, unit: unit, scale: 0.38)
        turn-top = turn-y + 0.95
      }
      let turn-fingering = _annotation-with-prefix(item.layout, "turn-f=")
      if turn-fingering != none {
        content(
          (item.x, turn-y + 1.08),
          text(size: unit * 0.62, weight: "bold", turn-fingering),
          anchor: "south",
          padding: 0pt,
        )
        turn-top = turn-y + 1.85
      }
    }
    let fingering = _annotation-with-prefix(item.layout, "f=")
    if fingering != none {
      // LilyPond's default fingering direction is up with half a space of
      // staff padding, so digits float in a common band just above the staff
      // and rise only when the notehead (never the stem), an articulation,
      // or a turn stacked above reaches higher.
      let fingering-y = calc.max(bottom-y + 4.56, ink-top + 0.55)
      if turn-top != none {
        fingering-y = calc.max(fingering-y, turn-top + 0.3)
      }
      // A digit inside a slur moves above the bow; endpoint digits stay
      // under the raised slur tip.
      let slur-y = _slur-clearance-at(slur-layouts, item.x)
      if slur-y != none {
        fingering-y = calc.max(fingering-y, slur-y + 0.35)
      }
      content(
        (item.x, fingering-y),
        text(size: unit * 0.82, weight: "bold", fingering),
        anchor: "south",
        padding: 0pt,
      )
    }
    let marking = _annotation-with-prefix(item.layout, "text=")
    if marking != none {
      content(
        (item.x, bottom-y - 1.35),
        text(size: unit * 0.9, style: "italic", marking.replace("_", " ")),
        anchor: "north-west",
        padding: 0pt,
      )
    }
    let below-marking = _annotation-with-prefix(item.layout, "text-below=")
    if below-marking != none {
      content(
        (item.x, bottom-y - 6.8),
        text(size: unit * 0.9, style: "italic", below-marking.replace("_", " ")),
        anchor: "north-west",
        padding: 0pt,
      )
    }
  }
}

#let _collect-pedal-spans(placed-measures) = {
  let open-pedals = (:)
  let pedal-spans = ()
  for placed-events in placed-measures {
    for item in placed-events {
      for annotation in item.layout.annotations {
        let annotation-text = str(annotation)
        if annotation-text.starts-with("p") and annotation-text.ends-with("(") {
          open-pedals.insert(annotation-text.slice(0, -1), item.x)
        } else if annotation-text.starts-with("p") and annotation-text.ends-with(")") {
          let span-id = annotation-text.slice(0, -1)
          if span-id in open-pedals {
            pedal-spans.push((start: open-pedals.at(span-id), end: item.x))
            let _ = open-pedals.remove(span-id)
          }
        }
      }
    }
  }
  pedal-spans
}

#let _draw-pedal-spans(spans, y, unit: 8pt) = {
  import cetz.draw: *
  let stroke-style = 0.08 * unit + black
  for span in spans {
    draw-pedal-mark(span.start, y, unit: unit)
    let line-start = span.start + 1.72
    let line-end = span.end + 0.55
    if line-end > line-start {
      line((line-start, y), (line-end, y), stroke: stroke-style)
      line((line-end, y), (line-end, y + 0.48), stroke: stroke-style)
    }
  }
}

#let _collect-hairpins(placed-measures) = {
  let open-hairpins = (:)
  let hairpin-spans = ()
  for placed-events in placed-measures {
    for item in placed-events {
      for annotation in item.layout.annotations {
        let annotation-text = str(annotation)
        if (
          annotation-text.starts-with("h")
            and (annotation-text.ends-with("<") or annotation-text.ends-with(">"))
        ) {
          open-hairpins.insert(annotation-text.slice(0, -1), (
            x: item.x,
            kind: if annotation-text.ends-with("<") { "crescendo" } else { "diminuendo" },
            dynamic: _annotation-with-prefix(item.layout, "dyn="),
          ))
        } else if annotation-text.starts-with("h") and annotation-text.ends-with("!") {
          let span-id = annotation-text.slice(0, -1)
          if span-id in open-hairpins {
            let start = open-hairpins.at(span-id)
            let start-clearance = if start.dynamic == none { 0 } else { dynamic-width(start.dynamic) / 2 + 0.35 }
            let end-dynamic = _annotation-with-prefix(item.layout, "dyn=")
            let end-clearance = if end-dynamic == none { 0 } else { dynamic-width(end-dynamic) / 2 + 0.35 }
            let start-x = start.x + start-clearance
            let end-x = item.x - end-clearance
            if end-x > start-x + 0.4 {
              hairpin-spans.push((start: start-x, end: end-x, kind: start.kind))
            }
            let _ = open-hairpins.remove(span-id)
          }
        }
      }
    }
  }
  hairpin-spans
}

#let _draw-hairpins(spans, y, unit: 8pt) = {
  for span in spans {
    draw-hairpin((span.start, y), (span.end, y), kind: span.kind, unit: unit)
  }
}

// ---------------------------------------------------------------------------
// Ties
// ---------------------------------------------------------------------------

// Vertical tie discipline. A tie thin enough to live inside one staff space
// is centered in that space: the head's own space when the head sits in a
// space, or the adjacent space in the tie's direction when the head sits on
// a line (ledger lines included, so the same rule holds outside the staff).
// A taller tie keeps its tips clear of the line at the head and shifts so
// its apex does not graze the staff line it approaches.
#let _tie-tip-y(head-y, dir, apex, bottom-y) = {
  let staff-space-offset = head-y - bottom-y
  let nearest-line = calc.round(staff-space-offset)
  let on-line = calc.abs(staff-space-offset - nearest-line) < 0.25
  if apex < 0.625 {
    let space-center = if on-line { head-y + dir * 0.5 } else { head-y }
    let center-pos = space-center - bottom-y
    if center-pos > 0 and center-pos < 4 {
      space-center - dir * apex / 2
    } else {
      // Outside the staff there is no far line to dodge; float the whole
      // bow just past the notehead instead of centering on it.
      head-y + dir * 0.5
    }
  } else {
    let tip = if on-line { head-y + dir * 0.225 } else { head-y }
    let top = tip + dir * apex
    let top-pos = top - bottom-y
    let top-line = calc.round(top-pos)
    if top-line >= 0 and top-line <= 4 and calc.abs(top-pos - top-line) < 0.3 {
      tip + (bottom-y + top-line + dir * 0.3) - top
    } else {
      tip
    }
  }
}

// A tie leaving a dotted note must clear its augmentation dots, which sit in
// the same staff space the tie occupies.
#let _tie-start-gap(layout) = {
  if layout.duration.dots > 0 {
    _dot-gap-from-head + 0.2 + (layout.duration.dots - 1) * _dot-step + 0.45
  } else {
    0.2
  }
}

// Collect tie bows for a flat list of placed events (one voice across
// a whole system). Open ties at the system edge run to the right margin.
// Tie tips leave from just past the notehead edges at the head's own
// vertical level; _tie-tip-y settles them against the staff lines.
#let _collect-ties(
  placed,
  bottom-y: 0,
  line-gap: 1.0,
  continuation-left-x: none,
  continuation-right-x: none,
  incoming: false,
) = {
  let ties = ()
  if incoming and placed.len() > 0 and continuation-left-x != none {
    let item = placed.first()
    let positions = item.layout.pitches.map(p => p.staff_position)
    let direction = _stem-direction(positions)
    let sign = if direction == "up" { -1 } else { 1 }
    for pitch in item.layout.pitches {
      let head-y = staff-y(pitch.staff_position, bottom-y: bottom-y, line-gap: line-gap)
      let end-x = item.x - _head-half-width(item.layout) - 0.2
      if end-x - continuation-left-x < 0.8 {
        // Short post-signature fragments may enter the notehead slightly so
        // they still read as ties at small scales.
        end-x = item.x - 0.12
      }
      if end-x > continuation-left-x + 0.2 {
        let height = bow-height(end-x - continuation-left-x, 1.0, 0.333)
        let tip-y = _tie-tip-y(head-y, sign, 0.75 * height, bottom-y)
        ties.push((
          start: (continuation-left-x, tip-y),
          end: (end-x, tip-y),
          dir: sign,
          height: height,
        ))
      }
    }
  }
  for event-index in range(placed.len()) {
    let item = placed.at(event-index)
    if item.layout.rest or not item.layout.tie_to_next { continue }
    let positions = item.layout.pitches.map(p => p.staff_position)
    let direction = _stem-direction(positions)
    let sign = if direction == "up" { -1 } else { 1 }
    let next = if event-index + 1 < placed.len() {
      placed.at(event-index + 1)
    } else {
      none
    }
    // In chords the outermost ties curve away from the chord; inner ties
    // follow the stem rule.
    let chord = item.layout.pitches.len() >= 2
    let top-pos = calc.max(..item.layout.pitches.map(p => p.staff_position))
    let bottom-pos = calc.min(..item.layout.pitches.map(p => p.staff_position))
    let right-spread = calc.max(.._cluster-offsets(item.layout, direction), 0)
    for pitch in item.layout.pitches {
      let tie-dir = if chord and pitch.staff_position == top-pos { 1 } else if chord and pitch.staff_position == bottom-pos { -1 } else { sign }
      let head-y = staff-y(pitch.staff_position, bottom-y: bottom-y, line-gap: line-gap)
      let start-x = item.x + right-spread + _head-half-width(item.layout) + _tie-start-gap(item.layout)
      let end-x = if next != none {
        let next-direction = _stem-direction(next.layout.pitches.map(p => p.staff_position))
        let next-left = -calc.min(.._cluster-offsets(next.layout, next-direction), 0)
        next.x - next-left - _head-half-width(next.layout) - 0.2
      } else if continuation-right-x != none {
        continuation-right-x
      } else {
        none
      }
      // Under very tight spacing the gap between the heads is too small for
      // a tucked tie; arch a short bow over the head edges instead.
      let snug = next != none and end-x != none and end-x - start-x < 0.8
      if snug {
        start-x = item.x + 0.12
        end-x = next.x - 0.12
      }
      if end-x != none and end-x > start-x + 0.2 {
        let height = bow-height(end-x - start-x, 1.0, 0.333)
        let tip-y = if snug {
          head-y + tie-dir * 0.55
        } else {
          _tie-tip-y(head-y, tie-dir, 0.75 * height, bottom-y)
        }
        ties.push((
          start: (start-x, tip-y),
          end: (end-x, tip-y),
          dir: tie-dir,
          height: height,
        ))
      }
    }
  }
  ties
}

#let _draw-ties(ties, unit: 8pt) = {
  for tie in ties {
    draw-bow(
      tie.start,
      tie.end,
      direction-sign: tie.dir,
      height: tie.height,
      maximum-control-height: 1.0,
      initial-rise-ratio: 0.333,
      unit: unit,
    )
  }
}

// ---------------------------------------------------------------------------
// Slurs
// ---------------------------------------------------------------------------

// Slur tips attach on their chosen side of the boundary notes. On the stem
// side they clear the rendered stem tip; on the opposite side they sit just
// outside the notehead. The stem direction follows the visible beam group,
// not the lone note, so the attachment matches the notation that is drawn.
#let _slur-anchor(item, placed: (), beams: false, dir: 1, bottom-y: 0, line-gap: 1.0) = {
  if item.layout.rest or item.layout.pitches.len() == 0 {
    none
  } else {
    let direction = _annotation-stem-direction(item, placed, beams: beams, bottom-y: bottom-y)
    let stem-geometry = _event-stem-geometry(
      item.layout,
      item.x,
      bottom-y: bottom-y,
      line-gap: line-gap,
      direction-override: direction,
    )
    let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y, line-gap: line-gap))
    let head-edge = if dir == 1 { calc.max(..y-values) } else { calc.min(..y-values) }
    let same-side-stem = stem-geometry != none and (
      (dir == 1 and direction == "up") or (dir == -1 and direction == "down")
    )
    let (x, y) = if same-side-stem {
      (stem-geometry.point.at(0) - 0.2, stem-geometry.point.at(1) + 0.4)
    } else {
      // Half a space of head ink plus half a space of air: the tip sits one
      // space beyond the outermost pitch center on the free side.
      (item.x, head-edge + dir * 1.0)
    }
    if same-side-stem and dir == -1 {
      x = stem-geometry.point.at(0) + 0.2
      y = stem-geometry.point.at(1) - 0.4
    }
    let top = if stem-geometry != none and direction == "up" {
      calc.max(calc.max(..y-values), stem-geometry.point.at(1))
    } else {
      calc.max(..y-values)
    }
    let has-turn = _has-annotation(item.layout, "turn") or _has-annotation(item.layout, "chromatic-turn")
    if dir == 1 and has-turn {
      y = calc.max(y, top + 1.9)
      if _has-annotation(item.layout, "chromatic-turn") {
        y = calc.max(y, top + 2.75)
      }
      if _annotation-with-prefix(item.layout, "turn-f=") != none {
        y = calc.max(y, top + 3.2)
      }
    }
    if dir == 1 and _annotation-with-prefix(item.layout, "f=") != none {
      let ink-top = calc.max(..y-values) + 0.5
      let articulations = _event-articulations(item.layout)
      if articulations.len() > 0 and direction != "up" {
        let last = _articulation-stack(articulations, y-values, 1, bottom-y).last()
        ink-top = calc.max(ink-top, last.y + _articulation-height(last.mark) / 2)
      }
      // The digit rides on top of a turn stacked over the same note.
      if has-turn {
        ink-top = calc.max(ink-top, top + 1.64)
      }
      y = calc.max(y, calc.max(bottom-y + 4.56, ink-top + 0.55) + 1.2)
    }
    (x, y)
  }
}

#let _articulation-width(kind) = {
  if kind == "staccato" { 0.336 }
  else if kind == "tenuto" { 1.356 }
  else if kind == "staccatissimo" { 0.352 }
  else if kind == "accent" { 1.356 }
  else if kind == "marcato" { 0.944 }
  else { panic("unknown articulation " + kind) }
}

#let _top-obstacle-samples(x, y, half-width: 0) = {
  if half-width > 0 {
    ((x - half-width, y), (x, y), (x + half-width, y))
  } else {
    ((x, y),)
  }
}


// Upper edges of rendered articulations. Notes and stems are scored
// separately, and fingerings and ornaments move above the finished bow
// instead of shaping it, so articulation marks are the only annotations a
// slur must clear.
#let _slur-clearance-obstacles(item, placed, bottom-y: 0, beams: false) = {
  let anchor = _slur-anchor(item, placed: placed, beams: beams, dir: 1, bottom-y: bottom-y)
  if anchor == none { return () }
  let points = ()
  let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y))
  let articulations = _event-articulations(item.layout)

  if articulations.len() > 0 {
    let stem-direction = _annotation-stem-direction(item, placed, beams: beams, bottom-y: bottom-y)
    if stem-direction != "up" {
      for placement in _articulation-stack(articulations, y-values, 1, bottom-y) {
        points += _top-obstacle-samples(
          item.x,
          placement.y + _articulation-height(placement.mark) / 2,
          half-width: _articulation-width(placement.mark) / 2,
        )
      }
    }
  }
  points
}

#let _slur-overlaps(left-slur, right-slur) = {
  (
    left-slur.start.at(0) < right-slur.end.at(0)
      and right-slur.start.at(0) < left-slur.end.at(0)
  )
}

#let _validate-staff-slurs(layout-measures, staff-name) = {
  let open-slurs = (:)
  for measure-index in range(layout-measures.len()) {
    for layout in layout-measures.at(measure-index) {
      for annotation in layout.annotations {
        let annotation-text = str(annotation)
        if annotation-text.starts-with("s") and annotation-text.ends-with("(") {
          let span-id = annotation-text.slice(0, -1)
          if span-id in open-slurs {
            _score-error(
              staff-name + " bar " + str(measure-index + 1),
              "slur " + span-id + " opens twice; its first opening is in bar " + str(open-slurs.at(span-id)),
              expected: "one opening followed by one closing marker",
              fix: "close the first slur or use a different slur ID",
            )
          }
          open-slurs.insert(span-id, measure-index + 1)
        } else if annotation-text.starts-with("s") and annotation-text.ends-with(")") {
          let span-id = annotation-text.slice(0, -1)
          if span-id not in open-slurs {
            _score-error(
              staff-name + " bar " + str(measure-index + 1),
              "slur " + span-id + " closes without opening",
              expected: span-id + "( on an earlier note or chord",
              fix: "add the opening marker or remove this closing marker",
            )
          }
          let _ = open-slurs.remove(span-id)
        }
      }
    }
  }
  if open-slurs.len() > 0 {
    let span-id = open-slurs.keys().first()
    _score-error(
      staff-name,
      "slur " + span-id + " opened in bar " + str(open-slurs.at(span-id)) + " was never closed",
      expected: span-id + ") on a later note or chord",
      fix: "add the matching closing marker",
    )
  }
}

#let _pitch-label(pitch) = {
  let accidental = if pitch.accidental == "Sharp" { "#" }
    else if pitch.accidental == "Flat" { "b" }
    else if pitch.accidental == "DoubleSharp" { "##" }
    else if pitch.accidental == "DoubleFlat" { "bb" }
    else { "" }
  pitch.letter + accidental + str(pitch.octave)
}

#let _layout-pitch-label(layout) = {
  if layout.rest {
    "rest"
  } else {
    layout.pitches.map(item => _pitch-label(item.pitch)).sorted().join(" ")
  }
}

// A tie joins immediately adjacent events of the same written pitch set.
// Enharmonic respellings remain available as slurs, where re-articulation is
// semantically correct and an accidental may be shown normally.
#let _validate-staff-ties(layout-measures, staff-name) = {
  let events = ()
  for (measure-index, layouts) in layout-measures.enumerate() {
    for layout in layouts {
      events.push((layout: layout, bar: measure-index + 1))
    }
  }
  for event-index in range(events.len()) {
    let source = events.at(event-index)
    if source.layout.at("tie_to_next", default: false) {
      if event-index + 1 >= events.len() {
        _score-error(
          staff-name + " bar " + str(source.bar),
          "tie after " + _layout-pitch-label(source.layout) + " has no following event",
          expected: "an immediately following note or chord with the same written pitch set",
          fix: "add the tied target or remove the trailing ~",
        )
      }
      let target = events.at(event-index + 1)
      let source-pitches = _layout-pitch-label(source.layout)
      let target-pitches = _layout-pitch-label(target.layout)
      if target.layout.rest or source-pitches != target-pitches {
        _score-error(
          staff-name + " bar " + str(source.bar),
          "tie must connect the same written pitch or chord",
          value: source-pitches + " followed by " + target-pitches,
          expected: source-pitches + " followed immediately by the same written pitch set",
          fix: "correct the target pitch or replace the tie with a slur",
        )
      }
    }
  }
}

#let _validate-staff-direction-spans(layout-measures, staff-name) = {
  let open-pedals = (:)
  let open-hairpins = (:)
  for (measure-index, layouts) in layout-measures.enumerate() {
    for layout in layouts {
      for annotation in layout.annotations {
        let annotation-text = str(annotation)
        if annotation-text.starts-with("p") and annotation-text.ends-with("(") {
          let span-id = annotation-text.slice(0, -1)
          if span-id in open-pedals {
            _score-error(
              staff-name + " bar " + str(measure-index + 1),
              "pedal " + span-id + " opens twice",
              expected: "one opening followed by one closing marker",
              fix: "close the first pedal span or use a different ID",
            )
          }
          open-pedals.insert(span-id, measure-index + 1)
        } else if annotation-text.starts-with("p") and annotation-text.ends-with(")") {
          let span-id = annotation-text.slice(0, -1)
          if span-id not in open-pedals {
            _score-error(
              staff-name + " bar " + str(measure-index + 1),
              "pedal " + span-id + " closes without opening",
              expected: span-id + "( on an earlier event",
              fix: "add the opening marker or remove this closing marker",
            )
          }
          let _ = open-pedals.remove(span-id)
        } else if (
          annotation-text.starts-with("h")
            and (annotation-text.ends-with("<") or annotation-text.ends-with(">"))
        ) {
          let span-id = annotation-text.slice(0, -1)
          if span-id in open-hairpins {
            _score-error(
              staff-name + " bar " + str(measure-index + 1),
              "hairpin " + span-id + " opens twice",
              expected: "one < or > opening followed by one ! closing marker",
              fix: "close the first hairpin or use a different ID",
            )
          }
          open-hairpins.insert(span-id, measure-index + 1)
        } else if annotation-text.starts-with("h") and annotation-text.ends-with("!") {
          let span-id = annotation-text.slice(0, -1)
          if span-id not in open-hairpins {
            _score-error(
              staff-name + " bar " + str(measure-index + 1),
              "hairpin " + span-id + " closes without opening",
              expected: span-id + "< or " + span-id + "> on an earlier event",
              fix: "add the opening marker or remove this closing marker",
            )
          }
          let _ = open-hairpins.remove(span-id)
        }
      }
    }
  }
  if open-pedals.len() > 0 {
    let span-id = open-pedals.keys().first()
    _score-error(
      staff-name,
      "pedal " + span-id + " opened in bar " + str(open-pedals.at(span-id)) + " was never closed",
      expected: span-id + ") on a later event",
      fix: "add the matching pedal closing marker",
    )
  }
  if open-hairpins.len() > 0 {
    let span-id = open-hairpins.keys().first()
    _score-error(
      staff-name,
      "hairpin " + span-id + " opened in bar " + str(open-hairpins.at(span-id)) + " was never closed",
      expected: span-id + "! on a later event",
      fix: "add the matching hairpin closing marker",
    )
  }
}

// LilyPond places a neutral slur below only when every encompassed non-rest
// note column has an upward stem. One downward stem sends the slur above.
#let _automatic-slur-direction(entries, beams: false, bottom-y: 0) = {
  for entry in entries {
    let item = entry.item
    if item.layout.rest or item.layout.pitches.len() == 0 { continue }
    let direction = _annotation-stem-direction(
      item,
      entry.placed,
      beams: beams,
      bottom-y: bottom-y,
    )
    if direction == "down" { return 1 }
  }
  -1
}

// Collect slurs for one staff across a system. Slurs that continue past
// the system run to the continuation edges.
#let _collect-system-slurs(
  placed-measures,
  staff-name,
  bottom-y: 0,
  continuation-left-x: 0,
  continuation-right-x: 0,
  beams: false,
) = {
  let events = ()
  for (measure-index, placed-events) in placed-measures.enumerate() {
    for item in placed-events {
      events.push((item: item, placed: placed-events, bar: measure-index + 1))
    }
  }
  let open-slurs = (:)
  let completed-slurs = ()
  for (event-index, entry) in events.enumerate() {
    let item = entry.item
    for annotation in item.layout.annotations {
      let annotation-text = str(annotation)
      if annotation-text.starts-with("s") and annotation-text.ends-with("(") {
        let span-id = annotation-text.slice(0, -1)
        open-slurs.insert(span-id, (index: event-index, entry: entry))
      } else if annotation-text.starts-with("s") and annotation-text.ends-with(")") {
        let span-id = annotation-text.slice(0, -1)
        let start-index = if span-id in open-slurs {
          open-slurs.at(span-id).index
        } else {
          0
        }
        let segment = events.slice(start-index, event-index + 1)
        let direction-sign = _automatic-slur-direction(
          segment,
          beams: beams,
          bottom-y: bottom-y,
        )
        let end = _slur-anchor(
          item,
          placed: entry.placed,
          beams: beams,
          dir: direction-sign,
          bottom-y: bottom-y,
        )
        if end != none {
          let start-entry = if span-id in open-slurs {
            let opened = open-slurs.at(span-id)
            let _ = open-slurs.remove(span-id)
            opened.entry
          } else {
            none
          }
          let start = if start-entry != none {
            _slur-anchor(
              start-entry.item,
              placed: start-entry.placed,
              beams: beams,
              dir: direction-sign,
              bottom-y: bottom-y,
            )
          } else {
            (continuation-left-x, end.at(1))
          }
          if start != none {
            completed-slurs.push((
              id: span-id,
              start: start,
              end: end,
              span: end.at(0) - start.at(0),
              dir: direction-sign,
              edge-beamed: beams and (
                item.layout.at("beam_group", default: none) != none
                  or (start-entry != none and start-entry.item.layout.at("beam_group", default: none) != none)
              ),
            ))
          }
        }
      }
    }
  }
  for span-id in open-slurs.keys() {
    let opened = open-slurs.at(span-id)
    let segment = events.slice(opened.index)
    let direction-sign = _automatic-slur-direction(
      segment,
      beams: beams,
      bottom-y: bottom-y,
    )
    let start = _slur-anchor(
      opened.entry.item,
      placed: opened.entry.placed,
      beams: beams,
      dir: direction-sign,
      bottom-y: bottom-y,
    )
    if start != none {
      completed-slurs.push((
        id: span-id,
        start: start,
        end: (continuation-right-x, start.at(1)),
        span: continuation-right-x - start.at(0),
        dir: direction-sign,
        edge-beamed: beams and opened.entry.item.layout.at("beam_group", default: none) != none,
      ))
    }
  }
  completed-slurs
}

// Nudge a slur attachment point that would land on a staff line into the
// adjacent space on its side, so the tip does not merge with the line ink.
#let _off-staff-line(y, bottom-y, dir) = {
  let staff-space-offset = y - bottom-y
  let nearest-line = calc.round(staff-space-offset)
  if (
    nearest-line >= 0
      and nearest-line <= 4
      and calc.abs(staff-space-offset - nearest-line) < 0.2
  ) {
    y + dir * 0.15
  } else {
    y
  }
}

// Endpoint offsets tried outward from the base attachments, in staff spaces.
#let _slur-candidate-raises = (0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0)

// One slur candidate: endpoints fixed, the canonical bow inflated just
// enough to clear the avoid points that are not close to either end (the
// endpoint enumeration is responsible for those). Inflating the height in
// the frame of the chord keeps the tips anchored to the notes, where a
// whole-curve translation would detach them.
#let _slur-candidate(sx, sy, ex, ey, avoid, dir) = {
  let (dx, dy) = (ex - sx, ey - sy)
  let chord = calc.sqrt(dx * dx + dy * dy)
  let h0 = bow-height(chord, 2.0, 0.25)
  let indent = bow-indent(chord, 2.0)
  let max-h = bow-max-height(chord, indent)
  let (ux, uy) = (dx / chord, dy / chord)
  let canonical = bow-samples((
    (0, 0),
    (indent, 1.0),
    (chord - indent, 1.0),
    (chord, 0),
  ))
  let fit = 0
  for (ox, oy) in avoid {
    let (zx, zy) = (ox - sx, oy - sy)
    let fx = zx * ux + zy * uy
    if fx > 2.5 and fx < chord - 2.5 {
      let unit-y = sampled-y-at-x(canonical, fx)
      if unit-y != none and unit-y > 0.01 {
        fit = calc.max(fit, dir * (zy * ux - zx * uy) / (h0 * unit-y))
      }
    }
  }
  let height = calc.max(h0, calc.min(h0 * fit, max-h))
  (
    height: height,
    samples: bow-samples(
      bow-control-points(
        (sx, sy),
        (ex, ey),
        height,
        2.0,
        direction-sign: dir,
      ),
    ),
  )
}

// Weighted demerits for one candidate. Covering a notehead is effectively
// forbidden; beyond that the score prefers even air between the bow and the
// notes it spans, endpoints near their anchors, and a tilt that neither
// exceeds nor opposes the interval between the end notes.
#let _slur-demerits(candidate, sx, sy, ex, ey, raises, musical-dy, interior, clearance, dir, edge-beamed: false) = {
  let (dx, dy) = (ex - sx, ey - sy)
  let slope = dy / dx
  let side-slope = dir * slope
  // Tips prefer staying at their notes: the pull is linear in the offset and
  // slope-weighted, so a tilted bow may lift its musically rising end.
  let score = (
    4 * raises.at(0) * calc.exp(-1.7 * side-slope)
      + 4 * raises.at(1) * calc.exp(1.7 * side-slope)
  )
  let head-distances = ()
  for o in interior {
    let y = sampled-y-at-x(candidate.samples, o.x)
    if y == none { continue }
    // Covering a notehead is effectively forbidden; passing near one costs
    // by closeness, measured wherever the bow comes nearest over the head's
    // full width rather than only above its center. A stem poking through
    // the bow is a mild offense, so a long bow may skim beamed stems rather
    // than fly over every stem tip.
    let head-dy = dir * (y - o.head)
    for edge-x in (o.x - notehead-half-width, o.x + notehead-half-width) {
      let edge-y = sampled-y-at-x(candidate.samples, edge-x)
      if edge-y != none {
        head-dy = calc.min(head-dy, dir * (edge-y - o.head))
      }
    }
    if head-dy < 0 {
      score += 1000
      head-distances.push(0.0)
    } else {
      score += calc.clamp(1 / calc.max(head-dy, 0.001) - 1 / 0.3, 0, 1000)
      let baseline-y = sy + dy * (o.x - sx) / dx
      let boundary = if dir == 1 { calc.max(o.outer, baseline-y) } else { calc.min(o.outer, baseline-y) }
      head-distances.push(calc.abs(y - boundary))
    }
    if dir * (y - o.outer) < 0 { score += 30 }
  }
  if head-distances.len() > 0 {
    let min-d = calc.min(..head-distances)
    let n = head-distances.len()
    let total = head-distances.sum()
    // For one or two covered notes the average distance alone is not a
    // stable normalizer; mix the bow height in.
    if n <= 2 {
      total += candidate.height
      n += 1
    }
    let variance = if min-d <= 0 {
      3.0
    } else {
      calc.clamp(total / n / (min-d + 0.3) - 1, 0, 3.0)
    }
    score += variance * 10
  }
  for (ox, oy) in clearance {
    let y = sampled-y-at-x(candidate.samples, ox)
    if y != none {
      score += 50 * calc.clamp(1 - dir * (y - oy) / 0.3, 0, 1)
    }
  }
  score += 10 * calc.max(calc.abs(slope) - 1.1, 0)
  // A beam under an end note already tilts the picture, so a bow anchored to
  // beamed notes may deviate a full extra space from the musical interval and
  // opposing its sign costs a tenth as much.
  let slope-allowance = if edge-beamed { 1.2 } else { 0.2 }
  score += 50 * calc.max(calc.abs(dy) - (calc.abs(musical-dy) + slope-allowance), 0)
  if calc.abs(musical-dy) < 0.01 and calc.abs(dy) > 0.01 { score += 15 }
  if calc.abs(musical-dy) >= 0.01 and calc.abs(dy) >= 0.01 and musical-dy * dy < 0 {
    score += if edge-beamed { 2 } else { 20 }
  }
  score
}

// Slur layout: enumerate endpoint offsets on the selected side, shape
// each candidate around the interior obstacles, and keep the candidate with
// the fewest demerits. `obstacles` carry per-event head and outer (stem tip)
// heights; the optional annotation-aware set adds soft clearance penalties
// only. Inner slurs are laid out first so enclosing slurs can arch over
// their apexes. Returns the finished curves so annotations can position
// themselves against them before anything is drawn.
#let _layout-slurs(slurs, obstacles: (), clearance-obstacles: none, bottom-y: 0) = {
  let clearance-points = if clearance-obstacles == none { () } else { clearance-obstacles }
  let layouts = ()
  let inner-apexes = ()
  for slur in slurs.sorted(key: s => s.span) {
    let dir = slur.dir
    let (sx, base-sy) = slur.start
    let (ex, base-ey) = slur.end
    if ex - sx < 0.3 { continue }
    let base-sy = _off-staff-line(base-sy, bottom-y, dir)
    let base-ey = _off-staff-line(base-ey, bottom-y, dir)
    let interior = obstacles.filter(o => o.x > sx + 0.3 and o.x < ex - 0.3).map(o => (
      x: o.x,
      head: if dir == 1 { o.head-top } else { o.head-bottom },
      outer: if dir == 1 { o.outer-top } else { o.outer-bottom },
    ))
    let clearance = if dir == 1 {
      clearance-points.filter(o => o.at(0) > sx + 0.3 and o.at(0) < ex - 0.3)
    } else {
      ()
    }
    let avoid = (
      interior.map(o => (o.x, o.outer + dir * 0.3))
        + inner-apexes.filter(o => o.dir == dir and o.x > sx + 0.3 and o.x < ex - 0.3).map(o => (o.x, o.y))
    )
    let musical-dy = base-ey - base-sy
    // With nothing to arch over, the tips stay at their notes no matter how
    // steep the interval: a detached tip reads worse than a steep bow.
    let raises = if interior.len() == 0 and avoid.len() == 0 {
      (0.0, 0.5, 1.0)
    } else {
      _slur-candidate-raises
    }
    let best = none
    for raise-left in raises {
      for raise-right in raises {
        let sy = base-sy + dir * raise-left
        let ey = base-ey + dir * raise-right
        let candidate = _slur-candidate(sx, sy, ex, ey, avoid, dir)
        let score = _slur-demerits(
          candidate,
          sx, sy, ex, ey,
          (raise-left, raise-right),
          musical-dy,
          interior,
          clearance,
          dir,
          edge-beamed: slur.at("edge-beamed", default: false),
        )
        if best == none or score < best.score {
          best = (score: score, sy: sy, ey: ey, height: candidate.height, samples: candidate.samples)
        }
      }
    }
    if best != none {
      layouts.push((
        start: (sx, best.sy),
        end: (ex, best.ey),
        height: best.height,
        samples: best.samples,
        dir: dir,
      ))
      let apex = best.samples.at(calc.floor(best.samples.len() / 2))
      inner-apexes.push((x: apex.at(0), y: apex.at(1) + dir * 0.8, dir: dir))
    }
  }
  layouts
}

#let _draw-slur-bows(layouts, unit: 8pt) = {
  for layout in layouts {
    draw-bow(
      layout.start,
      layout.end,
      direction-sign: layout.dir,
      height: layout.height,
      maximum-control-height: 2.0,
      unit: unit,
    )
  }
}

// ---------------------------------------------------------------------------
// Rational helpers for bar validation
// ---------------------------------------------------------------------------

#let _gcd(a, b) = {
  if b == 0 { a } else { _gcd(b, calc.rem(a, b)) }
}

#let _rational(n, d) = {
  let g = _gcd(n, d)
  (numerator: n / g, denominator: d / g)
}

#let _rational-add(a, b) = {
  _rational(
    a.numerator * b.denominator + b.numerator * a.denominator,
    a.denominator * b.denominator,
  )
}

#let _rational-eq(a, b) = {
  a.numerator * b.denominator == b.numerator * a.denominator
}

#let _rational-lte(a, b) = {
  a.numerator * b.denominator <= b.numerator * a.denominator
}

#let _format-rational(value) = {
  if value.denominator == 1 {
    str(value.numerator)
  } else {
    str(value.numerator) + "/" + str(value.denominator)
  }
}

#let _time-digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

#let _parse-time-rational(time, label: "time signature", optional: true) = {
  if time == none {
    if optional {
      none
    } else {
      _score-error(
        label,
        "a meter is required",
        value: time,
        expected: "a string such as \"4/4\" or \"12/8\"",
        fix: "set time to the active meter",
      )
    }
  } else {
    if type(time) != str {
      _score-error(
        label,
        "meter must be a string",
        value: time,
        expected: "a value such as \"4/4\" or \"12/8\"",
        fix: "quote the meter",
      )
    }
    let parts = time.split("/")
    if (
      parts.len() != 2
        or parts.any(part => (
          part == ""
            or part.len() > 9
            or part.codepoints().any(digit => digit not in _time-digits)
        ))
    ) {
      _score-error(
        label,
        "meter has invalid syntax",
        value: time,
        expected: "positive whole numbers separated by one slash, such as \"4/4\" or \"12/8\"",
        fix: "write the numerator and denominator with ASCII digits",
      )
    }
    let numerator = int(parts.at(0))
    let denominator = int(parts.at(1))
    if numerator <= 0 or denominator <= 0 {
      _score-error(
        label,
        "meter values must be positive",
        value: time,
        expected: "a numerator and denominator greater than zero",
        fix: "replace zero with the intended positive meter value",
      )
    }
    _rational(numerator, denominator)
  }
}

#let _duration-sum(layouts) = {
  let total = (numerator: 0, denominator: 1)
  for layout in layouts {
    total = _rational-add(total, layout.duration_value)
  }
  total
}

#let _validate-measure-duration(layouts, time, staff-name, measure-number) = {
  let expected = _parse-time-rational(
    time,
    label: staff-name + " bar " + str(measure-number) + " meter",
  )
  if expected != none {
    let actual = _duration-sum(layouts)
    if not _rational-eq(actual, expected) {
      _score-error(
        staff-name + " bar " + str(measure-number),
        "voice durations sum to " + _format-rational(actual),
        expected: time,
        fix: "add, remove, or change event durations so this voice fills the active bar or partial",
      )
    }
  }
}

// Harmony is an independent, duration-bearing sequence in a bar. Symbols are
// intentionally author-controlled text; only the trailing duration is parsed.
#let _harmony-duration-values = (
  "w": (numerator: 1, denominator: 1),
  "w.": (numerator: 3, denominator: 2),
  "w..": (numerator: 7, denominator: 4),
  "h": (numerator: 1, denominator: 2),
  "h.": (numerator: 3, denominator: 4),
  "h..": (numerator: 7, denominator: 8),
  "q": (numerator: 1, denominator: 4),
  "q.": (numerator: 3, denominator: 8),
  "q..": (numerator: 7, denominator: 16),
  "e": (numerator: 1, denominator: 8),
  "e.": (numerator: 3, denominator: 16),
  "e..": (numerator: 7, denominator: 32),
  "s": (numerator: 1, denominator: 16),
  "s.": (numerator: 3, denominator: 32),
  "s..": (numerator: 7, denominator: 64),
  "t": (numerator: 1, denominator: 32),
  "t.": (numerator: 3, denominator: 64),
  "t..": (numerator: 7, denominator: 128),
)

#let _layout-harmony(sequence, time, bar-number) = {
  if sequence == none { return () }
  if type(sequence) != str or sequence.trim() == "" {
    _score-error(
      "harmony in bar " + str(bar-number),
      "harmony must be a non-empty string",
      value: sequence,
      expected: "space-separated symbol:duration tokens such as \"Cmaj7:h G7:h\"",
      fix: "provide timed harmony text or remove the harmony field",
    )
  }
  if time == none {
    _score-error(
      "harmony in bar " + str(bar-number),
      "timed harmony requires an active meter",
      value: sequence,
      expected: "a bar time or partial value",
      fix: "set time for the score or partial for this bar",
    )
  }
  let layouts = ()
  let onset = _rational(0, 1)
  for token in sequence.trim().split(" ") {
    if token == "" { continue }
    let parts = token.split(":")
    if parts.len() != 2 or parts.first().trim() == "" or parts.last() not in _harmony-duration-values {
      _score-error(
        "harmony token in bar " + str(bar-number),
        "harmony token has invalid syntax",
        value: token,
        expected: "one symbol, one colon, and a duration such as Cmaj7:h",
        fix: "add the missing symbol, colon, or supported duration code",
      )
    }
    let duration = _harmony-duration-values.at(parts.last())
    layouts.push((symbol: parts.first(), onset: onset, duration-value: duration))
    onset = _rational-add(onset, duration)
  }
  let expected = _parse-time-rational(time, label: "harmony bar " + str(bar-number) + " meter")
  if not _rational-eq(onset, expected) {
    _score-error(
      "harmony bar " + str(bar-number),
      "durations sum to " + _format-rational(onset),
      expected: time,
      fix: "change the harmony durations so they fill the active bar or partial",
    )
  }
  layouts
}

// ---------------------------------------------------------------------------
// Score input normalization
// ---------------------------------------------------------------------------

#let _required-string(value, label) = {
  if type(value) != str {
    _score-error(
      label,
      "value must be a string",
      value: value,
      expected: "quoted text",
      fix: "replace the value with a string",
    )
  }
  value
}

#let _required-nonempty-string(value, label) = {
  let validated = _required-string(value, label)
  if validated.trim() == "" {
    _score-error(
      label,
      "string must contain at least one musical token",
      value: value,
      expected: "a note, chord, rest, group, or automatic-rest token",
      fix: "add the intended event or remove the empty voice",
    )
  }
  validated
}

#let _positive-number(value, label, optional: false) = {
  if optional and value == none { return }
  if (
    type(value) not in (int, float)
      or value != value
      or value in (float.inf, -float.inf)
      or value <= 0
  ) {
    _score-error(
      label,
      "value must be a positive number",
      value: value,
      expected: "an integer or float greater than zero",
      fix: "use a positive staff-space value",
    )
  }
}

#let _nonnegative-number(value, label) = {
  if (
    type(value) not in (int, float)
      or value != value
      or value in (float.inf, -float.inf)
      or value < 0
  ) {
    _score-error(
      label,
      "value must be a non-negative number",
      value: value,
      expected: "an integer or float greater than or equal to zero",
      fix: "use zero or a positive staff-space value",
    )
  }
}

#let _valid-clefs = ("treble", "bass", "alto", "tenor")

#let _validate-clef(value, label) = {
  if type(value) != str or value not in _valid-clefs {
    _score-error(
      label,
      "unknown clef",
      value: value,
      expected: "treble, bass, alto, or tenor",
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

#let _validate-marking(value, label, optional: true) = {
  if optional and value == none { return value }
  if type(value) not in (str, content) {
    _score-error(
      label,
      "value must be text or content",
      value: value,
      expected: "a string, content value, or none",
      fix: "quote plain text or wrap styled material as Typst content",
    )
  }
  if type(value) == str and value.trim() == "" {
    _score-error(
      label,
      "text must not be empty",
      value: value,
      fix: "provide visible text or remove the argument",
    )
  }
  value
}

#let _validate-system-gap(value) = {
  if type(value) != length {
    _score-error(
      "score system-gap",
      "value must be a non-negative length",
      value: value,
      expected: "a Typst length such as 1.2em or 12pt",
      fix: "add a length unit and use zero or a positive value",
    )
  }
  if (
    value != value
      or value in (float.inf * 1pt, -float.inf * 1pt)
      or value < 0pt
  ) {
    _score-error(
      "score system-gap",
      "value must be a finite non-negative length",
      value: value,
      expected: "a finite length greater than or equal to zero",
      fix: "replace the value with a normal length such as 1.2em or 12pt",
    )
  }
}

#let _tempo-beat-glyphs = (
  "whole": "met-note-whole",
  "half": "met-note-half",
  "quarter": "met-note-quarter",
  "eighth": "met-note-eighth",
  "sixteenth": "met-note-sixteenth",
  "thirty-second": "met-note-thirty-second",
)

#let _normalize-tempo(value, label) = {
  if value == none { return none }
  if type(value) != dictionary {
    return _validate-marking(value, label)
  }
  let allowed = ("text", "beat", "bpm")
  for key in value.keys() {
    if key not in allowed {
      _score-error(
        label,
        "tempo dictionary has unknown field",
        value: key,
        expected: "text, beat, and bpm fields only",
        fix: "remove or rename the unknown field",
      )
    }
  }
  let tempo-text = value.at("text", default: none)
  let _ = _validate-marking(tempo-text, label + " text")
  let beat = value.at("beat", default: none)
  let bpm = value.at("bpm", default: none)
  if type(beat) != str or beat not in _tempo-beat-glyphs {
    _score-error(
      label + " beat",
      "unsupported metronome beat",
      value: beat,
      expected: "whole, half, quarter, eighth, sixteenth, or thirty-second",
      fix: "choose one of the supported beat names",
    )
  }
  if (
    type(bpm) not in (int, float)
      or bpm != bpm
      or bpm in (float.inf, -float.inf)
      or bpm <= 0
  ) {
    _score-error(
      label + " bpm",
      "tempo must be a positive number",
      value: bpm,
      expected: "an integer or float greater than zero",
      fix: "set bpm to the intended positive tempo",
    )
  }
  (text: tempo-text, beat: beat, bpm: bpm)
}

#let _draw-tempo(tempo, x, y, unit) = {
  import cetz.draw: *
  let style = (size: unit * 1.25, style: "italic")
  if type(tempo) != dictionary {
    content((x, y), text(..style, tempo), anchor: "west", padding: 0pt)
    return
  }
  let prefix = if tempo.text == none { none } else { text(..style, tempo.text) }
  let prefix-width = if prefix == none { 0 } else { measure(prefix).width / unit }
  let glyph = _tempo-beat-glyphs.at(tempo.beat)
  let glyph-scale = 0.42
  let glyph-half-width = _bravura-width(glyph) * glyph-scale / 2
  let note-x = x + glyph-half-width
  if prefix != none {
    content((x, y), prefix, anchor: "west", padding: 0pt)
    let open-x = x + prefix-width + 0.16
    let open = text(..style, "(")
    content((open-x, y), open, anchor: "west", padding: 0pt)
    note-x = open-x + measure(open).width / unit + 0.28 + glyph-half-width
  }
  _draw-bravura-glyph(glyph, note-x, y, unit: unit, glyph-scale: glyph-scale)
  let after-note = note-x + glyph-half-width + 0.18
  let suffix = "= " + str(tempo.bpm) + if prefix == none { "" } else { ")" }
  content((after-note, y), text(..style, suffix), anchor: "west", padding: 0pt)
}

#let _measure-metadata-fields = (
  "key", "time", "clef", "partial", "tempo", "harmony", "barline", "ending",
  "rehearsal", "navigation",
)

#let _normalize-barline(value, label) = {
  if value == none {
    return (left: none, right: none)
  }
  if type(value) != dictionary {
    _score-error(
      label + " barline",
      "barline must be a dictionary",
      value: value,
      expected: "left and/or right fields",
      fix: "write barline: (right: \"final\") or remove it",
    )
  }
  for field in value.keys() {
    if field != "left" and field != "right" {
      _score-error(
        label + " barline",
        "barline has unknown field",
        value: field,
        expected: "left or right",
        fix: "remove or rename the unknown field",
      )
    }
  }
  let left = value.at("left", default: none)
  let right = value.at("right", default: none)
  if left == none and right == none {
    _score-error(
      label + " barline",
      "barline dictionary does not select a boundary style",
      value: value,
      expected: "a supported left or right value",
      fix: "add a barline style or remove the empty dictionary",
    )
  }
  if left != none and left != "repeat-start" {
    _score-error(
      label + " barline left",
      "unsupported left barline",
      value: left,
      expected: "repeat-start or none",
      fix: "use repeat-start on the left boundary",
    )
  }
  if right != none and right not in ("repeat-end", "double", "final", "dashed") {
    _score-error(
      label + " barline right",
      "unsupported right barline",
      value: right,
      expected: "repeat-end, double, final, dashed, or none",
      fix: "choose one of the supported right-boundary styles",
    )
  }
  (left: left, right: right)
}

#let _normalize-boundary-mark(value, label) = {
  _validate-marking(value, label)
}

#let _normalize-ending(value, label) = {
  if value == none {
    return (label: none, start: false, stop: false)
  }
  if type(value) != dictionary {
    _score-error(
      label + " ending",
      "ending must be a dictionary",
      value: value,
      expected: "label plus start and/or stop",
      fix: "write ending: (label: \"1.\", start: true)",
    )
  }
  for field in value.keys() {
    if field != "label" and field != "start" and field != "stop" {
      _score-error(
        label + " ending",
        "ending has unknown field",
        value: field,
        expected: "label, start, or stop",
        fix: "remove or rename the unknown field",
      )
    }
  }
  let ending-label = value.at("label", default: none)
  let start = value.at("start", default: false)
  let stop = value.at("stop", default: false)
  if type(start) != bool or type(stop) != bool {
    _score-error(
      label + " ending",
      "start and stop must be booleans",
      value: value,
      expected: "true or false for each lifecycle flag",
      fix: "replace the invalid flag with a boolean",
    )
  }
  if type(ending-label) != str or ending-label.trim() == "" or (not start and not stop) {
    _score-error(
      label + " ending",
      "ending needs a non-empty label and at least one lifecycle flag",
      value: value,
      expected: "label: \"1.\" with start: true and/or stop: true",
      fix: "add the label and the intended start or stop flag",
    )
  }
  (label: ending-label, start: start, stop: stop)
}

#let _normalize-staves(staves, clef) = {
  if staves == none {
    return ((
      id: "staff",
      field: "notes",
      clef: _validate-clef(clef, "score clef"),
      label: none,
      short-label: none,
    ),)
  }
  if clef != "treble" {
    _score-error(
      "score clef",
      "clef applies only to the implicit single-staff form and cannot be combined with staves",
      value: clef,
      expected: "clefs inside each staves entry",
      fix: "remove the top-level clef argument and set every staff's clef field",
    )
  }
  if type(staves) != dictionary or staves.len() == 0 {
    _score-error(
      "score staves",
      "staves must be a non-empty dictionary",
      value: staves,
      expected: "staff-id dictionaries with clef fields",
      fix: "declare each staff or omit staves and use notes for one staff",
    )
  }
  let normalized-staves = ()
  for staff-id in staves.keys() {
    if staff-id in _measure-metadata-fields or staff-id == "notes" {
      _score-error(
        "staff id " + staff-id,
        "staff ID is reserved for bar metadata",
        value: staff-id,
        expected: "an ID not used by notes, key, time, clef, partial, tempo, harmony, barline, ending, rehearsal, or navigation",
        fix: "rename the staff and update its field in every bar",
      )
    }
    let staff-config = staves.at(staff-id)
    if type(staff-config) != dictionary {
      _score-error(
        "staff " + staff-id,
        "staff configuration must be a dictionary",
        value: staff-config,
        expected: "a dictionary containing clef and optional label fields",
        fix: "wrap the staff settings in parentheses",
      )
    }
    for field in staff-config.keys() {
      if field not in ("clef", "label", "short-label") {
        _score-error(
          "staff " + staff-id,
          "staff configuration has unknown field",
          value: field,
          expected: "clef, label, or short-label",
          fix: "remove or rename the unknown field",
        )
      }
    }
    let staff-clef = staff-config.at("clef", default: none)
    if staff-clef == none {
      _score-error(
        "staff " + staff-id,
        "staff configuration is missing clef",
        expected: "clef: \"treble\", \"bass\", \"alto\", or \"tenor\"",
        fix: "add a supported clef field",
      )
    }
    let staff-label = staff-config.at("label", default: none)
    let short-label = staff-config.at("short-label", default: none)
    if staff-label != none and (type(staff-label) != str or staff-label.trim() == "") {
      _score-error(
        "staff " + staff-id + " label",
        "label must be a non-empty string",
        value: staff-label,
        fix: "provide visible text or remove label",
      )
    }
    if short-label != none and (type(short-label) != str or short-label.trim() == "") {
      _score-error(
        "staff " + staff-id + " short-label",
        "short-label must be a non-empty string",
        value: short-label,
        fix: "provide visible abbreviated text or remove short-label",
      )
    }
    normalized-staves.push((
      id: staff-id,
      field: staff-id,
      clef: _validate-clef(staff-clef, "staff " + staff-id + " clef"),
      label: staff-label,
      short-label: short-label,
    ))
  }
  normalized-staves
}

#let _normalize-score-measures(staves, bars, clef, key, time, tempo) = {
  if type(bars) != array or bars.len() == 0 {
    _score-error(
      "score bars",
      "bars must be a non-empty array",
      value: bars,
      expected: "one or more bar dictionaries",
      fix: "add a dictionary such as (notes: \"c4:w\")",
    )
  }
  let staff-specs = _normalize-staves(staves, clef)
  let allowed-fields = _measure-metadata-fields + staff-specs.map(staff => staff.field)
  let normalized-measures = ()
  let current-key = _validate-key(key, "score key")
  let current-time = time
  let _ = _parse-time-rational(current-time, label: "score time")
  let current-clefs = (:)
  for staff in staff-specs {
    current-clefs.insert(staff.id, staff.clef)
  }
  let voice-counts = (:)
  for measure-index in range(bars.len()) {
    let measure-input = bars.at(measure-index)
    let measure-label = "bar " + str(measure-index + 1)
    if type(measure-input) != dictionary {
      _score-error(
        measure-label,
        "bar must be a dictionary",
        value: measure-input,
        expected: "staff content plus optional metadata fields",
        fix: "wrap the bar fields in parentheses",
      )
    }
    for field in measure-input.keys() {
      if field not in allowed-fields {
        _score-error(
          measure-label,
          "bar has unknown field",
          value: field,
          expected: allowed-fields.map(field => repr(field)).join(", "),
          fix: "remove the field or use a declared staff ID",
        )
      }
    }
    current-key = _validate-key(
      measure-input.at("key", default: current-key),
      measure-label + " key",
    )
    current-time = measure-input.at("time", default: current-time)
    let current-time-value = _parse-time-rational(
      current-time,
      label: measure-label + " time",
    )
    let partial = measure-input.at("partial", default: none)
    let partial-value = _parse-time-rational(
      partial,
      label: measure-label + " partial",
    )
    if (
      partial-value != none and current-time-value != none
        and not _rational-lte(partial-value, current-time-value)
    ) {
      _score-error(
        measure-label + " partial",
        "pickup duration is longer than the active meter",
        value: partial,
        expected: "a positive duration no greater than " + current-time,
        fix: "reduce partial or change the active time signature",
      )
    }
    let clef-change = measure-input.at("clef", default: none)
    if clef-change != none {
      if type(clef-change) == str {
        if staff-specs.len() != 1 {
          _score-error(
            measure-label + " clef",
            "a single clef string cannot target a multi-staff score",
            value: clef-change,
            expected: "a dictionary mapping declared staff IDs to clefs",
            fix: "write clef: (staff-id: \"bass\")",
          )
        }
        current-clefs.insert(
          staff-specs.first().id,
          _validate-clef(clef-change, measure-label + " clef"),
        )
      } else if type(clef-change) == dictionary {
        if clef-change.len() == 0 {
          _score-error(
            measure-label + " clef",
            "clef-change dictionary must not be empty",
            value: clef-change,
            fix: "map at least one declared staff ID to a supported clef or remove clef",
          )
        }
        for staff-id in clef-change.keys() {
          if not staff-specs.any(staff => staff.id == staff-id) {
            _score-error(
              measure-label + " clef",
              "clef change references an unknown staff",
              value: staff-id,
              expected: staff-specs.map(staff => staff.id).join(", "),
              fix: "use a declared staff ID",
            )
          }
          current-clefs.insert(
            staff-id,
            _validate-clef(
              clef-change.at(staff-id),
              measure-label + " clef " + staff-id,
            ),
          )
        }
      } else {
        _score-error(
          measure-label + " clef",
          "clef change has the wrong type",
          value: clef-change,
          expected: "a clef string for one staff or a staff-ID dictionary",
          fix: "quote the clef or map each changed staff to its clef",
        )
      }
    }
    let measure-voices = ()
    for (staff-index, staff) in staff-specs.enumerate() {
      let notes = measure-input.at(staff.field, default: none)
      if notes == none {
        _score-error(
          measure-label,
          "bar is missing content for staff " + staff.field,
          expected: "a non-empty event string or an array of one to four voice strings",
          fix: "add the " + staff.field + " field",
        )
      }
      let voice-sequences = if type(notes) == str { (notes,) } else if type(notes) == array {
        if notes.len() == 0 or notes.len() > 4 {
          _score-error(
            measure-label + " " + staff.field,
            "voice array has an unsupported size",
            value: notes.len(),
            expected: "one to four voice strings",
            fix: "add a voice or reduce the array to at most four voices",
          )
        }
        notes
      } else {
        _score-error(
          measure-label + " " + staff.field,
          "staff content has the wrong type",
          value: notes,
          expected: "a string or array of one to four strings",
          fix: "quote the event sequence or wrap voice strings in an array",
        )
      }
      let known-voice-count = voice-counts.at(staff.id, default: none)
      if known-voice-count == none {
        voice-counts.insert(staff.id, voice-sequences.len())
      } else if known-voice-count != voice-sequences.len() {
        _score-error(
          measure-label + " " + staff.field,
          "voice count changed from earlier bars",
          value: voice-sequences.len(),
          expected: str(known-voice-count) + " voices",
          fix: "keep the same number of voice strings for this staff in every bar",
        )
      }
      for (voice-index, voice-sequence) in voice-sequences.enumerate() {
        measure-voices.push((
          id: staff.id + ".voice" + str(voice-index + 1),
          staff-id: staff.id,
          staff-index: staff-index,
          layer-index: voice-index,
          layer-count: voice-sequences.len(),
          clef: current-clefs.at(staff.id),
          label: staff.label,
          short-label: staff.short-label,
          notes: _required-nonempty-string(
            voice-sequence,
            measure-label + " " + staff.field + " voice " + str(voice-index + 1),
          ),
        ))
      }
    }
    normalized-measures.push((
      key: current-key,
      time: current-time,
      partial: partial,
      tempo: _normalize-tempo(
        measure-input.at("tempo", default: if measure-index == 0 { tempo } else { none }),
        "tempo in bar " + str(measure-index + 1),
      ),
      harmony: measure-input.at("harmony", default: none),
      barline: _normalize-barline(
        measure-input.at("barline", default: none),
        measure-label,
      ),
      ending: _normalize-ending(
        measure-input.at("ending", default: none),
        measure-label,
      ),
      rehearsal: _normalize-boundary-mark(
        measure-input.at("rehearsal", default: none),
        measure-label + " rehearsal",
      ),
      navigation: _normalize-boundary-mark(
        measure-input.at("navigation", default: none),
        measure-label + " navigation",
      ),
      staff-count: staff-specs.len(),
      voices: measure-voices,
    ))
  }
  normalized-measures
}

// Parse, validate, and pre-compute shared positions for every measure.
#let _prepare-score-measures(staves, bars, clef, key, time, tempo, note-spacing: 3.1, beams: false) = {
  let normalized-measures = _normalize-score-measures(staves, bars, clef, key, time, tempo)
  let prepared-measures = ()
  let previous-key = none
  let previous-time = none
  let previous-clefs = (:)
  let pitch-anchors = (:)
  let duration-anchors = (:)
  for measure-index in range(normalized-measures.len()) {
    let normalized-measure = normalized-measures.at(measure-index)
    let validation-time = normalized-measure.at("partial", default: none)
    if validation-time == none {
      validation-time = normalized-measure.time
    }
    let prepared-voices = ()
    for voice in normalized-measure.voices {
      let voice-location = (
        "bar " + str(measure-index + 1)
          + ", staff " + voice.staff-id
          + ", voice " + str(voice.layer-index + 1)
      )
      let layout-response = _layout-sequence(
        voice.notes,
        clef: voice.clef,
        time: validation-time,
        anchor: pitch-anchors.at(voice.id, default: none),
        duration-anchor: duration-anchors.at(voice.id, default: none),
        location: voice-location,
      )
      let event-layouts = layout-response.layouts
      pitch-anchors.insert(voice.id, layout-response.anchor)
      duration-anchors.insert(voice.id, layout-response.duration_anchor)
      _validate-measure-duration(
        event-layouts,
        validation-time,
        "staff " + voice.staff-id + " voice " + str(voice.layer-index + 1),
        measure-index + 1,
      )
      let forced-direction = if voice.layer-count == 1 { none }
        else if calc.rem(voice.layer-index, 2) == 0 { "up" }
        else { "down" }
      let rest-offset = if voice.layer-count == 1 { 0 }
        else if calc.rem(voice.layer-index, 2) == 0 { 1.0 + calc.floor(voice.layer-index / 2) }
        else { -1.0 - calc.floor(voice.layer-index / 2) }
      let event-layouts = event-layouts.map(layout => layout + (
        stem-direction: forced-direction,
        rest-offset: rest-offset,
      ))
      prepared-voices.push((
        id: voice.id,
        staff-id: voice.staff-id,
        staff-index: voice.staff-index,
        layer-index: voice.layer-index,
        layer-count: voice.layer-count,
        clef: voice.clef,
        show-clef: measure-index == 0
          or voice.clef != previous-clefs.at(voice.staff-id, default: none),
        label: voice.label,
        short-label: voice.short-label,
        notes: voice.notes,
        layouts: event-layouts,
      ))
    }
    let harmony = _layout-harmony(
      normalized-measure.harmony,
      validation-time,
      measure-index + 1,
    )
    let spacing = _measure-positions(
      prepared-voices.map(voice => voice.layouts),
      harmony: harmony,
      note-spacing: note-spacing,
      beams: beams,
      key: normalized-measure.key,
    )
    prepared-measures.push((
      key: normalized-measure.key,
      previous-key: previous-key,
      time: normalized-measure.time,
      partial: normalized-measure.at("partial", default: none),
      tempo: normalized-measure.at("tempo", default: none),
      harmony: harmony,
      barline: normalized-measure.barline,
      ending: normalized-measure.ending,
      rehearsal: normalized-measure.rehearsal,
      navigation: normalized-measure.navigation,
      staff-count: normalized-measure.staff-count,
      voices: prepared-voices,
      positions: spacing.positions,
      content-width: spacing.width,
      show-key: measure-index == 0 or normalized-measure.key != previous-key,
      show-time: measure-index == 0 or normalized-measure.time != previous-time,
      show-clef: prepared-voices.any(voice => voice.show-clef),
    ))
    for voice in prepared-voices {
      previous-clefs.insert(voice.staff-id, voice.clef)
    }
    previous-key = normalized-measure.key
    previous-time = normalized-measure.time
  }
  prepared-measures
}

// ---------------------------------------------------------------------------
// System packing and rendering
// ---------------------------------------------------------------------------

#let _min-staff-position(layouts) = {
  let minimum-position = none
  for layout in layouts {
    for item in layout.pitches {
      if minimum-position == none or item.staff_position < minimum-position {
        minimum-position = item.staff_position
      }
    }
  }
  if minimum-position == none { 2 } else { minimum-position }
}

#let _max-staff-position(layouts) = {
  let maximum-position = none
  for layout in layouts {
    for item in layout.pitches {
      if maximum-position == none or item.staff_position > maximum-position {
        maximum-position = item.staff_position
      }
    }
  }
  if maximum-position == none { 10 } else { maximum-position }
}

#let _lane-layouts-for-measures(measures) = {
  let lane-count = measures.first().voices.len()
  let lane-layouts = ()
  for voice-index in range(lane-count) {
    let layouts = ()
    for measure in measures {
      layouts += measure.voices.at(voice-index).layouts
    }
    lane-layouts.push(layouts)
  }
  lane-layouts
}

#let _staff-layouts-for-measures(measures) = {
  let staff-layouts = ()
  for staff-index in range(measures.first().staff-count) {
    let layouts = ()
    for measure in measures {
      for voice in measure.voices {
        if voice.staff-index == staff-index {
          layouts += voice.layouts
        }
      }
    }
    staff-layouts.push(layouts)
  }
  staff-layouts
}

// Estimated vertical ink span of one event relative to its staff's bottom
// line: noteheads, stems (with the middle-line rule), articulation and
// fingering stacks, ornaments, and the fixed bands that dynamics,
// hairpins, pedal marks, and text occupy below the staff. Gap selection
// errs generous, so estimates round outward.
#let _layout-vertical-extent(layout) = {
  let high = 4.0
  let low = 0.0
  let note-ink-low = 0.0
  if not layout.rest and layout.pitches.len() > 0 {
    let ys = layout.pitches.map(p => staff-y(p.staff_position))
    let head-high = calc.max(..ys)
    let head-low = calc.min(..ys)
    let ink-high = head-high + 0.3
    let ink-low = head-low - 0.3
    if layout.stem {
      let direction = _layout-stem-direction(layout)
      if direction == "up" {
        ink-high = calc.max(ink-high, head-high + 3.5, 2.0)
      } else {
        ink-low = calc.min(ink-low, head-low - 3.5, 2.0)
      }
    }
    let articulations = _event-articulations(layout)
    if articulations.len() > 0 {
      // Stem direction here ignores beam grouping, so reserve the stack on
      // both sides rather than guessing wrong.
      let above = _articulation-stack(articulations, ys, 1, 0.0).last()
      let below = _articulation-stack(articulations, ys, -1, 0.0).last()
      ink-high = calc.max(ink-high, above.y + _articulation-height(above.mark) / 2)
      ink-low = calc.min(ink-low, below.y - _articulation-height(below.mark) / 2)
    }
    if _annotation-with-prefix(layout, "f=") != none {
      ink-high = calc.max(ink-high + 1.6, 4.56 + 0.95)
    }
    if _has-annotation(layout, "turn") or _has-annotation(layout, "chromatic-turn") {
      ink-high = calc.max(ink-high, head-high + 4.4)
    }
    // A slur endpoint implies a bow arching a couple of spaces past the
    // outermost head on the side away from the stem.
    let slurred = layout.annotations.any(annotation => {
      let annotation-text = str(annotation)
      (
        annotation-text.starts-with("s")
          and (annotation-text.ends-with("(") or annotation-text.ends-with(")"))
      )
    })
    if slurred {
      if layout.stem and _layout-stem-direction(layout) == "up" {
        ink-low = calc.min(ink-low, head-low - 2.5)
      } else {
        ink-high = calc.max(ink-high, head-high + 2.5)
      }
    }
    high = calc.max(high, ink-high)
    low = calc.min(low, ink-low)
    note-ink-low = calc.min(note-ink-low, ink-low)
  }
  // A dynamic letter hangs its full glyph below the event's deepest ink.
  if _annotation-with-prefix(layout, "dyn=") != none {
    low = calc.min(low, -2.7, note-ink-low - 2.7)
  }
  if _annotation-with-prefix(layout, "text=") != none { low = calc.min(low, -2.4) }
  if _annotation-with-prefix(layout, "text-below=") != none { low = calc.min(low, -7.8) }
  for annotation in layout.annotations {
    let annotation-text = str(annotation)
    if (
      annotation-text.starts-with("h")
        and (
          annotation-text.ends-with("<")
            or annotation-text.ends-with(">")
            or annotation-text.ends-with("!")
        )
    ) {
      // Hairpins ride the shared dynamics baseline, which sinks below the
      // system's deepest note ink.
      low = calc.min(low, -3.6, note-ink-low - 2.4)
    } else if (
      annotation-text.starts-with("p")
        and (annotation-text.ends-with("(") or annotation-text.ends-with(")"))
    ) {
      low = calc.min(low, -7.8)
    }
  }
  (high: high, low: low)
}

#let _voice-vertical-extent(layouts) = {
  let high = 4.0
  let low = 0.0
  for layout in layouts {
    let extent = _layout-vertical-extent(layout)
    high = calc.max(high, extent.high)
    low = calc.min(low, extent.low)
  }
  (high: high, low: low)
}

#let _staff-stack(voice-layouts, staff-gap: none) = {
  let voice-count = voice-layouts.len()
  let bottom-map = (:)
  let current-bottom = 0
  let lower-high = _voice-vertical-extent(voice-layouts.last()).high
  bottom-map.insert(str(voice-count - 1), current-bottom)
  if voice-count > 1 {
    for voice-index in range(voice-count - 2, -1, step: -1) {
      let extent = _voice-vertical-extent(voice-layouts.at(voice-index))
      let gap = if staff-gap == none {
        calc.max(7, lower-high - extent.low + 1.2)
      } else {
        staff-gap
      }
      current-bottom += gap
      bottom-map.insert(str(voice-index), current-bottom)
      lower-high = extent.high
    }
  }
  (
    bottoms: bottom-map,
    bottom: bottom-map.at(str(voice-count - 1)),
    top: bottom-map.at("0") + 4,
  )
}

#let _left-bar-x-for-group(group-style, measures, staff-gap) = {
  if group-style != "brace" {
    return _default-left-bar-x
  }
  let stack = _staff-stack(_staff-layouts-for-measures(measures), staff-gap: staff-gap)
  let brace-width = brace-width-for-span(stack.top - stack.bottom)
  calc.max(
    _default-left-bar-x,
    brace-width + _group-symbol-to-bar-gap + 0.12,
  )
}

// LilyPond reserves an instrument-name column before the grouped system.
// Full labels belong to the first system; short labels belong to later ones.
#let _staff-label-reserve(voices, unit, short: false) = {
  let widest = 0
  for voice in voices {
    if voice.at("layer-index", default: 0) != 0 { continue }
    let label = if short { voice.short-label } else { voice.label }
    if label != none {
      widest = calc.max(widest, measure(text(size: unit, label)).width / unit)
    }
  }
  if widest == 0 { 0 } else { widest + _staff-label-to-group-gap }
}

#let _measure-prefix-in-system(measure, is-system-start, staff-x, clef-x) = {
  let prefix = if is-system-start {
    _prologue-start-x(
      measure.key,
      measure.time,
      previous-key: measure.at("previous-key"),
      staff-x: staff-x,
      clef-x: clef-x,
    ) - staff-x
  } else {
    _inline-signature-note-start(
      0,
      measure.key,
      measure.time,
      measure.at("show-key"),
      measure.at("show-time"),
      show-clef: measure.at("show-clef"),
      previous-key: measure.at("previous-key"),
      repeat-start: measure.barline.left == "repeat-start",
    )
  }
  let repeat-gap = if is-system-start and measure.barline.left == "repeat-start" {
    _system-repeat-start-gap
  } else {
    0
  }
  prefix + repeat-gap
}

#let _boundary-mark-min-width(item) = {
  let width = 0
  if item.rehearsal != none {
    width = calc.max(
      width,
      // Include the rendered type size, box inset, boundary offset, and the
      // same outward padding LilyPond applies to rehearsal marks.
      measure(text(size: 8pt * 1.12, weight: "bold", item.rehearsal)).width / 8pt + 1.2,
    )
  }
  if item.navigation != none {
    let navigation-width = if type(item.navigation) == str and item.navigation == "segno" {
      3.2
    } else if type(item.navigation) == str and item.navigation == "coda" {
      4.6
    } else {
      measure(text(size: 8pt * 1.02, style: "italic", item.navigation)).width / 8pt + 1.2
    }
    width = calc.max(width, navigation-width)
  }
  width
}

#let _measure-width-in-system(measure, is-system-start, staff-x, clef-x) = {
  let prefix = _measure-prefix-in-system(measure, is-system-start, staff-x, clef-x)
  let repeat-end-gap = if measure.barline.right == "repeat-end" {
    _repeat-side-clearance
  } else {
    0
  }
  // Compound barlines are moved inward at a system end so their outer edge
  // terminates the staff. Reserve their full right-hand inset in the measure
  // width so the final note keeps the same optical clearance under compression.
  let end-barline-gap = if measure.barline.right == "repeat-end" {
    barline-separation / 2 + thick-barline-thickness
  } else if measure.barline.right == "final" {
    (thin-barline-thickness + barline-separation + thick-barline-thickness) / 2
  } else if measure.barline.right == "double" {
    barline-separation / 2 + thin-barline-thickness
  } else {
    0
  }
  calc.max(
    4.5,
    prefix + measure.content-width + repeat-end-gap + end-barline-gap,
    _boundary-mark-min-width(measure),
  )
}

// LilyPond-like line breaking permits modest compression, but evaluates all
// legal barline partitions instead of taking the first line that overflows.
#let _minimum-justification-scale = 0.82
#let _density-adjustment = 0.65

#let _line-break-badness(scale, final-single: false) = {
  let compression = calc.max(0, 1 - scale)
  let expansion = calc.max(0, scale - 1)
  let compression-cost = calc.pow(compression / (1 - _minimum-justification-scale), 2)
  let expansion-cost = calc.pow(expansion / _density-adjustment, 2)
  let final-single-cost = if final-single and expansion > 0 {
    expansion-cost
  } else {
    0
  }
  compression-cost + expansion-cost + final-single-cost
}

#let _adjacent-line-badness(left-scale, right-scale) = {
  calc.pow((left-scale - right-scale) / _density-adjustment, 2) * 0.35
}

// Mark-aware justification treats each boundary mark's measured extent as a
// hard floor. Remaining musical space is still stretchable, so systems end at
// the requested right margin without compressing long navigation text into the
// following bar.
#let _allocate-measure-widths(measures, widths, prefixes, available, ragged: false) = {
  let natural = ()
  let minimum = ()
  for measure-index in range(widths.len()) {
    let flexible = widths.at(measure-index) - prefixes.at(measure-index)
    natural.push(flexible)
    minimum.push(calc.max(
      0,
      _boundary-mark-min-width(measures.at(measure-index)) - prefixes.at(measure-index),
    ))
  }
  let natural-total = natural.sum()
  let minimum-total = minimum.sum()
  if available + 0.0001 < minimum-total {
    return none
  }

  let allocated = ()
  if ragged and available > natural-total {
    allocated = natural
  } else if available >= natural-total {
    let scale = available / natural-total
    allocated = natural.map(value => value * scale)
  } else {
    let compressible = natural-total - minimum-total
    let scale = if compressible <= 0 { 0 } else {
      (available - minimum-total) / compressible
    }
    for measure-index in range(natural.len()) {
      allocated.push(
        minimum.at(measure-index)
          + (natural.at(measure-index) - minimum.at(measure-index)) * scale,
      )
    }
  }

  let density = none
  for measure-index in range(natural.len()) {
    if natural.at(measure-index) > 0 {
      let ratio = allocated.at(measure-index) / natural.at(measure-index)
      density = if density == none { ratio } else { calc.min(density, ratio) }
    }
  }
  if density == none { density = 1 }
  (
    widths: range(widths.len()).map(i => prefixes.at(i) + allocated.at(i)),
    density: density,
  )
}

#let _line-break-candidate(
  measures,
  start,
  stop,
  max-width,
  left-bar-x,
  indent,
  short-indent,
  first-label-reserve,
  short-label-reserve,
  ragged-right,
  ragged-last,
) = {
  let is-first-system = start == 0
  let name-left = if is-first-system { indent } else { short-indent }
  let label-reserve = if is-first-system { first-label-reserve } else { short-label-reserve }
  let system-left-bar-x = left-bar-x + name-left + label-reserve
  let widths = ()
  let prefixes = ()
  let flexible-width = 0

  for index in range(start, stop) {
    let is-first-in-system = index == start
    let measure = measures.at(index)
    let prefix = _measure-prefix-in-system(
      measure,
      is-first-in-system,
      system-left-bar-x,
      system-left-bar-x + _system-clef-after-barline-gap,
    )
    let measure-width = _measure-width-in-system(
      measure,
      is-first-in-system,
      system-left-bar-x,
      system-left-bar-x + _system-clef-after-barline-gap,
    )
    widths.push(measure-width)
    prefixes.push(prefix)
    flexible-width += measure-width - prefix
  }

  let available-flexible-width = max-width - system-left-bar-x - prefixes.sum()
  let justified-density = available-flexible-width / flexible-width
  let ragged = ragged-right == true or (
    stop == measures.len() and (
      ragged-last or (ragged-right == auto and start == 0)
    )
  )
  let allocation = _allocate-measure-widths(
    measures.slice(start, stop),
    widths,
    prefixes,
    available-flexible-width,
    ragged: ragged and justified-density > 1,
  )
  if allocation == none {
    return none
  }
  let density = allocation.density
  // A multi-measure line that cannot reach this density must break; an
  // exceptionally wide individual measure remains legal because it cannot be
  // divided at a barline.
  if density < _minimum-justification-scale and stop - start > 1 {
    return none
  }
  (
    start: start,
    stop: stop,
    density: density,
    badness: _line-break-badness(
      density,
      final-single: stop == measures.len() and stop - start == 1,
    ),
    system: (
      start: start,
      widths: widths,
      natural-width: system-left-bar-x + widths.sum(),
      left-bar-x: system-left-bar-x,
      name-left: name-left,
      label-reserve: label-reserve,
    ),
  )
}

#let _pack-score-systems(
  measures,
  max-width,
  left-bar-x,
  indent,
  short-indent,
  first-label-reserve,
  short-label-reserve,
  ragged-right,
  ragged-last,
) = {
  let candidates = ()
  for start in range(measures.len()) {
    for stop in range(start + 1, measures.len() + 1) {
      let candidate = _line-break-candidate(
        measures,
        start,
        stop,
        max-width,
        left-bar-x,
        indent,
        short-indent,
        first-label-reserve,
        short-label-reserve,
        ragged-right,
        ragged-last,
      )
      if candidate != none {
        candidates.push(candidate)
      }
    }
  }

  // Dynamic programming over legal system candidates. A state retains the
  // previous system's density so the scorer can prefer even neighboring lines.
  let best = (:)
  for candidate-index in range(candidates.len()) {
    let candidate = candidates.at(candidate-index)
    let state = if candidate.start == 0 {
      (cost: candidate.badness, systems: (candidate.system,), density: candidate.density)
    } else {
      let selected = none
      for previous-index in range(candidate-index) {
        let previous = candidates.at(previous-index)
        if previous.stop != candidate.start { continue }
        let prior = best.at(str(previous-index), default: none)
        if prior == none { continue }
        let cost = prior.cost + candidate.badness + _adjacent-line-badness(
          prior.density,
          candidate.density,
        )
        if selected == none or cost < selected.cost {
          selected = (
            cost: cost,
            systems: prior.systems + (candidate.system,),
            density: candidate.density,
          )
        }
      }
      selected
    }
    if state != none {
      best.insert(str(candidate-index), state)
    }
  }

  let selected = none
  for candidate-index in range(candidates.len()) {
    let candidate = candidates.at(candidate-index)
    let state = best.at(str(candidate-index), default: none)
    if candidate.stop == measures.len() and state != none and {
      selected == none or state.cost < selected.cost
    } {
      selected = state
    }
  }
  if selected == none {
    _score-error(
      "score layout",
      "no legal system partition fits the requested width",
      value: max-width,
      expected: "enough staff-space width for every system prologue, label, and complete bar",
      fix: "increase width, reduce indent or note-spacing, shorten labels, or disable wrap",
    )
  }
  selected.systems
}

#let _finalize-systems(systems, max-width, ragged-right, ragged-last) = {
  let all-ragged = if ragged-right == auto { systems.len() == 1 } else { ragged-right }
  let finalized-systems = ()
  for (system-index, system) in systems.enumerate() {
    let is-last = system-index + 1 == systems.len()
    let width = if all-ragged or (is-last and ragged-last) {
      system.natural-width
    } else {
      max-width
    }
    finalized-systems.push((
      start: system.start,
      widths: system.widths,
      natural-width: system.natural-width,
      width: width,
      left-bar-x: system.left-bar-x,
      name-left: system.name-left,
      label-reserve: system.label-reserve,
    ))
  }
  finalized-systems
}

#let _collect-ending-spans(measures) = {
  let spans = ()
  let open = none
  for measure-index in range(measures.len()) {
    let ending = measures.at(measure-index).ending
    if ending.start {
      if open != none {
        _score-error(
          "bar " + str(measure-index + 1) + " ending",
          "ending " + open.label + " is still open when " + ending.label + " starts",
          expected: "the open ending to stop before another starts",
          fix: "add a matching stop or remove the overlapping start",
        )
      }
      open = (label: ending.label, start: measure-index)
    }
    if ending.stop {
      if open == none {
        _score-error(
          "bar " + str(measure-index + 1) + " ending",
          "ending " + ending.label + " stops without opening",
          expected: "a matching start in this or an earlier bar",
          fix: "add the start or remove this stop",
        )
      }
      if ending.label != open.label {
        _score-error(
          "bar " + str(measure-index + 1) + " ending",
          "ending " + ending.label + " stops while " + open.label + " is open",
          expected: "the stop label to match " + open.label,
          fix: "use the same label on both lifecycle markers",
        )
      }
      spans.push((label: ending.label, start: open.start, stop: measure-index))
      open = none
    }
  }
  if open != none {
    _score-error(
      "score endings",
      "ending " + open.label + " opened in bar " + str(open.start + 1) + " was never stopped",
      expected: "a later bar with the same label and stop: true",
      fix: "add the matching stop marker",
    )
  }
  spans
}

#let _draw-barline-stroke(x, thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected) = {
  import cetz.draw: *
  let stroke = thickness * unit + black
  if connected {
    line((x, system-bottom), (x, system-top), stroke: stroke)
  } else {
    for voice-index in range(voice-count) {
      let bottom-y = bottom-map.at(str(voice-index))
      line((x, bottom-y), (x, bottom-y + 4), stroke: stroke)
    }
  }
}

#let _draw-repeat-dots(x, voice-count, bottom-map, unit) = {
  for voice-index in range(voice-count) {
    let bottom-y = bottom-map.at(str(voice-index))
    draw-augmentation-dot(x, bottom-y + 1.5, unit: unit, scale: 0.85)
    draw-augmentation-dot(x, bottom-y + 2.5, unit: unit, scale: 0.85)
  }
}

#let _draw-dashed-barline(x, staff-count, bottom-map, unit) = {
  import cetz.draw: *
  for staff-index in range(staff-count) {
    let bottom-y = bottom-map.at(str(staff-index))
    for step in range(6) {
      let y = bottom-y + step * 0.72
      line(
        (x, y),
        (x, calc.min(y + 0.38, bottom-y + 4)),
        stroke: thin-barline-thickness * unit + black,
      )
    }
  }
}

#let _barline-right-extent(backward: false, forward: false, kind: none) = {
  let thin-half = thin-barline-thickness / 2
  if backward and forward {
    barline-separation / 2 + thick-barline-thickness
  } else if backward or forward or kind == "final" {
    (thin-barline-thickness + barline-separation + thick-barline-thickness) / 2
  } else if kind == "double" {
    barline-separation / 2 + thin-barline-thickness
  } else {
    thin-half
  }
}

#let _draw-score-barline(
  x,
  voice-count,
  system-bottom,
  system-top,
  bottom-map,
  backward: false,
  forward: false,
  kind: none,
  connected: false,
  unit: 8pt,
) = {
  // Barline groups center on the musical boundary. Line thicknesses, the
  // edge-to-edge gap between locked barlines, and the dot standoff follow
  // the Bravura engraving defaults; repeat dots sit past the thin line.
  let thin-half = thin-barline-thickness / 2
  let thick-half = thick-barline-thickness / 2
  let dot-offset = repeat-barline-dot-separation + 0.17
  if backward and forward {
    let center-offset = barline-separation / 2 + thick-half
    _draw-barline-stroke(x - center-offset, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-barline-stroke(x + center-offset, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-repeat-dots(x - center-offset - thick-half - dot-offset, voice-count, bottom-map, unit)
    _draw-repeat-dots(x + center-offset + thick-half + dot-offset, voice-count, bottom-map, unit)
  } else if backward {
    let span = thin-barline-thickness + barline-separation + thick-barline-thickness
    let thin-center = x - span / 2 + thin-half
    let thick-center = x + span / 2 - thick-half
    _draw-barline-stroke(thin-center, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-barline-stroke(thick-center, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-repeat-dots(thin-center - thin-half - dot-offset, voice-count, bottom-map, unit)
  } else if forward {
    let span = thin-barline-thickness + barline-separation + thick-barline-thickness
    let thick-center = x - span / 2 + thick-half
    let thin-center = x + span / 2 - thin-half
    _draw-barline-stroke(thick-center, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-barline-stroke(thin-center, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-repeat-dots(thin-center + thin-half + dot-offset, voice-count, bottom-map, unit)
  } else if kind == "double" {
    let offset = (barline-separation + thin-barline-thickness) / 2
    _draw-barline-stroke(x - offset, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-barline-stroke(x + offset, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
  } else if kind == "final" {
    let span = thin-barline-thickness + barline-separation + thick-barline-thickness
    let thin-center = x - span / 2 + thin-half
    let thick-center = x + span / 2 - thick-half
    _draw-barline-stroke(thin-center, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
    _draw-barline-stroke(thick-center, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
  } else if kind == "dashed" {
    _draw-dashed-barline(x, voice-count, bottom-map, unit)
  } else {
    _draw-barline-stroke(x, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, unit, connected)
  }
}

#let _draw-system-endings(ending-spans, system, measure-starts, unit, left-bar-x, system-width, volta-y) = {
  import cetz.draw: *
  let system-last = system.start + system.widths.len() - 1
  let stroke = repeat-ending-line-thickness * unit + black
  for span in ending-spans {
    if span.stop >= system.start and span.start <= system-last {
      let starts-here = span.start >= system.start
      let stops-here = span.stop <= system-last
      let start-x = if starts-here {
        measure-starts.at(span.start - system.start)
      } else {
        left-bar-x
      }
      let stop-x = if stops-here {
        let local-stop = span.stop - system.start
        measure-starts.at(local-stop) + system.widths.at(local-stop)
      } else {
        system-width
      }
      line((start-x, volta-y), (stop-x, volta-y), stroke: stroke)
      if starts-here {
        line((start-x, volta-y - 1.4), (start-x, volta-y), stroke: stroke)
        content(
          (start-x + 0.18, volta-y - 0.18),
          text(size: unit * 1.1, span.label),
          anchor: "north-west",
          padding: 0pt,
        )
      }
      if stops-here {
        line((stop-x, volta-y), (stop-x, volta-y - 1.1), stroke: stroke)
      }
    }
  }
}

#let _render-score-system(
  measures,
  system,
  unit,
  beams: false,
  staff-gap: none,
  composer: none,
  ending-spans: (),
  group-style: "none",
  bar-numbers: false,
  first-bar-number: 1,
) = {
  let system-measures = measures.slice(system.start, system.start + system.widths.len())
  let lane-count = system-measures.first().voices.len()
  let staff-count = system-measures.first().staff-count
  let staff-layouts = _staff-layouts-for-measures(system-measures)

  // Stack staves bottom-up, leaving room for ledger-line excursions.
  // Extents are relative to each staff's own bottom line.
  let stack = _staff-stack(staff-layouts, staff-gap: staff-gap)
  let bottom-map = stack.bottoms
  let system-bottom = stack.bottom
  let system-top = stack.top
  let left-bar-x = system.left-bar-x
  let clef-x = left-bar-x + _system-clef-after-barline-gap
  let system-width = system.width

  // Prefixes (clefs, signatures, and repeat clearance) retain their exact
  // geometry. Only the timed body of each measure stretches or contracts.
  let prefixes = ()
  for measure-index in range(system.widths.len()) {
    let prefix = _measure-prefix-in-system(
      system-measures.at(measure-index),
      measure-index == 0,
      left-bar-x,
      clef-x,
    )
    prefixes.push(prefix)
  }
  let available-flexible-width = system-width - left-bar-x - prefixes.sum()
  let allocation = _allocate-measure-widths(
    system-measures,
    system.widths,
    prefixes,
    available-flexible-width,
    ragged: system-width == system.natural-width,
  )
  let measure-widths = allocation.widths
  let measure-justifications = range(system.widths.len()).map(measure-index => (
    (measure-widths.at(measure-index) - prefixes.at(measure-index))
      / (system.widths.at(measure-index) - prefixes.at(measure-index))
  ))

  let measure-starts = ()
  let current-x = left-bar-x
  for measure-width in measure-widths {
    measure-starts.push(current-x)
    current-x += measure-width
  }

  let placed-by-voice = ()
  for _ in range(lane-count) {
    placed-by-voice.push(())
  }
  let first-note-start = _prologue-start-x(
    system-measures.first().key,
    system-measures.first().time,
    previous-key: system-measures.first().at("previous-key"),
    staff-x: left-bar-x,
    clef-x: clef-x,
  )
  let system-repeat-gap = if system-measures.first().barline.left == "repeat-start" {
    _system-repeat-start-gap
  } else {
    0
  }
  let continuation-left-x = first-note-start + system-repeat-gap - 1.1
  let continuation-right-x = system-width - 0.15
  for measure-index in range(system-measures.len()) {
    let measure = system-measures.at(measure-index)
    let measure-start = measure-starts.at(measure-index)
    let note-start = if measure-index == 0 {
      first-note-start + system-repeat-gap
    } else {
      _inline-signature-note-start(
        measure-start,
        measure.key,
        measure.time,
        measure.at("show-key"),
        measure.at("show-time"),
        show-clef: measure.at("show-clef"),
        previous-key: measure.at("previous-key"),
        repeat-start: measure.barline.left == "repeat-start",
      )
    }
    for voice-index in range(lane-count) {
      let voice = measure.voices.at(voice-index)
      placed-by-voice.at(voice-index).push(
        _place-voice-at-onsets(
          voice.layouts,
          measure.positions,
          note-start,
          scale: measure-justifications.at(measure-index),
          voice: voice,
          all-voices: measure.voices,
        )
      )
    }
  }
  let slurs-by-voice = ()
  for voice-index in range(lane-count) {
    let voice = system-measures.first().voices.at(voice-index)
    slurs-by-voice.push(_collect-system-slurs(
      placed-by-voice.at(voice-index),
      voice.id,
      bottom-y: bottom-map.at(str(voice.staff-index)),
      continuation-left-x: continuation-left-x,
      continuation-right-x: continuation-right-x,
      beams: beams,
    ))
  }
  // Slur curves are settled before anything is drawn so fingerings and
  // ornaments can climb over the finished bows, and each voice's dynamics
  // share one system-wide baseline.
  let dynamics-baseline-by-voice = ()
  for voice-index in range(lane-count) {
    let staff-index = system-measures.first().voices.at(voice-index).staff-index
    let bottom-y = bottom-map.at(str(staff-index))
    let placed-flat = ()
    for placed in placed-by-voice.at(voice-index) {
      placed-flat += placed
    }
    dynamics-baseline-by-voice.push(_dynamics-baseline(placed-flat, bottom-y: bottom-y))
  }
  let slur-layouts-by-voice = ()
  for voice-index in range(lane-count) {
    let staff-index = system-measures.first().voices.at(voice-index).staff-index
    let bottom-y = bottom-map.at(str(staff-index))
    let placed-flat = ()
    for placed in placed-by-voice.at(voice-index) {
      placed-flat += placed
    }
    let obstacles = ()
    for placed in placed-by-voice.at(voice-index) {
      for item in placed {
        if item.layout.rest or item.layout.pitches.len() == 0 { continue }
        let y-values = item.layout.pitches.map(p => staff-y(p.staff_position, bottom-y: bottom-y))
        // A notehead is one staff space tall, so its ink reaches half a
        // space beyond the outermost pitch centers.
        let head-top = calc.max(..y-values) + 0.5
        let head-bottom = calc.min(..y-values) - 0.5
        let direction = _annotation-stem-direction(
          item,
          placed,
          beams: beams,
          bottom-y: bottom-y,
        )
        let stem-geometry = _event-stem-geometry(
          item.layout,
          item.x,
          bottom-y: bottom-y,
          direction-override: direction,
        )
        let outer-top = if stem-geometry != none and stem-geometry.direction == "up" {
          calc.max(stem-geometry.point.at(1), head-top)
        } else {
          head-top
        }
        let outer-bottom = if stem-geometry != none and stem-geometry.direction == "down" {
          calc.min(stem-geometry.point.at(1), head-bottom)
        } else {
          head-bottom
        }
        obstacles.push((
          x: item.x,
          head-top: head-top,
          head-bottom: head-bottom,
          outer-top: outer-top,
          outer-bottom: outer-bottom,
        ))
      }
    }
    let clearance-obstacles = ()
    for placed in placed-by-voice.at(voice-index) {
      for item in placed {
        clearance-obstacles += _slur-clearance-obstacles(
          item,
          placed,
          bottom-y: bottom-y,
          beams: beams,
        )
      }
    }
    slur-layouts-by-voice.push(_layout-slurs(
      slurs-by-voice.at(voice-index),
      obstacles: obstacles,
      clearance-obstacles: clearance-obstacles,
      bottom-y: bottom-y,
    ))
  }

  let system-last = system.start + system.widths.len() - 1
  let has-system-ending = ending-spans.any(span =>
    span.stop >= system.start and span.start <= system-last
  )
  let has-harmony = system-measures.any(measure => measure.harmony.len() > 0)
  let volta-y = system-top + 2.0
  if has-system-ending {
    for placed in placed-by-voice.first() {
      for item in placed {
        volta-y = calc.max(
          volta-y,
          _event-decoration-top(
            item,
            placed,
            beams: beams,
            bottom-y: bottom-map.at(str(system-measures.first().voices.first().staff-index)),
          ) + 1.35,
        )
      }
    }
    // Slurs are intentionally given their own air above note and annotation
    // bounds because their final clearance shift depends on the whole span.
    if slurs-by-voice.first().len() > 0 {
      volta-y += 2.2
    }
  }
  let header-y-base = if has-system-ending {
    calc.max(system-top + 4.6, volta-y + 1.6)
  } else {
    system-top + 4.6
  }
  let harmony-y = system-top + 2.4
  let header-y = if has-harmony { calc.max(header-y-base, harmony-y + 3.0) } else { header-y-base }

  block(width: system-width * unit, {
    music-canvas(length: unit, keep-origin: true, {
    if group-style == "brace" {
      draw-grand-brace(left-bar-x - _group-symbol-to-bar-gap, system-bottom, system-top, unit: unit)
    } else if group-style == "bracket" {
      draw-staff-bracket(left-bar-x - _group-symbol-to-bar-gap - 0.36, system-bottom, system-top, unit: unit)
    } else if group-style == "line" {
      draw-staff-group-line(left-bar-x - _group-symbol-to-bar-gap - 0.42, system-bottom, system-top, unit: unit)
    }
    // Instrument names use LilyPond's system-start model: full labels on the
    // first system, optional short labels thereafter. The shared name column
    // keeps them centered horizontally and each label centers on its staff.
    if system.label-reserve > 0 {
      for staff-index in range(staff-count) {
        let voice = system-measures.first().voices.find(voice => (
          voice.staff-index == staff-index and voice.layer-index == 0
        ))
        let label = if system.start == 0 { voice.label } else { voice.short-label }
        if label != none {
          import cetz.draw: *
          content(
            (system.name-left + system.label-reserve / 2, bottom-map.at(str(staff-index)) + 2),
            text(size: unit, label),
            anchor: "center",
            padding: 0pt,
          )
        }
      }
    }
    for staff-index in range(staff-count) {
      draw-staff-lines(system-width - left-bar-x, x: left-bar-x, bottom-y: bottom-map.at(str(staff-index)), unit: unit)
    }
    // A multi-staff system opens with a barline joining all its staves,
    // whatever group symbol (or none) sits to its left.
    if staff-count > 1 {
      import cetz.draw: *
      line(
        (left-bar-x, system-bottom),
        (left-bar-x, system-top),
        stroke: thin-barline-thickness * unit + black,
      )
    }

    if composer != none {
      import cetz.draw: *
      content(
        (system-width - 0.3, header-y + 0.8),
        text(size: unit * 1.18, composer),
        anchor: "east",
        padding: 0pt,
      )
    }

    for measure-index in range(system-measures.len()) {
      let measure = system-measures.at(measure-index)
      let measure-start = measure-starts.at(measure-index)
      let note-start = if measure-index == 0 {
        first-note-start + system-repeat-gap
      } else {
        _inline-signature-note-start(
          measure-start,
          measure.key,
          measure.time,
          measure.at("show-key"),
          measure.at("show-time"),
          show-clef: measure.at("show-clef"),
          previous-key: measure.at("previous-key"),
          repeat-start: measure.barline.left == "repeat-start",
        )
      }
      if measure.tempo != none {
        _draw-tempo(measure.tempo, measure-start + 0.4, header-y, unit)
      }
      if measure.rehearsal != none {
        import cetz.draw: *
        content(
          (measure-start + 0.18, system-top + 2.15),
          box(
            inset: 0.18em,
            stroke: 0.10 * unit + black,
            text(size: unit * 1.12, weight: "bold", measure.rehearsal),
          ),
          anchor: "south-west",
          padding: 0pt,
        )
      }
      if measure.navigation != none {
        import cetz.draw: *
        if type(measure.navigation) == str and measure.navigation in ("segno", "coda") {
          draw-navigation-symbol(
            measure.navigation,
            measure-start + 1.5,
            system-top + if measure.rehearsal == none { 3.0 } else { 4.55 },
            unit: unit,
            scale: 0.62,
          )
        } else {
          content(
            (measure-start + 0.18, system-top + if measure.rehearsal == none { 2.0 } else { 3.65 }),
            text(size: unit * 1.02, style: "italic", measure.navigation),
            anchor: "south-west",
            padding: 0pt,
          )
        }
      }
      let show-bar-number = bar-numbers == "all" or (
        bar-numbers == "systems" and measure-index == 0 and system.start > 0
      )
      if show-bar-number {
        import cetz.draw: *
        content(
          // LilyPond places BarNumber (outside-staff priority 100) before and
          // therefore closer to the staff than RehearsalMark (priority 1500).
          (measure-start + 0.12, system-top + 1.05),
          text(
            size: unit * 0.78,
            str(first-bar-number + system.start + measure-index),
          ),
          anchor: "south-west",
          padding: 0pt,
        )
      }
      for harmony in measure.harmony {
        import cetz.draw: *
        // Chord names are time-point items: their center sits at the onset
        // where the harmony becomes active, independent of its duration.
        let onset-x = (
          note-start
            + measure.positions.at(str(_onset-key(harmony.onset)))
              * measure-justifications.at(measure-index)
        )
        content(
          (
            onset-x,
            harmony-y,
          ),
          text(size: unit * 1.12, weight: "bold", harmony.symbol),
          anchor: "south",
          padding: 0pt,
        )
      }
      for voice-index in range(lane-count) {
        let voice = measure.voices.at(voice-index)
        let bottom-y = bottom-map.at(str(voice.staff-index))
        if voice.layer-index == 0 and measure-index == 0 {
          _draw-prologue(
            voice.clef,
            measure.key,
            measure.time,
            previous-key: measure.at("previous-key"),
            bottom-y: bottom-y,
            unit: unit,
            staff-x: left-bar-x,
            clef-x: clef-x,
          )
        } else if voice.layer-index == 0 {
          _draw-inline-signature(
            voice.clef,
            measure.key,
            measure.time,
            measure-start,
            previous-key: measure.at("previous-key"),
            bottom-y: bottom-y,
            unit: unit,
            show-key: measure.at("show-key"),
            show-time: measure.at("show-time"),
            show-clef: voice.show-clef,
            reserve-clef: measure.at("show-clef"),
          )
        }
        let global-measure-index = system.start + measure-index
        let tied-from-previous = global-measure-index > 0 and {
          let previous-layouts = measures.at(global-measure-index - 1).voices.at(voice-index).layouts
          previous-layouts.len() > 0 and previous-layouts.last().at("tie_to_next", default: false)
        }
        _draw-placed-sequence(
          placed-by-voice.at(voice-index).at(measure-index),
          bottom-y: bottom-y,
          unit: unit,
          beams: beams,
          key: measure.key,
          tied-from-previous: tied-from-previous,
        )
        _draw-tuplets(
          placed-by-voice.at(voice-index).at(measure-index),
          bottom-y: bottom-y,
          unit: unit,
          beams: beams,
        )
        _draw-placed-annotations(
          placed-by-voice.at(voice-index).at(measure-index),
          bottom-y: bottom-y,
          unit: unit,
          beams: beams,
          slur-layouts: slur-layouts-by-voice.at(voice-index),
          dynamics-baseline: dynamics-baseline-by-voice.at(voice-index),
        )
      }
    }

    for voice-index in range(lane-count) {
      let staff-index = system-measures.first().voices.at(voice-index).staff-index
      let bottom-y = bottom-map.at(str(staff-index))
      let placed-flat = ()
      for placed in placed-by-voice.at(voice-index) {
        placed-flat += placed
      }
      _draw-ties(
        _collect-ties(
          placed-flat,
          bottom-y: bottom-y,
          continuation-left-x: continuation-left-x,
          continuation-right-x: continuation-right-x,
          incoming: system.start > 0 and {
            let previous-layouts = measures.at(system.start - 1).voices.at(voice-index).layouts
            previous-layouts.len() > 0 and previous-layouts.last().at("tie_to_next", default: false)
          },
        ),
        unit: unit,
      )
      _draw-slur-bows(slur-layouts-by-voice.at(voice-index), unit: unit)
      _draw-hairpins(
        _collect-hairpins(placed-by-voice.at(voice-index)),
        if dynamics-baseline-by-voice.at(voice-index) == none {
          bottom-y - 3.2
        } else {
          dynamics-baseline-by-voice.at(voice-index)
        },
        unit: unit,
      )
      _draw-pedal-spans(
        _collect-pedal-spans(placed-by-voice.at(voice-index)),
        bottom-y - 7.0,
        unit: unit,
      )
    }

    _draw-system-endings(
      ending-spans,
      (start: system.start, widths: measure-widths, width: system-width),
      measure-starts,
      unit,
      left-bar-x,
      system-width,
      volta-y,
    )
    for boundary in range(system-measures.len() + 1) {
      let backward = boundary > 0 and system-measures.at(boundary - 1).barline.right == "repeat-end"
      let forward = boundary < system-measures.len() and system-measures.at(boundary).barline.left == "repeat-start"
      let barline-kind = if boundary > 0 { system-measures.at(boundary - 1).barline.right } else { none }
      let x = if boundary == 0 and forward {
        first-note-start - 0.6
      } else if boundary == 0 {
        left-bar-x
      } else {
        measure-starts.at(boundary - 1) + measure-widths.at(boundary - 1)
      }
      // Internal barline groups straddle their shared musical boundary. At a
      // system end, the group's outer right edge instead terminates the staff,
      // keeping all five staff lines visibly connected to the final stroke.
      if boundary == system-measures.len() {
        x -= _barline-right-extent(
          backward: backward,
          forward: forward,
          kind: barline-kind,
        )
      }
      _draw-score-barline(
        x,
        staff-count,
        system-bottom,
        system-top,
        bottom-map,
        backward: backward,
        forward: forward,
        kind: barline-kind,
        connected: group-style == "brace",
        unit: unit,
      )
    }
    })
  })
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

#let score(
  clef: "treble",
  staves: none,
  bars: (),
  key: "C",
  time: "4/4",
  tempo: none,
  composer: none,
  width: none,
  scale: 1.0,
  note-spacing: 3.1,
  beams: false,
  staff-gap: none,
  group: auto,
  wrap: true,
  indent: 0,
  short-indent: 0,
  ragged-right: auto,
  ragged-last: false,
  system-gap: 1.2em,
  bar-numbers: false,
  first-bar-number: 1,
) = {
  layout(size => context {
    let _ = _validate-clef(clef, "score clef")
    let _ = _validate-key(key, "score key")
    let _ = _parse-time-rational(time, label: "score time")
    let _ = _normalize-tempo(tempo, "score tempo")
    let _ = _validate-marking(composer, "score composer")
    _positive-number(scale, "scale")
    _positive-number(note-spacing, "note-spacing")
    _positive-number(width, "width", optional: true)
    _positive-number(staff-gap, "staff-gap", optional: true)
    _nonnegative-number(indent, "indent")
    _nonnegative-number(short-indent, "short-indent")
    _validate-system-gap(system-gap)
    if type(beams) != bool {
      _score-error(
        "score beams",
        "value must be a boolean",
        value: beams,
        expected: "true or false",
        fix: "choose whether automatic beam groups are drawn",
      )
    }
    if type(wrap) != bool {
      _score-error(
        "score wrap",
        "value must be a boolean",
        value: wrap,
        expected: "true or false",
        fix: "choose whether bars may wrap across systems",
      )
    }
    if ragged-right != auto and type(ragged-right) != bool {
      _score-error(
        "score ragged-right",
        "unsupported value",
        value: ragged-right,
        expected: "auto, true, or false",
        fix: "choose automatic, ragged, or justified system widths",
      )
    }
    if type(ragged-last) != bool {
      _score-error(
        "score ragged-last",
        "value must be a boolean",
        value: ragged-last,
        expected: "true or false",
        fix: "choose whether the final system stays at natural width",
      )
    }
    if bar-numbers != false and bar-numbers not in ("systems", "all") {
      _score-error(
        "score bar-numbers",
        "unsupported numbering mode",
        value: bar-numbers,
        expected: "false, systems, or all",
        fix: "disable numbering or choose a documented mode",
      )
    }
    if type(first-bar-number) != int or first-bar-number < 1 {
      _score-error(
        "score first-bar-number",
        "value must be a positive integer",
        value: first-bar-number,
        expected: "an integer greater than zero",
        fix: "set the number assigned to the first bar",
      )
    }
    if not wrap and short-indent != 0 {
      _score-error(
        "score short-indent",
        "short-indent has no later system when wrap is false",
        value: short-indent,
        expected: "zero for an unwrapped score",
        fix: "remove short-indent or enable wrap",
      )
    }
    if not wrap and ragged-last {
      _score-error(
        "score ragged-last",
        "ragged-last has no distinct effect on a one-system unwrapped score",
        value: ragged-last,
        expected: "false when wrap is false",
        fix: "remove ragged-last or enable wrap",
      )
    }
    if (
      not wrap and width != none
        and (ragged-right != false or ragged-last)
    ) {
      _score-error(
        "score width",
        "width is ignored by an unwrapped ragged score",
        value: width,
        expected: "ragged-right: false when combining width with wrap: false",
        fix: "set ragged-right to false or remove width",
      )
    }
    if not wrap and bar-numbers == "systems" {
      _score-error(
        "score bar-numbers",
        "systems mode cannot produce a later system when wrap is false",
        value: bar-numbers,
        expected: "false or all for an unwrapped score",
        fix: "use bar-numbers: \"all\" or enable wrap",
      )
    }
    let unit = 8pt * scale
    let measures = _prepare-score-measures(
      staves, bars, clef, key, time, tempo,
      note-spacing: note-spacing,
      beams: beams,
    )
    let lane-count = measures.first().voices.len()
    let staff-count = measures.first().staff-count
    if staff-count == 1 and staff-gap != none {
      _score-error(
        "score staff-gap",
        "staff-gap requires at least two staves",
        value: staff-gap,
        expected: "none for a single-staff score",
        fix: "remove staff-gap or declare multiple staves",
      )
    }
    let group-style = if group == auto {
      if staff-count == 1 { "none" }
      else if staff-count == 2 { "brace" }
      else { "bracket" }
    } else {
      if type(group) != str or group not in ("brace", "bracket", "line", "none") {
        _score-error(
          "score group",
          "unsupported grouping style",
          value: group,
          expected: "auto, brace, bracket, line, or none",
          fix: "choose a documented grouping style",
        )
      }
      if staff-count == 1 and group != "none" {
        _score-error(
          "score group",
          "a visible staff group requires at least two staves",
          value: group,
          expected: "auto or none for a single staff",
          fix: "remove group or declare the intended staves",
        )
      }
      group
    }
    let ending-spans = _collect-ending-spans(measures)
    for voice-index in range(lane-count) {
      let staff-layouts = measures.map(measure => measure.voices.at(voice-index).layouts)
      _validate-staff-slurs(
        staff-layouts,
        measures.first().voices.at(voice-index).id,
      )
      _validate-staff-ties(staff-layouts, measures.first().voices.at(voice-index).id)
      _validate-staff-direction-spans(staff-layouts, measures.first().voices.at(voice-index).id)
    }
    let left-bar-x = _left-bar-x-for-group(group-style, measures, staff-gap)
    let first-label-reserve = _staff-label-reserve(measures.first().voices, unit)
    let short-label-reserve = _staff-label-reserve(measures.first().voices, unit, short: true)
    let max-width = if width == none { size.width / unit } else { width }
    let packed-systems = if wrap {
      _pack-score-systems(
        measures,
        max-width,
        left-bar-x,
        indent,
        short-indent,
        first-label-reserve,
        short-label-reserve,
        ragged-right,
        ragged-last,
      )
    } else {
      let widths = ()
      let system-name-left = indent
      let system-left-bar-x = left-bar-x + system-name-left + first-label-reserve
      let system-width = system-left-bar-x
      for measure-index in range(measures.len()) {
        let measure-width = _measure-width-in-system(
          measures.at(measure-index),
          measure-index == 0,
          system-left-bar-x,
          system-left-bar-x + _system-clef-after-barline-gap,
        )
        widths.push(measure-width)
        system-width += measure-width
      }
      ((
        start: 0,
        widths: widths,
        natural-width: system-width,
        left-bar-x: system-left-bar-x,
        name-left: system-name-left,
        label-reserve: first-label-reserve,
      ),)
    }
    let systems = _finalize-systems(packed-systems, max-width, ragged-right, ragged-last)
    for system-index in range(systems.len()) {
      _render-score-system(
        measures,
        systems.at(system-index),
        unit,
        beams: beams,
          staff-gap: staff-gap,
          composer: if system-index == 0 { composer } else { none },
          ending-spans: ending-spans,
          group-style: group-style,
          bar-numbers: bar-numbers,
          first-bar-number: first-bar-number,
        )
      if system-index + 1 < systems.len() {
        v(system-gap)
      }
    }
  })
}

#let bar(
  notes,
  key: "C",
  time: none,
  clef: "treble",
) = {
  score(
    clef: clef,
    bars: ((notes: notes,),),
    key: key,
    time: time,
    wrap: false,
  )
}
