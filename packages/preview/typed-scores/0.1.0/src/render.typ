#import "@preview/cetz:0.5.2"

#let _rotate-content = rotate

// All coordinates live in staff-unit space: 1 unit = one staff space
// (the gap between adjacent staff lines). The `unit` parameter converts
// to actual page length. Glyph geometry follows Bravura's SMuFL metadata.

// Bravura engraving defaults (in staff spaces), from the engravingDefaults
// table of bravura_metadata.json. Regenerate the values with
// scripts/extract-bravura-defaults.py when updating the font.
#let stem-thickness = 0.12
#let beam-thickness = 0.5
#let beam-spacing = 0.25
#let ledger-thickness = 0.16
#let ledger-extension = 0.4
#let staff-line-thickness = 0.13
#let thin-barline-thickness = 0.16
#let thick-barline-thickness = 0.5
#let barline-separation = 0.4
#let repeat-barline-dot-separation = 0.16
#let hairpin-thickness = 0.16
#let repeat-ending-line-thickness = 0.16
// Bows: the midpoint value is the full ink width at the bow's center and
// the endpoint value the width at its tips, for slurs and ties alike.
#let bow-midpoint-thickness = 0.22
#let bow-endpoint-thickness = 0.1

// Vertical distance between a notehead center and its stem attachment
// point (SMuFL stemUpSE / stemDownNW anchors of noteheadBlack).
#let stem-anchor-dy = 0.168
// Half-width of the regular (black/half) notehead.
#let notehead-half-width = 0.59
// Horizontal center of a stem relative to the notehead center.
#let stem-center-dx = notehead-half-width - stem-thickness / 2
#let stem-center-offset(scale: 1.0) = notehead-half-width * scale - stem-thickness / 2

#let staff-y(position, bottom-y: 0, line-gap: 1.0) = {
  bottom-y + (position - 2) * line-gap / 2
}

#let music-canvas(length: 8pt, keep-origin: false, body) = {
  cetz.canvas(length: length, {
    if keep-origin {
      import cetz.draw: *
      content((0, 0), box(width: 0pt, height: 0pt), anchor: "center", padding: 0pt)
    }
    body
  })
}

// Glyph bounding boxes from bravura_metadata.json, relative to the glyph
// origin, in staff spaces.
#let _bravura-bbox(kind) = {
  let table = (
    "notehead-black": (sw: (0.0, -0.5), ne: (1.18, 0.5)),
    "notehead-half": (sw: (0.0, -0.5), ne: (1.18, 0.5)),
    "notehead-whole": (sw: (0.0, -0.5), ne: (1.688, 0.5)),
    "met-note-whole": (sw: (0.0, -0.5), ne: (1.836, 0.592)),
    "met-note-half": (sw: (0.0, -0.564), ne: (1.364, 2.752)),
    "met-note-quarter": (sw: (0.0, -0.564), ne: (1.328, 2.752)),
    "met-note-eighth": (sw: (0.0, -0.564), ne: (2.132, 2.784)),
    "met-note-sixteenth": (sw: (0.0, -0.564), ne: (2.084, 2.8)),
    "met-note-thirty-second": (sw: (0.0, -0.564), ne: (2.152, 3.692)),
    "augmentation-dot": (sw: (0.0, -0.2), ne: (0.4, 0.2)),
    "treble-clef": (sw: (0.0, -2.632), ne: (2.684, 4.392)),
    "bass-clef": (sw: (-0.02, -2.54), ne: (2.736, 1.048)),
    "alto-clef": (sw: (0.0, -2.024), ne: (2.796, 2.024)),
    "tenor-clef": (sw: (0.0, -2.024), ne: (2.796, 2.024)),
    "sharp": (sw: (0.0, -1.392), ne: (0.996, 1.4)),
    "flat": (sw: (0.0, -0.7), ne: (0.904, 1.756)),
    "natural": (sw: (0.0, -1.34), ne: (0.672, 1.364)),
    "double-sharp": (sw: (0.0, -0.5), ne: (0.988, 0.508)),
    "double-flat": (sw: (0.0, -0.7), ne: (1.644, 1.748)),
    "rest-whole": (sw: (0.0, -0.54), ne: (1.128, 0.036)),
    "rest-half": (sw: (0.0, -0.008), ne: (1.128, 0.568)),
    "rest-quarter": (sw: (0.004, -1.5), ne: (1.08, 1.492)),
    "rest-eighth": (sw: (0.0, -1.004), ne: (0.988, 0.696)),
    "rest-sixteenth": (sw: (0.0, -2.0), ne: (1.28, 0.716)),
    "rest-thirty-second": (sw: (0.0, -2.0), ne: (1.452, 1.704)),
    "flag-eighth-up": (sw: (0.0, -3.2408), ne: (1.056, 0.0352)),
    "flag-eighth-down": (sw: (0.0, -0.0576), ne: (1.224, 3.2329)),
    "flag-sixteenth-up": (sw: (0.0, -3.252), ne: (1.116, 0.008)),
    "flag-sixteenth-down": (sw: (0.0, -0.036), ne: (1.1636, 3.248)),
    "flag-thirty-second-up": (sw: (0.0, -3.248), ne: (1.044, 0.596)),
    "flag-thirty-second-down": (sw: (0.0, -0.6875), ne: (1.092, 3.248)),
    "staccato-above": (sw: (0.0, 0.0), ne: (0.336, 0.336)),
    "staccato-below": (sw: (0.0, -0.336), ne: (0.336, 0.0)),
    "tenuto-above": (sw: (-0.004, 0.0), ne: (1.352, 0.192)),
    "tenuto-below": (sw: (-0.004, -0.192), ne: (1.352, 0.0)),
    "staccatissimo-above": (sw: (0.004, 0.0), ne: (0.356, 1.16)),
    "staccatissimo-below": (sw: (0.004, -1.16), ne: (0.356, 0.0)),
    "marcato-above": (sw: (-0.004, -0.004), ne: (0.94, 1.012)),
    "marcato-below": (sw: (-0.004, -1.016), ne: (0.94, 0.0)),
    "accent-above": (sw: (0.0, 0.004), ne: (1.356, 0.98)),
    "accent-below": (sw: (0.0, -0.976), ne: (1.356, 0.0)),
    "ornament-turn": (sw: (0.0, 0.0), ne: (1.84, 0.872)),
    "pedal-ped": (sw: (0.0, -0.032), ne: (4.076, 2.22)),
    "pedal-up": (sw: (0.0, 0.0), ne: (1.8, 1.8)),
    "dynamic-p": (sw: (-0.356, -0.568), ne: (1.464, 1.096)),
    "dynamic-m": (sw: (-0.08, -0.04), ne: (1.784, 1.096)),
    "dynamic-f": (sw: (-0.564, -0.608), ne: (1.456, 1.776)),
    "dynamic-r": (sw: (-0.08, 0.0), ne: (1.108, 1.096)),
    "dynamic-s": (sw: (0.0, -0.04), ne: (0.916, 1.092)),
    "dynamic-z": (sw: (-0.12, -0.04), ne: (0.976, 1.072)),
    "dynamic-n": (sw: (-0.092, -0.04), ne: (1.232, 1.096)),
    "fermata-above": (sw: (0.012, -0.012), ne: (2.42, 1.316)),
    "breath-mark-comma": (sw: (0.004, 0.008), ne: (0.608, 1.004)),
    "segno": (sw: (0.016, -0.108), ne: (2.2, 3.036)),
    "coda": (sw: (-0.016, -0.632), ne: (3.82, 3.592)),
    "arpeggio-wiggle": (sw: (-0.132, 0.0), ne: (1.168, 0.476)),
    "bracket-top": (sw: (0.0, 0.0), ne: (1.876, 1.18)),
    "bracket-bottom": (sw: (0.0, -1.18), ne: (1.876, 0.0)),
    "time-sig-0": (sw: (0.08, -1.0), ne: (1.8, 1.004)),
    "time-sig-1": (sw: (0.08, -1.0), ne: (1.256, 1.004)),
    "time-sig-2": (sw: (0.08, -1.028), ne: (1.704, 1.016)),
    "time-sig-3": (sw: (0.08, -1.004), ne: (1.604, 0.996)),
    "time-sig-4": (sw: (0.08, -1.0), ne: (1.8, 1.004)),
    "time-sig-5": (sw: (0.08, -1.004), ne: (1.532, 0.984)),
    "time-sig-6": (sw: (0.08, -0.996), ne: (1.656, 1.004)),
    "time-sig-7": (sw: (0.08, -1.0), ne: (1.684, 0.996)),
    "time-sig-8": (sw: (0.08, -1.036), ne: (1.664, 1.036)),
    "time-sig-9": (sw: (0.08, -0.996), ne: (1.656, 1.004)),
  )
  if kind not in table {
    panic("unknown Bravura glyph " + kind)
  }
  table.at(kind)
}

#let _bravura-file(kind) = "assets/glyphs/" + kind + ".svg"

#let _bravura-width(kind) = {
  let bbox = _bravura-bbox(kind)
  bbox.ne.at(0) - bbox.sw.at(0)
}

#let _bravura-height(kind) = {
  let bbox = _bravura-bbox(kind)
  bbox.ne.at(1) - bbox.sw.at(1)
}

// Draw a Bravura glyph. With `origin: true`, (x, y) is the glyph's SMuFL
// origin; otherwise (x, y) is the center of its bounding box.
#let _draw-bravura-glyph(kind, x, y, unit: 8pt, origin: false, glyph-scale: 1.0) = {
  let bbox = _bravura-bbox(kind)
  let cx = if origin { x + (bbox.sw.at(0) + bbox.ne.at(0)) * glyph-scale / 2 } else { x }
  let cy = if origin { y + (bbox.sw.at(1) + bbox.ne.at(1)) * glyph-scale / 2 } else { y }
  cetz.draw.content(
    (cx, cy),
    image(_bravura-file(kind), width: _bravura-width(kind) * unit * glyph-scale),
    anchor: "center",
    padding: 0pt,
  )
}

#let draw-staff-lines(
  width,
  x: 0,
  bottom-y: 0,
  line-gap: 1.0,
  unit: 8pt,
) = {
  import cetz.draw: *
  for i in range(5) {
    let y = bottom-y + i * line-gap
    line((x, y), (x + width, y), stroke: staff-line-thickness * unit + black)
  }
}

#let draw-filled-notehead(x, y, unit: 8pt, scale: 1.0) = {
  _draw-bravura-glyph("notehead-black", x, y, unit: unit, glyph-scale: scale)
}

#let draw-open-notehead(x, y, unit: 8pt, scale: 1.0) = {
  _draw-bravura-glyph("notehead-half", x, y, unit: unit, glyph-scale: scale)
}

#let draw-whole-notehead(x, y, unit: 8pt, scale: 1.0) = {
  _draw-bravura-glyph("notehead-whole", x, y, unit: unit, glyph-scale: scale)
}

#let draw-augmentation-dot(x, y, unit: 8pt, scale: 1.0) = {
  _draw-bravura-glyph("augmentation-dot", x, y, unit: unit, glyph-scale: scale)
}

// The page-space point where a stem of the given length ends.
// (x, y) is the notehead center; length is measured from the stem
// attachment point to the tip.
#let stem-tip(x, y, direction: "up", length: 3.5, glyph-scale: 1.0) = {
  if direction == "up" {
    (x + stem-center-offset(scale: glyph-scale), y + stem-anchor-dy * glyph-scale + length)
  } else {
    (x - stem-center-offset(scale: glyph-scale), y - stem-anchor-dy * glyph-scale - length)
  }
}

#let draw-stem(x, y, direction: "up", length: 3.5, unit: 8pt, glyph-scale: 1.0) = {
  import cetz.draw: *
  let tip = stem-tip(x, y, direction: direction, length: length, glyph-scale: glyph-scale)
  let attach-y = if direction == "up" { y + stem-anchor-dy * glyph-scale } else { y - stem-anchor-dy * glyph-scale }
  line(
    (tip.at(0), attach-y),
    tip,
    // LilyPond reduces grace heads and flags but retains the normal stem
    // thickness; glyph-scale therefore affects placement, not stem weight.
    stroke: stem-thickness * unit + black,
  )
}

#let draw-ledger-lines(
  x,
  position,
  bottom-y: 0,
  line-gap: 1.0,
  head-half-width: notehead-half-width,
  left-extension: ledger-extension,
  right-extension: ledger-extension,
  unit: 8pt,
) = {
  import cetz.draw: *
  let left = x - head-half-width - left-extension
  let right = x + head-half-width + right-extension
  let stroke-style = ledger-thickness * unit + black
  if position <= 0 {
    for p in range(0, position - 1, step: -2) {
      let y = staff-y(p, bottom-y: bottom-y, line-gap: line-gap)
      line((left, y), (right, y), stroke: stroke-style)
    }
  }
  if position >= 12 {
    for p in range(12, position + 1, step: 2) {
      let y = staff-y(p, bottom-y: bottom-y, line-gap: line-gap)
      line((left, y), (right, y), stroke: stroke-style)
    }
  }
}

// Draw 1-3 flags hanging off a stem tip. (x, y) is the stem tip; the
// glyph's SMuFL attachment anchor is aligned with the stem's outer edge.
#let draw-flag(x, y, direction: "up", count: 1, unit: 8pt, scale: 1.0) = {
  let (kind, anchor-y) = if direction == "up" {
    // stemUpNW anchors of flag8thUp / flag16thUp / flag32ndUp.
    if count == 1 { ("flag-eighth-up", -0.04) }
    else if count == 2 { ("flag-sixteenth-up", -0.088) }
    else { ("flag-thirty-second-up", 0.376) }
  } else {
    // stemDownSW anchors of flag8thDown / flag16thDown / flag32ndDown.
    if count == 1 { ("flag-eighth-down", 0.132) }
    else if count == 2 { ("flag-sixteenth-down", 0.128) }
    else { ("flag-thirty-second-down", -0.448) }
  }
  let stem-left = x - stem-thickness / 2
  _draw-bravura-glyph(kind, stem-left, y - anchor-y * scale, unit: unit, origin: true, glyph-scale: scale)
}

// A single beam segment between two stem-tip points; start/end give the
// beam's vertical center line.
#let draw-beam(start, end, thickness: beam-thickness, paint: black) = {
  import cetz.draw: *
  let (x1, y1) = start
  let (x2, y2) = end
  let h = thickness / 2
  merge-path(close: true, fill: paint, stroke: none, {
    line((x1, y1 - h), (x2, y2 - h))
    line((x2, y2 - h), (x2, y2 + h))
    line((x2, y2 + h), (x1, y1 + h))
  })
}

// LilyPond's StemTremolo is a filled sloping strip with vertical end edges,
// not a rotated line. Its default 1.42-space width, 0.375 rise, 0.4 fill,
// and 0.08 outline produce the documented 0.48-space beam weight.
#let draw-stem-tremolo(x, y, unit: 8pt) = {
  import cetz.draw: *
  let half-width = 0.71
  let half-fill = 0.20
  let rise = 0.375
  merge-path(
    close: true,
    fill: black,
    stroke: 0.08 * unit + black,
    {
      line((x - half-width, y - half-fill), (x + half-width, y + rise - half-fill))
      line((x + half-width, y + rise - half-fill), (x + half-width, y + rise + half-fill))
      line((x + half-width, y + rise + half-fill), (x - half-width, y + half-fill))
    },
  )
}

#let _brace-asset(span) = {
  if span <= 6 { (file: "brace-small.svg", width: 0.412, height: 3.988) }
  else if span <= 12 { (file: "brace.svg", width: 0.32, height: 3.988) }
  else if span <= 22 { (file: "brace-large.svg", width: 0.268, height: 3.988) }
  else if span <= 48 { (file: "brace-larger.svg", width: 0.24, height: 3.988) }
  else { (file: "brace-flat.svg", width: 0.224, height: 3.996) }
}

#let brace-width-for-span(span) = {
  let asset = _brace-asset(span)
  span * asset.width / asset.height
}

// Bravura supplies progressively flatter brace designs for taller groups.
// Each selected outline is scaled proportionally, never squeezed into a
// fixed-width box, so the full silhouette remains visible.
#let draw-grand-brace(right-x, bottom-y, top-y, unit: 8pt) = {
  import cetz.draw: *
  let span = top-y - bottom-y
  let asset = _brace-asset(span)
  content(
    (right-x, (bottom-y + top-y) / 2),
    image("assets/glyphs/" + asset.file, height: span * unit),
    anchor: "east",
    padding: 0pt,
  )
}

#let draw-staff-bracket(x, bottom-y, top-y, unit: 8pt) = {
  import cetz.draw: *
  let terminal-scale = 0.72
  let stem-width = 0.5 * terminal-scale
  merge-path(close: true, fill: black, stroke: none, {
    line((x, bottom-y), (x + stem-width, bottom-y))
    line((x + stem-width, bottom-y), (x + stem-width, top-y))
    line((x + stem-width, top-y), (x, top-y))
  })
  _draw-bravura-glyph("bracket-top", x, top-y, unit: unit, origin: true, glyph-scale: terminal-scale)
  _draw-bravura-glyph("bracket-bottom", x, bottom-y, unit: unit, origin: true, glyph-scale: terminal-scale)
}

#let draw-staff-group-line(x, bottom-y, top-y, unit: 8pt) = {
  import cetz.draw: *
  let width = 0.42
  merge-path(close: true, fill: black, stroke: none, {
    line((x, bottom-y), (x + width, bottom-y))
    line((x + width, bottom-y), (x + width, top-y))
    line((x + width, top-y), (x, top-y))
  })
}

// Tie and slur bows are cubic Beziers shaped like classical engravings:
// the control height saturates asymptotically with the span, and the middle
// control points sit inset from the ends so long bows go flat on top with
// rounded shoulders instead of arching ever higher. All lengths are staff
// spaces.

// Control height of a bow of a given width. Grows like `r-0 * width` for
// short bows and approaches `h-inf` asymptotically for long ones. The
// rendered apex reaches 3/4 of the control height.
#let bow-height(width, h-inf, r-0) = {
  h-inf * (2 / calc.pi) * calc.atan(calc.pi * width * r-0 / (2 * h-inf)).rad()
}

// Horizontal inset of the middle control points. Approaches `width / 3.1`
// for short bows and `2 h-inf` for long ones, and never exceeds the third
// of the width that would let the ends bulge faster than the middle.
#let bow-indent(width, h-inf) = {
  let max-fraction = 1 / 3.1
  let q = 2 * h-inf / max-fraction
  calc.min(
    2 * h-inf - q * q * max-fraction / (width + q),
    width * max-fraction,
  )
}

// Tallest control height at which the curve still travels fastest at its
// middle, keeping the bow from folding toward a loop.
#let bow-max-height(width, indent) = {
  let a = width * width / 3.0 - 0.75 * calc.pow(indent + width / 3.0, 2)
  if a <= 0 { width / 3.0 } else { calc.sqrt(a) }
}

// Control points for a bow between two arbitrary points. The shoulders are
// inset along the chord connecting the endpoints, but the bulge rises
// vertically rather than perpendicular to it: for level bows the two
// coincide, while a steep bow keeps its apex between the tips instead of
// overshooting sideways past the upper note. `dir` +1 arches the bow
// upward, -1 downward.
#let bow-control-points(start, end, height, h-inf, dir: 1) = {
  let (sx, sy) = start
  let (ex, ey) = end
  let (dx, dy) = (ex - sx, ey - sy)
  let len = calc.sqrt(dx * dx + dy * dy)
  let (ux, uy) = (dx / len, dy / len)
  let indent = bow-indent(len, h-inf)
  (
    (sx, sy),
    (sx + ux * indent, sy + uy * indent + height * dir),
    (ex - ux * indent, ey - uy * indent + height * dir),
    (ex, ey),
  )
}

#let bezier-point(cps, t) = {
  let s = 1 - t
  let w0 = s * s * s
  let w1 = 3 * s * s * t
  let w2 = 3 * s * t * t
  let w3 = t * t * t
  (
    w0 * cps.at(0).at(0) + w1 * cps.at(1).at(0) + w2 * cps.at(2).at(0) + w3 * cps.at(3).at(0),
    w0 * cps.at(0).at(1) + w1 * cps.at(1).at(1) + w2 * cps.at(2).at(1) + w3 * cps.at(3).at(1),
  )
}

#let bow-samples(cps, n: 32) = {
  range(n + 1).map(i => bezier-point(cps, i / n))
}

// y of a sampled curve at a given x, by linear interpolation between the
// bracketing samples. Returns none outside the sampled x range.
#let sampled-y-at-x(samples, x) = {
  let result = none
  for i in range(samples.len() - 1) {
    let (ax, ay) = samples.at(i)
    let (bx, by) = samples.at(i + 1)
    if result == none and x >= calc.min(ax, bx) and x <= calc.max(ax, bx) {
      result = if bx == ax { ay } else { ay + (by - ay) * (x - ax) / (bx - ax) }
    }
  }
  result
}

// Draw a bow between two points. The body is a sandwich of two Beziers whose
// middle control points differ by `thickness` across the chord, so the ink
// tapers from the middle toward the tips; the surrounding pen keeps the tips
// softly rounded instead of razor-sharp. `height` overrides the natural
// control height after collision handling has inflated it.
#let draw-bow(
  start,
  end,
  dir: 1,
  height: none,
  h-inf: 2.0,
  r-0: 0.25,
  thickness: bow-midpoint-thickness - bow-endpoint-thickness,
  pen: bow-endpoint-thickness,
  unit: 8pt,
) = {
  import cetz.draw: *
  let (sx, sy) = start
  let (ex, ey) = end
  let (dx, dy) = (ex - sx, ey - sy)
  let len = calc.sqrt(dx * dx + dy * dy)
  let h = if height == none { bow-height(len, h-inf, r-0) } else { height }
  let outer = bow-control-points(start, end, h + thickness / 2, h-inf, dir: dir)
  let inner = bow-control-points(start, end, calc.max(h - thickness / 2, 0.01), h-inf, dir: dir)
  merge-path(
    close: true,
    fill: black,
    stroke: (paint: black, thickness: pen * unit, join: "round"),
    {
      bezier(outer.at(0), outer.at(3), outer.at(1), outer.at(2))
      bezier(inner.at(3), inner.at(0), inner.at(2), inner.at(1))
    },
  )
}

#let draw-staccato(x, y, placement: "above", unit: 8pt) = {
  _draw-bravura-glyph("staccato-" + placement, x, y, unit: unit)
}

#let draw-articulation(kind, x, y, placement: "above", unit: 8pt) = {
  _draw-bravura-glyph(kind + "-" + placement, x, y, unit: unit)
}

#let draw-ornament-turn(x, y, unit: 8pt, scale: 1.0) = {
  _draw-bravura-glyph("ornament-turn", x, y, unit: unit, glyph-scale: scale)
}

#let draw-pedal-mark(x, y, unit: 8pt, release: false, scale: 0.62) = {
  let kind = if release { "pedal-up" } else { "pedal-ped" }
  _draw-bravura-glyph(kind, x, y, unit: unit, glyph-scale: scale)
}

#let _dynamic-glyph(letter) = {
  let names = (
    p: "dynamic-p",
    m: "dynamic-m",
    f: "dynamic-f",
    r: "dynamic-r",
    s: "dynamic-s",
    z: "dynamic-z",
    n: "dynamic-n",
  )
  names.at(letter)
}

#let _dynamic-advance(letter) = {
  let advances = (p: 1.46, m: 1.748, f: 1.456, r: 1.108, s: 0.916, z: 0.976, n: 1.232)
  advances.at(letter)
}

#let dynamic-width(value, scale: 0.78) = {
  let cursor = 0
  let left = none
  let right = none
  for letter in value.codepoints() {
    let bbox = _bravura-bbox(_dynamic-glyph(letter))
    let glyph-left = cursor + bbox.sw.at(0)
    let glyph-right = cursor + bbox.ne.at(0)
    left = if left == none { glyph-left } else { calc.min(left, glyph-left) }
    right = if right == none { glyph-right } else { calc.max(right, glyph-right) }
    cursor += _dynamic-advance(letter)
  }
  (right - left) * scale
}

#let draw-dynamic(value, x, y, unit: 8pt, scale: 0.78) = {
  let glyphs = ()
  let cursor = 0
  let left = none
  let right = none
  for letter in value.codepoints() {
    let kind = _dynamic-glyph(letter)
    let bbox = _bravura-bbox(kind)
    glyphs.push((kind: kind, origin-x: cursor))
    let glyph-left = cursor + bbox.sw.at(0)
    let glyph-right = cursor + bbox.ne.at(0)
    left = if left == none { glyph-left } else { calc.min(left, glyph-left) }
    right = if right == none { glyph-right } else { calc.max(right, glyph-right) }
    cursor += _dynamic-advance(letter)
  }
  let offset = x - (left + right) * scale / 2
  for glyph in glyphs {
    _draw-bravura-glyph(
      glyph.kind,
      offset + glyph.origin-x * scale,
      y,
      unit: unit,
      origin: true,
      glyph-scale: scale,
    )
  }
}

#let draw-fermata(x, y, unit: 8pt, scale: 0.72) = {
  _draw-bravura-glyph("fermata-above", x, y, unit: unit, glyph-scale: scale)
}

#let draw-breath-mark(x, y, unit: 8pt, scale: 0.82) = {
  _draw-bravura-glyph("breath-mark-comma", x, y, unit: unit, glyph-scale: scale)
}

#let draw-navigation-symbol(kind, x, y, unit: 8pt, scale: 0.82) = {
  if kind not in ("segno", "coda") { panic("unknown navigation symbol " + kind) }
  _draw-bravura-glyph(kind, x, y, unit: unit, glyph-scale: scale)
}

#let draw-arpeggio(x, low-y, high-y, direction: "normal", unit: 8pt) = {
  import cetz.draw: *
  let low = calc.min(low-y, high-y) - 0.42
  let high = calc.max(low-y, high-y) + 0.42
  let step = 0.82
  let count = calc.max(1, int(calc.ceil((high - low) / step)))
  for index in range(count) {
    let y = low + (index + 0.5) * (high - low) / count
    content(
      (x, y),
      _rotate-content(90deg, image(_bravura-file("arpeggio-wiggle"), width: 1.30 * unit)),
      anchor: "center",
      padding: 0pt,
    )
  }
  if direction == "up" {
    line(
      (x, high + 0.82),
      (x - 0.52, high + 0.10),
      (x + 0.52, high + 0.10),
      close: true,
      fill: black,
      stroke: none,
    )
  } else if direction == "down" {
    line(
      (x, low - 0.82),
      (x - 0.52, low - 0.10),
      (x + 0.52, low - 0.10),
      close: true,
      fill: black,
      stroke: none,
    )
  }
}

// Crescendo opens to the right; diminuendo opens to the left.
#let draw-hairpin(start, end, kind: "crescendo", spread: 0.65, unit: 8pt) = {
  import cetz.draw: *
  let (sx, sy) = start
  let (ex, ey) = end
  let stroke-style = hairpin-thickness * unit + black
  if kind == "crescendo" {
    line((sx, sy), (ex, ey + spread / 2), stroke: stroke-style)
    line((sx, sy), (ex, ey - spread / 2), stroke: stroke-style)
  } else {
    line((sx, sy + spread / 2), (ex, ey), stroke: stroke-style)
    line((sx, sy - spread / 2), (ex, ey), stroke: stroke-style)
  }
}

#let draw-clef(clef, x, y, unit: 8pt, scale: 1.0) = {
  _draw-bravura-glyph(clef + "-clef", x, y, unit: unit, origin: true, glyph-scale: scale)
}

// (x, y) is the glyph origin: x at the accidental's left edge, y level
// with the notehead it modifies.
#let draw-accidental(accidental, x, y, unit: 8pt, scale: 1.0) = {
  let name = if accidental == "Natural" { "natural" }
    else if accidental == "Sharp" { "sharp" }
    else if accidental == "Flat" { "flat" }
    else if accidental == "DoubleSharp" { "double-sharp" }
    else if accidental == "DoubleFlat" { "double-flat" }
    else { none }
  if name != none {
    _draw-bravura-glyph(name, x, y, unit: unit, origin: true, glyph-scale: scale)
  }
}

#let accidental-width(accidental) = {
  if accidental == "Natural" { _bravura-width("natural") }
  else if accidental == "Sharp" { _bravura-width("sharp") }
  else if accidental == "Flat" { _bravura-width("flat") }
  else if accidental == "DoubleSharp" { _bravura-width("double-sharp") }
  else if accidental == "DoubleFlat" { _bravura-width("double-flat") }
  else { 0 }
}

// Rests attach to staff lines: the whole rest hangs from the 4th line,
// the half rest sits on the middle line, the rest glyphs center there.
#let draw-rest(duration-base, x, bottom-y: 0, line-gap: 1.0, unit: 8pt) = {
  let (name, origin-y) = if duration-base == "Whole" { ("rest-whole", 3) }
    else if duration-base == "Half" { ("rest-half", 2) }
    else if duration-base == "Quarter" { ("rest-quarter", 2) }
    else if duration-base == "Eighth" { ("rest-eighth", 2) }
    else if duration-base == "Sixteenth" { ("rest-sixteenth", 2) }
    else { ("rest-thirty-second", 2) }
  _draw-bravura-glyph(name, x, bottom-y + origin-y * line-gap, unit: unit, origin: true)
}

#let rest-width(duration-base) = {
  if duration-base == "Whole" { _bravura-width("rest-whole") }
  else if duration-base == "Half" { _bravura-width("rest-half") }
  else if duration-base == "Quarter" { _bravura-width("rest-quarter") }
  else if duration-base == "Eighth" { _bravura-width("rest-eighth") }
  else if duration-base == "Sixteenth" { _bravura-width("rest-sixteenth") }
  else { _bravura-width("rest-thirty-second") }
}

#let _time-sig-digit-gap = 0.08

#let _time-sig-row-width(digits) = {
  let width = 0
  for (i, d) in digits.codepoints().enumerate() {
    if i > 0 { width += _time-sig-digit-gap }
    width += _bravura-width("time-sig-" + d)
  }
  width
}

#let _draw-time-sig-row(digits, cx, y, unit) = {
  let total = _time-sig-row-width(digits)
  let x = cx - total / 2
  for (i, d) in digits.codepoints().enumerate() {
    let kind = "time-sig-" + d
    let bbox = _bravura-bbox(kind)
    _draw-bravura-glyph(kind, x - bbox.sw.at(0), y, unit: unit, origin: true)
    x += _bravura-width(kind) + _time-sig-digit-gap
  }
}

// Width (in staff spaces) the time signature occupies.
#let time-signature-width(time) = {
  if time == none { 0 } else {
    let parts = time.split("/")
    let top = _time-sig-row-width(parts.at(0))
    let bottom = if parts.len() > 1 { _time-sig-row-width(parts.at(1)) } else { 0 }
    calc.max(top, bottom)
  }
}

// Numerator centered on the 4th line, denominator on the 2nd; `x` is the
// left edge of the signature.
#let draw-time-signature(time, x, bottom-y: 0, unit: 8pt) = {
  if time != none {
    let parts = time.split("/")
    let cx = x + time-signature-width(time) / 2
    _draw-time-sig-row(parts.at(0), cx, bottom-y + 3, unit)
    if parts.len() > 1 {
      _draw-time-sig-row(parts.at(1), cx, bottom-y + 1, unit)
    }
  }
}
