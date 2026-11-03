#import "primitives.typ": bow-control-points, bow-height, bow-indent, bow-max-height, bow-samples, draw-bow, notehead-half-width, sampled-y-at-x, staff-y
#import "../foundation/diagnostics.typ": _score-error
#import "event-geometry.typ": _dot-gap-from-head, _dot-step, _head-half-width, _stem-direction
#import "spacing.typ": _cluster-offsets
#import "events.typ": _event-stem-geometry
#import "markings.typ": _annotation-stem-direction, _annotation-with-prefix, _articulation-height, _articulation-stack, _event-articulations, _has-annotation, _has-turn-ornament, _ornament-scale, _simple-ornament

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

#let _draw-ties(ties, unit: 8pt, paint: black) = {
  for tie in ties {
    draw-bow(
      tie.start,
      tie.end,
      direction-sign: tie.dir,
      height: tie.height,
      maximum-control-height: 1.0,
      initial-rise-ratio: 0.333,
      unit: unit,
      paint: paint,
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
    let has-turn = _has-turn-ornament(item.layout)
    if dir == 1 and has-turn {
      y = calc.max(y, top + 1.9)
      if _has-annotation(item.layout, "chromatic-turn") {
        y = calc.max(y, top + 2.75)
      }
      if _annotation-with-prefix(item.layout, "turn-f=") != none {
        y = calc.max(y, top + 3.2)
      }
    }
    let simple-ornament = _simple-ornament(item.layout)
    if dir == 1 and simple-ornament != none {
      let ornament-height = (simple-ornament.half-below + simple-ornament.half-above) * _ornament-scale
      y = calc.max(y, top + 1.0 + ornament-height + 0.3)
    }
    if dir == 1 and _annotation-with-prefix(item.layout, "f=") != none {
      let ink-top = calc.max(..y-values) + 0.5
      let articulations = _event-articulations(item.layout)
      if articulations.len() > 0 and direction != "up" {
        let last = _articulation-stack(articulations, y-values, 1, bottom-y).last()
        ink-top = calc.max(ink-top, last.y + _articulation-height(last.mark) / 2)
      }
      // The digit rides on top of any ornament stacked over the same note.
      if has-turn {
        ink-top = calc.max(ink-top, top + 1.64)
      }
      if simple-ornament != none {
        let ornament-height = (simple-ornament.half-below + simple-ornament.half-above) * _ornament-scale
        ink-top = calc.max(ink-top, top + 0.863 + ornament-height)
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

#let _draw-slur-bows(layouts, unit: 8pt, paint: black) = {
  for layout in layouts {
    draw-bow(
      layout.start,
      layout.end,
      direction-sign: layout.dir,
      height: layout.height,
      maximum-control-height: 2.0,
      unit: unit,
      paint: paint,
    )
  }
}
