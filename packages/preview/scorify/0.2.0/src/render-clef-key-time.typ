// render-clef-key-time.typ - Draw clefs, key signatures, and time signatures

#import "@preview/cetz:0.4.2"
#import "constants.typ": *
#import "glyph-metadata.typ": place-glyph, advance-width

// ===== Width calculation functions (pure, no drawing) =====

/// Compute the width of a clef in staff-space units.
#let clef-advance(clef-name: "treble", sp: 1.0, scale: 1.0, music-font-config: none) = {
  let smufl = clef-smufl-name.at(clef-name, default: "gClef")
  advance-width(smufl, config: music-font-config) * sp * scale + default-clef-padding * sp
}

/// Compute the width of a key signature in staff-space units.
#let key-sig-advance(key-name, sp: 1.0, music-font-config: none) = {
  let count = key-sig-accidental-count.at(key-name, default: 0)
  let n = calc.abs(count)
  if n == 0 { 0.0 }
  else {
    let acc-smufl = if count > 0 { "accidentalSharp" } else { "accidentalFlat" }
    let acc-w = advance-width(acc-smufl, config: music-font-config)
    n * (acc-w + 0.2) * sp + default-key-sig-padding * sp
  }
}

/// Compute the width of a time signature in staff-space units.
#let time-sig-advance(upper, lower, symbol: none, sp: 1.0, music-font-config: none) = {
  if symbol == "common" or symbol == "cut" {
    let name = if symbol == "common" { "timeSigCommon" } else { "timeSigCutCommon" }
    advance-width(name, config: music-font-config) * sp + default-time-sig-padding * sp
  } else {
    let upper-str = if type(upper) == str { upper } else { str(upper) }
    let lower-str = if type(lower) == str { lower } else { str(lower) }
    let upper-w = 0.0
    for ch in upper-str {
      if ch >= "0" and ch <= "9" {
        upper-w += advance-width("timeSig" + ch, config: music-font-config) * sp
      }
    }
    let lower-w = 0.0
    for ch in lower-str {
      if ch >= "0" and ch <= "9" {
        lower-w += advance-width("timeSig" + ch, config: music-font-config) * sp
      }
    }
    calc.max(upper-w, lower-w) + default-time-sig-padding * sp
  }
}

// ===== Drawing functions (CeTZ canvas side-effects only) =====

/// Draw a clef at the given position (no return value).
#let draw-clef(x, y-top, clef-name, sp: 1.0, scale: 1.0, music-font-config: none) = {
  let smufl = clef-smufl-name.at(clef-name, default: "gClef")
  let origin-offset = clef-origin-offset.at(clef-name, default: 3.0)
  let glyph = clef-config.at(clef-name).glyph
  let origin-y = y-top - origin-offset * sp
  place-glyph(x, origin-y, glyph, smufl, sp * scale, config: music-font-config)
}

/// Draw a key signature at the given position (no return value).
#let draw-key-signature(x, y-top, key-name, clef-name, sp: 1.0, music-font-config: none) = {
  let count = key-sig-accidental-count.at(key-name, default: 0)
  if count == 0 { return }

  let acc-glyph = none
  let acc-smufl = none
  let positions = ()
  let n = calc.abs(count)

  // If no clef was provided, position accidentals using the treble mapping.
  let use-clef = if clef-name == none { "treble" } else { clef-name }
  if count > 0 {
    acc-glyph = smufl-accidentals.sharp
    acc-smufl = "accidentalSharp"
    positions = key-sig-sharp-positions.at(use-clef, default: key-sig-sharp-positions.treble)
  } else {
    acc-glyph = smufl-accidentals.flat
    acc-smufl = "accidentalFlat"
    positions = key-sig-flat-positions.at(use-clef, default: key-sig-flat-positions.treble)
  }

  let acc-spacing = (advance-width(acc-smufl, config: music-font-config) + 0.2) * sp
  for i in range(n) {
    let staff-pos = positions.at(i)
    let acc-y = y-top - staff-pos * sp / 2.0
    let acc-x = x + i * acc-spacing
    place-glyph(acc-x, acc-y, acc-glyph, acc-smufl, sp, config: music-font-config)
  }
}

/// Draw a time signature at the given position (no return value).
#let draw-time-signature(x, y-top, upper, lower, symbol: none, sp: 1.0, music-font-config: none) = {
  // If no explicit time signature was provided, do nothing.
  if upper == none and symbol == none { return }

  if symbol == "common" {
    place-glyph(x, y-top - 2.0 * sp, smufl-time-common, "timeSigCommon", sp, config: music-font-config)
    return
  }

  if symbol == "cut" {
    place-glyph(x, y-top - 2.0 * sp, smufl-time-cut, "timeSigCutCommon", sp, config: music-font-config)
    return
  }

  let upper-str = if type(upper) == str { upper } else { str(upper) }
  let lower-str = if type(lower) == str { lower } else { str(lower) }

  // Draw upper digits centered in the upper half of the staff
  let upper-y = y-top - 1.0 * sp
  let dx = 0.0
  for ch in upper-str {
    if ch >= "0" and ch <= "9" {
      let glyph-name = "timeSig" + ch
      let glyph-char = smufl-time-digits.at(int(ch))
      place-glyph(x + dx, upper-y, glyph-char, glyph-name, sp, config: music-font-config)
      dx += advance-width(glyph-name, config: music-font-config) * sp
    }
  }

  // Draw lower digits centered in the lower half of the staff
  let lower-y = y-top - 3.0 * sp
  dx = 0.0
  for ch in lower-str {
    if ch >= "0" and ch <= "9" {
      let glyph-name = "timeSig" + ch
      let glyph-char = smufl-time-digits.at(int(ch))
      place-glyph(x + dx, lower-y, glyph-char, glyph-name, sp, config: music-font-config)
      dx += advance-width(glyph-name, config: music-font-config) * sp
    }
  }
}
