#import "@preview/cetz:0.5.2"
#import "render.typ": _bravura-width, _draw-bravura-glyph, draw-accidental, draw-articulation, draw-breath-mark, draw-dynamic, draw-fermata, draw-hairpin, draw-ornament-turn, draw-pedal-mark, dynamic-width, sampled-y-at-x, staff-y
#import "diagnostics.typ": _score-error, _validate-marking
#import "event-geometry.typ": _head-half-width, _stem-direction
#import "event-engraving.typ": _beam-group-visible, _event-stem-geometry

// Tempo, event markings, and direction spanners.

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

#let _draw-tempo(tempo, x, y, unit, paint: black) = {
  import cetz.draw: *
  let style = (size: unit * 1.25, style: "italic", fill: paint)
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
  _draw-bravura-glyph(glyph, note-x, y, unit: unit, glyph-scale: glyph-scale, paint: paint)
  let after-note = note-x + glyph-half-width + 0.18
  let suffix = "= " + str(tempo.bpm) + if prefix == none { "" } else { ")" }
  content((after-note, y), text(..style, suffix), anchor: "west", padding: 0pt)
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

#let _draw-placed-annotations(placed, bottom-y: 0, unit: 8pt, beams: false, slur-layouts: (), dynamics-baseline: none, paint: black) = {
  import cetz.draw: *
  for item in placed {
    let dynamic = _annotation-with-prefix(item.layout, "dyn=")
    if dynamic != none {
      let y = if dynamics-baseline == none { bottom-y - 2.0 } else { dynamics-baseline }
      draw-dynamic(dynamic, item.x, y, unit: unit, paint: paint)
    }
    if _has-annotation(item.layout, "fermata") {
      draw-fermata(item.x, _event-top(item, bottom-y: bottom-y) + 1.15, unit: unit, paint: paint)
    }
    if _has-annotation(item.layout, "breath") {
      draw-breath-mark(
        item.x + _head-half-width(item.layout) + 0.72,
        _event-top(item, bottom-y: bottom-y) + 0.78,
        unit: unit,
        paint: paint,
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
        draw-articulation(placement.mark, item.x, placement.y, placement: articulation-placement, unit: unit, paint: paint)
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
      draw-ornament-turn(item.x, turn-y, unit: unit, scale: 0.82, paint: paint)
      turn-top = turn-y + 0.42
      if _has-annotation(item.layout, "chromatic-turn") {
        draw-accidental("Flat", item.x - 0.72, turn-y + 0.58, unit: unit, scale: 0.38, paint: paint)
        draw-accidental("Natural", item.x + 0.34, turn-y - 0.74, unit: unit, scale: 0.38, paint: paint)
        turn-top = turn-y + 0.95
      }
      let turn-fingering = _annotation-with-prefix(item.layout, "turn-f=")
      if turn-fingering != none {
        content(
          (item.x, turn-y + 1.08),
          text(size: unit * 0.62, weight: "bold", fill: paint, turn-fingering),
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
        text(size: unit * 0.82, weight: "bold", fill: paint, fingering),
        anchor: "south",
        padding: 0pt,
      )
    }
    let marking = _annotation-with-prefix(item.layout, "text=")
    if marking != none {
      content(
        (item.x, bottom-y - 1.35),
        text(size: unit * 0.9, style: "italic", fill: paint, marking.replace("_", " ")),
        anchor: "north-west",
        padding: 0pt,
      )
    }
    let below-marking = _annotation-with-prefix(item.layout, "text-below=")
    if below-marking != none {
      content(
        (item.x, bottom-y - 6.8),
        text(size: unit * 0.9, style: "italic", fill: paint, below-marking.replace("_", " ")),
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

#let _draw-pedal-spans(spans, y, unit: 8pt, paint: black) = {
  import cetz.draw: *
  let stroke-style = 0.08 * unit + paint
  for span in spans {
    draw-pedal-mark(span.start, y, unit: unit, paint: paint)
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

#let _draw-hairpins(spans, y, unit: 8pt, paint: black) = {
  for span in spans {
    draw-hairpin((span.start, y), (span.end, y), kind: span.kind, unit: unit, paint: paint)
  }
}


// ---------------------------------------------------------------------------
// Direction-span validation
// ---------------------------------------------------------------------------

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
