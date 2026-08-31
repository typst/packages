#import "primitives.typ": accidental-width, notehead-half-width, rest-width, stem-thickness
#import "event-geometry.typ": _accidental-gap, _dot-gap-from-head, _dot-step, _duration-base, _grace-main-gap, _grace-note-step, _head-half-width, _min-onset-step, _stem-direction
#import "signatures.typ": _barline-clearance, _key-alters-natural, _key-suppresses-accidental
#import "lyrics.typ": _add-lyric-spacing-demands

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
  lyrics: (),
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

  let lyric-spacing = _add-lyric-spacing-demands(
    lyrics,
    first-onset-x,
    demands-by-ending-onset,
    measure-end-demands,
  )
  first-onset-x = lyric-spacing.first-onset-x
  demands-by-ending-onset = lyric-spacing.demands-by-ending-onset
  measure-end-demands = lyric-spacing.measure-end-demands

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
