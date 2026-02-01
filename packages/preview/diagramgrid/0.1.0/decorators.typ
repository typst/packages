// decorators.typ — Decorator support for diagramgrid shapes
// Provides stereotype, status, and stroke presets for visual annotations

/// Parse position string into placement parameters
/// Returns (alignment, dx, dy) for use with place()
#let parse-position(position, decorator-type: "default") = {
  // Status dots go inside the shape
  if decorator-type == "status" {
    if position == "top-left" {
      (top + left, 4pt, 4pt)
    } else if position == "top-right" {
      (top + right, -4pt, 4pt)
    } else if position == "bottom-left" {
      (bottom + left, 4pt, -4pt)
    } else if position == "bottom-right" {
      (bottom + right, -4pt, -4pt)
    } else {
      (top + right, -4pt, 4pt)
    }
  } else {
    // Stereotypes straddle the top edge
    if position == "top-left" {
      (top + left, 4pt, -6pt)
    } else if position == "top-right" {
      (top + right, -4pt, -6pt)
    } else if position == "top-center" {
      (top + center, 0pt, -6pt)
    } else if position == "bottom-left" {
      (bottom + left, 4pt, 6pt)
    } else if position == "bottom-right" {
      (bottom + right, -4pt, 6pt)
    } else if position == "bottom-center" {
      (bottom + center, 0pt, 6pt)
    } else {
      // Default to top-center for stereotypes
      (top + center, 0pt, -6pt)
    }
  }
}

/// Create a stereotype decorator (e.g., «interface», «service»)
/// - label: The stereotype text (without guillemets)
/// - position: Where to place it ("top-center", "top-left", "top-right", etc.)
/// - fill: Background color
/// - stroke: Border stroke
/// - text-size: Font size
#let dg-stereotype(
  label,
  position: "top-center",
  fill: rgb("#f0f0f0"),
  stroke: 0.5pt + luma(150),
  text-size: 7pt,
) = (
  type: "stereotype",
  label: label,
  position: position,
  fill: fill,
  stroke: stroke,
  text-size: text-size,
)

/// Create a status dot decorator
/// - color: The dot color
/// - position: Where to place it ("top-right", "top-left", etc.)
/// - size: Diameter of the dot
#let dg-status(
  color,
  position: "top-right",
  size: 6pt,
) = (
  type: "status",
  color: color,
  position: position,
  size: size,
)

/// Render a single decorator using place()
#let render-decorator(dec) = {
  if dec.type == "stereotype" {
    let (align-pos, dx, dy) = parse-position(dec.position, decorator-type: "stereotype")
    place(
      align-pos,
      dx: dx,
      dy: dy,
      box(
        fill: dec.fill,
        stroke: dec.stroke,
        inset: (x: 4pt, y: 2pt),
        radius: 2pt,
        text(size: dec.text-size)[«#dec.label»]
      )
    )
  } else if dec.type == "status" {
    let (align-pos, dx, dy) = parse-position(dec.position, decorator-type: "status")
    place(
      align-pos,
      dx: dx,
      dy: dy,
      circle(
        fill: dec.color,
        width: dec.size,
        stroke: none,
      )
    )
  }
}

// Stroke presets for common patterns

/// Dashed stroke for optional or secondary elements
#let stroke-dashed = (paint: luma(120), thickness: 0.8pt, dash: "dashed")

/// Dotted stroke for weak or tentative connections
#let stroke-dotted = (paint: luma(120), thickness: 0.8pt, dash: "dotted")

/// Planned/future stroke with specific dash pattern
#let stroke-planned = (paint: luma(150), thickness: 1pt, dash: (4pt, 2pt))
