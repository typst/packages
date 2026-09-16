// layout-spacing.typ - Duration-to-width calculations
//
// Converts event durations into horizontal spacing values.

#import "utils.typ": duration-to-beats, duration-spacing-factor
#import "constants.typ": default-note-spacing-base, default-time-sig-padding, default-accidental-padding, default-inline-clef-scale
#import "render-clef-key-time.typ": clef-advance, time-sig-advance
#import "glyph-metadata.typ": advance-width

#let inline-time-sig-width(event, prev-event: none, next-event: none, music-font-config: none) = {
  let glyph-w = calc.max(
    time-sig-advance(event.upper, event.lower, symbol: event.symbol, sp: 1.0, music-font-config: music-font-config) - default-time-sig-padding,
    0.0,
  )
  let extra = if prev-event != none and prev-event.type == "barline" {
    0.18
  } else if next-event != none and next-event.type == "barline" {
    0.0
  } else {
    0.12
  }
  glyph-w + extra
}

#let notehead-width(duration, music-font-config: none) = {
  let smufl = if duration == 1 { "noteheadWhole" }
    else if duration == 2 { "noteheadHalf" }
    else { "noteheadBlack" }
  advance-width(smufl, config: music-font-config)
}

#let accidental-width(accidental, music-font-config: none) = {
  let smufl = if accidental == "sharp" { "accidentalSharp" }
    else if accidental == "flat" { "accidentalFlat" }
    else if accidental == "natural" { "accidentalNatural" }
    else if accidental == "double-sharp" { "accidentalDoubleSharp" }
    else if accidental == "double-flat" { "accidentalDoubleFlat" }
    else { none }
  if smufl == none { 0.0 } else { advance-width(smufl, config: music-font-config) }
}

#let required-leading-accidental-space(next-event, music-font-config: none) = {
  if next-event == none { return 0.0 }
  let next-is-grace = next-event.at("grace", default: false)
  let scale = if next-is-grace { 0.68 } else { 1.0 }
  let cluster-factor = if next-is-grace and (
    (next-event.at("type", default: "") == "note")
    or (next-event.at("type", default: "") == "chord")
  ) { 0.55 } else { 1.0 }
  if next-event.type == "note" and next-event.at("accidental", default: none) != none {
    (accidental-width(next-event.at("accidental"), music-font-config: music-font-config) + default-accidental-padding) * scale * cluster-factor
  } else if next-event.type == "chord" {
    let acc-widths = next-event.at("notes", default: ()).map(n => accidental-width(n.at("accidental", default: none), music-font-config: music-font-config))
    if acc-widths.len() > 0 {
      (acc-widths.fold(0.0, calc.max) + default-accidental-padding) * scale * cluster-factor
    } else {
      0.0
    }
  } else {
    0.0
  }
}

#let leading-accidental-extra(available-space, next-event, music-font-config: none) = {
  let required = required-leading-accidental-space(next-event, music-font-config: music-font-config)
  if required <= 0.0 { return 0.0 }
  let comfort = 0.08
  calc.max(required + comfort - available-space, 0.0)
}

#let grace-body-width(event, prev-event: none, next-event: none, music-font-config: none) = {
  let grace-scale = 0.68
  let duration = event.at("duration", default: 4)
  let head-w = notehead-width(duration, music-font-config: music-font-config)
  let rest-w = if event.type == "rest" {
    let smufl = if duration == 1 { "restWhole" }
      else if duration == 2 { "restHalf" }
      else if duration == 4 { "restQuarter" }
      else if duration == 8 { "rest8th" }
      else if duration == 16 { "rest16th" }
      else if duration == 32 { "rest32nd" }
      else if duration == 64 { "rest64th" }
      else { "restQuarter" }
    advance-width(smufl, config: music-font-config)
  } else {
    0.0
  }
  let inter-note-gap = if next-event != none and not next-event.at("grace", default: false) {
    0.04
  } else if prev-event != none and prev-event.at("grace", default: false) {
    0.08
  } else {
    0.12
  }
  calc.max(head-w, rest-w) * grace-scale + inter-note-gap
}

/// Compute the horizontal width (in staff-spaces) for an event's duration.
#let event-width(event, base-width: default-note-spacing-base, prev-event: none, next-event: none, music-font-config: none) = {
  if event.type == "barline" {
    // Tighten barlines when they are adjacent to inline boundary changes.
    let touches-inline-boundary = (
      (prev-event != none and (prev-event.type == "clef" or prev-event.type == "time-sig"))
      or (next-event != none and (next-event.type == "clef" or next-event.type == "time-sig"))
    )
    if touches-inline-boundary {
      0.6
    } else {
      2.5
    }
  } else if event.type == "clef" {
    clef-advance(clef-name: event.clef, sp: 1.0, scale: default-inline-clef-scale, music-font-config: music-font-config)
  } else if event.type == "time-sig" {
    inline-time-sig-width(event, prev-event: prev-event, next-event: next-event, music-font-config: music-font-config)
  } else if event.type == "key-sig" {
    // Non-rhythmic events: fixed width
    2.0
  } else if event.type == "gap" {
    0.7 * event.at("amount", default: 1)
  } else {
    if event.at("grace", default: false) {
      let body = grace-body-width(event, prev-event: prev-event, next-event: next-event, music-font-config: music-font-config)
      return body + leading-accidental-extra(body, next-event, music-font-config: music-font-config)
    }
    // Notes, rests, spacers, chords: duration-proportional
    let dur = event.at("duration", default: 4)
    let dots = event.at("dots", default: 0)
    let factor = duration-spacing-factor(dur, dots: dots)
    let w = base-width * factor
    // Tuplet notes: total group width = width of tuplet-beats, divided among notes
    let tb = event.at("tuplet-beats", default: 0)
    let tc = event.at("tuplet-count", default: 0)
    if tb > 0 and tc > 0 {
      let equiv-dur = 4.0 / tb
      let total-w = base-width * duration-spacing-factor(equiv-dur)
      w = total-w / tc
    }
    w + leading-accidental-extra(w, next-event, music-font-config: music-font-config)
  }
}

/// Given an array of events, compute an array of x-positions.
/// Returns an array of (x, width) pairs.
#let compute-event-positions(events, base-width: default-note-spacing-base, music-font-config: none) = {
  let positions = ()
  let x = 0.0
  for (i, event) in events.enumerate() {
    let prev-event = if i > 0 { events.at(i - 1) } else { none }
    let next-event = if i + 1 < events.len() { events.at(i + 1) } else { none }
    let w = event-width(event, base-width: base-width, prev-event: prev-event, next-event: next-event, music-font-config: music-font-config)
    positions.push((x: x, width: w))
    x += w
  }
  positions
}

/// Compute total width of all events.
#let total-events-width(events, base-width: default-note-spacing-base, music-font-config: none) = {
  let total = 0.0
  for (i, event) in events.enumerate() {
    let prev-event = if i > 0 { events.at(i - 1) } else { none }
    let next-event = if i + 1 < events.len() { events.at(i + 1) } else { none }
    total += event-width(event, base-width: base-width, prev-event: prev-event, next-event: next-event, music-font-config: music-font-config)
  }
  total
}

/// Align multiple staves' layouts so events at the same beat position share
/// the same x coordinate. Uses a distributed-width approach: each event's
/// width is spread evenly across the beat columns it spans, so a whole note
/// sharing beat 0 with a quarter note does not inflate that column.
///
/// Boundary events like barlines and inline clefs reserve a shared column
/// across all staves, even if only one staff contains the event.
#let align-staves-by-beat(laid-out-staves, music-font-config: none) = {
  if laid-out-staves.len() <= 1 { return laid-out-staves }

  let barline-epsilon = 0.000001
  let is-grace-event(ev) = {
    ev.at("grace", default: false)
  }
  let is-rhythmic-event(ev) = {
    (ev.type == "note" or ev.type == "rest" or ev.type == "spacer" or ev.type == "chord") and not is-grace-event(ev)
  }
  let is-boundary-event(ev) = {
    ev.type == "barline" or ev.type == "clef" or ev.type == "key-sig" or ev.type == "time-sig" or ev.type == "gap"
  }
  let is-pre-barline-boundary(items, idx) = {
    (
      idx + 1 < items.len()
      and (items.at(idx).event.type == "clef" or items.at(idx).event.type == "time-sig")
      and items.at(idx + 1).event.type == "barline"
    )
  }
  let rounded-beat(beat) = calc.round(beat, digits: 6)
  let beat-key(beat) = str(rounded-beat(beat))

  // 1. For each beat boundary, compute the maximum number of non-rhythmic
  //    columns that occur before the next rhythmic event on any staff.
  let beat-boundary-widths = (:)
  for laid-out in laid-out-staves {
    let beat = 0.0
    let boundary-count = 0
    let items = laid-out.items
    for (ii, item) in items.enumerate() {
      let ev = item.event
      let key = beat-key(beat)
      if is-pre-barline-boundary(items, ii) {
        continue
      } else if is-grace-event(ev) {
        boundary-count += 1
        let current = beat-boundary-widths.at(key, default: 0)
        if boundary-count > current {
          beat-boundary-widths.insert(key, boundary-count)
        }
      } else if is-boundary-event(ev) {
        boundary-count += 1
        let current = beat-boundary-widths.at(key, default: 0)
        if boundary-count > current {
          beat-boundary-widths.insert(key, boundary-count)
        }
      } else if is-rhythmic-event(ev) {
        let current = beat-boundary-widths.at(key, default: 0)
        if boundary-count > current {
          beat-boundary-widths.insert(key, boundary-count)
        }
        boundary-count = 0

        let dur = ev.at("duration", default: 4)
        let dots = ev.at("dots", default: 0)
        let dur-beats = duration-to-beats(dur, dots: dots)
        let tb = ev.at("tuplet-beats", default: 0)
        let tc = ev.at("tuplet-count", default: 0)
        if tb > 0 and tc > 0 {
          dur-beats = tb / tc
        }
        beat += dur-beats
      }
    }

    let final-key = beat-key(beat)
    let current = beat-boundary-widths.at(final-key, default: 0)
    if boundary-count > current {
      beat-boundary-widths.insert(final-key, boundary-count)
    }
  }

  // 2. Compute cumulative beat offsets for every item in every staff.
  //    Rhythmic events start after the maximum boundary width at that beat,
  //    so a clef on one staff reserves space on every other staff too.
  let staves-beats = ()
  let staff-terminal-beats = ()
  for laid-out in laid-out-staves {
    let beats = ()
    let beat = 0.0
    let boundary-phase = 0
    let items = laid-out.items
    for (ii, item) in items.enumerate() {
      let ev = item.event
      let rb = rounded-beat(beat)
      let boundary-width = beat-boundary-widths.at(beat-key(beat), default: 0)

      if is-pre-barline-boundary(items, ii) {
        beats.push(calc.round(rb - barline-epsilon, digits: 6))
      } else if is-grace-event(ev) {
        beats.push(calc.round(rb + boundary-phase * barline-epsilon, digits: 6))
        boundary-phase += 1
      } else if is-boundary-event(ev) {
        beats.push(calc.round(rb + boundary-phase * barline-epsilon, digits: 6))
        boundary-phase += 1
      } else if is-rhythmic-event(ev) {
        beats.push(calc.round(rb + boundary-width * barline-epsilon, digits: 6))

        let dur = ev.at("duration", default: 4)
        let dots = ev.at("dots", default: 0)
        let dur-beats = duration-to-beats(dur, dots: dots)
        let tb = ev.at("tuplet-beats", default: 0)
        let tc = ev.at("tuplet-count", default: 0)
        if tb > 0 and tc > 0 {
          dur-beats = tb / tc
        }
        beat += dur-beats
        boundary-phase = 0
      } else {
        beats.push(calc.round(rb + boundary-width * barline-epsilon, digits: 6))
      }
    }
    staves-beats.push(beats)
    let terminal-boundary-width = beat-boundary-widths.at(beat-key(beat), default: 0)
    staff-terminal-beats.push(calc.round(rounded-beat(beat) + terminal-boundary-width * barline-epsilon, digits: 6))
  }

  // 3. Sorted unique beat positions.
  let beat-set = (:)
  for staff-beats in staves-beats {
    for b in staff-beats {
      beat-set.insert(str(b), b)
    }
  }
  for b in staff-terminal-beats {
    beat-set.insert(str(b), b)
  }
  let all-beats = beat-set.values().sorted()

  // 4. Beat -> column index map.
  let beat-to-col = (:)
  for (ci, b) in all-beats.enumerate() {
    beat-to-col.insert(str(b), ci)
  }
  let n-cols = all-beats.len()

  // 5. Compute column widths using the distributed-width approach.
  let col-widths = range(n-cols).map(_ => 0.0)

  for (si, laid-out) in laid-out-staves.enumerate() {
    let staff-beats = staves-beats.at(si)
    let terminal-col = beat-to-col.at(str(staff-terminal-beats.at(si)))
    let items = laid-out.items
    for (ii, item) in items.enumerate() {
      let start-col = beat-to-col.at(str(staff-beats.at(ii)))
      let end-col = if ii + 1 < items.len() {
        beat-to-col.at(str(staff-beats.at(ii + 1)))
      } else {
        terminal-col
      }
      let span = calc.max(end-col - start-col, 1)
      let prev-event = if ii > 0 { items.at(ii - 1).event } else { none }
      let next-event = if ii + 1 < items.len() { items.at(ii + 1).event } else { none }
      let w = event-width(item.event, prev-event: prev-event, next-event: next-event, music-font-config: music-font-config)
      let distributed = w / span
      for c in range(start-col, calc.min(end-col, n-cols)) {
        if distributed > col-widths.at(c) {
          col-widths.at(c) = distributed
        }
      }
    }
  }

  // 6. Cumulative x positions per column.
  let col-xs = ()
  let x = 0.0
  for w in col-widths {
    col-xs.push(x)
    x += w
  }
  let total-w = x

  // 7. Reassign x to each item based on its column.
  let result = ()
  for (si, laid-out) in laid-out-staves.enumerate() {
    let staff-beats = staves-beats.at(si)
    let new-items = ()
    for (ii, item) in laid-out.items.enumerate() {
      let ci = beat-to-col.at(str(staff-beats.at(ii)))
      let new-item = (
        event: item.event,
        x: col-xs.at(ci),
        y: item.y,
        stem-dir: item.stem-dir,
        stem-y-end: item.stem-y-end,
      )
      let chord-ys = item.at("chord-ys", default: none)
      let chord-staff-positions = item.at("chord-staff-positions", default: none)
      if chord-ys != none { new-item.insert("chord-ys", chord-ys) }
      if chord-staff-positions != none {
        new-item.insert("chord-staff-positions", chord-staff-positions)
      }
      new-items.push(new-item)
    }
    result.push((
      items: new-items,
      total-width: total-w,
      clef: laid-out.clef,
      time: laid-out.at("time", default: none),
      show-time-prefix: laid-out.at("show-time-prefix", default: false),
      lyric-prefix-states: laid-out.at("lyric-prefix-states", default: ()),
    ))
  }

  result
}
