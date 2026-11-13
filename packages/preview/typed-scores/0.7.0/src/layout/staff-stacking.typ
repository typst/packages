#import "../engraving/primitives.typ": brace-width-for-span, staff-y
#import "../foundation/diagnostics.typ": _score-error
#import "../engraving/event-geometry.typ": _event-staff-index, _layout-stem-direction, _pitch-staff-index
#import "../engraving/events.typ": _kneed-beam-required-gap
#import "../engraving/markings.typ": _annotation-with-prefix, _articulation-height, _articulation-stack, _event-articulations, _has-annotation
#import "../engraving/lyrics.typ": _lyric-lane-center, _lyric-verse-counts
#import "../engraving/figured-bass.typ": _figure-row-step

#let _system-repeat-start-gap = 1.7
#let _default-left-bar-x = 1.36
#let _group-symbol-to-bar-gap = 0.34
#let _system-clef-after-barline-gap = 0.8
#let _staff-label-to-group-gap = 0.6

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

// Dynamics, hairpins, pedal marks, and below-staff text belong to the voice
// and stay under its home staff even while its notes are drawn elsewhere.
#let _voice-direction-annotations(layout) = {
  layout.annotations.filter(annotation => {
    let annotation-text = str(annotation)
    (
      annotation-text.starts-with("dyn=")
        or annotation-text.starts-with("text-below=")
        or (
          annotation-text.starts-with("h")
            and (annotation-text.ends-with("<") or annotation-text.ends-with(">") or annotation-text.ends-with("!"))
        )
        or (
          annotation-text.starts-with("p")
            and (annotation-text.ends-with("(") or annotation-text.ends-with(")"))
        )
    )
  })
}

// The ink of one event on each staff that draws part of it. Stems joining
// two staves (kneed beams and split chords) are left out: their length
// follows the gap between the staves instead of shaping it.
#let _display-staff-parts(layout) = {
  if layout.pitches.len() == 0 {
    return ((staff-index: _event-staff-index(layout), layout: layout),)
  }
  let staves = layout.pitches.map(_pitch-staff-index).dedup().sorted()
  let joins-staves = layout.at("beam-crosses-staves", default: false)
  let stem-staff = if _layout-stem-direction(layout) == "up" { staves.first() } else { staves.last() }
  staves.map(staff-index => (
    staff-index: staff-index,
    layout: layout + (
      pitches: layout.pitches.filter(positioned-pitch => _pitch-staff-index(positioned-pitch) == staff-index),
      stem: layout.stem and not joins-staves and staff-index == stem-staff,
    ),
  ))
}

#let _staff-layouts-for-measures(measures) = {
  let staff-layouts = range(measures.first().staff-count).map(_ => ())
  for measure in measures {
    for voice in measure.voices {
      for layout in voice.layouts {
        let is-drawn-on-home-staff = (
          layout.pitches.all(positioned-pitch => _pitch-staff-index(positioned-pitch) == voice.staff-index)
            and _event-staff-index(layout) == voice.staff-index
        )
        if is-drawn-on-home-staff and not layout.at("beam-crosses-staves", default: false) {
          staff-layouts.at(voice.staff-index).push(layout)
          continue
        }
        let voice-directions = _voice-direction-annotations(layout)
        let note-annotations = layout.annotations.filter(annotation => annotation not in voice-directions)
        for part in _display-staff-parts(layout + (annotations: note-annotations)) {
          staff-layouts.at(part.staff-index).push(part.layout)
        }
        if voice-directions.len() > 0 {
          staff-layouts.at(voice.staff-index).push(layout + (
            rest: true,
            pitches: (),
            annotations: voice-directions,
          ))
        }
      }
    }
  }
  staff-layouts
}

// Minimum distances between the bottom lines of adjacent staves, keyed by
// the upper staff's index, that keep every kneed beam clear of the notes.
#let _kneed-beam-gaps(measures) = {
  let required-gaps = (:)
  for measure in measures {
    for voice in measure.voices {
      let group-ids = voice.layouts
        .filter(layout => layout.at("beam-crosses-staves", default: false))
        .map(layout => layout.beam_group)
        .dedup()
      for group-id in group-ids {
        let requirement = _kneed-beam-required-gap(
          voice.layouts.filter(layout => layout.at("beam_group", default: none) == group-id),
        )
        if requirement != none {
          let key = str(requirement.upper-staff)
          required-gaps.insert(key, calc.max(required-gaps.at(key, default: 0), requirement.gap))
        }
      }
    }
  }
  required-gaps
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
  // An ottava bracket stands on the outermost ink of its events.
  let ottava = layout.at("ottava", default: none)
  if ottava != none {
    if ottava.kind in ("8va", "15ma") {
      high = calc.max(high + 1.8, 6.2)
    } else {
      low = calc.min(low - 1.8, -2.9)
    }
  }
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

// Fret numbers sit centered on the tab lines, so their ink reaches about
// half a digit beyond the outer lines.
#let _tab-number-overhang = 0.6

#let _staff-stack(
  voice-layouts,
  staff-heights: none,
  staff-tabs: none,
  staff-gap: none,
  required-gaps: (:),
  lyric-verse-counts: (:),
  lyric-size: 0.9,
  lyric-gap: 0.8,
  verse-gap: 1.45,
  figure-rows: 0,
) = {
  let voice-count = voice-layouts.len()
  let staff-heights = if staff-heights == none { range(voice-count).map(_ => 4) } else { staff-heights }
  let staff-tabs = if staff-tabs == none { range(voice-count).map(_ => none) } else { staff-tabs }
  let note-extents = range(voice-count).map(staff-index => {
    if staff-tabs.at(staff-index) != none {
      (high: staff-heights.at(staff-index) + _tab-number-overhang, low: -_tab-number-overhang)
    } else {
      _voice-vertical-extent(voice-layouts.at(staff-index))
    }
  })
  // Figured bass fills a band under the bottom staff's ink; lyrics of that
  // staff then sit below the band.
  let figure-top = none
  if figure-rows > 0 {
    let bottom-extent = note-extents.last()
    figure-top = calc.min(bottom-extent.low - 0.7, -1.8)
    note-extents.last() = bottom-extent + (
      low: figure-top - _figure-row-step * (figure-rows - 1) - 1.3,
    )
  }
  let staff-extents = ()
  for staff-index in range(voice-count) {
    let note-extent = note-extents.at(staff-index)
    let verse-count = lyric-verse-counts.at(str(staff-index), default: 0)
    let low = note-extent.low
    if verse-count > 0 {
      low = calc.min(
        low,
        _lyric-lane-center(
          note-extent.low,
          verse-count - 1,
          lyric-size,
          lyric-gap,
          verse-gap,
        ) - lyric-size / 2,
      )
    }
    staff-extents.push((high: note-extent.high, low: low))
  }
  let bottom-map = (:)
  let current-bottom = 0
  let lower-high = staff-extents.last().high
  let lower-height = staff-heights.last()
  bottom-map.insert(str(voice-count - 1), current-bottom)
  if voice-count > 1 {
    for voice-index in range(voice-count - 2, -1, step: -1) {
      let extent = staff-extents.at(voice-index)
      let required-gap = required-gaps.at(str(voice-index), default: 0)
      if staff-gap != none and staff-tabs.at(voice-index + 1) != none and staff-gap < lower-height + 1 {
        _score-error(
          "score staff-gap",
          "staff-gap leaves no room for the tab staff below staff " + str(voice-index + 1),
          value: staff-gap,
          expected: "at least " + str(lower-height + 1) + ", the tab staff's height plus one staff space",
          fix: "increase staff-gap or remove it so the gap is computed from the notes",
        )
      }
      if staff-gap != none and staff-gap < required-gap {
        _score-error(
          "score staff-gap",
          "staff-gap is too small for a kneed beam between staff " + str(voice-index + 1) + " and staff " + str(voice-index + 2),
          value: staff-gap,
          expected: "at least " + str(calc.round(required-gap, digits: 2)),
          fix: "increase staff-gap or remove it so the gap is computed from the notes",
        )
      }
      // Adjacent staves keep at least three staff spaces between them.
      let gap = if staff-gap == none {
        calc.max(lower-height + 3, lower-high - extent.low + 1.2, required-gap)
      } else {
        staff-gap
      }
      current-bottom += gap
      bottom-map.insert(str(voice-index), current-bottom)
      lower-high = extent.high
      lower-height = staff-heights.at(voice-index)
    }
  }
  (
    bottoms: bottom-map,
    bottom: bottom-map.at(str(voice-count - 1)),
    top: bottom-map.at("0") + staff-heights.first(),
    heights: staff-heights,
    note-extents: note-extents,
    figure-top: figure-top,
  )
}

#let _left-bar-x-for-group(
  group-style,
  measures,
  staff-gap,
  lyric-size: 0.9,
  lyric-gap: 0.8,
  verse-gap: 1.45,
) = {
  if group-style != "brace" {
    return _default-left-bar-x
  }
  let stack = _staff-stack(
    _staff-layouts-for-measures(measures),
    staff-heights: measures.first().staff-heights,
    staff-tabs: measures.first().staff-tabs,
    staff-gap: staff-gap,
    required-gaps: _kneed-beam-gaps(measures),
    lyric-verse-counts: _lyric-verse-counts(measures, measures.first().staff-count),
    lyric-size: lyric-size,
    lyric-gap: lyric-gap,
    verse-gap: verse-gap,
  )
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
