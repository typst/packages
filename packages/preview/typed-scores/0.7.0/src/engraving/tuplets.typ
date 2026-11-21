#import "@preview/cetz:0.5.3"
#import "event-geometry.typ": _event-bottom-y, _event-notation-scale, _event-pitch-ys, _group-notation-scale, _head-half-width, _layout-stem-direction, _stem-direction
#import "events.typ": _beam-group-staves, _beam-group-visible, _event-stem-geometry

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
  let pitched = group.filter(item => item.layout.pitches.len() > 0)
  if _beam-group-staves(pitched).len() > 1 {
    let directions = pitched.map(item => _layout-stem-direction(item.layout)).dedup()
    return if directions == ("down",) { "below" } else { "above" }
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
      let tuplet-scale = _group-notation-scale(group)
      let shows-number = tuplet.at("number", default: "always") != "never"
      // LilyPond centers a TupletNumber on the note-column origins. Our event
      // x coordinates denote notehead centers, so use each boundary head's
      // left-side origin rather than the center of its bounding box. The
      // asymmetric terminal padding includes the last column's stem edge.
      let left = tuplet.at("continuation-left-x", default: group.first().x - _head-half-width(group.first().layout) * _event-notation-scale(group.first().layout) - 0.16)
      let right = tuplet.at("continuation-right-x", default: group.last().x + _head-half-width(group.last().layout) * _event-notation-scale(group.last().layout) + 0.16)
      let lane = tuplet.depth * 1.12
      let y = if above {
        let top = calc.max(..group.map(item => {
          if item.layout.rest or item.layout.pitches.len() == 0 {
            _event-bottom-y(item.layout, bottom-y) + 4.7
          } else {
            let heads = _event-pitch-ys(item.layout, bottom-y: bottom-y)
            // A numeral on the notehead side must clear the head outline, not its center.
            let head-top = calc.max(..heads) + (0.5 + 0.2) * _event-notation-scale(item.layout)
            let stem = _event-stem-geometry(item.layout, item.x, bottom-y: bottom-y)
            if stem != none and stem.direction == "up" {
              calc.max(head-top, stem.point.at(1))
            } else {
              head-top
            }
          }
        }))
        let top = if tuplet.at("crosses-measures", default: false) {
          calc.max(top, _event-bottom-y(group.first().layout, bottom-y) + 4.7)
        } else { top }
        top + 0.66 * tuplet-scale + lane
      } else {
        let bottom = calc.min(..group.map(item => {
          if item.layout.rest or item.layout.pitches.len() == 0 {
            _event-bottom-y(item.layout, bottom-y)
          } else {
            let heads = _event-pitch-ys(item.layout, bottom-y: bottom-y)
            let stem = _event-stem-geometry(item.layout, item.x, bottom-y: bottom-y)
            if stem != none and stem.direction == "down" {
              calc.min(calc.min(..heads) - 0.3, stem.point.at(1))
            } else {
              calc.min(..heads) - 0.3
            }
          }
        }))
        let bottom = if tuplet.at("crosses-measures", default: false) {
          calc.min(bottom, _event-bottom-y(group.first().layout, bottom-y) - 0.7)
        } else { bottom }
        bottom - 0.66 * tuplet-scale - lane
      }
      let number = text(size: unit * 1.55 * tuplet-scale, style: "italic", fill: paint, str(tuplet.numerator))
      let number-half = measure(number).width / unit / 2 + 0.32 * tuplet-scale
      // Compensate for the rightward ink overhang of the italic digit so its
      // visible center, not merely its advance box, lands on the span center.
      let center = (left + right) / 2 - 0.04
      let show-bracket = tuplet.bracket == "always" or (
        tuplet.bracket == "auto" and (
          tuplet.at("crosses-measures", default: false) or not _tuplet-full-beam(group, beams)
        )
      )
      if show-bracket {
        let stroke = 0.16 * unit + paint
        if not shows-number {
          line((left, y), (right, y), stroke: stroke)
        } else {
          if center - number-half > left {
            line((left, y), (center - number-half, y), stroke: stroke)
          }
          if center + number-half < right {
            line((center + number-half, y), (right, y), stroke: stroke)
          }
        }
        let hook = (if above { -0.70 } else { 0.70 }) * tuplet-scale
        if tuplet.at("continuation-left-x", default: none) == none {
          line((left, y), (left, y + hook), stroke: stroke)
        }
        if tuplet.at("continuation-right-x", default: none) == none {
          line((right, y), (right, y + hook), stroke: stroke)
        }
      }
      if shows-number {
        content(
          (center, y),
          number,
          anchor: "center",
          padding: 0pt,
        )
      }
    }
  }
}

#let _tuplet-span-ids(layouts) = {
  let spans = ()
  for layout in layouts {
    for tuplet in layout.at("tuplet_starts", default: ()) {
      let span = tuplet.at("span", default: none)
      if span != none { spans.push(span) }
    }
  }
  spans.dedup()
}

#let _draw-system-tuplets(placed-by-measure, incoming: (), outgoing: (), left-x: 0, right-x: 0, bottom-y: 0, unit: 8pt, beams: false, paint: black) = {
  let flat-placed = ()
  let measure-start-indices = ()
  let next-start-index = 0
  for measure-placed in placed-by-measure {
    measure-start-indices.push(next-start-index)
    flat-placed += measure-placed
    next-start-index += measure-placed.len()
  }

  let cross-measure-ranges = (:)
  for (measure-index, measure-placed) in placed-by-measure.enumerate() {
    let measure-start-index = measure-start-indices.at(measure-index)
    for (event-index, item) in measure-placed.enumerate() {
      for tuplet in item.layout.at("tuplet_starts", default: ()) {
        let span = tuplet.at("span", default: none)
        if span == none { continue }
        let span-start-index = measure-start-index + event-index
        let span-end-index = measure-start-index + tuplet.end_index
        let existing = cross-measure-ranges.at(span, default: none)
        if existing == none {
          cross-measure-ranges.insert(span, (
            start-index: span-start-index,
            end-index: span-end-index,
            fragments: 1,
          ))
        } else {
          cross-measure-ranges.insert(span, existing + (end-index: span-end-index, fragments: existing.fragments + 1))
        }
      }
    }
  }

  let draw-placed = ()
  for (measure-index, measure-placed) in placed-by-measure.enumerate() {
    let measure-start-index = measure-start-indices.at(measure-index)
    for (event-index, item) in measure-placed.enumerate() {
      let global-event-index = measure-start-index + event-index
      let tuplet-starts = ()
      for tuplet in item.layout.at("tuplet_starts", default: ()) {
        let span = tuplet.at("span", default: none)
        if span == none {
          tuplet-starts.push(tuplet + (end_index: measure-start-index + tuplet.end_index,))
        } else {
          let span-range = cross-measure-ranges.at(span)
          if global-event-index == span-range.start-index {
            let joined = tuplet + (
              end_index: span-range.end-index,
              crosses-measures: span-range.fragments > 1 or incoming.contains(span) or outgoing.contains(span),
            )
            if incoming.contains(span) {
              joined += (continuation-left-x: left-x, number: "never")
            }
            if outgoing.contains(span) {
              joined += (continuation-right-x: right-x,)
            }
            tuplet-starts.push(joined)
          }
        }
      }
      let layout = item.layout + (tuplet_starts: tuplet-starts,)
      draw-placed.push(item + (layout: layout,))
    }
  }
  _draw-tuplets(draw-placed, bottom-y: bottom-y, unit: unit, beams: beams, paint: paint)
}
