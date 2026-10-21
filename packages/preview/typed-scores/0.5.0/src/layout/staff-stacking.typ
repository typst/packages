#import "../engraving/primitives.typ": brace-width-for-span, staff-y
#import "../engraving/event-geometry.typ": _layout-stem-direction
#import "../engraving/markings.typ": _annotation-with-prefix, _articulation-height, _articulation-stack, _event-articulations, _has-annotation
#import "../engraving/lyrics.typ": _lyric-lane-center, _lyric-verse-counts

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

#let _staff-stack(
  voice-layouts,
  staff-gap: none,
  lyric-verse-counts: (:),
  lyric-size: 0.9,
  lyric-gap: 0.8,
  verse-gap: 1.45,
) = {
  let voice-count = voice-layouts.len()
  let note-extents = voice-layouts.map(_voice-vertical-extent)
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
  bottom-map.insert(str(voice-count - 1), current-bottom)
  if voice-count > 1 {
    for voice-index in range(voice-count - 2, -1, step: -1) {
      let extent = staff-extents.at(voice-index)
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
    note-extents: note-extents,
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
    staff-gap: staff-gap,
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
