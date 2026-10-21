#import "@preview/cetz:0.5.2"
#import "render.typ": barline-separation, brace-width-for-span, draw-augmentation-dot, draw-grand-brace, draw-navigation-symbol, draw-staff-bracket, draw-staff-group-line, draw-staff-lines, music-canvas, repeat-barline-dot-separation, repeat-ending-line-thickness, staff-y, thick-barline-thickness, thin-barline-thickness
#import "diagnostics.typ": _score-error
#import "event-geometry.typ": _layout-stem-direction
#import "signatures.typ": _draw-inline-signature, _draw-prologue, _inline-signature-note-start, _prologue-start-x, _repeat-side-clearance
#import "spacing.typ": _onset-key, _place-voice-at-onsets
#import "event-engraving.typ": _draw-placed-sequence, _draw-tuplets, _event-stem-geometry
#import "markings.typ": _annotation-stem-direction, _annotation-with-prefix, _articulation-height, _articulation-stack, _collect-hairpins, _collect-pedal-spans, _draw-hairpins, _draw-pedal-spans, _draw-placed-annotations, _draw-tempo, _dynamics-baseline, _event-articulations, _event-decoration-top, _has-annotation
#import "ties-slurs.typ": _collect-system-slurs, _collect-ties, _draw-slur-bows, _draw-ties, _layout-slurs, _slur-clearance-obstacles
#import "lyrics.typ": _draw-system-lyrics, _lyric-lane-center, _lyric-verse-counts, _placed-lyric-items

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
  if (
    density < _minimum-justification-scale
      and measures.slice(start, stop).any(measure => measure.lyrics.len() > 0)
  ) {
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
      fix: "increase width, reduce indent, note-spacing, or lyric-size, shorten labels or lyric syllables, or disable wrap",
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
  lyric-size: 0.9,
  lyric-font: none,
  lyric-gap: 0.8,
  verse-gap: 1.45,
) = {
  let system-measures = measures.slice(system.start, system.start + system.widths.len())
  let lane-count = system-measures.first().voices.len()
  let staff-count = system-measures.first().staff-count
  let staff-layouts = _staff-layouts-for-measures(system-measures)

  // Stack staves bottom-up, leaving room for ledger-line excursions.
  // Extents are relative to each staff's own bottom line.
  let stack = _staff-stack(
    staff-layouts,
    staff-gap: staff-gap,
    lyric-verse-counts: _lyric-verse-counts(measures, staff-count),
    lyric-size: lyric-size,
    lyric-gap: lyric-gap,
    verse-gap: verse-gap,
  )
  let bottom-map = stack.bottoms
  let staff-note-extents = stack.note-extents
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
  if (
    allocation.density < _minimum-justification-scale
      and system-measures.any(measure => measure.lyrics.len() > 0)
  ) {
    _score-error(
      "score lyrics layout",
      "requested width would compress lyric text into adjacent syllables",
      value: system-width,
      expected: "enough width to preserve lyric syllable clearance",
      fix: "increase width, reduce lyric-size, shorten the lyric text, or enable wrapping",
    )
  }
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
  let measure-note-starts = ()
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
    measure-note-starts.push(note-start)
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
  let placed-lyrics = _placed-lyric-items(
    system-measures,
    measure-note-starts,
    measure-justifications,
  )
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

    _draw-system-lyrics(
      measures,
      system,
      placed-lyrics,
      bottom-map,
      staff-note-extents,
      lyric-size,
      lyric-font,
      lyric-gap,
      verse-gap,
      left-bar-x + 0.25,
      system-width - 0.25,
      unit,
    )

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
