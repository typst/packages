#import "../tokens.typ": *

// SAPIANS Precision Code Box Component
/// A bordered, monospaced code container with an optional title bar
/// showing a label and a language tag. Use it whenever a slide, paper, or
/// report needs to show source code as a self-contained block rather than
/// inline `raw` text.
///
/// ```example
/// #code-box(width: 60mm, title: "Listing 1", lang: "Python")[
///   #raw("def f(x):\n    return x + 1", lang: "python", block: true)
/// ]
/// ```
/// -> content
#let code-box(
  /// Code (or any content) shown inside the box. -> content
  body,

  /// Box width, forwarded to the underlying `block`. -> auto | relative
  width: 100%,

  /// Box height, forwarded to the underlying `block`. -> auto | relative
  height: auto,

  /// Uppercase label shown in the title bar, e.g. `"Listing 1"`. The title
  /// bar (and its hairline rule) is omitted entirely when `none`.
  /// -> none | str
  title: none,

  /// Language tag shown at the right of the title bar in terracotta, e.g.
  /// `"Python"`. Only shown when `title` is also set. -> none | str
  lang: none,

  /// Whether the box sits on a dark canvas; swaps background, border, and
  /// text colors for the dark palette. -> bool
  dark: false,
) = {
  let bg-color = if dark { sapians-code-bg-dark } else { sapians-code-bg }
  let border-stroke = if dark { stroke-dark } else { stroke-light }
  let text-fill = if dark { sapians-text-light } else { sapians-text-dark }

  block(
    width: width,
    height: height,
    fill: bg-color,
    radius: radius-sm,
    stroke: border-stroke,
    inset: (x: 3.0mm, y: 3.0mm),
    clip: true,
  )[
    #if title != none [
      #grid(
        columns: (1fr, auto),
        align: (left, right),
        text(
          fill: if dark { sapians-muted-light } else { sapians-muted-dark },
          size: 5.0pt,
          weight: "bold",
          tracking: 0.12em,
        )[#upper(title)],
        if lang != none {
          text(fill: sapians-terracotta, size: 5.0pt, weight: "bold")[#lang]
        },
      )
      #v(1.2mm)
      #line(length: 100%, stroke: border-stroke)
      #v(1.2mm)
    ]
    #set text(font: font-mono, size: font-size-code, fill: text-fill)
    #set par(leading: 0.42em)
    #body
  ]
}
