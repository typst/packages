#import "@preview/cetz:0.5.2"
#import "primitives.typ": _bravura-height, _bravura-width, _draw-bravura-glyph, octave-line-thickness
#import "../foundation/diagnostics.typ": _score-error
#import "event-geometry.typ": _head-half-width, _pitch-staff-index
#import "markings.typ": _event-decoration-top, _event-ink-bottom, _slur-clearance-at

// Ottava spans. Authors write sounding pitches; every event under the span is
// drawn one or two octaves nearer the staff, and a dashed bracket names the
// shift. Spans continue across barlines and wrapped systems.

// Staff-position shift that turns a sounding pitch into its drawn position,
// whether the bracket sits above the staff, and its opening and continuation
// glyphs (SMuFL ottavaAlta, ottavaBassaVb, quindicesimaAlta, and
// quindicesimaBassaMb, then the bare numerals).
#let _ottava-kinds = (
  "8va": (shift: -7, above: true, glyph: "ottava-8va", continuation: "ottava-8"),
  "8vb": (shift: 7, above: false, glyph: "ottava-8vb", continuation: "ottava-8"),
  "15ma": (shift: -14, above: true, glyph: "ottava-15ma", continuation: "ottava-15"),
  "15mb": (shift: 14, above: false, glyph: "ottava-15mb", continuation: "ottava-15"),
)

// The parser allows at most one opening and one closing marker per event.
#let _ottava-marker(layout, suffix) = {
  for annotation in layout.annotations {
    let annotation-text = str(annotation)
    if annotation-text.ends-with(suffix) and annotation-text.slice(0, -1) in _ottava-kinds {
      return annotation-text.slice(0, -1)
    }
  }
  none
}

// Shift the events of one voice's bar that fall under an ottava and mark
// each with the span it belongs to. `open` carries the span still open from
// an earlier bar, as (kind, bar), and the span open after this bar is
// returned beside the layouts.
#let _apply-ottava(layouts, open, bar-number, home-staff-index, location) = {
  let shifted = ()
  for layout in layouts {
    let opening = _ottava-marker(layout, "(")
    let closing = _ottava-marker(layout, ")")
    if opening != none {
      if open != none {
        _score-error(
          location,
          "ottava " + opening + " opens while " + open.kind + " from bar " + str(open.bar) + " is still open",
          expected: "one ottava at a time in each voice",
          fix: "close the " + open.kind + " span with " + open.kind + ") before opening another",
        )
      }
      open = (kind: opening, bar: bar-number)
    }
    if open == none {
      if closing != none {
        _score-error(
          location,
          "ottava " + closing + ") closes without opening",
          expected: closing + "( on this or an earlier event",
          fix: "add the opening marker or remove this closing marker",
        )
      }
      shifted.push(layout)
      continue
    }
    if closing != none and closing != open.kind {
      _score-error(
        location,
        "ottava " + closing + ") closes the " + open.kind + " span opened in bar " + str(open.bar),
        expected: open.kind + ")",
        fix: "close the span with the same marker that opened it",
      )
    }
    if layout.pitches.any(pitch => _pitch-staff-index(pitch) != home-staff-index) {
      _score-error(
        location,
        "an event under ottava " + open.kind + " is drawn on another staff",
        expected: "every event of the span on the voice's own staff",
        fix: "end the ottava before the staff switch and open a new one afterwards",
      )
    }
    let shift = _ottava-kinds.at(open.kind).shift
    shifted.push(layout + (
      pitches: layout.pitches.map(pitch => pitch + (staff_position: pitch.staff_position + shift)),
      ottava: (kind: open.kind, start: opening != none, stop: closing != none),
    ))
    if closing != none {
      open = none
    }
  }
  (layouts: shifted, open: open)
}

#let _validate-ottava-closed(open, location) = {
  if open != none {
    _score-error(
      location,
      "ottava " + open.kind + " opened in bar " + str(open.bar) + " was never closed",
      expected: open.kind + ") on a later event",
      fix: "add the matching ottava closing marker",
    )
  }
}

// Consecutive events of one voice that share an ottava span within a system.
// A span broken by the system edge continues from `continuation-left-x` or
// to `continuation-right-x`.
#let _collect-ottava-spans(placed-measures, continuation-left-x, continuation-right-x) = {
  let spans = ()
  let current = none
  for placed in placed-measures {
    for item in placed {
      let ottava = item.layout.at("ottava", default: none)
      if ottava == none { continue }
      if current == none or ottava.start {
        if current != none { spans.push(current) }
        current = (
          kind: ottava.kind,
          starts: ottava.start,
          stops: false,
          start-x: if ottava.start {
            item.x - _head-half-width(item.layout)
          } else {
            continuation-left-x
          },
          end-x: continuation-right-x,
          xs: (),
        )
      }
      current.xs.push(item.x)
      if ottava.stop {
        current.stops = true
        current.end-x = item.x + _head-half-width(item.layout)
        spans.push(current)
        current = none
      }
    }
  }
  if current != none { spans.push(current) }
  spans
}

#let _ottava-glyph-scale = 0.72
#let _ottava-hook = 0.8
// The dashed line runs through the middle of the numeral's figure height.
#let _ottava-line-rise = 0.62
#let _ottava-text-height = 1.852 * _ottava-glyph-scale

// Settle each span's height against the ink it passes over: every event of
// the staff between its ends (all voices), the slurs of its own voice, and,
// for brackets below the staff, the voice's dynamics baseline.
#let _place-ottava-spans(spans, staff-items, bottom-y: 0, beams: false, slur-layouts: (), dynamics-baseline: none) = {
  spans.map(span => {
    let kind = _ottava-kinds.at(span.kind)
    let covered = staff-items.filter(entry => (
      entry.item.x >= span.start-x - 0.6 and entry.item.x <= span.end-x + 0.6
    ))
    let baseline = if kind.above {
      let clearance = bottom-y + 4 + 1.0
      for entry in covered {
        clearance = calc.max(
          clearance,
          _event-decoration-top(entry.item, entry.placed, beams: beams, bottom-y: bottom-y) + 0.3,
        )
      }
      for x in span.xs {
        let slur-y = _slur-clearance-at(slur-layouts, x)
        if slur-y != none { clearance = calc.max(clearance, slur-y + 0.45) }
      }
      clearance
    } else {
      let clearance = bottom-y - 1.1
      for entry in covered {
        clearance = calc.min(clearance, _event-ink-bottom(entry.item, bottom-y: bottom-y) - 0.5)
      }
      if dynamics-baseline != none {
        clearance = calc.min(clearance, dynamics-baseline - 1.0)
      }
      clearance - _ottava-text-height
    }
    span + (
      baseline: baseline,
      line-y: baseline + _ottava-line-rise,
      above: kind.above,
      glyph: if span.starts { kind.glyph } else { kind.continuation },
    )
  })
}

// The highest ink of the brackets above the staff, or none.
#let _ottava-spans-top(placed-spans) = {
  let top = none
  for span in placed-spans.filter(span => span.above) {
    let span-top = span.baseline + _ottava-text-height
    top = if top == none { span-top } else { calc.max(top, span-top) }
  }
  top
}

#let _draw-dashed-line(start-x, end-x, y, stroke-style) = {
  import cetz.draw: *
  let dash = 0.4
  let gap = 0.4
  let x = start-x
  while x < end-x {
    line((x, y), (calc.min(x + dash, end-x), y), stroke: stroke-style)
    x += dash + gap
  }
}

#let _draw-ottava-spans(placed-spans, unit: 8pt, paint: black) = {
  import cetz.draw: *
  let stroke-style = octave-line-thickness * unit + paint
  for span in placed-spans {
    _draw-bravura-glyph(
      span.glyph,
      span.start-x,
      span.baseline,
      unit: unit,
      origin: true,
      glyph-scale: _ottava-glyph-scale,
      paint: paint,
    )
    // Gould: a span too short for its line, such as a single note, shows
    // the sign alone.
    let line-start = span.start-x + _bravura-width(span.glyph) * _ottava-glyph-scale + 0.3
    if span.end-x < line-start + 0.5 { continue }
    _draw-dashed-line(line-start, span.end-x, span.line-y, stroke-style)
    if span.stops {
      let hook-end = if span.above { span.line-y - _ottava-hook } else { span.line-y + _ottava-hook }
      line((span.end-x, span.line-y), (span.end-x, hook-end), stroke: stroke-style)
    }
  }
}
