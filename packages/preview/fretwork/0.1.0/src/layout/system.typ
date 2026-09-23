// Breaking music into systems, and placing events along each one.
//
// The result is a single array of x-positions per system, shared by every lane
// drawn on it. That sharing is deliberate: a chord name, a rhythm stem and a
// fret number belonging to the same event must line up vertically, and a
// notation staff added later lines up for free by consuming the same positions.

#import "../tuning.typ": string-count
#import "spacing.typ": barline-allowance, measure-natural, meter-allowance

/// Pack measures greedily into systems.
///
/// `widths` holds one packed width per measure — its natural width plus its
/// barline allowance. `indent` is what the system start consumes before any
/// music, i.e. the vertical TAB mark.
///
/// A measure wider than the whole line still gets a system of its own rather
/// than being dropped.
#let pack(widths, available, indent) = {
  let limit = available - indent
  let systems = ()
  let current = ()
  let used = 0pt

  for (i, w) in widths.enumerate() {
    if current.len() > 0 and used + w > limit {
      systems.push(current)
      current = ()
      used = 0pt
    }
    current.push(i)
    used += w
  }
  if current.len() > 0 { systems.push(current) }
  systems
}

/// How far to stretch a system so it reaches the right margin.
///
/// Justification is proportional: one factor applied to every natural width,
/// so measures keep their relative sizes and a bar of sixteenths does not end
/// up as wide as a bar of whole notes.
///
/// A final system that is barely started is left unstretched, the way the last
/// line of a paragraph is — spreading four events across a full page reads as a
/// mistake rather than as music.
#let justify-factor(stretchable, available, last: false, min-fill: 0.65) = {
  if stretchable <= 0pt { return 1.0 }
  let factor = available / stretchable
  if last and factor > 1.0 and available > 0pt and stretchable / available < min-fill {
    return 1.0
  }
  factor
}

/// Assign an x-position to every event in one system.
///
/// Returns `(measures: (…), width: length)`, where each measure carries its
/// start and end x and its events carry the x at which their fret number is
/// centred. Barline allowances are *not* scaled: a repeat sign is a fixed piece
/// of graphic, so only the music between barlines stretches.
#let place-system(theme, strings, measures, times, naturals, glyph-widths, indices, factor, indent, show-time: true) = {
  let x = indent
  let placed = ()

  for mi in indices {
    let m = measures.at(mi)
    let start = x
    if m.start-repeat { x += 1.1 * theme.staff-space }
    // A time signature is leading furniture: it stands between the opening
    // barline and the first note, so its room comes off the front of the
    // measure rather than the back, where the closing barline's does.
    let meter-x = x
    let meter = meter-allowance(theme, strings, m, times.at(mi), show-time and mi == 0)
    x += meter
    x += theme.measure-padding * factor

    let events = ()
    for (i, ev) in m.events.enumerate() {
      let alloc = naturals.at(mi).events.at(i) * factor
      let gw = glyph-widths.at(mi).at(i, default: (total: 0pt, anchor: 0pt))
      events.push((
        event: ev,
        // Aligned on the event's own number, not on the whole run it prints, so
        // a rhythm stem stays over the note it belongs to even when a hammer-on
        // target follows it.
        x: x + gw.anchor / 2 + theme.min-event-gap / 2,
        left: x,
        alloc: alloc,
        glyph-width: gw.total,
      ))
      x += alloc
    }

    x += theme.measure-padding * factor
    x += barline-allowance(theme, m) - (if m.start-repeat { 1.1 * theme.staff-space } else { 0pt })
    placed.push((
      index: mi,
      measure: m,
      // The signature in force here, not merely one declared here: renderers
      // need it for beam grouping and for the count row.
      time: times.at(mi),
      // Where to print that signature, and `none` where it is not printed —
      // so the renderer draws what it is told rather than re-deciding.
      meter: if meter > 0pt { (x: meter-x, width: meter) } else { none },
      start: start,
      end: x,
      events: events,
    ))
  }

  (measures: placed, width: x)
}

/// Break a part into placed systems.
///
/// `glyph-widths` is a per-measure array of per-event widths, measured by the
/// caller. `available` is the usable line width.
/// `show-time` prints the signature in force at the first measure. A passage
/// set as its own `tab` block gets one; a later block of the same piece, or a
/// later section of one imported tab, passes `false` so the reader is not told
/// twice.
#let layout-part(theme, part, glyph-widths, available, indent, show-time: true) = {
  // The signature in force at each measure, carried forward in one pass —
  // calling `time-signature-at` per measure rescans the part each time, which
  // is quadratic over the piece.
  let times = ()
  let sig = part.time
  for m in part.measures {
    if m.time != none { sig = m.time }
    times.push(sig)
  }
  let strings = string-count(part.tuning)
  let naturals = part
    .measures
    .enumerate()
    .map(((i, m)) => measure-natural(theme, m, glyph-widths.at(i, default: ())))
  // Furniture: fixed graphic that never stretches with justification.
  let furniture(i) = (
    barline-allowance(theme, part.measures.at(i))
      + meter-allowance(theme, strings, part.measures.at(i), times.at(i), show-time and i == 0)
  )
  let packed-widths = part
    .measures
    .enumerate()
    .map(((i, _)) => naturals.at(i).total + furniture(i))

  let groups = pack(packed-widths, available, indent)

  groups
    .enumerate()
    .map(((gi, indices)) => {
      let fixed = indices.fold(0pt, (acc, mi) => acc + furniture(mi))
      let stretchable = indices.fold(0pt, (acc, mi) => acc + naturals.at(mi).total)
      let factor = justify-factor(
        stretchable,
        available - indent - fixed,
        last: gi == groups.len() - 1,
      )
      place-system(
        theme,
        strings,
        part.measures,
        times,
        naturals,
        glyph-widths,
        indices,
        factor,
        indent,
        show-time: show-time,
      )
    })
}
