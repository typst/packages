// render-articulations.typ - Articulation and dynamic rendering
//
// Articulations are drawn near the notehead, on the opposite side of the stem.
// Rendering order from notehead outward: tenuto, accent, staccato. Fermata separate.
// Dynamics are drawn below the staff using SMuFL dynamic glyphs.

#import "constants.typ": smufl-articulations, smufl-dynamics, smufl-ornaments, smufl-other, default-music-font-size-factor
#import "glyph-metadata.typ": font-family, place-glyph, advance-width, bbox

/// Draw articulation marks for a note or chord.
///
/// Parameters:
/// - x: horizontal centre of the notehead
/// - note-y: absolute y of the notehead (or the outermost note for articulation side)
/// - articulations: array of strings ("accent", "staccato", "tenuto", "fermata")
/// - stem-dir: "up" or "down"
/// - y-top: absolute y of the top staff line
/// - sp: staff space in absolute units
#let draw-articulations(x, note-y, articulations, stem-dir, y-top, sp: 1.0, music-font-config: none) = {
  import "@preview/cetz:0.4.2"
  import cetz.draw: *

  if articulations.len() == 0 { return }

  let y-bottom = y-top - 4.0 * sp

  // Separate fermata from the rest
  let fermata = articulations.filter(a => a == "fermata")
  let non-fermata = articulations.filter(a => a != "fermata")

  // Sort non-fermata: tenuto, accent, staccato (closest to notehead first)
  let order = ("tenuto": 0, "accent": 1, "staccato": 2)
  let sorted = non-fermata.sorted(key: a => order.at(a, default: 9))

  // Articulations go on the opposite side of the stem
  // stem-up → articulations below notehead; stem-down → articulations above notehead
  let art-above = stem-dir == "down"

  // Starting position: just outside the notehead
  // SMuFL glyphs have built-in whitespace, so the visual gap differs from the numeric offset.
  // above: anchor "south" - glyph extends upward from anchor, so gap must clear the notehead top
  // below: anchor "north" - glyph extends downward, built-in space makes it appear far, use tight offset
  let gap = if art-above { 0.75 * sp } else { -1.0 * sp }
  let art-spacing = 1.0 * sp // spacing between stacked articulations

  if art-above {
    // Place above the notehead
    let cur-y = note-y + gap
    for art in sorted {
      let glyph = if art == "staccato" { smufl-articulations.staccato-above }
        else if art == "accent" { smufl-articulations.accent-above }
        else if art == "tenuto" { smufl-articulations.tenuto-above }
        else { none }
      if glyph != none {
        content(
          (x, cur-y),
          anchor: "south",
          text(font: font-family(config: music-font-config), size: default-music-font-size-factor * sp * 1mm, glyph),
        )
        cur-y += art-spacing
      }
    }
  } else {
    // Place below the notehead
    let cur-y = note-y - gap
    for art in sorted {
      let glyph = if art == "staccato" { smufl-articulations.staccato-below }
        else if art == "accent" { smufl-articulations.accent-below }
        else if art == "tenuto" { smufl-articulations.tenuto-below }
        else { none }
      if glyph != none {
        content(
          (x, cur-y),
          anchor: "north",
          text(font: font-family(config: music-font-config), size: default-music-font-size-factor * sp * 1mm, glyph),
        )
        cur-y -= art-spacing
      }
    }
  }

  // Fermata: always above the staff
  if fermata.len() > 0 {
    let fermata-y = calc.max(note-y + gap, y-top + 0.5 * sp)
    // If other articulations were placed above, push fermata further up
    if art-above and sorted.len() > 0 {
      fermata-y = calc.max(note-y + gap, y-top + 0.5 * sp) + sorted.len() * art-spacing
    }
    content(
      (x, fermata-y),
      anchor: "south",
      text(font: font-family(config: music-font-config), size: default-music-font-size-factor * sp * 1mm, smufl-articulations.fermata-above),
    )
  }
}

/// Draw a dynamic marking below the staff.
///
/// Parameters:
/// - x: horizontal centre of the note
/// - y-bottom: absolute y of the bottom staff line
/// - dynamic: string e.g. "f", "pp", "mf", "sfz", "fp"
/// - sp: staff space in absolute units
/// - extra-offset: additional downward offset (e.g. for articulations below the staff)
#let draw-dynamic(x, y-bottom, dynamic, sp: 1.0, extra-offset: 0.0, music-font-config: none) = {
  import "@preview/cetz:0.4.2"
  import cetz.draw: *

  if dynamic == none or dynamic == "" { return }

  let gap = 1.0 * sp  // distance below bottom staff line
  let dyn-y = y-bottom - gap - extra-offset

  // Check if every character of the dynamic is in our glyph set
  let all-smufl = dynamic.clusters().all(ch => ch in smufl-dynamics)

  if all-smufl {
    // Render using SMuFL dynamic glyphs
    let glyph-str = dynamic.clusters().map(ch => smufl-dynamics.at(ch)).join()
    content(
      (x, dyn-y),
      anchor: "north",
      text(font: font-family(config: music-font-config), size: default-music-font-size-factor * sp * 1mm, glyph-str),
    )
  } else {
    // Fallback: render as italic text
    content(
      (x, dyn-y),
      anchor: "north",
      text(size: 8pt, style: "italic", weight: "bold", dynamic),
    )
  }
}

/// Draw a crescendo / decrescendo hairpin below the staff.
///
/// Parameters:
/// - x-start: horizontal start of the span
/// - x-end: horizontal end of the span
/// - y-center: vertical centre line of the hairpin
/// - kind: "cresc" or "decresc"
/// - sp: staff space in absolute units
#let draw-hairpin(x-start, x-end, y-center, kind, sp: 1.0, start-half-height: none, end-half-height: none) = {
  import "@preview/cetz:0.4.2"
  import cetz.draw: *

  if kind == none or x-end <= x-start { return }

  let full-half-height = 0.55 * sp
  let start-h = if start-half-height != none {
    start-half-height
  } else if kind == "cresc" {
    0.0
  } else {
    full-half-height
  }
  let end-h = if end-half-height != none {
    end-half-height
  } else if kind == "cresc" {
    full-half-height
  } else {
    0.0
  }
  let thickness = 0.14 * sp
  let stroke = (thickness: thickness * 1mm, paint: black, cap: "butt")

  if kind == "cresc" or kind == "decresc" {
    line((x-start, y-center + start-h), (x-end, y-center + end-h), stroke: stroke)
    line((x-start, y-center - start-h), (x-end, y-center - end-h), stroke: stroke)
  }
}

#let trill-symbol-width(sp: 1.0, music-font-config: none) = {
  advance-width("ornamentTrill", config: music-font-config) * sp
}

#let trill-wiggle-width(sp: 1.0, music-font-config: none) = {
  advance-width("wiggleTrill", config: music-font-config) * sp
}

#let draw-trill-symbol(x, y, sp: 1.0, music-font-config: none) = {
  place-glyph(x, y, smufl-ornaments.trill, "ornamentTrill", sp, config: music-font-config)
}

#let draw-trill-wiggle(x-start, x-end, y, sp: 1.0, music-font-config: none) = {
  if x-end <= x-start { return }

  let seg-w = trill-wiggle-width(sp: sp, music-font-config: music-font-config)
  if seg-w <= 0 { return }

  let step = seg-w * 0.92
  let cur-x = x-start
  while cur-x < x-end {
    place-glyph(cur-x, y, smufl-ornaments.wiggle-trill, "wiggleTrill", sp, config: music-font-config)
    cur-x += step
  }
}

#let draw-staff-marker(x, y, kind, sp: 1.0, music-font-config: none, anchor-mode: "south") = {
  import "@preview/cetz:0.4.2"
  import cetz.draw: *
  let glyph = if kind == "breath-mark" { smufl-other.breath-mark }
    else if kind == "caesura" { smufl-other.caesura }
    else if kind == "dal-segno" { smufl-other.segno }
    else if kind == "coda" { smufl-other.coda }
    else { none }
  let smufl = if kind == "breath-mark" { "breathMarkComma" }
    else if kind == "caesura" { "caesura" }
    else if kind == "dal-segno" { "segno" }
    else if kind == "coda" { "coda" }
    else { none }
  let scale = if kind == "breath-mark" or kind == "caesura" { 0.92 } else { 1.08 }
  if glyph == none or smufl == none { return }
  let size = default-music-font-size-factor * scale * sp * 1mm
  let bb = bbox(smufl, config: music-font-config)
  if anchor-mode == "south-west" {
    content(
      (x, y),
      anchor: "south-west",
      text(font: font-family(config: music-font-config), size: size, glyph),
    )
  } else if anchor-mode == "center-west" and bb != none {
    let height = (bb.ne.y - bb.sw.y) * scale * sp
    content(
      (x, y - 0.5 * height),
      anchor: "south-west",
      text(font: font-family(config: music-font-config), size: size, glyph),
    )
  } else {
    content(
      (x, y),
      anchor: "south",
      text(font: font-family(config: music-font-config), size: size, glyph),
    )
  }
}
