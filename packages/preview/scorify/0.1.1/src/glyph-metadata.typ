// glyph-metadata.typ - Load and expose Bravura/SMuFL glyph metrics
//
// All bounding-box and anchor values are in staff-space units.
// SMuFL convention: font em-square = 4 staff-spaces.
// Glyph origin (0,0) is the glyph's "reference point":
//   - Noteheads: left edge, vertically centered on staff line
//   - Clefs: the staff line their pitch refers to (G4 for gClef, F3 for fClef, C4 for cClef)
//   - Accidentals: left edge, vertically centered on the staff line they affect
//   - Rests: varies per rest type (whole hangs from line, half sits on line, etc.)
//   - Flags: stem connection point at (0,0)

#let _meta = json("../data/bravura_metadata.json")

// --- Engraving defaults (all in staff-space units) ---
#let engraving = _meta.engravingDefaults

// --- Glyph bounding boxes ---
// Returns (sw, ne) where sw = (x,y) of south-west corner, ne = (x,y) of north-east corner
// All in staff-space units relative to glyph origin.
#let bbox(glyph-name) = {
  let b = _meta.glyphBBoxes.at(glyph-name, default: none)
  if b == none { return none }
  let sw = b.bBoxSW
  let ne = b.bBoxNE
  // Convert from JSON arrays to (x,y) tuples
  (
    sw: (x: float(sw.at(0)), y: float(sw.at(1))),
    ne: (x: float(ne.at(0)), y: float(ne.at(1))),
  )
}

/// Get advance width of a glyph in staff-space units.
#let advance-width(glyph-name) = {
  let w = _meta.glyphAdvanceWidths.at(glyph-name, default: none)
  if w == none { 0.0 } else { float(w) }
}

/// Get anchor points for a glyph (e.g., stem attachment points for noteheads).
#let anchors(glyph-name) = {
  let a = _meta.glyphsWithAnchors.at(glyph-name, default: none)
  if a == none { return (:) }
  let result = (:)
  for (key, val) in a {
    result.insert(key, (x: float(val.at(0)), y: float(val.at(1))))
  }
  result
}

// --- Pre-computed metrics for commonly used glyphs ---

// Notehead dimensions
#let notehead-black-width = advance-width("noteheadBlack")   // ~1.18
#let notehead-half-width = advance-width("noteheadHalf")     // ~1.18
#let notehead-whole-width = advance-width("noteheadWhole")   // ~1.688

// Stem attachment points for noteheads
#let _nh-black-anchors = anchors("noteheadBlack")
#let _nh-half-anchors = anchors("noteheadHalf")
#let stem-up-se-black = _nh-black-anchors.at("stemUpSE", default: (x: 1.18, y: 0.168))
#let stem-down-nw-black = _nh-black-anchors.at("stemDownNW", default: (x: 0.0, y: -0.168))
#let stem-up-se-half = _nh-half-anchors.at("stemUpSE", default: (x: 1.18, y: 0.168))
#let stem-down-nw-half = _nh-half-anchors.at("stemDownNW", default: (x: 0.0, y: -0.168))

// Clef bounding boxes (for sizing reference)
#let gclef-bbox = bbox("gClef")       // SW=(0,-2.632) NE=(2.684, 4.392)
#let fclef-bbox = bbox("fClef")       // SW=(-0.02,-2.54) NE=(2.736, 1.048)
#let cclef-bbox = bbox("cClef")       // SW=(0,-2.024) NE=(2.796, 2.024)

// Clef advance widths
#let gclef-width = advance-width("gClef")
#let fclef-width = advance-width("fClef")
#let cclef-width = advance-width("cClef")

// --- Central glyph placement function ---
// Places a SMuFL glyph with its origin at exact canvas coordinates (x, y).
// Uses top-edge/bottom-edge "bounds" so the Typst text box = glyph ink bbox.
// Uses anchor "south-west" and offsets by the glyph's bounding box SW corner
// so the glyph's SMuFL origin lands precisely at (x, y).

#import "@preview/cetz:0.4.2"

/// Place a Bravura/SMuFL glyph at exact (x, y) in a CeTZ canvas.
/// - x, y: canvas coordinates where the glyph origin should be (in mm units)
/// - glyph-char: the Unicode character(s) to render
/// - glyph-name: the SMuFL glyph name for looking up bbox in metadata
/// - sp: staff-space size (dimensionless mm number)
#let place-glyph(x, y, glyph-char, glyph-name, sp) = {
  import cetz.draw: *
  let fsize = 4.0 * sp * 1mm
  let bb = bbox(glyph-name)
  if bb == none {
    // Fallback: just place at (x, y) without bbox correction
    content(
      (x, y),
      anchor: "south-west",
      text(font: "Bravura", size: fsize, top-edge: "bounds", bottom-edge: "bounds", glyph-char),
    )
    return
  }
  // Offset so glyph origin lands at (x, y):
  // The "bounds" text box's SW corner corresponds to glyph ink's SW corner,
  // which is at (sw.x, sw.y) in staff-space units from the glyph origin.
  // So we place the box's SW corner at (x + sw.x*sp, y + sw.y*sp).
  let px = x + bb.sw.x * sp
  let py = y + bb.sw.y * sp
  content(
    (px, py),
    anchor: "south-west",
    text(font: "Bravura", size: fsize, top-edge: "bounds", bottom-edge: "bounds", glyph-char),
  )
}
