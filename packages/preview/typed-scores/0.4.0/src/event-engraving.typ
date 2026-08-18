#import "@preview/cetz:0.5.2"
#import "render.typ": beam-spacing, beam-thickness, draw-accidental, draw-arpeggio, draw-augmentation-dot, draw-beam, draw-bow, draw-filled-notehead, draw-flag, draw-ledger-lines, draw-open-notehead, draw-rest, draw-stem, draw-stem-tremolo, draw-whole-notehead, ledger-extension, rest-width, staff-y, stem-anchor-dy, stem-center-offset, stem-tip
#import "event-geometry.typ": _accidental-gap, _alternating-tremolo-strokes, _default-stem-length, _dot-gap-from-head, _dot-step, _dot-y, _draw-dots, _duration-base, _grace-beam-center-step, _grace-beam-thickness, _grace-notation-scale, _grace-stem-length, _grace-stem-length-fraction, _head-half-width, _layout-stem-direction, _single-tremolo-strokes, _stem-direction
#import "signatures.typ": _key-default-accidental
#import "spacing.typ": _accidental-plan, _cluster-offsets

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
  paint: black,
) = {
  import cetz.draw: *
  let notation-scale = if layout.at("grace", default: false) { _grace-notation-scale } else { 1.0 }
  if layout.rest {
    let rest-bottom = bottom-y + layout.at("rest-offset", default: 0)
    draw-rest(_duration-base(layout), x, bottom-y: rest-bottom, line-gap: line-gap, unit: unit, paint: paint)
    let dot-x = x + rest-width(_duration-base(layout)) + _dot-gap-from-head
    _draw-dots(dot-x, rest-bottom + 2.5 * line-gap, layout.duration.dots, unit: unit, paint: paint)
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
        paint: paint,
      )
      let placement = accidental-plan.placements.at(str(pitch-index), default: none)
      if placement != none {
        draw-accidental(
          placement.kind,
          x - left-spread - head-half-width - _accidental-gap - placement.dx,
          notehead-y,
          unit: unit,
          scale: notation-scale,
          paint: paint,
        )
      }
      if layout.notehead == "whole" {
        draw-whole-notehead(head-x, notehead-y, unit: unit, scale: notation-scale, paint: paint)
      } else if layout.notehead == "half" {
        draw-open-notehead(head-x, notehead-y, unit: unit, scale: notation-scale, paint: paint)
      } else {
        draw-filled-notehead(head-x, notehead-y, unit: unit, scale: notation-scale, paint: paint)
      }
      let dot-x = x + right-spread + head-half-width + _dot-gap-from-head + 0.2
      for dot-index in range(layout.duration.dots) {
        draw-augmentation-dot(
          dot-x + dot-index * _dot-step * notation-scale,
          _dot-y(staff-position, notehead-y, line-gap),
          unit: unit,
          scale: notation-scale,
          paint: paint,
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
      draw-stem(x, stem-start-y, direction: direction, length: stem-length, unit: unit, glyph-scale: notation-scale, paint: paint)
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
          draw-stem-tremolo(stem-x, y, unit: unit, paint: paint)
        }
      }
      if layout.flags > 0 and not suppress-flags {
        let tip = stem-tip(x, stem-start-y, direction: direction, length: stem-length, glyph-scale: notation-scale)
        draw-flag(tip.at(0), tip.at(1), direction: direction, count: layout.flags, unit: unit, scale: notation-scale, paint: paint)
      }
    } else if tremolo != none {
      let strokes = _single-tremolo-strokes(layout, tremolo)
      for stroke-index in range(strokes) {
        let y = calc.max(..y-values) + 0.8 + stroke-index * 0.81
        draw-stem-tremolo(x, y, unit: unit, paint: paint)
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
        paint: paint,
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

#let _draw-beam-group(group, bottom-y: 0, line-gap: 1.0, unit: 8pt, key: "C", paint: black) = {
  if group.len() == 0 { return }
  if group.len() == 1 {
    let item = group.first()
    _draw-notated-event(item.layout, x: item.x, bottom-y: bottom-y, unit: unit, key: key, paint: paint)
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
      paint: paint,
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
        paint: paint,
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
        draw-beam((item.sx, beam-y(item.sx) + dy), (x2, beam-y(x2) + dy), thickness: local-beam-thickness, paint: paint)
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

#let _draw-grace-details(placed, bottom-y: 0, unit: 8pt, paint: black) = {
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
          stroke: 0.20 * unit + paint,
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
        paint: paint,
      )
    }
  }
}

#let _draw-alternating-tremolos(placed, bottom-y: 0, unit: 8pt, paint: black) = {
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
            paint: paint,
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
  paint: black,
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
        _draw-beam-group(group, bottom-y: bottom-y, unit: unit, key: key, paint: paint)
      } else {
        for member in group {
          _draw-notated-event(
            member.layout,
            x: member.x,
            bottom-y: bottom-y,
            unit: unit,
            key: key,
            paint: paint,
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
        paint: paint,
      )
      event-index += 1
    }
  }
  _draw-grace-details(placed, bottom-y: bottom-y, unit: unit, paint: paint)
  _draw-alternating-tremolos(placed, bottom-y: bottom-y, unit: unit, paint: paint)
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

#let _draw-tuplets(placed, bottom-y: 0, unit: 8pt, beams: false, paint: black) = {
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
      let number = text(size: unit * 1.55, style: "italic", fill: paint, str(tuplet.numerator))
      let number-half = measure(number).width / unit / 2 + 0.32
      // Compensate for the rightward ink overhang of the italic digit so its
      // visible center, not merely its advance box, lands on the span center.
      let center = (left + right) / 2 - 0.04
      let show-bracket = tuplet.bracket == "always" or (
        tuplet.bracket == "auto" and not _tuplet-full-beam(group, beams)
      )
      if show-bracket {
        let stroke = 0.16 * unit + paint
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
