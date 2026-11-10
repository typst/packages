// render-slurs-ties.typ - Slur and tie curve rendering
//
// Draws tie arcs (connecting two notes of the same pitch) and slur arcs
// (phrasing curves spanning multiple notes) as cubic bezier curves.

#import "@preview/cetz:0.4.2"
#import "constants.typ": *
#import "glyph-metadata.typ": advance-width

/// Get the notehead width for a given duration (in staff-space units).
#let _nh-width(duration) = {
  let smufl = if duration == 1 { "noteheadWhole" }
    else if duration == 2 { "noteheadHalf" }
    else { "noteheadBlack" }
  advance-width(smufl)
}

/// Draw a single curved arc (used for both ties and slurs).
/// Uses two filled bezier curves (outer and inner) to create the traditional
/// engraving look: thin at the endpoints, thick in the middle.
///
/// - x1, y1: start point (notehead center x/y in absolute canvas coords)
/// - x2, y2: end point
/// - direction: +1 for curve above (arching upward), -1 for curve below
/// - sp: staff space
/// - max-thickness: maximum thickness at the midpoint (in staff spaces)
/// - height-factor: controls how tall the arc is (fraction of span)
#let draw-arc(x1, y1, x2, y2, direction, sp: 1.0, max-thickness: 0.22, height-factor: 0.3) = {
  import cetz.draw: *

  let dx = x2 - x1
  let mid-x = (x1 + x2) / 2.0
  let mid-y = (y1 + y2) / 2.0

  // Height of the arc: proportional to horizontal span, clamped
  let arc-height = calc.min(calc.max(calc.abs(dx) * height-factor, 0.8 * sp), 3.0 * sp)

  // Half-thickness at the peak (the curve tapers to ~0 at endpoints)
  let half-thick = max-thickness * sp / 2.0

  // Outer curve (further from noteheads)
  let outer-cp1-x = x1 + dx * 0.2
  let outer-cp1-y = y1 + direction * (arc-height + half-thick) * 0.9
  let outer-cp2-x = x1 + dx * 0.8
  let outer-cp2-y = y2 + direction * (arc-height + half-thick) * 0.9

  // Inner curve (closer to noteheads) — less height = thinner at edges
  let inner-cp1-x = x1 + dx * 0.25
  let inner-cp1-y = y1 + direction * calc.max(arc-height - half-thick, arc-height * 0.5) * 0.9
  let inner-cp2-x = x1 + dx * 0.75
  let inner-cp2-y = y2 + direction * calc.max(arc-height - half-thick, arc-height * 0.5) * 0.9

  // Draw as a filled shape: outer bezier forward, inner bezier backward
  // CeTZ merge-path lets us combine two beziers into one filled region.
  merge-path(
    fill: black,
    stroke: none,
    close: true,
    {
      bezier(
        (x1, y1), (x2, y2),
        (outer-cp1-x, outer-cp1-y), (outer-cp2-x, outer-cp2-y),
      )
      bezier(
        (x2, y2), (x1, y1),
        (inner-cp2-x, inner-cp2-y), (inner-cp1-x, inner-cp1-y),
      )
    },
  )
}

/// Draw all ties and slurs for a system.
///
/// - items: laid-out event items (from layout-staff)
/// - item-xs: pre-computed x positions (absolute canvas coords)
/// - y-top: absolute y of top staff line
/// - sp: staff space
/// - adj-stem-dirs: dictionary of str(i) -> stem-dir overrides (from beaming)
#let draw-ties-and-slurs(items, item-xs, y-top, sp: 1.0, adj-stem-dirs: (:)) = {
  import cetz.draw: *

  let get-stem-dir(i, item) = {
    adj-stem-dirs.at(str(i), default: item.stem-dir)
  }

  // ── Ties ──────────────────────────────────────────────────────────────────
  for (i, item) in items.enumerate() {
    let ev = item.event
    if ev.type != "note" and ev.type != "chord" { continue }
    if not ev.at("tie", default: false) { continue }

    // Find the next note/chord event (skip barlines, rests, spacers)
    let j = i + 1
    while j < items.len() {
      let nev = items.at(j).event
      if nev.type == "note" or nev.type == "chord" { break }
      j += 1
    }
    if j >= items.len() { continue }

    let next-item = items.at(j)
    let stem-dir = get-stem-dir(i, item)

    // Tie curves opposite to stem: stem-up → tie below, stem-down → tie above
    let direction = if stem-dir == "up" { -1.0 } else { 1.0 }

    // Compute notehead-edge x coordinates
    let nh-w = _nh-width(ev.duration) * sp
    let nh-w-next = _nh-width(next-item.event.duration) * sp

    // Start x: right edge of first notehead. End x: left edge of second notehead.
    let start-x = item-xs.at(i) + nh-w / 2.0 * 0.8
    let end-x = item-xs.at(j) - nh-w-next / 2.0 * 0.8

    // Y positions: near the notehead, offset slightly in curve direction
    let note-y = y-top + item.y * sp
    let next-note-y = y-top + next-item.y * sp
    let y-offset = direction * 0.35 * sp
    let start-y = note-y + y-offset
    let end-y = next-note-y + y-offset

    draw-arc(start-x, start-y, end-x, end-y, direction, sp: sp, max-thickness: 0.2, height-factor: 0.25)
  }

  // ── Slurs ─────────────────────────────────────────────────────────────────
  // Find slur-start/slur-end pairs. Support nested slurs with a simple stack.
  let slur-starts = ()  // stack of (index, item) for open slurs
  for (i, item) in items.enumerate() {
    let ev = item.event
    if ev.type != "note" and ev.type != "chord" { continue }

    if ev.at("slur-start", default: false) {
      slur-starts.push(i)
    }

    if ev.at("slur-end", default: false) and slur-starts.len() > 0 {
      let start-idx = slur-starts.pop()
      let start-item = items.at(start-idx)
      let start-ev = start-item.event

      let stem-dir = get-stem-dir(start-idx, start-item)

      // Slur curves opposite to stem direction
      let direction = if stem-dir == "up" { -1.0 } else { 1.0 }

      let nh-w-start = _nh-width(start-ev.duration) * sp
      let nh-w-end = _nh-width(ev.duration) * sp

      let start-x = item-xs.at(start-idx) + nh-w-start / 2.0 * 0.8
      let end-x = item-xs.at(i) - nh-w-end / 2.0 * 0.8

      let start-note-y = y-top + start-item.y * sp
      let end-note-y = y-top + item.y * sp
      let y-offset = direction * 0.4 * sp
      let start-y = start-note-y + y-offset
      let end-y = end-note-y + y-offset

      draw-arc(start-x, start-y, end-x, end-y, direction, sp: sp, max-thickness: 0.25, height-factor: 0.35)
    }
  }
}
