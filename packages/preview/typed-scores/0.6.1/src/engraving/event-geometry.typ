#import "primitives.typ": draw-augmentation-dot, notehead-geometry, notehead-half-width, staff-y, stem-anchor-dy

// Shared note-event geometry and duration-derived engraving decisions.

#let _default-stem-length = 3.5 - stem-anchor-dy
#let _accidental-gap = 0.25
#let _dot-gap-from-head = 0.4
#let _dot-step = 0.55
#let _min-onset-step = 1.0
#let _grace-note-step = 1.05
#let _grace-main-gap = 0.42
// Grace and cue notes share LilyPond's reduced notation size (font-size -3).
#let _small-notation-scale = 0.7071
#let _small-stem-length-fraction = 0.80
#let _small-beam-thickness = 0.384
#let _small-beam-center-step = 0.648
#let _small-stem-length = 3.5 * _small-stem-length-fraction - stem-anchor-dy * _small-notation-scale

// ---------------------------------------------------------------------------
// Small helpers
// ---------------------------------------------------------------------------

#let _duration-base(layout) = str(layout.duration.base)

#let _uses-small-notation(layout) = (
  layout.at("grace", default: false) or layout.at("cue", default: false)
)

#let _event-notation-scale(layout) = {
  if _uses-small-notation(layout) { _small-notation-scale } else { 1.0 }
}

#let _group-notation-scale(group) = {
  if group.all(item => _uses-small-notation(item.layout)) { _small-notation-scale } else { 1.0 }
}

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
  if clef in ("treble", "treble-8") { staff-y(4, bottom-y: bottom-y, line-gap: line-gap) }
  else if clef in ("bass", "bass-8") { staff-y(8, bottom-y: bottom-y, line-gap: line-gap) }
  else if clef == "alto" { staff-y(6, bottom-y: bottom-y, line-gap: line-gap) }
  else if clef == "tenor" { staff-y(8, bottom-y: bottom-y, line-gap: line-gap) }
  else if clef == "percussion" { staff-y(6, bottom-y: bottom-y, line-gap: line-gap) }
  else { panic("unknown clef " + clef) }
}

#let _pitch-head-shape(positioned-pitch) = positioned-pitch.at("head", default: "normal")

// The widest notehead of the event, so chords that mix shapes keep their
// ledger lines, dots, and neighbors clear of every head.
#let _head-half-width(layout) = {
  let kind = layout.at("notehead", default: "black")
  let shapes = layout.at("pitches", default: ()).map(_pitch-head-shape).dedup()
  if shapes.len() == 0 { shapes = ("normal",) }
  calc.max(..shapes.map(shape => notehead-geometry.at(shape).at(kind).half-width))
}

// ---------------------------------------------------------------------------
// Display staves
// ---------------------------------------------------------------------------

// A voice belongs to its home staff while each event is drawn on its display
// staff. Once a system is stacked, placed events carry the absolute bottom
// line of that staff; before stacking, geometry is measured against the
// staff passed in by the caller.
#let _event-bottom-y(layout, voice-bottom-y) = {
  layout.at("display-bottom-y", default: voice-bottom-y)
}

// Split chords draw some pitches on the neighboring staff.
#let _pitch-bottom-y(positioned-pitch, event-bottom-y) = {
  positioned-pitch.at("display-bottom-y", default: event-bottom-y)
}

#let _event-pitch-ys(layout, bottom-y: 0, line-gap: 1.0) = {
  let event-bottom-y = _event-bottom-y(layout, bottom-y)
  layout.pitches.map(positioned-pitch => staff-y(
    positioned-pitch.staff_position,
    bottom-y: _pitch-bottom-y(positioned-pitch, event-bottom-y),
    line-gap: line-gap,
  ))
}

#let _pitch-staff-index(positioned-pitch) = positioned-pitch.at("staff_index", default: 0)

#let _event-staff-index(layout) = layout.at("staff_index", default: 0)

#let _is-split-chord(layout) = {
  layout.pitches.map(_pitch-staff-index).dedup().len() > 1
}

// Orders pitches bottom to top across staves: every pitch of a higher staff
// (smaller index) ranks above every pitch of the staff below it.
#let _pitch-vertical-rank(positioned-pitch) = {
  positioned-pitch.staff_position - _pitch-staff-index(positioned-pitch) * 1000
}

// Dots sit in the space above line notes.
#let _dot-y(position, y, line-gap) = {
  if calc.rem(position, 2) == 0 { y + line-gap / 2 } else { y }
}

#let _draw-dots(x, y, dots, unit: 8pt, scale: 1.0, paint: black) = {
  for dot-index in range(dots) {
    draw-augmentation-dot(x + dot-index * _dot-step * scale, y, unit: unit, scale: scale, paint: paint)
  }
}
