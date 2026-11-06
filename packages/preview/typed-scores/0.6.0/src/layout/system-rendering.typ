#import "@preview/cetz:0.5.2"
#import "../foundation/diagnostics.typ": _score-error
#import "../engraving/primitives.typ": barline-separation, draw-augmentation-dot, draw-grand-brace, draw-navigation-symbol, draw-staff-bracket, draw-staff-group-line, draw-staff-lines, music-canvas, repeat-barline-dot-separation, repeat-ending-line-thickness, thick-barline-thickness, thin-barline-thickness
#import "../engraving/signatures.typ": _draw-inline-signature, _draw-prologue, _inline-signature-note-start, _inline-time-x, _prologue-start-x, _prologue-time-x
#import "../engraving/spacing.typ": _onset-key, _place-voice-at-onsets
#import "../engraving/event-geometry.typ": _event-pitch-ys, _event-staff-index, _pitch-staff-index
#import "../engraving/events.typ": _beamed-stem-tips, _draw-placed-sequence, _draw-tuplets, _event-stem-geometry, _resolve-cross-staff-beams, _resolve-staff-accidentals
#import "../engraving/markings.typ": _annotation-stem-direction, _collect-hairpins, _collect-pedal-spans, _draw-hairpins, _draw-pedal-spans, _draw-placed-annotations, _draw-tempo, _dynamics-baseline, _event-decoration-top
#import "../engraving/ties-slurs.typ": _collect-system-slurs, _collect-ties, _draw-slur-bows, _draw-ties, _layout-slurs, _slur-clearance-obstacles
#import "../engraving/lyrics.typ": _draw-system-lyrics, _lyric-verse-counts, _placed-lyric-items
#import "../engraving/figured-bass.typ": _draw-figure-stack, _figure-rows
#import "../engraving/ottava.typ": _collect-ottava-spans, _draw-ottava-spans, _ottava-spans-top, _place-ottava-spans
#import "../engraving/chord-diagrams.typ": _chord-diagram-extent, _draw-chord-diagram, _score-diagram-scale
#import "../engraving/tablature.typ": _draw-tab-clef, _draw-tab-numbers, _draw-tab-staff-lines, _draw-tab-time-signature, _tab-number-items, tab-line-gap
#import "staff-stacking.typ": _group-symbol-to-bar-gap, _kneed-beam-gaps, _staff-layouts-for-measures, _staff-stack, _system-clef-after-barline-gap, _system-repeat-start-gap
#import "system-breaking.typ": _allocate-measure-widths, _measure-prefix-in-system, _minimum-justification-scale

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

#let _draw-barline-stroke(x, thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint) = {
  import cetz.draw: *
  let stroke = thickness * unit + paint
  if connected {
    line((x, system-bottom), (x, system-top), stroke: stroke)
  } else {
    for voice-index in range(voice-count) {
      let bottom-y = bottom-map.at(str(voice-index))
      line((x, bottom-y), (x, bottom-y + heights.at(voice-index)), stroke: stroke)
    }
  }
}

// Repeat dots take the two spaces nearest the staff's middle, straddling the
// middle line or, when the middle falls in a space, skipping over it.
#let _repeat-dot-offsets(height, tab) = {
  let line-gap = if tab == none { 1 } else { tab-line-gap }
  let spaces = calc.round(height / line-gap)
  let middle = spaces / 2
  let spread = if calc.rem(spaces, 2) == 0 { 0.5 } else { 1 }
  ((middle - spread) * line-gap, (middle + spread) * line-gap)
}

#let _draw-repeat-dots(x, voice-count, bottom-map, heights, tabs, unit, paint) = {
  for voice-index in range(voice-count) {
    let bottom-y = bottom-map.at(str(voice-index))
    for offset in _repeat-dot-offsets(heights.at(voice-index), tabs.at(voice-index)) {
      draw-augmentation-dot(x, bottom-y + offset, unit: unit, scale: 0.85, paint: paint)
    }
  }
}

#let _draw-dashed-barline(x, staff-count, bottom-map, heights, unit, paint) = {
  import cetz.draw: *
  for staff-index in range(staff-count) {
    let bottom-y = bottom-map.at(str(staff-index))
    let top-y = bottom-y + heights.at(staff-index)
    for step in range(calc.ceil(heights.at(staff-index) / 0.72) + 1) {
      let y = bottom-y + step * 0.72
      if y >= top-y { break }
      line(
        (x, y),
        (x, calc.min(y + 0.38, top-y)),
        stroke: thin-barline-thickness * unit + paint,
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
  heights: (),
  tabs: (),
  backward: false,
  forward: false,
  kind: none,
  connected: false,
  unit: 8pt,
  paint: black,
) = {
  // Barline groups center on the musical boundary. Line thicknesses, the
  // edge-to-edge gap between locked barlines, and the dot standoff follow
  // the Bravura engraving defaults; repeat dots sit past the thin line.
  let thin-half = thin-barline-thickness / 2
  let thick-half = thick-barline-thickness / 2
  let dot-offset = repeat-barline-dot-separation + 0.17
  if backward and forward {
    let center-offset = barline-separation / 2 + thick-half
    _draw-barline-stroke(x - center-offset, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-barline-stroke(x + center-offset, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-repeat-dots(x - center-offset - thick-half - dot-offset, voice-count, bottom-map, heights, tabs, unit, paint)
    _draw-repeat-dots(x + center-offset + thick-half + dot-offset, voice-count, bottom-map, heights, tabs, unit, paint)
  } else if backward {
    let span = thin-barline-thickness + barline-separation + thick-barline-thickness
    let thin-center = x - span / 2 + thin-half
    let thick-center = x + span / 2 - thick-half
    _draw-barline-stroke(thin-center, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-barline-stroke(thick-center, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-repeat-dots(thin-center - thin-half - dot-offset, voice-count, bottom-map, heights, tabs, unit, paint)
  } else if forward {
    let span = thin-barline-thickness + barline-separation + thick-barline-thickness
    let thick-center = x - span / 2 + thick-half
    let thin-center = x + span / 2 - thin-half
    _draw-barline-stroke(thick-center, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-barline-stroke(thin-center, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-repeat-dots(thin-center + thin-half + dot-offset, voice-count, bottom-map, heights, tabs, unit, paint)
  } else if kind == "double" {
    let offset = (barline-separation + thin-barline-thickness) / 2
    _draw-barline-stroke(x - offset, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-barline-stroke(x + offset, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
  } else if kind == "final" {
    let span = thin-barline-thickness + barline-separation + thick-barline-thickness
    let thin-center = x - span / 2 + thin-half
    let thick-center = x + span / 2 - thick-half
    _draw-barline-stroke(thin-center, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
    _draw-barline-stroke(thick-center, thick-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
  } else if kind == "dashed" {
    _draw-dashed-barline(x, voice-count, bottom-map, heights, unit, paint)
  } else {
    _draw-barline-stroke(x, thin-barline-thickness, voice-count, system-bottom, system-top, bottom-map, heights, unit, connected, paint)
  }
}

#let _draw-system-endings(ending-spans, system, measure-starts, unit, left-bar-x, system-width, volta-y, paint) = {
  import cetz.draw: *
  let system-last = system.start + system.widths.len() - 1
  let stroke = repeat-ending-line-thickness * unit + paint
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
          text(size: unit * 1.1, fill: paint, span.label),
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

// Once the staves of a system are stacked, every event learns the absolute
// bottom line of the staff that draws it (and of each pitch of a split chord).
#let _attach-display-staff-baselines(placed, bottom-map) = {
  placed.map(item => {
    let pitches = item.layout.pitches.map(positioned-pitch => positioned-pitch + (
      display-bottom-y: bottom-map.at(str(_pitch-staff-index(positioned-pitch))),
    ))
    item + (layout: item.layout + (
      display-bottom-y: bottom-map.at(str(_event-staff-index(item.layout))),
      pitches: pitches,
    ))
  })
}

#let _voice-tied-from-previous-measure(measures, measure-index, voice-index) = {
  if measure-index == 0 { return false }
  let previous-layouts = measures.at(measure-index - 1).voices.at(voice-index).layouts
  previous-layouts.len() > 0 and previous-layouts.last().at("tie_to_next", default: false)
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
  paint: black,
) = {
  let system-measures = measures.slice(system.start, system.start + system.widths.len())
  let lane-count = system-measures.first().voices.len()
  let staff-count = system-measures.first().staff-count
  let staff-layouts = _staff-layouts-for-measures(system-measures)

  // Stack staves bottom-up, leaving room for ledger-line excursions.
  // Extents are relative to each staff's own bottom line.
  let staff-tabs = system-measures.first().staff-tabs
  // Tablature repeats the rhythm of the notation above it, so a tab staff
  // prints time signatures only when the score has no notation staff.
  let tab-shows-time = staff-tabs.all(tab => tab != none)
  let stack = _staff-stack(
    staff-layouts,
    staff-heights: system-measures.first().staff-heights,
    staff-tabs: staff-tabs,
    staff-gap: staff-gap,
    required-gaps: _kneed-beam-gaps(system-measures),
    lyric-verse-counts: _lyric-verse-counts(measures, staff-count),
    lyric-size: lyric-size,
    lyric-gap: lyric-gap,
    verse-gap: verse-gap,
    figure-rows: calc.max(0, ..system-measures.map(measure => _figure-rows(measure.figures))),
  )
  let bottom-map = stack.bottoms
  let staff-heights = stack.heights
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
    system-measures.first().at("show-time"),
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
    let measure-placed-voices = ()
    for voice-index in range(lane-count) {
      let voice = measure.voices.at(voice-index)
      let placed = _place-voice-at-onsets(
        voice.layouts,
        measure.positions,
        note-start,
        scale: measure-justifications.at(measure-index),
        voice: voice,
        all-voices: measure.voices,
      )
      measure-placed-voices.push(
        _resolve-cross-staff-beams(_attach-display-staff-baselines(placed, bottom-map))
      )
    }
    let global-measure-index = system.start + measure-index
    measure-placed-voices = _resolve-staff-accidentals(
      measure-placed-voices,
      measure.key,
      range(lane-count).map(voice-index => _voice-tied-from-previous-measure(
        measures,
        global-measure-index,
        voice-index,
      )),
    )
    for voice-index in range(lane-count) {
      placed-by-voice.at(voice-index).push(measure-placed-voices.at(voice-index))
    }
  }
  let placed-lyrics = _placed-lyric-items(
    system-measures,
    measure-note-starts,
    measure-justifications,
  )
  let is-tab-voice(voice-index) = system-measures.first().voices.at(voice-index).tab != none
  let slurs-by-voice = ()
  for voice-index in range(lane-count) {
    let voice = system-measures.first().voices.at(voice-index)
    if voice.tab != none {
      slurs-by-voice.push(())
      continue
    }
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
    if is-tab-voice(voice-index) {
      dynamics-baseline-by-voice.push(none)
      continue
    }
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
    if is-tab-voice(voice-index) {
      slur-layouts-by-voice.push(())
      continue
    }
    let staff-index = system-measures.first().voices.at(voice-index).staff-index
    let bottom-y = bottom-map.at(str(staff-index))
    let placed-flat = ()
    for placed in placed-by-voice.at(voice-index) {
      placed-flat += placed
    }
    let obstacles = ()
    for placed in placed-by-voice.at(voice-index) {
      let beamed-stem-tips = _beamed-stem-tips(placed, beams, bottom-y: bottom-y)
      for (event-index, item) in placed.enumerate() {
        if item.layout.rest or item.layout.pitches.len() == 0 { continue }
        let y-values = _event-pitch-ys(item.layout, bottom-y: bottom-y)
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
        let beamed-tip = beamed-stem-tips.at(str(event-index), default: none)
        let outer-top = if beamed-tip != none and beamed-tip.direction == "up" {
          calc.max(beamed-tip.tip-y, head-top)
        } else if stem-geometry != none and stem-geometry.direction == "up" {
          calc.max(stem-geometry.point.at(1), head-top)
        } else {
          head-top
        }
        let outer-bottom = if beamed-tip != none and beamed-tip.direction == "down" {
          calc.min(beamed-tip.tip-y, head-bottom)
        } else if stem-geometry != none and stem-geometry.direction == "down" {
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

  // Ottava brackets clear every event of their staff and their voice's slurs.
  let staff-items = range(staff-count).map(_ => ())
  for voice-index in range(lane-count) {
    for placed in placed-by-voice.at(voice-index) {
      for item in placed {
        staff-items.at(_event-staff-index(item.layout)).push((item: item, placed: placed))
      }
    }
  }
  let ottava-spans-by-voice = range(lane-count).map(voice-index => {
    let staff-index = system-measures.first().voices.at(voice-index).staff-index
    _place-ottava-spans(
      _collect-ottava-spans(placed-by-voice.at(voice-index), continuation-left-x, continuation-right-x),
      staff-items.at(staff-index),
      bottom-y: bottom-map.at(str(staff-index)),
      beams: beams,
      slur-layouts: slur-layouts-by-voice.at(voice-index),
      dynamics-baseline: dynamics-baseline-by-voice.at(voice-index),
    )
  })
  // Marks above the system (chord names, voltas, rehearsal marks, tempo)
  // rise over an ottava bracket on the top staff.
  let top-ottava = none
  for voice-index in range(lane-count) {
    if system-measures.first().voices.at(voice-index).staff-index != 0 { continue }
    let voice-top = _ottava-spans-top(ottava-spans-by-voice.at(voice-index))
    if voice-top != none {
      top-ottava = if top-ottava == none { voice-top } else { calc.max(top-ottava, voice-top) }
    }
  }
  let above-top = if top-ottava == none { system-top } else { calc.max(system-top, top-ottava - 1.0) }

  let system-last = system.start + system.widths.len() - 1
  let has-system-ending = ending-spans.any(span =>
    span.stop >= system.start and span.start <= system-last
  )
  let has-harmony = system-measures.any(measure => measure.harmony.len() > 0)
  let volta-y = above-top + 2.0
  if has-system-ending and not is-tab-voice(0) {
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
    calc.max(above-top + 4.6, volta-y + 1.6)
  } else {
    above-top + 4.6
  }
  let harmony-y = above-top + 2.4
  // Chord diagrams stand in one row above the top staff's ink, tops
  // aligned, with their chord names above them.
  let system-diagrams = ()
  for measure in system-measures {
    system-diagrams += measure.harmony.filter(item => item.at("diagram", default: none) != none)
  }
  let diagram-top-y = none
  if system-diagrams.len() > 0 {
    let top-staff-ink = bottom-map.at("0") + staff-note-extents.first().high
    let tallest = calc.max(..system-diagrams.map(item => _chord-diagram-extent(item.diagram, _score-diagram-scale).height))
    // Diagrams also clear a volta bracket, whose label hangs below its line.
    let volta-clearance = if has-system-ending { volta-y + 0.8 } else { above-top }
    diagram-top-y = calc.max(above-top + 1.4, top-staff-ink + 0.8, volta-clearance) + tallest
    harmony-y = diagram-top-y + 0.5
  }

  let tab-numbers-by-staff = (:)
  for voice-index in range(lane-count) {
    let voice = system-measures.first().voices.at(voice-index)
    if voice.tab == none { continue }
    let key = str(voice.staff-index)
    tab-numbers-by-staff.insert(key, tab-numbers-by-staff.at(key, default: ()) + _tab-number-items(
      placed-by-voice.at(voice-index),
      voice.tab.tuning.len(),
      bottom-map.at(key),
      unit,
      paint,
    ))
  }
  let header-y = if has-harmony { calc.max(header-y-base, harmony-y + 3.0) } else { header-y-base }

  block(width: system-width * unit, {
    set text(fill: paint)
    music-canvas(length: unit, keep-origin: true, {
    if group-style == "brace" {
      draw-grand-brace(left-bar-x - _group-symbol-to-bar-gap, system-bottom, system-top, unit: unit, paint: paint)
    } else if group-style == "bracket" {
      draw-staff-bracket(left-bar-x - _group-symbol-to-bar-gap - 0.36, system-bottom, system-top, unit: unit, paint: paint)
    } else if group-style == "line" {
      draw-staff-group-line(left-bar-x - _group-symbol-to-bar-gap - 0.42, system-bottom, system-top, unit: unit, paint: paint)
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
            (
              system.name-left + system.label-reserve / 2,
              bottom-map.at(str(staff-index)) + staff-heights.at(staff-index) / 2,
            ),
            text(size: unit, label),
            anchor: "center",
            padding: 0pt,
          )
        }
      }
    }
    for staff-index in range(staff-count) {
      let tab = staff-tabs.at(staff-index)
      if tab == none {
        draw-staff-lines(system-width - left-bar-x, x: left-bar-x, bottom-y: bottom-map.at(str(staff-index)), unit: unit, paint: paint)
      } else {
        _draw-tab-staff-lines(
          left-bar-x,
          system-width,
          tab.tuning.len(),
          bottom-map.at(str(staff-index)),
          tab-numbers-by-staff.at(str(staff-index), default: ()),
          unit: unit,
          paint: paint,
        )
      }
    }
    // A multi-staff system opens with a barline joining all its staves,
    // whatever group symbol (or none) sits to its left.
    if staff-count > 1 {
      import cetz.draw: *
      line(
        (left-bar-x, system-bottom),
        (left-bar-x, system-top),
        stroke: thin-barline-thickness * unit + paint,
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
        _draw-tempo(measure.tempo, measure-start + 0.4, header-y, unit, paint: paint)
      }
      if measure.rehearsal != none {
        import cetz.draw: *
        content(
          (measure-start + 0.18, above-top + 2.15),
          box(
            inset: 0.18em,
            stroke: 0.10 * unit + paint,
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
            above-top + if measure.rehearsal == none { 3.0 } else { 4.55 },
            unit: unit,
            scale: 0.62,
            paint: paint,
          )
        } else {
          content(
            (measure-start + 0.18, above-top + if measure.rehearsal == none { 2.0 } else { 3.65 }),
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
        let diagram = harmony.at("diagram", default: none)
        if diagram != none {
          _draw-chord-diagram(
            diagram,
            onset-x,
            diagram-top-y - _chord-diagram-extent(diagram, _score-diagram-scale).height,
            unit: unit,
            scale: _score-diagram-scale,
            paint: paint,
          )
        }
      }
      // Figures stand under the bottom staff, centered on their onsets.
      for figure-layout in measure.figures {
        _draw-figure-stack(
          figure-layout,
          note-start
            + measure.positions.at(str(_onset-key(figure-layout.onset)))
              * measure-justifications.at(measure-index),
          bottom-map.at(str(staff-count - 1)) + stack.figure-top - 1.0,
          unit: unit,
          paint: paint,
        )
      }
      for voice-index in range(lane-count) {
        let voice = measure.voices.at(voice-index)
        let bottom-y = bottom-map.at(str(voice.staff-index))
        if voice.tab != none {
          // A tab staff opens with its clef alone; its fret numbers are
          // drawn once per staff after every voice is placed.
          let string-count = voice.tab.tuning.len()
          if voice.layer-index == 0 and measure-index == 0 {
            _draw-tab-clef(clef-x, string-count, bottom-y, unit: unit, paint: paint)
            if tab-shows-time and measure.at("show-time") {
              _draw-tab-time-signature(
                measure.time,
                _prologue-time-x(measure.key, previous-key: measure.at("previous-key"), clef-x: clef-x),
                string-count,
                bottom-y,
                unit: unit,
                paint: paint,
              )
            }
          } else if voice.layer-index == 0 and tab-shows-time and measure.at("show-time") {
            _draw-tab-time-signature(
              measure.time,
              _inline-time-x(
                measure-start,
                measure.key,
                measure.at("show-key"),
                reserve-clef: measure.at("show-clef"),
                previous-key: measure.at("previous-key"),
              ),
              string-count,
              bottom-y,
              unit: unit,
              paint: paint,
            )
          }
          continue
        }
        if voice.layer-index == 0 and measure-index == 0 {
          _draw-prologue(
            voice.clef,
            measure.key,
            measure.time,
            measure.at("show-time"),
            previous-key: measure.at("previous-key"),
            bottom-y: bottom-y,
            unit: unit,
            staff-x: left-bar-x,
            clef-x: clef-x,
            paint: paint,
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
            paint: paint,
          )
        }
        _draw-placed-sequence(
          placed-by-voice.at(voice-index).at(measure-index),
          bottom-y: bottom-y,
          unit: unit,
          beams: beams,
          key: measure.key,
          paint: paint,
        )
        _draw-tuplets(
          placed-by-voice.at(voice-index).at(measure-index),
          bottom-y: bottom-y,
          unit: unit,
          beams: beams,
          paint: paint,
        )
        _draw-placed-annotations(
          placed-by-voice.at(voice-index).at(measure-index),
          bottom-y: bottom-y,
          unit: unit,
          beams: beams,
          slur-layouts: slur-layouts-by-voice.at(voice-index),
          dynamics-baseline: dynamics-baseline-by-voice.at(voice-index),
          paint: paint,
        )
      }
    }

    for numbers in tab-numbers-by-staff.values() {
      _draw-tab-numbers(numbers)
    }

    for voice-index in range(lane-count) {
      if is-tab-voice(voice-index) { continue }
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
        paint: paint,
      )
      _draw-slur-bows(slur-layouts-by-voice.at(voice-index), unit: unit, paint: paint)
      _draw-hairpins(
        _collect-hairpins(placed-by-voice.at(voice-index)),
        if dynamics-baseline-by-voice.at(voice-index) == none {
          bottom-y - 3.2
        } else {
          dynamics-baseline-by-voice.at(voice-index)
        },
        unit: unit,
        paint: paint,
      )
      _draw-pedal-spans(
        _collect-pedal-spans(placed-by-voice.at(voice-index)),
        bottom-y - 7.0,
        unit: unit,
        paint: paint,
      )
      _draw-ottava-spans(ottava-spans-by-voice.at(voice-index), unit: unit, paint: paint)
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
      paint: paint,
    )

    _draw-system-endings(
      ending-spans,
      (start: system.start, widths: measure-widths, width: system-width),
      measure-starts,
      unit,
      left-bar-x,
      system-width,
      volta-y,
      paint,
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
        heights: staff-heights,
        tabs: staff-tabs,
        backward: backward,
        forward: forward,
        kind: barline-kind,
        connected: group-style == "brace",
        unit: unit,
        paint: paint,
      )
    }
    })
  })
}
