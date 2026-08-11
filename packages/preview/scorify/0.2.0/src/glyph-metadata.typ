// glyph-metadata.typ - Load and expose SMuFL glyph metrics
//
// All bounding-box and anchor values are in staff-space units.
// SMuFL convention: font em-square = 4 staff-spaces.
// Glyph origin (0,0) is the glyph's "reference point":
//   - Noteheads: left edge, vertically centered on staff line
//   - Clefs: the staff line their pitch refers to (G4 for gClef, F3 for fClef, C4 for cClef)
//   - Accidentals: left edge, vertically centered on the staff line they affect
//   - Rests: varies per rest type (whole hangs from line, half sits on line, etc.)
//   - Flags: stem connection point at (0,0)

#let default-music-font = "Bravura"
#let default-music-metadata = json("../data/bravura_metadata.json")
#let default-music-font-config = (
  font: default-music-font,
  metadata: default-music-metadata,
)

#let make-music-font-config(font: default-music-font, metadata: none) = {
  let resolved-metadata = if metadata == none { default-music-metadata } else { metadata }
  (
    font: font,
    metadata: resolved-metadata,
  )
}

#let _resolve-config(config) = if config == none { default-music-font-config } else { config }
#let _resolve-meta(config) = _resolve-config(config).metadata
#let font-family(config: none) = _resolve-config(config).font
#let _default-advance-widths = {
  let result = (:)
  for (key, val) in default-music-metadata.glyphAdvanceWidths {
    result.insert(key, float(val))
  }
  result
}
#let _default-bboxes = {
  let result = (:)
  for (key, val) in default-music-metadata.glyphBBoxes {
    result.insert(
      key,
      (
        sw: (x: float(val.bBoxSW.at(0)), y: float(val.bBoxSW.at(1))),
        ne: (x: float(val.bBoxNE.at(0)), y: float(val.bBoxNE.at(1))),
      ),
    )
  }
  result
}
#let _default-anchors = {
  let result = (:)
  for (key, val) in default-music-metadata.glyphsWithAnchors {
    let converted = (:)
    for (anchor-key, anchor-val) in val {
      converted.insert(anchor-key, (x: float(anchor-val.at(0)), y: float(anchor-val.at(1))))
    }
    result.insert(key, converted)
  }
  result
}
#let _is-default-config(config) = _resolve-meta(config) == default-music-metadata

// --- Engraving defaults (all in staff-space units) ---
#let engraving(config: none) = _resolve-meta(config).engravingDefaults

// --- Glyph bounding boxes ---
// Returns (sw, ne) where sw = (x,y) of south-west corner, ne = (x,y) of north-east corner
// All in staff-space units relative to glyph origin.
#let bbox(glyph-name, config: none) = {
  if _is-default-config(config) {
    return _default-bboxes.at(glyph-name, default: none)
  }
  let b = _resolve-meta(config).glyphBBoxes.at(glyph-name, default: none)
  if b == none { return none }
  (
    sw: (x: float(b.bBoxSW.at(0)), y: float(b.bBoxSW.at(1))),
    ne: (x: float(b.bBoxNE.at(0)), y: float(b.bBoxNE.at(1))),
  )
}

/// Get advance width of a glyph in staff-space units.
#let advance-width(glyph-name, config: none) = {
  if _is-default-config(config) {
    return _default-advance-widths.at(glyph-name, default: 0.0)
  }
  let w = _resolve-meta(config).glyphAdvanceWidths.at(glyph-name, default: none)
  if w == none { 0.0 } else { float(w) }
}

/// Get anchor points for a glyph (e.g., stem attachment points for noteheads).
#let anchors(glyph-name, config: none) = {
  if _is-default-config(config) {
    return _default-anchors.at(glyph-name, default: (:))
  }
  let a = _resolve-meta(config).glyphsWithAnchors.at(glyph-name, default: none)
  if a == none { return (:) }
  let result = (:)
  for (key, val) in a {
    result.insert(key, (x: float(val.at(0)), y: float(val.at(1))))
  }
  result
}

// --- Pre-computed metrics for the default Bravura config ---
#let notehead-black-width = advance-width("noteheadBlack")
#let notehead-half-width = advance-width("noteheadHalf")
#let notehead-whole-width = advance-width("noteheadWhole")

#let _nh-black-anchors = anchors("noteheadBlack")
#let _nh-half-anchors = anchors("noteheadHalf")
#let stem-up-se-black = _nh-black-anchors.at("stemUpSE", default: (x: 1.18, y: 0.168))
#let stem-down-nw-black = _nh-black-anchors.at("stemDownNW", default: (x: 0.0, y: -0.168))
#let stem-up-se-half = _nh-half-anchors.at("stemUpSE", default: (x: 1.18, y: 0.168))
#let stem-down-nw-half = _nh-half-anchors.at("stemDownNW", default: (x: 0.0, y: -0.168))

#let gclef-bbox = bbox("gClef")
#let fclef-bbox = bbox("fClef")
#let cclef-bbox = bbox("cClef")

#let gclef-width = advance-width("gClef")
#let fclef-width = advance-width("fClef")
#let cclef-width = advance-width("cClef")

#import "@preview/cetz:0.4.2"

/// Place a SMuFL glyph at exact (x, y) in a CeTZ canvas.
/// - x, y: canvas coordinates where the glyph origin should be (in mm units)
/// - glyph-char: the Unicode character(s) to render
/// - glyph-name: the SMuFL glyph name for looking up bbox in metadata
/// - sp: staff-space size (dimensionless mm number)
#let place-glyph(x, y, glyph-char, glyph-name, sp, config: none) = {
  import cetz.draw: *
  let fsize = 4.0 * sp * 1mm
  let family = font-family(config: config)
  let bb = bbox(glyph-name, config: config)
  if bb == none {
    content(
      (x, y),
      anchor: "south-west",
      text(font: family, size: fsize, top-edge: "bounds", bottom-edge: "bounds", glyph-char),
    )
    return
  }
  let px = x + bb.sw.x * sp
  let py = y + bb.sw.y * sp
  content(
    (px, py),
    anchor: "south-west",
    text(font: family, size: fsize, top-edge: "bounds", bottom-edge: "bounds", glyph-char),
  )
}
