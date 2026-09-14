// ============================================================================
// Atoms: the fundamental visual building blocks
// ============================================================================
//
// cell       - A colored box with a label (the core primitive)
// tag        - A dotted-border cell for markers / discriminants
// note       - Small inline annotation text
// badge      - A compact status indicator (e.g., STALLED, ERROR)
// sub-label  - Subscript-style size annotation (e.g., 2/4/8)
// span-label - A horizontal extent label (e.g., ← capacity →)
// ============================================================================

/// A colored rectangular cell — the atomic building block of all diagrams.
///
/// ```typst
/// #cell[A]                                    // default gray
/// #cell(fill: salmon)[T]                      // colored
/// #cell(fill: cyan, stroke: 3pt + gold)[len]  // thick border
/// #cell(fill: salmon, expandable: true)[T]    // shows ← T →
/// #cell(phantom: true)[]                      // faded, dashed
/// #cell(fill: green, overlay: [S])[03]        // state marker
/// ```
#let cell(
  body,
  fill: luma(220),
  width: auto,
  height: auto,
  stroke: 0.8pt + black,
  dash: none,
  radius: 0pt,
  inset: (x: 4pt, y: 2pt),
  expandable: false,
  phantom: false,
  overlay: none,
  baseline: 30%,
) = {
  let actual-fill = if phantom { fill.transparentize(60%) } else { fill }
  let actual-dash = if phantom { "dashed" } else { dash }

  // Build final stroke: apply dash override onto the user's stroke
  let stroke-val = if actual-dash != none {
    if type(stroke) == dictionary {
      (..stroke, dash: actual-dash)
    } else {
      // Native stroke (e.g. `2pt + red`): extract paint/thickness via std
      let s = std.stroke(stroke)
      (paint: s.paint, thickness: s.thickness, dash: actual-dash)
    }
  } else {
    stroke
  }

  box(
    width: width, height: height, fill: actual-fill,
    stroke: stroke-val, radius: radius, inset: inset, baseline: baseline,
    {
      set text(fill: black, hyphenate: false)
      set align(center)
      set par(justify: false)
      if expandable {
        text(size: 0.7em, sym.arrow.l)
        h(1pt)
        body
        h(1pt)
        text(size: 0.7em, sym.arrow.r)
      } else {
        body
      }
      if overlay != none {
        place(top + right,
          text(size: 0.5em, weight: "bold", fill: luma(60), overlay))
      }
    },
  )
}

/// A dotted-border cell for discriminants, tags, or markers.
///
/// Convenience wrapper: `cell` with dotted border and light green fill.
#let tag(body, fill: rgb("#90EE90")) = cell(body, fill: fill, dash: "dotted")

/// Small inline annotation text.
#let note(body) = text(size: 0.7em, body)

/// A compact status badge for indicating states or alerts.
///
/// ```typst
/// #badge[STALLED]
/// #badge(fill: rgb("#C8E6C9"), stroke: rgb("#2E7D32"))[HIT]
/// ```
#let badge(body, fill: rgb("#FFECB3"), stroke: rgb("#FF8F00")) = {
  box(
    fill: fill,
    stroke: (paint: stroke, thickness: 0.8pt),
    radius: 2pt,
    inset: (x: 3pt, y: 1pt),
    baseline: 30%,
    text(size: 0.6em, weight: "bold", fill: stroke.darken(40%), body),
  )
}

/// Subscript-style label for field size annotations.
///
/// Typically appended inside a cell: `#cell[ptr#sub-label[2/4/8]]`
#let sub-label(body) = text(size: 0.5em, baseline: -2pt, body)

/// A horizontal extent label showing a span: `← label →`.
///
/// When `width` is `auto` (default), it measures the immediately preceding
/// sibling content so the arrows align automatically.  Pass an explicit
/// length to override.
#let span-label(body, width: 100%) = {
  block(width: width, {
    set text(size: 0.55em, fill: luma(120))
    set align(center)
    [#sym.arrow.l~#body~#sym.arrow.r]
  })
}

/// A decorative wrapper that adds a thick colored border around content.
///
/// Used for double-border effects (e.g., Rust's `Cell<T>` has a thin black
/// inner border on the cell + thick gold outer border from `.celled`).
///
/// ```typst
/// #wrap(stroke: 3pt + gold)[
///   #cell(fill: salmon)[`T`]   // keeps its own thin black border
/// ]
/// ```
#let wrap(body, stroke: 3pt + black, radius: 3pt, inset: 2pt) = {
  box(
    stroke: stroke, radius: radius, inset: inset,
    baseline: 30%, body,
  )
}

/// A horizontal brace with a centered label below.
///
/// Draws a curly brace `⏟` spanning the given width with a label underneath.
///
/// ```typst
/// #brace(width: 120pt)[capacity]
/// ```
#let brace(body, width: 100pt) = {
  block(width: width, {
    set align(center)
    // Top: the brace line
    block(width: 100%, {
      set align(center)
      grid(
        columns: (1fr, auto, 1fr),
        align: horizon,
        line(length: 100%, stroke: 0.6pt + luma(120)),
        text(size: 0.7em, fill: luma(120), h(2pt) + sym.arrow.b + h(2pt)),
        line(length: 100%, stroke: 0.6pt + luma(120)),
      )
    })
    // Bottom: the label
    v(1pt)
    text(size: 0.65em, fill: luma(100), body)
  })
}
