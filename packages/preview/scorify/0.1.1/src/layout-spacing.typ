// layout-spacing.typ - Duration-to-width calculations
//
// Converts event durations into horizontal spacing values.

#import "utils.typ": duration-to-beats, duration-spacing-factor
#import "constants.typ": default-note-spacing-base

/// Compute the horizontal width (in staff-spaces) for an event's duration.
#let event-width(event, base-width: default-note-spacing-base) = {
  if event.type == "barline" {
    // Barlines have padding on both sides
    2.5
  } else if event.type == "clef" or event.type == "key-sig" or event.type == "time-sig" {
    // Non-rhythmic events: fixed width
    2.0
  } else {
    // Notes, rests, spacers, chords: duration-proportional
    let dur = event.at("duration", default: 4)
    let dots = event.at("dots", default: 0)
    let factor = duration-spacing-factor(dur, dots: dots)
    let w = base-width * factor
    // Extra space for notes/chords with accidentals
    if event.type == "note" and event.at("accidental", default: none) != none {
      w += 0.5
    }
    if event.type == "chord" {
      let any-acc = event.at("notes", default: ()).any(n => n.at("accidental", default: none) != none)
      if any-acc { w += 0.5 }
    }
    // Scale width for tuplet notes/rests (e.g. 3 notes in space of 2 → ×2/3)
    let tn = event.at("tuplet-n", default: 1)
    let tm = event.at("tuplet-m", default: 1)
    if tn > 1 { w = w * tm / tn }
    w
  }
}

/// Given an array of events, compute an array of x-positions.
/// Returns an array of (x, width) pairs.
#let compute-event-positions(events, base-width: default-note-spacing-base) = {
  let positions = ()
  let x = 0.0
  for event in events {
    let w = event-width(event, base-width: base-width)
    positions.push((x: x, width: w))
    x += w
  }
  positions
}

/// Compute total width of all events.
#let total-events-width(events, base-width: default-note-spacing-base) = {
  let total = 0.0
  for event in events {
    total += event-width(event, base-width: base-width)
  }
  total
}

/// Align multiple staves' layouts so events at the same beat position share
/// the same x coordinate.  Uses a distributed-width approach: each event's
/// width is spread evenly across the beat columns it spans, so a whole note
/// sharing beat 0 with a quarter note does not inflate that column.
///
/// Takes an array of layout results (from layout-staff) and returns a new
/// array with adjusted item x positions and a unified total-width.
#let align-staves-by-beat(laid-out-staves) = {
  if laid-out-staves.len() <= 1 { return laid-out-staves }

  let barline-epsilon = 0.000001

  // 1. Compute cumulative beat offset for every item in every staff.
  //    Barlines get a tiny epsilon bump so the next note occupies a separate
  //    column (barline and first note of the next measure share the same
  //    rhythmic beat but need distinct x positions).
  let staves-beats = ()
  for laid-out in laid-out-staves {
    let beats = ()
    let beat = 0.0
    for item in laid-out.items {
      beats.push(calc.round(beat, digits: 6))
      let ev = item.event
      if ev.type == "note" or ev.type == "rest" or ev.type == "spacer" or ev.type == "chord" {
        let dur = ev.at("duration", default: 4)
        let dots = ev.at("dots", default: 0)
        let dur-beats = duration-to-beats(dur, dots: dots)
        let tn = ev.at("tuplet-n", default: 1)
        let tm = ev.at("tuplet-m", default: 1)
        if tn > 1 { dur-beats = dur-beats * tm / tn }
        beat += dur-beats
      } else if ev.type == "barline" {
        beat += barline-epsilon
      }
    }
    staves-beats.push(beats)
  }

  // 2. Sorted unique beat positions.
  let beat-set = (:)
  for staff-beats in staves-beats {
    for b in staff-beats {
      beat-set.insert(str(b), b)
    }
  }
  let all-beats = beat-set.values().sorted()

  // 3. Beat → column index map.
  let beat-to-col = (:)
  for (ci, b) in all-beats.enumerate() {
    beat-to-col.insert(str(b), ci)
  }
  let n-cols = all-beats.len()

  // 4. Compute column widths using the distributed-width approach.
  //    Each event's width is distributed evenly across the columns from its
  //    start to the next event's start on the same staff.  The per-column
  //    width is then the max across all staves.
  let col-widths = range(n-cols).map(_ => 0.0)

  for (si, laid-out) in laid-out-staves.enumerate() {
    let staff-beats = staves-beats.at(si)
    let items = laid-out.items
    for (ii, item) in items.enumerate() {
      let start-col = beat-to-col.at(str(staff-beats.at(ii)))
      let end-col = if ii + 1 < items.len() {
        beat-to-col.at(str(staff-beats.at(ii + 1)))
      } else {
        start-col + 1
      }
      let span = calc.max(end-col - start-col, 1)
      let w = event-width(item.event)
      let distributed = w / span
      for c in range(start-col, calc.min(end-col, n-cols)) {
        if distributed > col-widths.at(c) {
          col-widths.at(c) = distributed
        }
      }
    }
  }

  // 5. Cumulative x positions per column.
  let col-xs = ()
  let x = 0.0
  for w in col-widths {
    col-xs.push(x)
    x += w
  }
  let total-w = x

  // 6. Reassign x to each item based on its column.
  let result = ()
  for (si, laid-out) in laid-out-staves.enumerate() {
    let staff-beats = staves-beats.at(si)
    let new-items = ()
    for (ii, item) in laid-out.items.enumerate() {
      let ci = beat-to-col.at(str(staff-beats.at(ii)))
      new-items.push((
        event: item.event,
        x: col-xs.at(ci),
        y: item.y,
        stem-dir: item.stem-dir,
        stem-y-end: item.stem-y-end,
      ))
    }
    result.push((
      items: new-items,
      total-width: total-w,
      clef: laid-out.clef,
    ))
  }

  result
}
