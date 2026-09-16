// render-staff.typ - Draw staff lines, barlines, braces, and brackets

#import "@preview/cetz:0.4.2"
#import "constants.typ": *
#import "glyph-metadata.typ": place-glyph, advance-width, bbox, font-family

/// Draw the five staff lines.
/// - ctx: CeTZ draw context (caller does `import cetz.draw: *`)
/// - x-start: left x position
/// - x-end: right x position
/// - y-top: y position of the top staff line
/// - sp: staff space size (1.0 in staff-space units)
#let draw-staff-lines(x-start, x-end, y-top, sp: 1.0) = {
  import cetz.draw: *
  let thickness = default-staff-line-thickness * sp
  for i in range(5) {
    let y = y-top - i * sp
    line(
      (x-start, y), (x-end, y),
      stroke: thickness * 1mm + black,
    )
  }
}

/// Draw a single barline.
/// - x: horizontal position
/// - y-top: y of top staff line
/// - y-bottom: y of bottom staff line
/// - style: "single", "double", "final", "repeat-start", "repeat-end", "repeat-both"
/// - sp: staff space
/// - dot-staff-tops: array of y-top values for each staff where repeat dots
///   should be drawn. Defaults to just (y-top,) for a single staff.
#let draw-barline(x, y-top, y-bottom, style: "single", sp: 1.0, dot-staff-tops: none) = {
  import cetz.draw: *
  let thin = default-barline-thickness * sp
  let thick = default-thick-barline * sp
  let dot-radius = 0.22 * sp

  // Resolve which staff y-tops get repeat dots
  let staff-tops = if dot-staff-tops != none { dot-staff-tops } else { (y-top,) }
  let draw-bar = (bar-x, thickness) => {
    line((bar-x, y-top), (bar-x, y-bottom), stroke: thickness * 1mm + black)
  }
  let draw-repeat-dots = dot-x => {
    for st in staff-tops {
      for dot-y in (st - 1.5 * sp, st - 2.5 * sp) {
        circle((dot-x, dot-y), radius: dot-radius, fill: black, stroke: none)
      }
    }
  }

  if style == "single" {
    draw-bar(x, thin)
  } else if style == "double" {
    draw-bar(x - 0.5 * sp, thin)
    draw-bar(x, thin)
  } else if style == "final" {
    draw-bar(x - 0.5 * sp, thin)
    draw-bar(x, thick)
  } else if style == "repeat-start" {
    draw-bar(x, thick)
    draw-bar(x + 0.5 * sp, thin)
    draw-repeat-dots(x + 1.0 * sp)
  } else if style == "repeat-end" {
    draw-repeat-dots(x - 1.0 * sp)
    draw-bar(x - 0.5 * sp, thin)
    draw-bar(x, thick)
  } else if style == "repeat-both" {
    draw-repeat-dots(x - 1.0 * sp)
    draw-bar(x - 0.5 * sp, thin)
    draw-bar(x, thick)
    draw-bar(x + 0.5 * sp, thin)
    draw-repeat-dots(x + 1.0 * sp)
  }
}

/// Draw a thin vertical line connecting staves on the left side of a system.
/// Used for all multi-staff groupings.
/// - y-top: top of the first staff
/// - y-bottom: bottom of the last staff
/// - sp: staff space
#let draw-system-line(y-top, y-bottom, sp: 1.0) = {
  import cetz.draw: *
  let thin = default-barline-thickness * sp
  // Draw so the LEFT edge of the line is flush with x=0 (same
  // convention as the per-staff opening barline).
  line(
    (thin / 2.0, y-top), (thin / 2.0, y-bottom),
    stroke: thin * 1mm + black,
  )
}

/// Draw a piano brace (the curly brace glyph) spanning from y-top to y-bottom.
/// Placed to the left of the system line.
/// - y-top: top of the first staff's top line
/// - y-bottom: bottom of the last staff's bottom line
/// - sp: staff space
#let draw-brace(y-top, y-bottom, sp: 1.0, music-font-config: none) = {
  import cetz.draw: *
  let span = y-top - y-bottom      // total height in mm (positive)
  if span <= 0 { return }

  // The brace glyph spans 4 staff-spaces at size=4*sp.
  // We scale the font size so the glyph fills the requested span.
  let glyph = "\u{E000}"           // SMuFL brace
  let nominal-height = 4.0 * sp   // height at default font size
  let scale = span / nominal-height
  let fsize = 4.0 * sp * scale * 1mm

  // The brace glyph origin is at the left, vertically centered.
  // Place it so the top of the brace aligns with y-top.
  let brace-w = advance-width("brace", config: music-font-config) * sp * scale
  // Place the brace to the left of x=0, with a small gap so it
  // sits close to the system line without being cramped.
  let extra = 0.3 * sp
  content(
    (-brace-w - extra, y-bottom),
    anchor: "south-west",
    text(font: font-family(config: music-font-config), size: fsize,
         top-edge: "bounds", bottom-edge: "bounds", glyph),
  )
}

/// Draw a thin bracket (square bracket) spanning from y-top to y-bottom,
/// with small serifs at top and bottom. Used for choir/orchestral groupings.
/// - y-top: top of the first staff's top line
/// - y-bottom: bottom of the last staff's bottom line
/// - sp: staff space
#let draw-bracket(y-top, y-bottom, sp: 1.0) = {
  import cetz.draw: *
  let thick = 0.3 * sp
  let serif = 0.6 * sp
  let x = -0.5 * sp   // offset left of the brace position
  // Vertical bar
  line(
    (x, y-top), (x, y-bottom),
    stroke: (thickness: thick * 1mm, paint: black, cap: "butt"),
  )
  // Top serif
  line(
    (x - serif / 2.0, y-top), (x + serif / 2.0, y-top),
    stroke: (thickness: thick * 1mm, paint: black, cap: "square"),
  )
  // Bottom serif
  line(
    (x - serif / 2.0, y-bottom), (x + serif / 2.0, y-bottom),
    stroke: (thickness: thick * 1mm, paint: black, cap: "square"),
  )
}
