// render-notes.typ - Draw noteheads, stems, flags, dots, and ledger lines

#import "@preview/cetz:0.4.2"
#import "constants.typ": *
#import "pitch.typ": staff-position, ledger-lines-needed
#import "glyph-metadata.typ": place-glyph, advance-width, anchors, bbox

/// Get the notehead glyph character for a given duration.
#let notehead-glyph(duration) = {
  if duration == 1 { smufl-noteheads.whole }
  else if duration == 2 { smufl-noteheads.half }
  else { smufl-noteheads.black }
}

/// Get the notehead SMuFL name for metadata lookup.
#let notehead-smufl-name(duration) = {
  if duration == 1 { "noteheadWhole" }
  else if duration == 2 { "noteheadHalf" }
  else { "noteheadBlack" }
}

/// Get the rest glyph character for a given duration.
#let rest-glyph(duration) = {
  if duration == 1 { smufl-rests.whole }
  else if duration == 2 { smufl-rests.half }
  else if duration == 4 { smufl-rests.quarter }
  else if duration == 8 { smufl-rests.eighth }
  else if duration == 16 { smufl-rests.sixteenth }
  else if duration == 32 { smufl-rests.thirtysecond }
  else if duration == 64 { smufl-rests.sixtyfourth }
  else { smufl-rests.quarter }
}

/// Get the rest SMuFL name for metadata lookup.
#let rest-smufl-name(duration) = {
  if duration == 1 { "restWhole" }
  else if duration == 2 { "restHalf" }
  else if duration == 4 { "restQuarter" }
  else if duration == 8 { "rest8th" }
  else if duration == 16 { "rest16th" }
  else if duration == 32 { "rest32nd" }
  else if duration == 64 { "rest64th" }
  else { "restQuarter" }
}

/// Get the flag glyph character for a duration and stem direction.
#let flag-glyph(duration, stem-dir) = {
  if stem-dir == "up" {
    if duration == 8 { smufl-flags.eighth-up }
    else if duration == 16 { smufl-flags.sixteenth-up }
    else if duration == 32 { smufl-flags.thirtysecond-up }
    else if duration == 64 { smufl-flags.sixtyfourth-up }
    else { none }
  } else {
    if duration == 8 { smufl-flags.eighth-down }
    else if duration == 16 { smufl-flags.sixteenth-down }
    else if duration == 32 { smufl-flags.thirtysecond-down }
    else if duration == 64 { smufl-flags.sixtyfourth-down }
    else { none }
  }
}

/// Get the flag SMuFL name for metadata lookup.
#let flag-smufl-name(duration, stem-dir) = {
  if stem-dir == "up" {
    if duration == 8 { "flag8thUp" }
    else if duration == 16 { "flag16thUp" }
    else if duration == 32 { "flag32ndUp" }
    else if duration == 64 { "flag64thUp" }
    else { none }
  } else {
    if duration == 8 { "flag8thDown" }
    else if duration == 16 { "flag16thDown" }
    else if duration == 32 { "flag32ndDown" }
    else if duration == 64 { "flag64thDown" }
    else { none }
  }
}

/// Draw a single notehead at the given position (centered at x, y).
#let draw-notehead(x, y, duration, sp: 1.0) = {
  let glyph = notehead-glyph(duration)
  let smufl = notehead-smufl-name(duration)
  let w = advance-width(smufl)
  // Center the notehead horizontally at x (glyph origin is at left edge)
  place-glyph(x - w / 2.0 * sp, y, glyph, smufl, sp)
}

/// Draw a stem line.
#let draw-stem(stem-x, start-y, end-y, sp: 1.0) = {
  import cetz.draw: *
  let thickness = default-stem-thickness * sp
  line(
    (stem-x, start-y),
    (stem-x, end-y),
    stroke: thickness * 1mm + black,
  )
}

/// Draw a flag at the stem tip.
#let draw-flag(stem-x, stem-end-y, duration, stem-dir, sp: 1.0) = {
  let glyph = flag-glyph(duration, stem-dir)
  if glyph == none { return }
  let smufl = flag-smufl-name(duration, stem-dir)
  if smufl == none { return }
  place-glyph(stem-x, stem-end-y, glyph, smufl, sp)
}

/// Draw augmentation dots next to a notehead.
#let draw-dots(x, y, count, duration, sp: 1.0) = {
  import cetz.draw: *
  if count == 0 { return }
  let nh-w = advance-width(notehead-smufl-name(duration))
  let dot-x = x + nh-w / 2.0 * sp + 0.6 * sp
  for i in range(count) {
    circle(
      (dot-x + i * 0.5 * sp, y),
      radius: 0.2 * sp,
      fill: black,
      stroke: none,
    )
  }
}

/// Draw ledger lines for a note at the given staff position.
#let draw-ledger-lines(x, y-top, staff-pos, sp: 1.0) = {
  import cetz.draw: *
  let info = ledger-lines-needed(staff-pos)
  if info.count == 0 { return }

  let ext = default-ledger-line-extension * sp
  let thickness = default-staff-line-thickness * sp
  let nh-w = advance-width("noteheadBlack")

  if info.direction == "above" {
    for i in range(info.count) {
      let ledger-pos = -2 - i * 2
      let ly = y-top - ledger-pos * sp / 2.0
      line(
        (x - nh-w / 2.0 * sp - ext, ly), (x + nh-w / 2.0 * sp + ext, ly),
        stroke: thickness * 1mm + black,
      )
    }
  } else {
    for i in range(info.count) {
      let ledger-pos = 10 + i * 2
      let ly = y-top - ledger-pos * sp / 2.0
      line(
        (x - nh-w / 2.0 * sp - ext, ly), (x + nh-w / 2.0 * sp + ext, ly),
        stroke: thickness * 1mm + black,
      )
    }
  }
}

/// Draw a rest symbol.
#let draw-rest(x, y, duration, dots: 0, sp: 1.0) = {
  let glyph = rest-glyph(duration)
  let smufl = rest-smufl-name(duration)
  place-glyph(x, y, glyph, smufl, sp)
  if dots > 0 {
    import cetz.draw: *
    let bb = bbox(smufl)
    let rest-right = if bb != none { bb.ne.x * sp } else { 0.8 * sp }
    let dot-x = x + rest-right + 0.3 * sp
    for i in range(dots) {
      circle(
        (dot-x + i * 0.4 * sp, y + 0.15 * sp),
        radius: 0.12 * sp,
        fill: black,
        stroke: none,
      )
    }
  }
}

/// Draw an accidental to the left of a notehead.
#let draw-accidental(x, y, accidental, duration, sp: 1.0) = {
  if accidental == none { return }

  let glyph = if accidental == "sharp" { smufl-accidentals.sharp }
    else if accidental == "flat" { smufl-accidentals.flat }
    else if accidental == "natural" { smufl-accidentals.natural }
    else if accidental == "double-sharp" { smufl-accidentals.double-sharp }
    else if accidental == "double-flat" { smufl-accidentals.double-flat }
    else { return }

  let smufl = if accidental == "sharp" { "accidentalSharp" }
    else if accidental == "flat" { "accidentalFlat" }
    else if accidental == "natural" { "accidentalNatural" }
    else if accidental == "double-sharp" { "accidentalDoubleSharp" }
    else if accidental == "double-flat" { "accidentalDoubleFlat" }
    else { return }

  let nh-w = advance-width(notehead-smufl-name(duration))
  let acc-w = advance-width(smufl)
  let acc-x = x - nh-w / 2.0 * sp - default-accidental-padding * sp - acc-w * sp
  place-glyph(acc-x, y, glyph, smufl, sp)
}

/// Compute the x coordinate of the stem attachment point for a note at canvas x.
/// Matches the stem-x logic used inside draw-note.
#let note-stem-x(x, duration, stem-dir, sp: 1.0) = {
  let smufl = notehead-smufl-name(duration)
  let nh-w = advance-width(smufl)
  let nh-anch = anchors(smufl)
  let stem-att = if stem-dir == "up" {
    nh-anch.at("stemUpSE", default: (x: nh-w, y: 0.168))
  } else {
    nh-anch.at("stemDownNW", default: (x: 0.0, y: -0.168))
  }
  let sx = x - nh-w / 2.0 * sp + stem-att.x * sp
  let half-thin = default-stem-thickness / 2.0 * sp
  sx + if stem-dir == "up" { -half-thin } else { half-thin }
}

/// Draw a chord event: multiple simultaneous noteheads with a single shared stem/flag.
/// - x: absolute canvas x (mm)
/// - chord-ys-abs: array of absolute canvas y (mm) for each note in the chord
/// - chord-staff-positions: array of staff positions (for ledger lines)
/// - event: the chord event (has .notes, .duration, .dots)
/// - stem-dir: "up" or "down"
/// - stem-y-end: absolute canvas y for the stem tip (mm)
/// - y-top: absolute canvas y of the top staff line (mm)
/// - beamed: suppress flag when true
#let draw-chord-event(
  x,
  chord-ys-abs,
  chord-staff-positions,
  event,
  stem-dir,
  stem-y-end,
  y-top,
  clef: "treble",
  sp: 1.0,
  beamed: false,
) = {
  import cetz.draw: *
  let duration = event.duration
  let smufl = notehead-smufl-name(duration)
  let nh-w = advance-width(smufl)
  let nh-anch = anchors(smufl)

  // Draw each notehead with its ledger lines, accidental, and dots
  for (ni, note) in event.notes.enumerate() {
    let ny = chord-ys-abs.at(ni)
    let nsp = chord-staff-positions.at(ni)
    draw-ledger-lines(x, y-top, nsp, sp: sp)
    if note.accidental != none {
      draw-accidental(x, ny, note.accidental, duration, sp: sp)
    }
    draw-notehead(x, ny, duration, sp: sp)
    if event.dots > 0 {
      draw-dots(x, ny, event.dots, duration, sp: sp)
    }
  }

  // Draw shared stem
  if duration >= 2 and stem-dir != none {
    let stem-att = if stem-dir == "up" {
      nh-anch.at("stemUpSE", default: (x: nh-w, y: 0.168))
    } else {
      nh-anch.at("stemDownNW", default: (x: 0.0, y: -0.168))
    }
    let stem-x-coord = x - nh-w / 2.0 * sp + stem-att.x * sp
    let half-thin = default-stem-thickness / 2.0 * sp
    let stem-x-coord = stem-x-coord + if stem-dir == "up" { -half-thin } else { half-thin }

    // Stem starts at the primary notehead (closest to stem base)
    let primary-y-abs = if stem-dir == "up" {
      chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
    } else {
      chord-ys-abs.fold(chord-ys-abs.at(0), calc.max)
    }
    let stem-start-y = primary-y-abs + stem-att.y * sp

    draw-stem(stem-x-coord, stem-start-y, stem-y-end, sp: sp)

    if duration >= 8 and not beamed {
      draw-flag(stem-x-coord, stem-y-end, duration, stem-dir, sp: sp)
    }
  }
}

/// Draw a complete note event (notehead + stem + flag + dots + accidental + ledger lines).
/// - beamed: when true, suppress flag (note is part of a beam group)
#let draw-note(
  x, y, event, stem-dir, stem-y-end,
  y-top,
  clef: "treble",
  sp: 1.0,
  beamed: false,
) = {
  import cetz.draw: *
  let duration = event.duration
  let staff-pos = staff-position(event.name, event.octave, clef: clef)

  // Draw ledger lines first (behind the note)
  draw-ledger-lines(x, y-top, staff-pos, sp: sp)

  // Draw accidental
  if event.accidental != none {
    draw-accidental(x, y, event.accidental, duration, sp: sp)
  }

  // Draw notehead
  draw-notehead(x, y, duration, sp: sp)

  // Draw stem (not for whole notes)
  if duration >= 2 and stem-dir != none {
    let smufl = notehead-smufl-name(duration)
    let nh-w = advance-width(smufl)
    let nh-anch = anchors(smufl)

    let stem-att = if stem-dir == "up" {
      nh-anch.at("stemUpSE", default: (x: nh-w, y: 0.168))
    } else {
      nh-anch.at("stemDownNW", default: (x: 0.0, y: -0.168))
    }
    let stem-x = x - nh-w / 2.0 * sp + stem-att.x * sp
    // Shift stem inward so its outer edge is flush with the notehead outer edge
    // rather than the stem center being at the notehead edge (which would let
    // half the stem width protrude past the notehead).
    let half-thin = default-stem-thickness / 2.0 * sp
    let stem-x = stem-x + if stem-dir == "up" { -half-thin } else { half-thin }
    let stem-start-y = y + stem-att.y * sp

    draw-stem(stem-x, stem-start-y, stem-y-end, sp: sp)

    // Draw flag (only for unbeamed 8th and shorter)
    if duration >= 8 and not beamed {
      draw-flag(stem-x, stem-y-end, duration, stem-dir, sp: sp)
    }
  }

  // Draw dots
  if event.dots > 0 {
    draw-dots(x, y, event.dots, duration, sp: sp)
  }
}
