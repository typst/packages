#import "../tokens.typ": *

// SAPIANS Precision Slide Header (DeepMind / Anthropic style)
/// Draws the fixed header strip at the top of a slide: a bold title, an
/// optional uppercase section tag, an optional right-aligned page counter,
/// and a hairline rule underneath. Call it once per slide, right after the
/// canvas background is set, so title/section/counter placement stays
/// identical across the whole deck.
///
/// ```example
/// #box(width: 70mm, height: 14mm, fill: white)[
///   #slide-header(title: "Method", section: "Overview", counter: "3 / 20")
/// ]
/// ```
/// -> content
#let slide-header(
  /// Slide title, shown bold at the top-left. -> str
  title: "",

  /// Uppercase section tag shown next to the title, in a muted tone.
  /// Omitted entirely when empty. -> str
  section: "",

  /// Page counter text shown at the top-right, e.g. `"3 / 20"`. Omitted
  /// entirely when empty. -> str
  counter: "",

  /// Whether the header sits on a dark canvas; swaps the title, section,
  /// and hairline colors for the dark palette. -> bool
  dark: false,
) = {
  let text-color = if dark { sapians-text-light } else { sapians-text-dark }
  let muted-color = if dark { sapians-muted-light } else { sapians-muted-dark }
  let line-color = if dark { sapians-line-dark } else { sapians-line }

  place(top + left, dx: 0mm, dy: 0mm)[
    #block(width: 100%, inset: (bottom: 2mm))[
      #grid(
        columns: (1fr, auto),
        align: (bottom + left, bottom + right),
        [
          #text(fill: text-color, size: 9.5pt, weight: "bold")[#title]
          #if section != "" [
            #h(4.5mm)
            #text(
              fill: muted-color,
              size: 5.2pt,
              weight: "medium",
              tracking: 0.14em,
            )[#upper(section)]
          ]
        ],
        [
          #if counter != "" [
            #text(
              fill: muted-color,
              size: 5.2pt,
              weight: "medium",
              tracking: 0.08em,
            )[#counter]
          ]
        ],
      )
      #v(2.0mm)
      #line(length: 100%, stroke: 0.25pt + line-color)
    ]
  ]
}

// Micro Kicker tag in Terracotta
/// A tiny uppercase tag in the SAPIANS terracotta accent color, tracked
/// wide. Use it to label a slide region ("DATA", "METHOD", ...) the same
/// way a kicker introduces a headline.
///
/// ```example
/// #box(fill: white, inset: 2pt)[#kicker("Data")]
/// ```
/// -> content
#let kicker(
  /// Text to render, upper-cased automatically. -> str
  text-content,

  /// Accepted for symmetry with the other header helpers; the kicker is
  /// always rendered in terracotta and this flag currently has no visual
  /// effect. -> bool
  dark: false,
) = {
  text(
    fill: sapians-terracotta,
    size: 5.2pt,
    weight: "bold",
    tracking: 0.14em,
  )[#upper(text-content)]
}

// Uppercase tracking label in Muted tone.
// Named caps-label so the package never shadows Typst's built-in label().
/// An uppercase, wide-tracked label in the muted secondary tone. Use it for
/// figure/table captions, axis labels, or any small annotation that should
/// read as metadata rather than body text.
///
/// ```example
/// #box(fill: white, inset: 2pt)[#caps-label("figure 1")]
/// ```
/// -> content
#let caps-label(
  /// Text to render, upper-cased automatically. -> str
  text-content,

  /// Whether the label sits on a dark canvas; picks the light-on-dark
  /// muted tone instead of the dark-on-light one. -> bool
  dark: false,
) = {
  let col = if dark { sapians-muted-light } else { sapians-muted-dark }
  text(fill: col, size: 5.2pt, weight: "bold", tracking: 0.12em)[#upper(
    text-content,
  )]
}

// Small secondary text
/// Small secondary body text in the muted tone, for captions, footnotes,
/// or source attributions that should stay visually quiet next to the
/// primary content.
///
/// ```example
/// #box(fill: white, inset: 2pt)[
///   #small-text("Source: internal benchmark, 2026.")
/// ]
/// ```
/// -> content
#let small-text(
  /// Content to render at the small secondary size. -> str | content
  text-content,

  /// Whether the text sits on a dark canvas; picks the light-on-dark
  /// muted tone instead of the dark-on-light one. -> bool
  dark: false,
) = {
  let col = if dark { sapians-muted-light } else { sapians-muted-dark }
  text(fill: col, size: 6.0pt)[#text-content]
}
