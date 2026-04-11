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

#let local-sp(sp, note-scale) = sp * note-scale

/// Draw a single notehead at the given position (centered at x, y).
#let draw-notehead(x, y, duration, sp: 1.0, note-scale: 1.0, music-font-config: none) = {
  let glyph = notehead-glyph(duration)
  let smufl = notehead-smufl-name(duration)
  let lsp = local-sp(sp, note-scale)
  let w = advance-width(smufl, config: music-font-config)
  place-glyph(x - w / 2.0 * lsp, y, glyph, smufl, lsp, config: music-font-config)
}

/// Draw a stem line.
#let draw-stem(stem-x, start-y, end-y, sp: 1.0, note-scale: 1.0) = {
  import cetz.draw: *
  let thickness = default-stem-thickness * local-sp(sp, note-scale)
  line(
    (stem-x, start-y),
    (stem-x, end-y),
    stroke: thickness * 1mm + black,
  )
}

/// Draw a flag at the stem tip.
#let draw-flag(stem-x, stem-end-y, duration, stem-dir, sp: 1.0, note-scale: 1.0, music-font-config: none) = {
  let glyph = flag-glyph(duration, stem-dir)
  if glyph == none { return }
  let smufl = flag-smufl-name(duration, stem-dir)
  if smufl == none { return }
  place-glyph(stem-x, stem-end-y, glyph, smufl, local-sp(sp, note-scale), config: music-font-config)
}

/// Draw augmentation dots next to a notehead.
#let draw-dots(x, y, count, duration, sp: 1.0, note-scale: 1.0, music-font-config: none) = {
  import cetz.draw: *
  if count == 0 { return }
  let lsp = local-sp(sp, note-scale)
  let nh-w = advance-width(notehead-smufl-name(duration), config: music-font-config)
  let dot-x = x + nh-w / 2.0 * lsp + 0.6 * lsp
  for i in range(count) {
    circle(
      (dot-x + i * 0.5 * lsp, y),
      radius: 0.2 * lsp,
      fill: black,
      stroke: none,
    )
  }
}

/// Draw ledger lines for a note at the given staff position.
#let draw-ledger-lines(x, y-top, staff-pos, sp: 1.0, note-scale: 1.0, music-font-config: none) = {
  import cetz.draw: *
  let info = ledger-lines-needed(staff-pos)
  if info.count == 0 { return }

  let lsp = local-sp(sp, note-scale)
  let ext = default-ledger-line-extension * lsp
  let thickness = default-staff-line-thickness * lsp
  let nh-w = advance-width("noteheadBlack", config: music-font-config)

  if info.direction == "above" {
    for i in range(info.count) {
      let ledger-pos = -2 - i * 2
      let ly = y-top - ledger-pos * sp / 2.0
      line(
        (x - nh-w / 2.0 * lsp - ext, ly), (x + nh-w / 2.0 * lsp + ext, ly),
        stroke: thickness * 1mm + black,
      )
    }
  } else {
    for i in range(info.count) {
      let ledger-pos = 10 + i * 2
      let ly = y-top - ledger-pos * sp / 2.0
      line(
        (x - nh-w / 2.0 * lsp - ext, ly), (x + nh-w / 2.0 * lsp + ext, ly),
        stroke: thickness * 1mm + black,
      )
    }
  }
}

/// Draw a rest symbol.
#let draw-rest(x, y, duration, dots: 0, sp: 1.0, note-scale: 1.0, music-font-config: none) = {
  let glyph = rest-glyph(duration)
  let smufl = rest-smufl-name(duration)
  let lsp = local-sp(sp, note-scale)
  place-glyph(x, y, glyph, smufl, lsp, config: music-font-config)
  if dots > 0 {
    import cetz.draw: *
    let bb = bbox(smufl, config: music-font-config)
    let rest-right = if bb != none { bb.ne.x * lsp } else { 0.8 * lsp }
    let dot-x = x + rest-right + 0.3 * lsp
    for i in range(dots) {
      circle(
        (dot-x + i * 0.4 * lsp, y + 0.15 * lsp),
        radius: 0.12 * lsp,
        fill: black,
        stroke: none,
      )
    }
  }
}

/// Draw an accidental to the left of a notehead.
#let draw-accidental(x, y, accidental, duration, sp: 1.0, note-scale: 1.0, music-font-config: none) = {
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

  let lsp = local-sp(sp, note-scale)
  let nh-w = advance-width(notehead-smufl-name(duration), config: music-font-config)
  let acc-w = advance-width(smufl, config: music-font-config)
  let acc-x = x - nh-w / 2.0 * lsp - default-accidental-padding * lsp - acc-w * lsp
  place-glyph(acc-x, y, glyph, smufl, lsp, config: music-font-config)
}

#let draw-grace-slash(stem-x, note-y, stem-dir, sp: 1.0, note-scale: 1.0) = {
  import cetz.draw: *
  let lsp = local-sp(sp, note-scale)
  let thickness = 0.11 * lsp
  let x0 = stem-x - 0.65 * lsp
  let x1 = stem-x + 0.28 * lsp
  let y0 = if stem-dir == "up" { note-y + 1.95 * lsp } else { note-y - 1.15 * lsp }
  let y1 = if stem-dir == "up" { note-y + 1.15 * lsp } else { note-y - 2.05 * lsp }
  line((x0, y0), (x1, y1), stroke: thickness * 1mm + black)
}

/// Compute the x coordinate of the stem attachment point for a note at canvas x.
/// Matches the stem-x logic used inside draw-note.
#let note-stem-x(x, duration, stem-dir, sp: 1.0, music-font-config: none) = {
  let smufl = notehead-smufl-name(duration)
  let nh-w = advance-width(smufl, config: music-font-config)
  let nh-anch = anchors(smufl, config: music-font-config)
  let stem-att = if stem-dir == "up" {
    nh-anch.at("stemUpSE", default: (x: nh-w, y: 0.168))
  } else {
    nh-anch.at("stemDownNW", default: (x: 0.0, y: -0.168))
  }
  let sx = x - nh-w / 2.0 * sp + stem-att.x * sp
  let half-thin = default-stem-thickness / 2.0 * sp
  sx + if stem-dir == "up" { -half-thin } else { half-thin }
}

/// Compute per-note horizontal offsets for seconds inside a chord.
///
/// Adjacent staff steps cannot share a notehead column. Starting at the
/// stem-base note, alternate columns only while the notes remain adjacent.
#let chord-notehead-x-offsets(chord-staff-positions, stem-dir, nh-w, lsp) = {
  let offsets = range(chord-staff-positions.len()).map(_ => 0.0)
  if chord-staff-positions.len() <= 1 { return offsets }

  let order = ()
  for i in range(chord-staff-positions.len()) {
    let inserted = false
    let next-order = ()
    for existing in order {
      let current-sp = chord-staff-positions.at(i)
      let existing-sp = chord-staff-positions.at(existing)
      let before-existing = if stem-dir == "down" {
        current-sp < existing-sp
      } else {
        current-sp > existing-sp
      }
      if not inserted and before-existing {
        next-order.push(i)
        inserted = true
      }
      next-order.push(existing)
    }
    if not inserted {
      next-order.push(i)
    }
    order = next-order
  }

  let alt-offset = if stem-dir == "down" { -nh-w * lsp } else { nh-w * lsp }
  let side = 0
  let prev-sp = none
  for idx in order {
    let current-sp = chord-staff-positions.at(idx)
    if prev-sp != none and calc.abs(current-sp - prev-sp) == 1 {
      side = 1 - side
    } else {
      side = 0
    }
    if side == 1 {
      offsets.at(idx) = alt-offset
    }
    prev-sp = current-sp
  }
  offsets
}

/// Draw a chord event: multiple simultaneous noteheads with a single shared stem/flag.
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
  note-scale: 1.0,
  grace-slash: false,
  music-font-config: none,
) = {
  let duration = event.duration
  let lsp = local-sp(sp, note-scale)
  let smufl = notehead-smufl-name(duration)
  let nh-w = advance-width(smufl, config: music-font-config)
  let nh-anch = anchors(smufl, config: music-font-config)
  let notehead-offsets = chord-notehead-x-offsets(chord-staff-positions, stem-dir, nh-w, lsp)

  for (ni, note) in event.notes.enumerate() {
    let ny = chord-ys-abs.at(ni)
    let nsp = chord-staff-positions.at(ni)
    let nx = x + notehead-offsets.at(ni)
    draw-ledger-lines(nx, y-top, nsp, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
    if note.accidental != none {
      draw-accidental(nx, ny, note.accidental, duration, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
    }
    draw-notehead(nx, ny, duration, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
    if event.dots > 0 {
      draw-dots(nx, ny, event.dots, duration, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
    }
  }

  if duration >= 2 and stem-dir != none {
    let stem-att = if stem-dir == "up" {
      nh-anch.at("stemUpSE", default: (x: nh-w, y: 0.168))
    } else {
      nh-anch.at("stemDownNW", default: (x: 0.0, y: -0.168))
    }
    let stem-x-coord = x - nh-w / 2.0 * lsp + stem-att.x * lsp
    let half-thin = default-stem-thickness / 2.0 * lsp
    let stem-x-coord = stem-x-coord + if stem-dir == "up" { -half-thin } else { half-thin }
    let primary-y-abs = if stem-dir == "up" {
      chord-ys-abs.fold(chord-ys-abs.at(0), calc.min)
    } else {
      chord-ys-abs.fold(chord-ys-abs.at(0), calc.max)
    }
    let stem-start-y = primary-y-abs + stem-att.y * lsp

    draw-stem(stem-x-coord, stem-start-y, stem-y-end, sp: sp, note-scale: note-scale)

    if duration >= 8 and not beamed {
      draw-flag(stem-x-coord, stem-y-end, duration, stem-dir, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
    }
    if grace-slash {
      draw-grace-slash(stem-x-coord, primary-y-abs, stem-dir, sp: sp, note-scale: note-scale)
    }
  }
}

/// Draw a complete note event (notehead + stem + flag + dots + accidental + ledger lines).
#let draw-note(
  x, y, event, stem-dir, stem-y-end,
  y-top,
  clef: "treble",
  sp: 1.0,
  beamed: false,
  note-scale: 1.0,
  grace-slash: false,
  music-font-config: none,
) = {
  let duration = event.duration
  let lsp = local-sp(sp, note-scale)
  let staff-pos = staff-position(event.name, event.octave, clef: clef)

  draw-ledger-lines(x, y-top, staff-pos, sp: sp, note-scale: note-scale, music-font-config: music-font-config)

  if event.accidental != none {
    draw-accidental(x, y, event.accidental, duration, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
  }

  draw-notehead(x, y, duration, sp: sp, note-scale: note-scale, music-font-config: music-font-config)

  if duration >= 2 and stem-dir != none {
    let smufl = notehead-smufl-name(duration)
    let nh-w = advance-width(smufl, config: music-font-config)
    let nh-anch = anchors(smufl, config: music-font-config)
    let stem-att = if stem-dir == "up" {
      nh-anch.at("stemUpSE", default: (x: nh-w, y: 0.168))
    } else {
      nh-anch.at("stemDownNW", default: (x: 0.0, y: -0.168))
    }
    let stem-x = x - nh-w / 2.0 * lsp + stem-att.x * lsp
    let half-thin = default-stem-thickness / 2.0 * lsp
    let stem-x = stem-x + if stem-dir == "up" { -half-thin } else { half-thin }
    let stem-start-y = y + stem-att.y * lsp

    draw-stem(stem-x, stem-start-y, stem-y-end, sp: sp, note-scale: note-scale)

    if duration >= 8 and not beamed {
      draw-flag(stem-x, stem-y-end, duration, stem-dir, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
    }
    if grace-slash {
      draw-grace-slash(stem-x, y, stem-dir, sp: sp, note-scale: note-scale)
    }
  }

  if event.dots > 0 {
    draw-dots(x, y, event.dots, duration, sp: sp, note-scale: note-scale, music-font-config: music-font-config)
  }
}
